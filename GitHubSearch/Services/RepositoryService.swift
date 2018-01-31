import Moya
import RxSwift

protocol RepositoryServiceType {
    func searchRepositories(query: String?, page: Int) -> Observable<(repositories: [Repository], nextPage: Int?)>
}

class RepositoryService: RepositoryServiceType {

    enum Error: Swift.Error {
        case limitExceeded
    }

    private let provider: MoyaProvider<GitHub>

    init(provider: MoyaProvider<GitHub> = GitHubProvider) {
        self.provider = provider
    }

    func searchRepositories(query: String?, page: Int) -> Observable<(repositories: [Repository], nextPage: Int?)> {
        let emptySearchResult: ([Repository], Int?) = ([], nil)

        guard let query = query, !query.isEmpty else {
            return Observable.just(emptySearchResult)
        }

        return provider.rx.request(.searchRepositories(query, page))
            .asObservable()
            .filterSuccessfulStatusCodes()
            .map([Repository].self, atKeyPath: "items")
            .map { $0.isEmpty ? emptySearchResult : ($0, page + 1) }
            .catchError { error in
                switch error as? MoyaError {
                case let .statusCode(response)? where response.statusCode == 403:
                    return Observable.error(Error.limitExceeded)
                default:
                    return Observable.empty()
                }
            }
    }
}
