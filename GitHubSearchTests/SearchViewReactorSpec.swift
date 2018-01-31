import Quick
import Nimble
import Stubber
import ReactorKit
import RxSwift
@testable import GitHubSearch

class SearchViewReactorSpec: QuickSpec {
    override func spec() {
        var repositoryService: RepositoryServiceStub!
        var reactor: SearchViewReactor!

        beforeEach {
            repositoryService = RepositoryServiceStub()
            reactor = SearchViewReactor(repositoryService: repositoryService)
        }

        it("sets state") {
            let text = "q"
            let searchResult: (repositories: [Repository], nextPage: Int?) = ([RepositoryFixture.repository], 2)
            Stubber.register(repositoryService.searchRepositories) { _ in
                return Observable.just(searchResult)
            }

            reactor.action.onNext(.inputQuery(text))

            expect(reactor.currentState.query).to(equal(text))
            expect(reactor.currentState.repositories).to(equal(searchResult.repositories))
            expect(reactor.currentState.nextPage).to(equal(searchResult.nextPage))
        }
    }
}

private class RepositoryServiceStub: RepositoryServiceType {
    func searchRepositories(query: String?, page: Int) -> Observable<(repositories: [Repository], nextPage: Int?)> {
        return Stubber.invoke(searchRepositories, args: (query, page))
    }
}

private struct RepositoryFixture {
    static let repository = Repository(id: 1, fullName: "A", htmlURL: URL(string: "https://github.com/A/A")!)
}
