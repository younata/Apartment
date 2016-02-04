import UIKit
import Ra
import ApartKit

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?
    public lazy var anInjector: Ra.Injector = {
        let injector = Ra.Injector()
        ApartKitModule().configureInjector(injector)
        injector.bind(NSUserDefaults.self, toInstance: NSUserDefaults.standardUserDefaults())
        return injector
    }()

    private lazy var homeRepository: HomeRepository = {
        return self.anInjector.create(HomeRepository)!
    }()

    private lazy var userDefaults: NSUserDefaults = {
        return self.anInjector.create(NSUserDefaults)!
    }()

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.makeKeyAndVisible()

        if NSClassFromString("XCTestCase") != nil && launchOptions?["test"] as? Bool != true {
            self.window?.rootViewController = UIViewController()
        } else {
            if let url = self.userDefaults.URLForKey("backendURL"), let password = self.userDefaults.stringForKey("backendPassword") {
                self.homeRepository.backendURL = url
                self.homeRepository.backendPassword = password
            }
            let homeViewController = anInjector.create(HomeViewController.self)!
            let navController = UINavigationController(rootViewController: homeViewController)
            navController.toolbarHidden = false
            navController.delegate = self
            let splitViewController = UISplitViewController()
            splitViewController.viewControllers = [navController]
            self.window?.rootViewController = splitViewController
        }

        return true
    }
}

extension AppDelegate: UINavigationControllerDelegate {
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        navigationController.setToolbarHidden(!(viewController is HomeViewController), animated: animated)
    }
}