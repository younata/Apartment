import Foundation
import Ra
import UIKit
import ApartKit

public class ApplicationModule {
    public func configureInjector(injector: Ra.Injector) {
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: URLSessionDelegate(), delegateQueue: nil)
        let homeAssistantURL = NSURL(string: "")!
        let apiKey = ""
        let homeService = HomeAssistantService(baseURL: homeAssistantURL, apiKey: apiKey, urlSession: urlSession, mainQueue: NSOperationQueue.mainQueue())
        injector.bind(HomeAssistantService.self, to: homeService)
    }

    public init() {}
}