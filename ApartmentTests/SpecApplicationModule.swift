import Ra
import Apartment
import ApartKit

class SpecApplicationModule : ApplicationModule {
    override func configureInjector(injector: Ra.Injector) {
        super.configureInjector(injector)

        injector.bind(kLightsService) {
            return FakeLightsService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")
//            return LightsService(backendURL: injector.create(kBackendService) as! String, urlSession: NSURLSession.sharedSession(), authenticationToken: "")
        }
    }
}