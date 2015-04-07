import Quick
import Nimble
import Ra

class BulbViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: BulbViewController! = nil
        var injector: Ra.Injector! = nil
        let bulb = Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
            saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
            effect: .none, reachable: true, alert: "none")

        beforeEach {
            injector = Ra.Injector()
            SpecApplicationModule().configureInjector(injector)

            subject = injector.create(BulbViewController.self) as! BulbViewController
            subject.configure(bulb)
        }

        describe("on view did load") {
            beforeEach {
                expect(subject.view).toNot(beNil())
            }

            it("should do the thing") {
                expect(true).to(beTruthy())
            }
        }
    }
}
