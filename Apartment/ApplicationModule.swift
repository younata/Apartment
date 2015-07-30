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

        injector.bind(kAuthenticationToken) {
            NSUserDefaults.standardUserDefaults().stringForKey(authenticationTokenUserDefault) ?? ""
        }

        let lightsService = LightsService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")

        injector.bind(kLightsService) {
            lightsService.backendURL = injector.create(kBackendService) as! String
            lightsService.authenticationToken = injector.create(authenticationTokenUserDefault) as! String
            return lightsService
        }

        let lockService = LockService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")

        injector.bind(kLockService) {
            lockService.backendURL = injector.create(kBackendService) as! String
            lockService.authenticationToken = injector.create(authenticationTokenUserDefault) as! String
            return lockService
        }

        injector.bind(UICollectionView.self) {
            return UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        }
    }

    public init() {}
}