import Quick
import Nimble
import UIKit
import Ra

class BulbSettingsViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: BulbSettingsViewController! = nil
        var injector: Ra.Injector! = nil
        var navigationController: UINavigationController! = nil

        beforeEach {
            injector = Ra.Injector()
            SpecApplicationModule().configureInjector(injector)

            subject = injector.create(BulbSettingsViewController.self) as! BulbSettingsViewController

            navigationController = UINavigationController(rootViewController: subject)
            navigationController.navigationBarHidden = true
        }

        describe("on viewDidLoad") {
            beforeEach {
                expect(subject.view).toNot(beNil())
            }

            it("should set the title to 'Bulb Settings'") {
                expect(subject.title).to(equal("Bulb Settings"))
            }

            describe("on viewWillAppear:") {
                beforeEach {
                    subject.viewWillAppear(false)
                }
                it("should unhide the navbar") {
                    expect(subject.navigationController?.navigationBarHidden).to(beFalsy())
                }
            }

            describe("collectionView") {
                it("should have one item") {
                    expect(subject.collectionView.numberOfItemsInSection(0)).to(equal(1))
                }

                describe("the cell") {
                    var cell : ListCard? = nil
                    beforeEach {
                        cell = subject.collectionView(subject.collectionView, cellForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? ListCard
                        expect(cell).toNot(beNil())
                    }

                    it("should have a LocationCard delegate") {
                        expect(cell?.delegate as? LocationCard).toNot(beNil())
                    }
                }
            }
        }
    }
}
