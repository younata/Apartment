import WatchKit
import WatchConnectivity
import ApartWatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    private(set) lazy var homeRepository: HomeRepository = {
        var homeRepository = ApartWatchKitModule.homeRepository()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let url = userDefaults.URLForKey("backendURL") where !url.absoluteString.isEmpty {
            homeRepository.backendURL = url
        }
        if let password = userDefaults.stringForKey("backendPassword") where !password.isEmpty {
            homeRepository.backendPassword = password
        }
        return homeRepository
    }()

    func applicationDidFinishLaunching() {
    }

    func applicationDidBecomeActive() {
    }
}
