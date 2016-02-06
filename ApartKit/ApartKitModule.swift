import Ra

public struct ApartKitModule: InjectorModule {
    public func configureInjector(injector: Injector) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: URLSessionDelegate(),
            delegateQueue: nil)
        let homeService = HomeAssistantService(urlSession: session,
            mainQueue: NSOperationQueue.mainQueue())
        let repository = HomeAssistantRepository(homeService: homeService)

        injector.bind(NSURLSession.self, toInstance: session)
        injector.bind(HomeRepository.self, toInstance: repository)
    }

    public init() {}
}

private class URLSessionDelegate: NSObject, NSURLSessionDelegate {
    @objc private func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
}