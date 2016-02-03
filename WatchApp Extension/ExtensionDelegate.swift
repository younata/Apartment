import WatchKit
import WatchConnectivity
import ApartWatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var homeRepository: HomeRepository! = nil

    func applicationDidFinishLaunching() {
        self.homeRepository = ApartWatchKitModule.homeRepository()
    }

    func applicationDidBecomeActive() {
    }
}
