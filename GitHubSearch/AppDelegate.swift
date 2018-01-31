import UIKit

struct Const {
    static let accessToken = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navigationController = window?.rootViewController as! UINavigationController
        let searchViewController = navigationController.topViewController as! SearchViewController
        searchViewController.reactor = SearchViewReactor()
        return true
    }
}
