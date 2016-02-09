import Quick
import Nimble
import ApartKit
import Apartment

class SettingsEntityTableViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: SettingsEntityTableViewController!
        var homeRepository: FakeHomeRepository!

        var presentingController: UIViewController!

        var receivedState: State? = nil
        var didCallOnFinish = false

        beforeEach {
            subject = SettingsEntityTableViewController()

            homeRepository = FakeHomeRepository()
            homeRepository.backendURL = NSURL(string: "https://example.com")
            homeRepository.backendPassword = "hello"

            subject.configure(homeRepository)

            receivedState = nil
            didCallOnFinish = false
            subject.onFinish = {
                receivedState = $0
                didCallOnFinish = true
            }

            subject.view.layoutIfNeeded()

            presentingController = UIViewController()
            presentingController.presentViewController(subject, animated: false, completion: nil)
        }

        it("makes a call for all the groups") {
            expect(homeRepository.statesCallbacks).toNot(beNil())
        }

        describe("the tableView") {
            it("has two sections") {
                expect(subject.tableView.numberOfSections) == 2
            }

            describe("the first section") {
                it("has one cell") {
                    expect(subject.tableView.numberOfRowsInSection(0)) == 1
                }

                it("the cell indicates to deselect the entity, tapping it will call onFinish with nil") {
                    let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                    expect(cell?.textLabel?.text) == "None"

                    cell?.tap()
                    expect(receivedState).to(beNil())
                    expect(didCallOnFinish) == true
                    expect(presentingController.presentedViewController).to(beNil())
                }
            }

            describe("the second section") {
                it("is initially empty") {
                    expect(subject.tableView.numberOfRowsInSection(1)) == 0
                }

                context("when the groups callback comes back") {
                    let groupState = State(attributes: ["entity_id": ["light.bedroom", "switch.internet_switch"], "friendly_name": "Test Group"], entityId: "group.test", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on")
                    let bedroomLight = State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on")
                    let internetSwitch = State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: NSDate(), lastUpdated: NSDate(), state: "off")

                    let states = [
                        bedroomLight,
                        State(attributes: ["auto": true, "entity_id": ["light.bedroom"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on"),
                        internetSwitch,
                        groupState
                    ]

                    beforeEach {
                        homeRepository.statesCallback?(states)
                    }

                    it("now has a cell for each manually-created group") {
                        expect(subject.tableView.numberOfRowsInSection(1)) == 1
                    }

                    it("the cell indicates the entity representing the group, tapping it will call onFinish with that entity") {
                        let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
                        expect(cell?.textLabel?.text) == "Test Group"

                        cell?.tap()

                        expect(receivedState) == groupState
                        expect(didCallOnFinish) == true
                        expect(presentingController.presentedViewController).to(beNil())
                    }
                }
            }
        }
    }
}