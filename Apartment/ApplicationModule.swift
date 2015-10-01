import Foundation
import Ra
import UIKit
import ApartKit

let kBackendService = "backendService"
public let kLightsService = "kLightsService"
public let kLockService = "kLockService"
public let kAuthenticationToken = "kAuthenticationToken"
let authenticationTokenUserDefault = "authenticationToken"

public class ApplicationModule {
    public func configureInjector(injector: Ra.Injector) {
<<<<<<< HEAD
        injector.bind(kBackendService) {
            NSUserDefaults.standardUserDefaults().stringForKey(kBackendService) ?? "http://localhost:3000/"
        }

        injector.bind(kAuthenticationToken) {
            NSUserDefaults.standardUserDefaults().stringForKey(authenticationTokenUserDefault) ?? ""
        }

        let lightsService = LightsService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "", mainQueue: NSOperationQueue.mainQueue())

        injector.bind(kLightsService) {
            lightsService.backendURL = injector.create(kBackendService) as! String
            lightsService.authenticationToken = injector.create(kAuthenticationToken) as! String
            return lightsService
        }

        let lockService = LockService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "", mainQueue: NSOperationQueue.mainQueue())

        injector.bind(kLockService) {
            lockService.backendURL = injector.create(kBackendService) as! String
            lockService.authenticationToken = injector.create(kAuthenticationToken) as! String
            return lockService
        }

        injector.bind(UICollectionView.self) {
            return UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        }
=======
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: URLSessionDelegate(), delegateQueue: nil)
        let homeAssistantURL = NSURL(string: "")!
        let apiKey = ""
        let homeService = HomeAssistantService(baseURL: homeAssistantURL, apiKey: apiKey, urlSession: urlSession, mainQueue: NSOperationQueue.mainQueue())

        let homeRepository = HomeAssistantRepository(homeService: homeService)
        homeRepository.watchSession.activateSession()
        injector.bind(HomeAssistantRepository.self, to: homeRepository)
>>>>>>> efa7124... Add HomeAssistantRepository, to better communicate with the watch
    }

    public init() {}
}

private class URLSessionDelegate: NSObject, NSURLSessionDelegate {
    @objc private func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
}