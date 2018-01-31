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
            return setSearchedRepositories(query: query, page: 1)

        case .loadNextPage:
            return Observable.never()
        }
    }

    private func setSearchedRepositories(query: String?, page: Int) -> Observable<Mutation> {
        return repositoryService.searchRepositories(query: query, page: page)
            .takeUntil(action.filterInputQuery()) // Cancels request when the new `.inputQuery` action is fired
            .map { Mutation.setRepositories($0, nextPage: $1) }
            .catchLimitExceededErrorJustReturn(Mutation.setLimitExceeded(true))
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
