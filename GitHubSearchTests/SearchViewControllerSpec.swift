import Quick
import Nimble
import ReactorKit
import RxSwift
@testable import GitHubSearch

class SearchViewControllerSpec: QuickSpec {
    override func spec() {
        var reactor: SearchViewReactor!
        var viewController: SearchViewController!

        beforeEach {
            reactor = SearchViewReactor(repositoryService: RepositoryServiceMock())
            reactor.stub.isEnabled = true
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: SearchViewController.self))
            viewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            viewController.reactor = reactor
            _ = viewController.view
        }

        describe("actions") {
            it("sends `.inputQuery` to the reactor") {
                expect(reactor.stub.actions.last!).toEventually(equal(.inputQuery("q")))
            }

            it("sends `.loadNextPage` to the reactor") {
                expect(reactor.stub.actions.last!).toEventually(equal(SearchViewReactor.Action.loadNextPage))
            }
        }
    }
}

private class RepositoryServiceMock: RepositoryServiceType {
    func searchRepositories(query: String?, page: Int) -> Observable<(repositories: [Repository], nextPage: Int?)> {
        return Observable.never()
    }
}
