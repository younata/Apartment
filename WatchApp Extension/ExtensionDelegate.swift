import WatchKit
import WatchConnectivity
import ApartWatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var homeRepository: HomeRepository! = nil

    func applicationDidFinishLaunching() {
        self.homeRepository = ApartWatchKitModule.homeRepository()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let url = userDefaults.URLForKey("backendURL") where !url.absoluteString.isEmpty {
            self.homeRepository.backendURL = url
        }
        if let password = userDefaults.stringForKey("backendPassword") where !password.isEmpty {
            self.homeRepository.backendPassword = password
        }
    }

    func applicationDidBecomeActive() {
    }
}
