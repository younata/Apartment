import Quick
import Nimble
import UIKit
import Ra
import Apartment
import ApartKit

class HomeViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: HomeViewController!
        var injector: Injector!
        var homeRepository: FakeHomeRepository!

        beforeEach {
            injector = Injector()

            homeRepository = FakeHomeRepository()
            injector.bind(HomeRepository.self, toInstance: homeRepository)

            subject = injector.create(HomeViewController)!
        }

        it("sets the title to something") {
            subject.view.layoutIfNeeded()
            expect(subject.title) == "Apartment"
        }

        context("if the home repository has not been configured") {
            beforeEach {
                subject.view.layoutIfNeeded()
            }

            it("presents a login view controller so that the user can login") {
                expect(subject.presentedViewController).to(beAKindOf(LoginViewController.self))
            }

            describe("when the user logs in") {
                beforeEach {
                    homeRepository.backendURL = NSURL(string: "https://example.com")
                    homeRepository.backendPassword = "password"

                    let loginVC = subject.presentedViewController as? LoginViewController
                    subject.dismissViewControllerAnimated(false, completion: nil)
                    loginVC?.onLogin?()
                }

                it("should request that the home service gets updated status") {
                    expect(homeRepository.statesCallback).toNot(beNil())
                }

                it("should request that the home service gets the list of all services") {
                    expect(homeRepository.servicesCallback).toNot(beNil())
                }

                it("should start off the refresh control") {
                    expect(subject.refreshControl?.refreshing).to(beTruthy())
                }
            }
        }

        context("once the home repository has been configured") {
            beforeEach {
                homeRepository.backendURL = NSURL(string: "https://example.com")
                homeRepository.backendPassword = "password"

                subject.view.layoutIfNeeded()
            }

            it("should request that the home service gets updated status") {
                expect(homeRepository.statesCallback).toNot(beNil())
            }

            it("should request that the home service gets the list of all services") {
                expect(homeRepository.servicesCallback).toNot(beNil())
            }

            it("should start off the refresh control") {
                expect(subject.refreshControl?.refreshing).to(beTruthy())
            }

            describe("when the home service comes back successfully") {
                beforeEach {
                    guard let callback = homeRepository.statesCallback else { return }

                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                    let states = [
                        State(attributes: ["xy_color": ["0.4499", "0.408"], "brightness": 254, "friendly_name": "Living room"], entityId: "light.living_room", lastChanged: NSDate(timeIntervalSince1970: 1443649080.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "on"),
                        State(attributes: ["active_requested": 0, "friendly_name": "romantic", "entity_id": [ "light.living_room", "light.bedroom"]], entityId: "scene.romantic", lastChanged: NSDate(timeIntervalSince1970: 1443601946.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "off"),
                        State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: NSDate(timeIntervalSince1970: 1443612568.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "off"),
                        State(attributes: ["xy_color": [ "0.4499", "0.408" ], "brightness": 254, "friendly_name": "Bedroom"], entityId: "light.bedroom", lastChanged: NSDate(timeIntervalSince1970: 1443649080.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "on"),
                        State(attributes: ["friendly_name": "Hue Lamp"], entityId: "light.hue_lamp", lastChanged: NSDate(timeIntervalSince1970: 1443601958.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "off"),
                        State(attributes: ["supported_media_commands": 63, "friendly_name": "osmc"], entityId: "media_player.osmc", lastChanged: NSDate(timeIntervalSince1970: 1443601945.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "idle"),
                        State(attributes: ["next_setting": "01:53:48 01-10-2015", "next_rising": "14:04:56 01-10-2015", "friendly_name": "Sun"], entityId: "sun.sun", lastChanged: NSDate(timeIntervalSince1970: 1443647044.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "above_horizon"),
                        State(attributes: ["friendly_name": "Weather Summary"], entityId: "sensor.weather_summary", lastChanged: NSDate(timeIntervalSince1970: 1443658172.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "Light Rain"),
                        State(attributes: ["active_requested": 0, "friendly_name": "all_lights_off", "entity_id": [ "light.living_room", "light.bedroom" ]], entityId: "scene.all_lights_off", lastChanged: NSDate(timeIntervalSince1970: 1443649080.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "off"),
                        State(attributes: ["active_requested": 0, "friendly_name": "all_lights_on", "entity_id": [ "light.living_room", "light.bedroom" ]], entityId: "scene.all_lights_on", lastChanged: NSDate(timeIntervalSince1970: 1443601946.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "off"),
                        State(attributes: ["auto": 1, "friendly_name": "all lights", "entity_id": [ "light.hue_lamp", "light.living_room", "light.bedroom" ]], entityId: "group.all_lights", lastChanged: NSDate(timeIntervalSince1970: 1443649080.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "on"),
                        State(attributes: ["auto": 1, "friendly_name": "all switches", "entity_id": [ "switch.internet_switch" ]], entityId: "group.all_switches", lastChanged: NSDate(timeIntervalSince1970: 1443612568.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "off"),
                        State(attributes: ["auto": 0, "friendly_name": "Apartment", "entity_id": [ "switch.internet_switch", "light.living_room", "light.bedroom", "sensor.weather_temperature", "device_tracker.my_phone" ]], entityId: "group.apartment", lastChanged: NSDate(), lastUpdated: NSDate(), state: "off"),
                        State(attributes: ["unit_of_measurement": "°F", "friendly_name": "Weather Temperature"], entityId: "sensor.weather_temperature", lastChanged: NSDate(timeIntervalSince1970: 1443658172.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "60.6"),
                        State(attributes: ["battery": 75, "friendly_name": "my phone", "gps_accuracy": 65, "latitude": 37, "longitude": 122], entityId: "device_tracker.my_phone", lastChanged: NSDate(), lastUpdated: NSDate(), state: "home"),
                    ]

                    callback(states)
                }

                describe("the tableView") {
                    var dataSource: UITableViewDataSource? = nil
                    var delegate: UITableViewDelegate? = nil

                    beforeEach {
                        dataSource = subject.tableView.dataSource
                        delegate = subject.tableView.delegate
                    }

                    it("should have a datasource") {
                        expect(dataSource).toNot(beNil())
                    }

                    it("should have a delegate") {
                        expect(delegate).toNot(beNil())
                    }

                    it("should have a section for each manually-created group, plus one for each scene") {
                        expect(dataSource?.numberOfSectionsInTableView?(subject.tableView)) == 2
                    }

                    describe("the first section") {
                        let sectionNumber = 0

                        it("should be titled 'scenes'") {
                            expect(dataSource?.tableView?(subject.tableView, titleForHeaderInSection: sectionNumber)) == "scenes"
                        }

                        it("should have only as many sections as there are scenes") {
                            expect(dataSource?.tableView(subject.tableView, numberOfRowsInSection: sectionNumber)) == 3
                        }

                        describe("a cell") {
                            var cell: UITableViewCell? = nil
                            let indexPath = NSIndexPath(forRow: 0, inSection: sectionNumber)

                            beforeEach {
                                cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath)
                                expect(cell).toNot(beNil())
                                expect(cell).toNot(beAKindOf(SwitchTableViewCell.self))
                            }

                            it("should have the same title as the displayName") {
                                expect(cell?.textLabel?.text) == "romantic"
                            }

                            it("should not have a detail text") {
                                expect(cell?.detailTextLabel?.text) == ""
                            }

                            describe("tapping it") {
                                describe("before the services request has finished") {
                                    beforeEach {
                                        delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                    }

                                    it("should not make any request to change things") {
                                        expect(homeRepository.updateServiceCallback).to(beNil())
                                    }
                                }

                                describe("after the services request has finished") {
                                    let services = [
                                        Service(domain: "light", services: ["turn_on", "turn_off"]),
                                        Service(domain: "scene", services: ["turn_on", "turn_off"]),
                                        Service(domain: "homeassistant", services: ["turn_on", "stop", "turn_off"])
                                    ]

                                    beforeEach {
                                        homeRepository.servicesCallback?(services)
                                        delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                    }

                                    it("should make a request to change the light") {
                                        expect(homeRepository.updateServiceCallback).toNot(beNil())
                                        expect(homeRepository.updateServiceService) == services[1]
                                        expect(homeRepository.updateServiceMethod) == "turn_on"
                                    }
                                }
                            }
                        }
                    }

                    describe("the last through n-1 section") {
                        let sectionNumber = 1

                        it("should be titled for that group name") {
                            expect(dataSource?.tableView?(subject.tableView, titleForHeaderInSection: sectionNumber)) == "Apartment"
                        }

                        it("should have only as many sections as there are items in the group") {
                            expect(dataSource?.tableView(subject.tableView, numberOfRowsInSection: sectionNumber)) == 5
                        }

                        describe("a cell for a switch/light") {
                            var cell: SwitchTableViewCell? = nil
                            let indexPath = NSIndexPath(forRow: 0, inSection: sectionNumber)

                            beforeEach {
                                cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath) as? SwitchTableViewCell
                                expect(cell).toNot(beNil())
                            }

                            it("should have the same title as the displayName") {
                                expect(cell?.textLabel?.text) == "Bedroom"
                            }

                            describe("toggling the switch") {
                                describe("before the services request has finished") {
                                    beforeEach {
                                        cell?.cellSwitch.on = false
                                        cell?.cellSwitch.sendActionsForControlEvents(.ValueChanged)
                                        delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                    }

                                    it("should not make any request to change things") {
                                        expect(homeRepository.updateServiceCallback).to(beNil())
                                    }
                                }

                                describe("after the services request has finished") {
                                    let services = [
                                        Service(domain: "light", services: ["turn_on", "turn_off"]),
                                        Service(domain: "scene", services: ["turn_on", "turn_off"]),
                                        Service(domain: "homeassistant", services: ["turn_on", "stop", "turn_off"])
                                    ]

                                    beforeEach {
                                        homeRepository.servicesCallback?(services)
                                        cell?.cellSwitch.on = false
                                        cell?.cellSwitch.sendActionsForControlEvents(.ValueChanged)
                                    }

                                    it("should make a request to change the light") {
                                        expect(homeRepository.updateServiceCallback).toNot(beNil())
                                        expect(homeRepository.updateServiceService) == services.first
                                        expect(homeRepository.updateServiceMethod) == "turn_off"
                                        expect(homeRepository.updateServiceEntity).toNot(beNil())
                                    }
                                }
                            }

                            describe("tapping the cell") {
                                beforeEach {
                                    delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                }

                                // displays value over time?
                            }
                        }

                        describe("a cell for a sensor") {
                            var cell: UITableViewCell? = nil
                            let indexPath = NSIndexPath(forRow: 2, inSection: sectionNumber)

                            beforeEach {
                                cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath)
                                expect(cell).toNot(beNil())
                            }

                            it("should have the same title as the displayName") {
                                expect(cell?.textLabel?.text) == "Weather Temperature"
                            }

                            it("should show the state as the detail") {
                                expect(cell?.detailTextLabel?.text) == "60.6 °F"
                            }

                            describe("tapping the cell") {
                                beforeEach {
                                    delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                }

                                // displays value over time?
                            }
                        }

                        describe("a cell for a device tracker") {
                            var cell: UITableViewCell? = nil
                            let indexPath = NSIndexPath(forRow: 4, inSection: sectionNumber)

                            beforeEach {
                                cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath)
                                expect(cell).toNot(beNil())
                            }

                            it("should have the same title as the displayName") {
                                expect(cell?.textLabel?.text) == "my phone"
                            }

                            it("should show the state as the detail") {
                                expect(cell?.detailTextLabel?.text) == "home"
                            }

                            describe("tapping the cell") {
                                beforeEach {
                                    delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                }

                                it("displays the map view controller") {
                                    expect(subject.shownDetailViewController).to(beAKindOf(MapViewController.self))

                                    if let mapViewController = subject.shownDetailViewController as? MapViewController {
                                        expect(mapViewController.devices.count) == 1
                                        expect(mapViewController.zones.isEmpty) == true
                                    }
                                }
                            }
                        }
                    }

                    it("should stop the refresh control") {
                        expect(subject.refreshControl?.refreshing).to(beFalsy())
                    }
                }

                describe("when the home service fails") {
                    beforeEach {
                        guard let callback = homeRepository.statesCallback else { return }
                        callback([])
                    }

                    it("should stop the refresh control") {
                        expect(subject.refreshControl?.refreshing).to(beFalsy())
                    }
                }
            }
        }
    }
}
