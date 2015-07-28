import WatchKit
import WatchConnectivity
import ApartWatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    lazy var session: WCSession = WCSession.defaultSession()

    lazy var statusRepository = StatusRepository()

    func applicationDidFinishLaunching() {
        session.delegate = self
        session.activateSession()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let baseURL = applicationContext["baseURL"] as? String
        let authenticationToken = applicationContext["authenticationToken"] as? String

        self.statusRepository.backendURL = baseURL ?? ""
        self.statusRepository.authenticationToken = authenticationToken ?? ""
    }
}
