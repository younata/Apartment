import WatchKit
import WatchConnectivity
import ApartWatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    lazy var session: WCSession = WCSession.defaultSession()

    func applicationDidFinishLaunching() {
        session.delegate = self
        session.activateSession()
    }

    func applicationDidBecomeActive() {
    }

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    }
}
