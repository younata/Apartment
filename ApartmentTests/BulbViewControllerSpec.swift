import Quick
import Nimble
import UIKit
import Ra
import Apartment
import ApartKit

class BulbViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: BulbViewController! = nil
        var injector: Ra.Injector! = nil
        let bulb = Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
            saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
            effect: .none, reachable: true, alert: "none")
        var navigationController: UINavigationController! = nil

        beforeEach {
            injector = Ra.Injector()
            SpecApplicationModule().configureInjector(injector)

            subject = injector.create(BulbViewController.self) as! BulbViewController
            subject.configure(bulb)

            navigationController = UINavigationController(rootViewController: subject)
            navigationController.navigationBarHidden = true
        }

        describe("on viewDidLoad") {
            beforeEach {
                expect(subject.view).toNot(beNil())
            }

            it("set the title's name to be the bulb's name") {
                expect(subject.titleField.text).to(equal("Hue Lamp 2"))
            }

            it("should display the bulb's current color as a point on a grid") {
                let hue : CGFloat = 15051.0 / 65535.0
                let saturation : CGFloat = 137.0 / 254.0

                let width = subject.colorPicker.bounds.width
                let height = subject.colorPicker.bounds.height
                let point = CGPointMake(hue * width, saturation * height)
                expect(subject.colorPicker.selectedPoint).to(equal(point))
            }

            describe("on viewWillAppear:") {
                beforeEach {
                    subject.viewWillAppear(false)
                }
                it("should unhide the navbar") {
                    expect(subject.navigationController?.navigationBarHidden).to(beFalsy())
                }
            }
        }
    }
}
