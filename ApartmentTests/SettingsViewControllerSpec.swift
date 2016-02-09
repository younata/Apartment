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
            homeRepository.backendURL = NSURL(string: "https://example.com")
            homeRepository.backendPassword = "Hello"
            homeRepository.watchComplicationEntityId = "test.state"
            homeRepository.watchGlanceEntityId = "test.state"
            injector.bind(HomeRepository.self, toInstance: homeRepository)

            subject = injector.create(SettingsViewController)!

            subject.view.layoutIfNeeded()
            subject.viewWillAppear(false)
        }

        it("makes a request to the homeRepository for the configuration") {
            expect(homeRepository.configurationCallback).toNot(beNil())
        }

        it("makes a request to the homeRepository for the current states") {
            expect(homeRepository.statesCallback).toNot(beNil())
        }

        it("is titled 'Settings'") {
            expect(subject.title) == "Settings"
        }

        it("sets the app version label text to the app's version") {
            let versionNumber = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
            expect(subject.appVersionLabel.text) == "App Version \(versionNumber)"
        }

        it("has a left navigation item that dismisses it") {
            let presentingViewController = UIViewController()

            presentingViewController.presentViewController(subject, animated: false, completion: nil)

            expect(subject.navigationItem.leftBarButtonItem).toNot(beNil())

            let lefty = subject.navigationItem.leftBarButtonItem
            expect(lefty?.title) == "Done"

            lefty?.tap()

            expect(presentingViewController.presentedViewController).to(beNil())
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

            it("sets the backend version label text to that configuration's version") {
                expect(subject.backendVersionLabel.text) == "Home Assistant Version 0.13.0"
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

                it("has the detail label 'Not Set' if the complication entity is not set or if we haven't heard from the server yet") {
                    expect(settingsView.detailLabel.text) == "Not Set"
                }

                context("when the home states come back") {
                    beforeEach {
                        let state = State(attributes: ["friendly_name": "Test"], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "Testing")
                        homeRepository.statesCallbacks.forEach {
                            $0([state])
                        }
                    }

                    it("updates the detail label text to the complication entity display name if it's there") {
                        expect(settingsView.detailLabel.text) == "Test"
                    }
                }

                context("when tapped") {
                    beforeEach {
                        settingsView.gestureRecognizers?.first?.recognize()
                    }

                    it("shows a WatchEntitySettingsController") {
                        expect(subject.shownViewController).to(beAKindOf(SettingsEntityTableViewController.self))
                        if let setvc = subject.shownViewController as? SettingsEntityTableViewController {
                            expect(setvc.homeRepository as? FakeHomeRepository === homeRepository) == true
                        }
                    }

                    context("when an entity is selected") {
                        it("sets the homeRepository's watchComplicationEntityId to that entity's id") {
                            let entity = State(attributes: [:], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "")
                            if let setvc = subject.shownViewController as? SettingsEntityTableViewController {
                                setvc.onFinish?(entity)
                                expect(homeRepository.watchComplicationEntityId) == entity.entityId
                            } else { fail("precondition failed") }
                        }
                    }

                    context("when nothing is selected") {
                        it("sets the homeRepository's watchComplicationEntityId to nil") {
                            if let setvc = subject.shownViewController as? SettingsEntityTableViewController {
                                setvc.onFinish?(nil)
                                expect(homeRepository.watchComplicationEntityId).to(beNil())
                            } else { fail("precondition failed") }
                        }
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

                it("has the detail label 'Not Set' if the complication entity is not set or if we haven't heard from the server yet") {
                    expect(settingsView.detailLabel.text) == "Not Set"
                }

                context("when the home states come back") {
                    beforeEach {
                        let state = State(attributes: ["friendly_name": "Test"], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "Testing")
                        homeRepository.statesCallbacks.forEach {
                            $0([state])
                        }
                    }

                    it("updates the detail label text to the complication entity display name if it's there") {
                        expect(settingsView.detailLabel.text) == "Test"
                    }
                }

                context("when tapped") {
                    beforeEach {
                        settingsView.gestureRecognizers?.first?.recognize()
                    }

                    it("shows a WatchEntitySettingsController") {
                        expect(subject.shownViewController).to(beAKindOf(SettingsEntityTableViewController.self))
                        if let setvc = subject.shownViewController as? SettingsEntityTableViewController {
                            expect(setvc.homeRepository as? FakeHomeRepository === homeRepository) == true
                        }
                    }

                    context("when an entity is selected") {
                        it("sets the homeRepository's watchGlanceEntityId to that entity's id") {
                            let entity = State(attributes: [:], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "")
                            if let setvc = subject.shownViewController as? SettingsEntityTableViewController {
                                setvc.onFinish?(entity)
                                expect(homeRepository.watchGlanceEntityId) == entity.entityId
                            } else { fail("precondition failed") }
                        }
                    }

                    context("when nothing is selected") {
                        it("sets the homeRepository's watchGlanceEntityId to nil") {
                            if let setvc = subject.shownViewController as? SettingsEntityTableViewController {
                                setvc.onFinish?(nil)
                                expect(homeRepository.watchGlanceEntityId).to(beNil())
                            } else { fail("precondition failed") }
                        }
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
