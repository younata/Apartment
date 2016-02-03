import Foundation
import Ra
import UIKit
import ApartKit

public class ApplicationModule {
    public func configureInjector(injector: Ra.Injector) {
        injector.bind(UICollectionView.self) {
            return UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        }
//        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: URLSessionDelegate(), delegateQueue: nil)
//        let homeAssistantURL = NSURL(string: "")!
//        let apiKey = ""
//        let homeService = HomeAssistantService(baseURL: homeAssistantURL, apiKey: apiKey, urlSession: urlSession, mainQueue: NSOperationQueue.mainQueue())
//
//        let homeRepository = HomeAssistantRepository(homeService: homeService)
//        homeRepository.watchSession.activateSession()
//        injector.bind(HomeAssistantRepository.self, to: homeRepository)
    }

    public init() {}
}

private class URLSessionDelegate: NSObject, NSURLSessionDelegate {
    @objc private func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
}
