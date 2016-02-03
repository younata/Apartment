import Quick
import Nimble
import UIKit
import Ra
import Apartment
import ApartKit

class HomeViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: HomeViewController! = nil
        var injector: Ra.Injector! = nil
        var navigationController: UINavigationController! = nil
        var appModule: SpecApplicationModule! = nil
        var homeService: FakeHomeAssistantService! = nil
        var homeRepository: HomeAssistantRepository! = nil

        beforeEach {
            injector = Ra.Injector()

            appModule = SpecApplicationModule()
            appModule.configureInjector(injector)

            homeService = FakeHomeAssistantService()
            homeRepository = HomeAssistantRepository(homeService: homeService)
            injector.bind(HomeAssistantRepository.self, to: homeRepository)

            subject = injector.create(HomeViewController.self) as! HomeViewController
            navigationController = UINavigationController(rootViewController: subject)
        }

        describe("on view load") {
            beforeEach {
                expect(subject.view).toNot(beNil())
            }

            it("should request that the home service gets updated status") {
                expect(homeService.statusCallback).toNot(beNil())
            }

            it("should request that the home service gets the list of all services") {
                expect(homeService.servicesCallback).toNot(beNil())
            }

            it("should start off the refresh control") {
                expect(subject.refreshControl?.refreshing).to(beTruthy())
            }

            describe("when the home service comes back successfully") {
                beforeEach {
                    guard let callback = homeService.statusCallback else { return }

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
                        State(attributes: ["unit_of_measurement": "°F", "friendly_name": "Weather Temperature"], entityId: "sensor.weather_temperature", lastChanged: NSDate(timeIntervalSince1970: 1443658172.0), lastUpdated: NSDate(timeIntervalSince1970: 1443658230.0), state: "60.6")
                    ]

                    callback(states, nil)
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

                    it("should have a section for each group, plus one for each scene") {
                        expect(dataSource?.numberOfSectionsInTableView?(subject.tableView)).to(equal(3))
                    }

                    describe("the first through n-1 section") {
                        let sectionNumber = 0

                        it("should be titled for that group name") {
                            expect(dataSource?.tableView?(subject.tableView, titleForHeaderInSection: sectionNumber)).to(equal("all lights"))
                        }

                        it("should have only as many sections as there are items in the group") {
                            expect(dataSource?.tableView(subject.tableView, numberOfRowsInSection: sectionNumber)).to(equal(3))
                        }

                        describe("a cell") {
                            var cell: SwitchTableViewCell? = nil
                            let indexPath = NSIndexPath(forRow: 0, inSection: sectionNumber)

                            beforeEach {
                                cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath) as? SwitchTableViewCell
                                expect(cell).toNot(beNil())
                            }

                            it("should have the same title as the displayName") {
                                expect(cell?.textLabel?.text).to(equal("Bedroom"))
                            }

                            describe("toggling the switch") {
                                describe("before the services request has finished") {
                                    beforeEach {
                                        cell?.cellSwitch.on = false
                                        cell?.cellSwitch.sendActionsForControlEvents(.ValueChanged)
                                        delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                    }

                                    it("should not make any request to change things") {
                                        expect(homeService.calledServiceCallback).to(beNil())
                                    }
                                }

                                describe("after the services request has finished") {
                                    beforeEach {
                                        let services = [
                                            Service(domain: "light", services: ["turn_on", "turn_off"]),
                                            Service(domain: "scene", services: ["turn_on", "turn_off"]),
                                            Service(domain: "homeassistant", services: ["turn_on", "stop", "turn_off"])
                                        ]
                                        homeService.servicesCallback?(services, nil)
                                        cell?.cellSwitch.on = false
                                        cell?.cellSwitch.sendActionsForControlEvents(.ValueChanged)
                                    }

                                    it("should make a request to change the light") {
                                        expect(homeService.calledServiceCallback).toNot(beNil())
                                        expect(homeService.calledServiceDomain).to(equal("light"))
                                        expect(homeService.calledService).to(equal("turn_off"))
                                    }
                                }
                            }

                            describe("tapping the cell") {
                                beforeEach {
                                    delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                }
                            }
                        }
                    }

                    describe("the last section") {
                        let sectionNumber = 2

                        it("should be titled 'scenes'") {
                            expect(dataSource?.tableView?(subject.tableView, titleForHeaderInSection: sectionNumber)).to(equal("scenes"))
                        }

                        it("should have only as many sections as there are scenes") {
                            expect(dataSource?.tableView(subject.tableView, numberOfRowsInSection: sectionNumber)).to(equal(3))
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
                                expect(cell?.textLabel?.text).to(equal("romantic"))
                            }

                            describe("tapping it") {
                                describe("before the services request has finished") {
                                    beforeEach {
                                        delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                    }

                                    it("should not make any request to change things") {
                                        expect(homeService.calledServiceCallback).to(beNil())
                                    }
                                }

                                describe("after the services request has finished") {
                                    beforeEach {
                                        let services = [
                                            Service(domain: "light", services: ["turn_on", "turn_off"]),
                                            Service(domain: "scene", services: ["turn_on", "turn_off"]),
                                            Service(domain: "homeassistant", services: ["turn_on", "stop", "turn_off"])
                                        ]
                                        homeService.servicesCallback?(services, nil)
                                        delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                    }

                                    it("should make a request to change the light") {
                                        expect(homeService.calledServiceCallback).toNot(beNil())
                                        expect(homeService.calledServiceDomain).to(equal("scene"))
                                        expect(homeService.calledService).to(equal("turn_on"))
                                    }
                                }
                            }
                        }
                    }

                    sharedExamples("a tableView section") {(sharedContext: SharedExampleContext) in
                        var sectionNumber: Int = 0

                        beforeEach {
                            sectionNumber = sharedContext()["section"] as? Int ?? 0
                        }

                        describe("a cell") {
                            var cell: UITableViewCell? = nil
                            var indexPath = NSIndexPath(forRow: 0, inSection: 0)

                            beforeEach {
                                indexPath = NSIndexPath(forRow: 0, inSection: sectionNumber)
                                cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath)
                                expect(cell).toNot(beNil())
                            }

                            it("should have the same title as the name") {
                                let expectedTitle = sharedContext()["cellTitle"] as? String
                                expect(cell?.textLabel?.text).to(equal(expectedTitle))
                            }

                            describe("tapping it") {
                                beforeEach {
                                    expect(delegate?.respondsToSelector("tableView:didSelectRowAtIndexPath:")).to(beTruthy())
                                    delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                                }

                                it("should navigate to the desired detail screen") {
                                    let expectedDetailScreen: AnyClass? = sharedContext()["cellDetailScreen"] as? AnyClass
                                    expect(expectedDetailScreen).toNot(beNil())
                                    if let detailScreen = expectedDetailScreen {
                                        expect(navigationController.topViewController).to(beAKindOf(detailScreen))
                                    }
                                }
                                it("resets the switch") {
                                    expect(cell?.bulbStatus.on).to(beFalsy())
                                }

                                it("should update the UI to show the not-in-progress state") {
                                    expect(cell?.contentView.backgroundColor).to(equal(UIColor.clearColor()))
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
                    guard let callback = homeService.statusCallback else { return }
                    let error = NSError(domain: "", code: 0, userInfo: nil)
                    callback([], error)
                }

                it("should stop the refresh control") {
                    expect(subject.refreshControl?.refreshing).to(beFalsy())
                }
            }
        }
    }
}
