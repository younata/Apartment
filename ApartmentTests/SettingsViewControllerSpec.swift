import Quick
import Nimble
import Ra
import CoreLocation
import ApartKit
import Apartment

class SettingsViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: SettingsViewController!

        var homeRepository: FakeHomeRepository!

        beforeEach {
            let injector = Injector()

            homeRepository = FakeHomeRepository()
            injector.bind(HomeRepository.self, toInstance: homeRepository)

            subject = injector.create(SettingsViewController)!

            subject.view.layoutIfNeeded()
        }

        it("makes a request to the homeRepository for the configuration") {
            expect(homeRepository.configurationCallback).toNot(beNil())
        }

        context("when the request succeeds") {
            let configuration = HomeConfiguration(components: [],
                coordinate: CLLocationCoordinate2D(),
                name: "Test",
                temperatureUnit: "F",
                timeZone: NSTimeZone(name: "America/Los_Angeles")!,
                version: "0.13.0")

            beforeEach {
                homeRepository.configurationCallback?(configuration)
            }

            it("sets the version label text to that configuration's version") {
                expect(subject.versionLabel.text) == "version 0.13.0"
            }
        }

        context("the stackView") {
            it("has 3 main subviews") {
                expect(subject.stackView.arrangedSubviews.count) == 3
            }

            describe("the first subview") {
                var settingsView: SettingsWatchEntityView!
                beforeEach {
                    settingsView = subject.stackView.arrangedSubviews.first as? SettingsWatchEntityView
                }

                it("has the title label 'Watch Complication Entity'") {
                    expect(settingsView.titleLabel.text) == "Watch Complication Entity"
                }

                it("has the detail label 'Not Set' if the complication entity is not set") {
                    expect(settingsView.detailLabel.text) == "Not Set"
                }

                it("shows a WatchEntitySettingsController on tap") {
                    settingsView.gestureRecognizers?.first?.recognize()

                    expect(subject.shownViewController).to(beAKindOf(SettingsEntityTableViewController.self))

                    if let setvc = subject.shownViewController as? SettingsEntityTableViewController {
                        setvc.onFinish?(nil)
                        expect(homeRepository.watchComplicationEntityId).to(beNil())
                    }
                }
            }

            describe("the middle subview") {
                var settingsView: SettingsWatchEntityView!
                beforeEach {
                    settingsView = subject.stackView.arrangedSubviews[1] as? SettingsWatchEntityView
                }

                it("has the title label 'Watch Glance Entity'") {
                    expect(settingsView.titleLabel.text) == "Watch Glance Entity"
                }

                it("has the detail label 'Not Set' if the complication entity is not set") {
                    expect(settingsView.detailLabel.text) == "Not Set"
                }

                it("shows a WatchEntitySettingsController on tap") {
                    settingsView.gestureRecognizers?.first?.recognize()

                    expect(subject.shownViewController).to(beAKindOf(SettingsEntityTableViewController.self))

                    if let setvc = subject.shownViewController as? SettingsEntityTableViewController {
                        setvc.onFinish?(nil)
                        expect(homeRepository.watchGlanceEntityId).to(beNil())
                    }
                }
            }

            describe("the last subview") {
                var button: UIButton!
                beforeEach {
                    button = subject.stackView.arrangedSubviews.last as? UIButton
                }

                it("is labeled 'Logout'") {
                    expect(button.titleForState(.Normal)) == "Logout"
                }

                it("logs the user out") {
                    homeRepository.backendURL = NSURL(string: "https://example.com")
                    homeRepository.backendPassword = "hello"

                    button.sendActionsForControlEvents(.TouchUpInside)

                    expect(homeRepository.loggedIn) == false
                }
            }
        }
    }
}
