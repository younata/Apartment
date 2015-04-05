import Quick
import Nimble
import Ra

class BulbViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: BulbViewController! = nil
        var injector: Ra.Injector! = nil

        beforeEach {
            injector = Ra.Injector()
            SpecApplicationModule().configureInjector(injector)

            subject = injector.create(BulbViewController.self) as! BulbViewController
        }
    }
}
