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
        statusRepository.updateLocks()
        statusRepository.updateBulbs()
    }

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let baseURL = applicationContext["baseURL"] as? String
        let authenticationToken = applicationContext["authenticationToken"] as? String

        self.statusRepository.backendURL = baseURL ?? ""
        self.statusRepository.authenticationToken = authenticationToken ?? ""
    }
}
