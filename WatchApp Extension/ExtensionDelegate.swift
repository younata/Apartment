import WatchKit
import WatchConnectivity
import ApartWatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var homeRepository: HomeAssistantRepository! = nil

    func applicationDidFinishLaunching() {
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: URLSessionDelegate(), delegateQueue: nil)
        let homeAssistantURL = NSURL(string: "")!
        let apiKey = ""
        let homeService = HomeAssistantService(baseURL: homeAssistantURL, apiKey: apiKey, urlSession: urlSession, mainQueue: NSOperationQueue.mainQueue())

        self.homeRepository = HomeAssistantRepository(homeService: homeService)
        self.homeRepository.watchSession.activateSession()
    }

    func applicationDidBecomeActive() {
    }
}
