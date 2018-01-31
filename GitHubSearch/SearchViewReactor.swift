import ReactorKit
import RxSwift

class SearchViewReactor: Reactor {
    enum Action {
        case inputQuery(String?)
        case loadNextPage
    }

    enum Mutation {
        case setQuery(String?)
        case setRepositories([Repository], nextPage: Int?)
        case appendRepositories([Repository], nextPage: Int?)
        case setLoading(Bool)
        case setLimitExceeded(Bool)
    }

    struct State {
        var query: String?
        var repositories: [Repository] = []
        var nextPage: Int?
        var isLoading: Bool = false
        var isLimitExceeded: Bool = false
    }

    let initialState = State()
    
    private let repositoryService: RepositoryServiceType

    init(repositoryService: RepositoryServiceType = RepositoryService()) {
        self.repositoryService = repositoryService
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .inputQuery(query):
            return Observable.concat([
                Observable.just(Mutation.setQuery(query)),
                setSearchedRepositories(query: query, page: 1)
            ])

        case .loadNextPage:
            guard let nextPage = currentState.nextPage, !currentState.isLoading && !currentState.isLimitExceeded else {
                return Observable.empty()
            }
            return setSearchedRepositories(query: currentState.query, page: nextPage)
        }
    }

    private func setSearchedRepositories(query: String?, page: Int) -> Observable<Mutation> {
        return Observable.concat([
            Observable.just(Mutation.setLoading(true)),
            Observable.just(Mutation.setLimitExceeded(false)),
            repositoryService.searchRepositories(query: query, page: page)
                .takeUntil(action.filterInputQuery()) // Cancels request when the new `.inputQuery` action is fired
                .map { page == 1 ? Mutation.setRepositories($0, nextPage: $1) : Mutation.appendRepositories($0, nextPage: $1) }
                .catchLimitExceededErrorJustReturn(Mutation.setLimitExceeded(true)),
            Observable.just(Mutation.setLoading(false))
        ])
        .catchErrorJustReturn(Mutation.setLoading(false))
    }

    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .setQuery(query):
            var newState = state
            newState.query = query
            return newState

        case let .setRepositories(repositories, nextPage):
            var newState = state
            newState.repositories = repositories
            newState.nextPage = nextPage
            return newState

        case let .appendRepositories(repositories, nextPage):
            var newState = state
            newState.repositories.append(contentsOf: repositories)
            newState.nextPage = nextPage
            return newState

        case let .setLoading(isLoading):
            var newState = state
            newState.isLoading = isLoading
            return newState

        case let .setLimitExceeded(isLimitExceeded):
            var newState = state
            newState.isLimitExceeded = isLimitExceeded
            return newState
        }
    }
}

private extension ObservableType where E == SearchViewReactor.Action {
    func filterInputQuery() -> Observable<E> {
        return filter {
            if case .inputQuery = $0 {
                return true
            } else {
                return false
            }
        }
    }
}

private extension ObservableType where E == SearchViewReactor.Mutation {
    func catchLimitExceededErrorJustReturn(_ element: E) -> Observable<E> {
        return catchError { error in
            switch error as? RepositoryService.Error {
            case .limitExceeded?:
                return Observable.just(element)
            default:
                return Observable.empty()
            }
        }
    }
}

extension SearchViewReactor.Action: Equatable {
    static func == (lhs: SearchViewReactor.Action, rhs: SearchViewReactor.Action) -> Bool {
        switch (lhs, rhs) {
        case let (.inputQuery(l), .inputQuery(r)):
            return l == r
        case (.loadNextPage, .loadNextPage):
            return true
        default:
            return false
        }
    }
}
