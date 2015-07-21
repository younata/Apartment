import Foundation
import Ra
import UIKit
import ApartKit

let kBackendService = "kBackendService"
public let kLightsService = "kLightsService"
public let kAuthenticationToken = "kAuthenticationToken"

public class ApplicationModule {
    public func configureInjector(injector: Ra.Injector) {
        injector.bind(kBackendService) {
            NSUserDefaults.standardUserDefaults().stringForKey(kBackendService) ?? "http://localhost:3000/"
        }

        injector.bind(NSURLSessionConfiguration.self) {
            let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
            let token = injector.create(kAuthenticationToken) as? String ?? "HelloWorld"
            conf.HTTPAdditionalHeaders = ["Authentication": "Token token=\(token)"]
            return conf
        }

        injector.bind(kLightsService) {
            return LightsService(backendURL: injector.create(kBackendService) as! String, urlSession: NSURLSession.sharedSession(), authenticationToken: "")
        }

        injector.bind(UICollectionView.self) {
            return UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        }
    }

    public init() {}
}
