import Foundation

public struct ApartWatchKitModule {
    private static let urlSession: NSURLSession = {
        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: URLSessionDelegate(),
            delegateQueue: nil)
    }()

    private static let homeAssistantRepository: HomeAssistantRepository = {
        let homeService = HomeAssistantService(urlSession: urlSession,
            mainQueue: NSOperationQueue.mainQueue())
        return HomeAssistantRepository(homeService: homeService, userDefaults: NSUserDefaults.standardUserDefaults())
    }()

    public static func homeRepository() -> HomeRepository {
        return homeAssistantRepository
    }
}

private class URLSessionDelegate: NSObject, NSURLSessionDelegate {
    @objc private func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
}