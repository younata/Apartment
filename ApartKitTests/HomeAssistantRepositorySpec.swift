import Quick
import Nimble
import WatchConnectivity
import CoreLocation
@testable import ApartKit

private class FakeHomeRepositorySubscriber: NSObject, HomeRepositorySubscriber {
    var userLoggedIn: Bool? = nil
    private func didChangeLoginStatus(loggedIn: Bool) {
        self.userLoggedIn = loggedIn
    }
}

class HomeAssistantRepositorySpec: QuickSpec {
    override func spec() {
        var subject: HomeAssistantRepository!
        var homeService: FakeHomeAssistantService!
        var subscriber: FakeHomeRepositorySubscriber!
        var userDefaults: FakeUserDefaults!

        beforeEach {
            homeService = FakeHomeAssistantService()

            subscriber = FakeHomeRepositorySubscriber()

            userDefaults = FakeUserDefaults()

            subject = HomeAssistantRepository(homeService: homeService, userDefaults: userDefaults)

            subject.addSubscriber(subscriber)
        }

        it("reflects the userDefaults key 'WatchGlanceID' for watchGlanceEntityId") {
            expect(subject.watchGlanceEntityId).to(beNil())

            userDefaults.setValue("test.state", forKey: "WatchGlanceID")

            expect(subject.watchGlanceEntityId) == "test.state"

            subject.watchGlanceEntityId = "testing.state"

            expect(userDefaults.stringForKey("WatchGlanceID")) == "testing.state"
        }

        it("reflects the userDefaults key 'WatchComplicationID' for watchComplicationEntityId") {
            expect(subject.watchComplicationEntityId).to(beNil())

            userDefaults.setValue("test.state", forKey: "WatchComplicationID")

            expect(subject.watchComplicationEntityId) == "test.state"

            subject.watchComplicationEntityId = "testing.state"

            expect(userDefaults.stringForKey("WatchComplicationID")) == "testing.state"
        }

        it("returns nil as the backendURL until it is set") {
            expect(subject.backendURL).to(beNil())
        }

        it("returns nil as the backendPassword until it is set") {
            expect(subject.backendPassword).to(beNil())
        }

        it("calling login actually checks that the api is available before informing any subscribers") {
            subject.backendURL = NSURL(string: "https://example.com")
            subject.backendPassword = "hello"

            expect(subscriber.userLoggedIn).to(beNil())
            expect(homeService.apiAvailableCallback).to(beNil())

            var userDidLogin: Bool? = nil
            subject.login(url: NSURL(string: "https://example.com")!, password: "hello") {
                userDidLogin = $0
            }

            expect(homeService.apiAvailableCallback).toNot(beNil())
            expect(userDidLogin).to(beNil())

            homeService.apiAvailableCallback?(false)
            expect(subscriber.userLoggedIn).to(beNil())
            expect(userDidLogin) == false

            homeService.apiAvailableCallback?(true)
            expect(subscriber.userLoggedIn) == true
            expect(userDidLogin) == true
        }

        describe("logging out") {
            context("when we're not logged in in the first place") {
                it("does not inform any subscribers") {
                    subject.logout()
                    expect(subscriber.userLoggedIn).to(beNil())
                }
            }

            context("when we are logged in") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"

                    subject.logout()
                }

                it("unsets the url and password") {
                    expect(subject.backendURL == nil) == true
                    expect(subject.backendPassword == nil) == true
                }

                it("informs any subscribers") {
                    expect(subscriber.userLoggedIn) == false
                }
            }
        }

        describe("testing if the api is available") {
            var apiIsAvailable: Bool?
            beforeEach {
                apiIsAvailable = nil
            }

            it("immediately returns false if the backendURL is not set") {
                subject.backendPassword = "hello"
                expect(subject.loggedIn) == false
                subject.apiAvailable { apiIsAvailable = $0 }

                expect(apiIsAvailable) == false
                expect(homeService.apiAvailableCallback).to(beNil())
            }

            it("immediately returns false if the backendPassword is not set") {
                subject.backendURL = NSURL(string: "https://example.com")
                expect(subject.loggedIn) == false
                subject.apiAvailable { apiIsAvailable = $0 }

                expect(apiIsAvailable) == false
                expect(homeService.apiAvailableCallback).to(beNil())
            }

            context("when both the backendURL and the backendPassword are set") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"
                    subject.apiAvailable { apiIsAvailable = $0 }
                    expect(subject.loggedIn) == true
                }

                it("calls out to the service") {
                    expect(apiIsAvailable).to(beNil())
                    expect(homeService.apiAvailableCallback).toNot(beNil())
                }

                it("returns true if the service says yes") {
                    homeService.apiAvailableCallback?(true)
                    expect(apiIsAvailable) == true
                }

                it("returns false if the service says no") {
                    homeService.apiAvailableCallback?(false)
                    expect(apiIsAvailable) == false
                }
            }
        }

        describe("updating the backendURL") {
            beforeEach {
                subject.backendPassword = "hello"
                subject.backendURL = NSURL(string: "https://example.com")
            }

            it("sets the homeService's baseURL") {
                expect(homeService.baseURL) == NSURL(string: "https://example.com/api/")
            }

            it("breaks the repositories cache and forces a refresh of states and services") {
                expect(homeService.statusCallback).toNot(beNil())
                expect(homeService.servicesCallback).toNot(beNil())
            }

            it("does not call out to the homeService if the backendURL wasn't actually changed") {
                homeService.statusCallback = nil
                homeService.servicesCallback = nil
                subject.backendURL = NSURL(string: "https://example.com")

                expect(homeService.statusCallback).to(beNil())
                expect(homeService.servicesCallback).to(beNil())
            }
        }

        describe("updating the backendPassword") {
            beforeEach {
                subject.backendURL = NSURL(string: "https://example.com")
                subject.backendPassword = "example"
            }

            it("sets the homeService's apiKey") {
                expect(homeService.apiKey) == "example"
            }

            it("breaks the repositories cache and forces a refresh of states and services") {
                expect(homeService.statusCallback).toNot(beNil())
                expect(homeService.servicesCallback).toNot(beNil())
            }

            it("does not call out to the homeService if the backendPassword wasn't actually changed") {
                homeService.statusCallback = nil
                homeService.servicesCallback = nil
                subject.backendPassword = "example"

                expect(homeService.statusCallback).to(beNil())
                expect(homeService.servicesCallback).to(beNil())
            }
        }

        describe("getting the home configuration") {
            var receivedConfiguration: HomeConfiguration?
            var didGetCalledBack = false

            beforeEach {
                receivedConfiguration = nil
                didGetCalledBack = false
            }

            context("when not logged in") {
                beforeEach {
                    subject.configuration {
                        receivedConfiguration = $0
                        didGetCalledBack = true
                    }
                }

                it("immediately returns nil") {
                    expect(receivedConfiguration).to(beNil())
                    expect(didGetCalledBack) == true
                }
            }

            context("when logged in") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"
                    subject.configuration {
                        receivedConfiguration = $0
                        didGetCalledBack = true
                    }
                }

                it("should not immediately return") {
                    expect(receivedConfiguration).to(beNil())
                    expect(didGetCalledBack) == false
                }

                it("kick off a request to the homeService") {
                    expect(homeService.configurationCallback).toNot(beNil())
                }

                context("when the request succeeds") {
                    let configuration = HomeConfiguration(components: ["a"],
                        coordinate: CLLocationCoordinate2D(latitude: 37, longitude: -122),
                        name: "hi",
                        temperatureUnit: "C",
                        timeZone: NSTimeZone(name: "America/Los_Angeles")!,
                        version: "hi")
                    beforeEach {
                        homeService.configurationCallback?(configuration, nil)
                    }

                    it("calls back with the configuration") {
                        expect(receivedConfiguration) == configuration
                        expect(didGetCalledBack) == true
                    }

                    it("caches the result for the next one") {
                        receivedConfiguration = nil
                        subject.configuration {
                            receivedConfiguration = $0
                        }

                        expect(receivedConfiguration) == configuration
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        let error = NSError(domain: "", code: 0, userInfo: [:])
                        homeService.configurationCallback?(nil, error)
                    }

                    it("calls back with nil") {
                        expect(receivedConfiguration).to(beNil())
                        expect(didGetCalledBack) == true
                    }
                }
            }
        }

        describe("getting the history") {
            var receivedStates: [State]? = nil
            beforeEach {
                receivedStates = nil
            }

            describe("of everything") { // part one, though.
                context("when not logged in") {
                    beforeEach {
                        subject.history(nil) { states in
                            receivedStates = states
                        }
                    }

                    it("immediately returns an empty array") {
                        expect(receivedStates) == []
                    }

                    it("makes no request to the homeService") {
                        expect(homeService.historyDay).to(beNil())
                        expect(homeService.historyState).to(beNil())
                        expect(homeService.historyCallback).to(beNil())
                    }
                }

                context("when logged in") {
                    beforeEach {
                        subject.backendURL = NSURL(string: "https://example.com")
                        subject.backendPassword = "hello"

                        subject.history(nil) { states in
                            receivedStates = states
                        }
                    }

                    it("does not immediately return") {
                        expect(receivedStates).to(beNil())
                    }

                    it("kicks off a request to the homeService") {
                        expect(homeService.historyDay).toNot(beNil())
                        expect(homeService.historyState).to(beNil())
                        expect(homeService.historyCallback).toNot(beNil())
                    }

                    context("when the request succeeds") {
                        let states = [
                            State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on"),
                            State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on"),
                            State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: NSDate(), lastUpdated: NSDate(), state: "off")
                        ]

                        beforeEach {
                            homeService.historyCallback?(states, nil)
                        }

                        it("returns the states") {
                            expect(receivedStates) == states
                        }

                        it("does not cache the results") {
                            receivedStates = nil

                            subject.history(nil) { states in
                                receivedStates = states
                            }

                            expect(receivedStates).to(beNil())
                        }
                    }

                    context("when the request fails") {
                        let error = NSError(domain: "", code: 0, userInfo: [:])
                        beforeEach {
                            homeService.historyCallback?([], error)
                        }
                        
                        it("returns an empty array") {
                            expect(receivedStates) == []
                        }
                    }
                }
            }

            describe("of a single entity") {
                let entity = State(attributes: [:], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "testing")

                context("when not logged in") {
                    beforeEach {
                        subject.history(entity) {states in
                            receivedStates = states
                        }
                    }

                    it("immediately returns an empty array") {
                        expect(receivedStates) == []
                    }

                    it("makes no request to the homeService") {
                        expect(homeService.historyDay).to(beNil())
                        expect(homeService.historyState).to(beNil())
                        expect(homeService.historyCallback).to(beNil())
                    }
                }

                context("when logged in") {
                    beforeEach {
                        subject.backendURL = NSURL(string: "https://example.com")
                        subject.backendPassword = "hello"

                        subject.history(entity) {states in
                            receivedStates = states
                        }
                    }

                    it("does not immediately return") {
                        expect(receivedStates).to(beNil())
                    }

                    it("sends kick off a request to the homeService") {
                        expect(homeService.historyDay).toNot(beNil())
                        expect(homeService.historyState) == entity
                        expect(homeService.historyCallback).toNot(beNil())
                    }

                    context("when the request succeeds") {
                        let states = [
                            State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on"),
                            State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on"),
                            State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: NSDate(), lastUpdated: NSDate(), state: "off")
                        ]

                        beforeEach {
                            homeService.historyCallback?(states, nil)
                        }

                        it("returns the states") {
                            expect(receivedStates) == states
                        }

                        it("does not cache the results") {
                            receivedStates = nil

                            subject.history(nil) { states in
                                receivedStates = states
                            }

                            expect(receivedStates).to(beNil())
                        }
                    }

                    context("when the request fails") {
                        let error = NSError(domain: "", code: 0, userInfo: [:])
                        beforeEach {
                            homeService.historyCallback?([], error)
                        }
                        
                        it("returns an empty array") {
                            expect(receivedStates) == []
                        }
                    }
                }
            }
        }

        describe("getting the watch glance entity") {
            var receivedEntity: State?
            var didReceiveEntity = false

            beforeEach {
                receivedEntity = nil
                didReceiveEntity = false
            }

            context("when not logged in") {
                context("when the watchGlanceEntityId is nil") {
                    beforeEach {
                        subject.watchGlanceEntity {
                            receivedEntity = $0
                            didReceiveEntity = true
                        }
                    }

                    it("makes no request to the service") {
                        expect(homeService.statusCallback).to(beNil())
                    }

                    it("immediately returns nil") {
                        expect(receivedEntity).to(beNil())
                        expect(didReceiveEntity) == true
                    }
                }

                context("when the watchGlanceEntityId is set") {
                    beforeEach {
                        subject.watchGlanceEntityId = "test.state"

                        subject.watchGlanceEntity {
                            receivedEntity = $0
                            didReceiveEntity = true
                        }
                    }

                    it("makes no request to the service") {
                        expect(homeService.statusCallback).to(beNil())
                    }

                    it("immediately returns nil") {
                        expect(receivedEntity).to(beNil())
                        expect(didReceiveEntity) == true
                    }
                }
            }

            context("when logged in") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"
                    homeService.statusCallback = nil
                }

                context("when the watchGlanceEntityId is nil") {
                    beforeEach {
                        subject.watchGlanceEntity {
                            receivedEntity = $0
                            didReceiveEntity = true
                        }
                    }

                    it("makes no request to the service") {
                        expect(homeService.statusCallback).to(beNil())
                    }

                    it("immediately returns nil") {
                        expect(receivedEntity).to(beNil())
                        expect(didReceiveEntity) == true
                    }
                }

                context("when the entity Id is set") {
                    beforeEach {
                        subject.watchGlanceEntityId = "test.state"
                    }

                    context("when we haven't already loaded the state history") {
                        beforeEach {
                            subject.watchGlanceEntity {
                                receivedEntity = $0
                                didReceiveEntity = true
                            }
                        }

                        it("does not immediately return") {
                            expect(didReceiveEntity) == false
                        }

                        it("should kick off a request to the homeService for states") {
                            expect(homeService.statusCallback).toNot(beNil())
                        }

                        context("when the request succeeds and the entity ID is in there") {
                            let df = NSDateFormatter()
                            df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                            let testState = State(attributes: [:], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "testing")

                            let states = [
                                State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                                State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                                State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off"),
                                testState
                            ]
                            
                            beforeEach {
                                homeService.statusCallback?(states, nil)
                            }

                            it("calls back with the status if it's there") {
                                expect(receivedEntity) == testState
                                expect(didReceiveEntity) == true
                            }
                        }

                        context("when the request succeeds and the entity ID is not present") {
                            let df = NSDateFormatter()
                            df.dateFormat = "HH:mm:ss dd-MM-yyyy"


                            let states = [
                                State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                                State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                                State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off"),
                            ]

                            beforeEach {
                                homeService.statusCallback?(states, nil)
                            }

                            it("calls back with the status if it's there") {
                                expect(receivedEntity).to(beNil())
                                expect(didReceiveEntity) == true
                            }
                        }
                    }

                    context("after we have loaded the state history") {
                        let df = NSDateFormatter()
                        df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                        let testState = State(attributes: [:], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "testing")

                        let states = [
                            State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                            State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                            State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off"),
                            testState
                        ]

                        beforeEach {
                            subject.states { _ in }

                            homeService.statusCallback?(states, nil)

                            subject.watchGlanceEntity {
                                receivedEntity = $0
                                didReceiveEntity = true
                            }

                            it("immediately returns the entity") {
                                expect(didReceiveEntity) == true
                                expect(receivedEntity) == testState
                            }
                        }
                    }
                }
            }
        }

        describe("getting the watch complication entity") {
            var receivedEntity: State?
            var didReceiveEntity = false

            beforeEach {
                receivedEntity = nil
                didReceiveEntity = false
            }

            context("when not logged in") {
                context("when the watchComplicationEntityId is nil") {
                    beforeEach {
                        subject.watchComplicationEntity {
                            receivedEntity = $0
                            didReceiveEntity = true
                        }
                    }

                    it("makes no request to the service") {
                        expect(homeService.statusCallback).to(beNil())
                    }

                    it("immediately returns nil") {
                        expect(receivedEntity).to(beNil())
                        expect(didReceiveEntity) == true
                    }
                }

                context("when the watchComplicationEntity is set") {
                    beforeEach {
                        subject.watchComplicationEntityId = "test.state"

                        subject.watchComplicationEntity {
                            receivedEntity = $0
                            didReceiveEntity = true
                        }
                    }

                    it("makes no request to the service") {
                        expect(homeService.statusCallback).to(beNil())
                    }

                    it("immediately returns nil") {
                        expect(receivedEntity).to(beNil())
                        expect(didReceiveEntity) == true
                    }
                }
            }

            context("when logged in") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"
                    homeService.statusCallback = nil
                }

                context("when the watchComplicationEntityId is nil") {
                    beforeEach {
                        subject.watchComplicationEntity {
                            receivedEntity = $0
                            didReceiveEntity = true
                        }
                    }

                    it("makes no request to the service") {
                        expect(homeService.statusCallback).to(beNil())
                    }

                    it("immediately returns nil") {
                        expect(receivedEntity).to(beNil())
                        expect(didReceiveEntity) == true
                    }
                }

                context("when the watchComplicationEntityId is set") {
                    beforeEach {
                        subject.watchComplicationEntityId = "test.state"
                    }

                    context("when we haven't already loaded the state history") {
                        beforeEach {
                            subject.watchComplicationEntity {
                                receivedEntity = $0
                                didReceiveEntity = true
                            }
                        }

                        it("does not immediately return") {
                            expect(didReceiveEntity) == false
                        }

                        it("should kick off a request to the homeService for states") {
                            expect(homeService.statusCallback).toNot(beNil())
                        }

                        context("when the request succeeds and the entity ID is in there") {
                            let df = NSDateFormatter()
                            df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                            let testState = State(attributes: [:], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "testing")

                            let states = [
                                State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                                State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                                State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off"),
                                testState
                            ]

                            beforeEach {
                                homeService.statusCallback?(states, nil)
                            }

                            it("calls back with the status if it's there") {
                                expect(receivedEntity) == testState
                                expect(didReceiveEntity) == true
                            }
                        }

                        context("when the request succeeds and the entity ID is not present") {
                            let df = NSDateFormatter()
                            df.dateFormat = "HH:mm:ss dd-MM-yyyy"


                            let states = [
                                State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                                State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                                State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off"),
                            ]

                            beforeEach {
                                homeService.statusCallback?(states, nil)
                            }

                            it("calls back with the status if it's there") {
                                expect(receivedEntity).to(beNil())
                                expect(didReceiveEntity) == true
                            }
                        }
                    }

                    context("after we have loaded the state history") {
                        let df = NSDateFormatter()
                        df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                        let testState = State(attributes: [:], entityId: "test.state", lastChanged: NSDate(), lastUpdated: NSDate(), state: "testing")

                        let states = [
                            State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                            State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                            State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off"),
                            testState
                        ]

                        beforeEach {
                            subject.states { _ in }
                            
                            homeService.statusCallback?(states, nil)
                            
                            subject.watchComplicationEntity {
                                receivedEntity = $0
                                didReceiveEntity = true
                            }
                            
                            it("immediately returns the entity") {
                                expect(didReceiveEntity) == true
                                expect(receivedEntity) == testState
                            }
                        }
                    }
                }
            }
        }

        describe("getting the visible groups") {
            var receivedStates: [State]?
            var receivedGroups: [Group]?

            beforeEach {
                receivedStates = nil
                receivedGroups = nil
            }

            context("when not logged in") {
                beforeEach {
                    subject.groups(includeScenes: true) {
                        receivedStates = $0
                        receivedGroups = $1
                    }
                }

                it("makes no request to the homeService") {
                    expect(homeService.statusCallback).to(beNil())
                }

                it("calls back with empty arrays") {
                    expect(receivedStates) == []
                    expect(receivedGroups) == []
                }
            }

            context("when logged in") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"
                    homeService.statusCallback = nil

                    subject.groups(includeScenes: true) {
                        receivedStates = $0
                        receivedGroups = $1
                    }
                }

                it("should kick off a request to the homeService for states") {
                    expect(homeService.statusCallback).toNot(beNil())
                }

                context("when the request suceeds") {
                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"


                    let groupState = State(attributes: ["entity_id": ["light.bedroom", "switch.internet_switch"]], entityId: "group.test", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on")
                    let bedroomLight = State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on")
                    let internetSwitch = State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off")


                    let group = Group(groupEntity: groupState, entities: [bedroomLight, internetSwitch])

                    let states = [
                        bedroomLight,
                        State(attributes: ["auto": true, "entity_id": ["light.bedroom"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                        internetSwitch,
                        groupState
                    ]

                    beforeEach {
                        homeService.statusCallback?(states, nil)
                    }

                    it("should call the callback with the states") {
                        expect(receivedStates) == states
                        expect(receivedGroups) == [group]
                    }

                    it("should immediately returns with the states when we request them again") {
                        receivedStates = nil
                        subject.states {newStates in
                            receivedStates = newStates
                        }
                        expect(receivedStates).to(equal(states))
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        let error = NSError(domain: "", code: 0, userInfo: nil)
                        homeService.statusCallback?([], error)
                    }

                    it("should immediately call the callback with no results") {
                        expect(receivedStates).to(equal(Array<State>()))
                    }
                }
            }
        }

        describe("getting states") {
            var receivedStates: [State]? = nil

            beforeEach {
                receivedStates = nil
            }

            context("when not logged in") {
                beforeEach {
                    subject.states { newStates in
                        receivedStates = newStates
                    }
                }

                it("makes no request to the homeservice") {
                    expect(homeService.statusCallback).to(beNil())
                }

                it("returns an empty list") {
                    expect(receivedStates) == []
                }
            }

            context("when logged in") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"
                    homeService.statusCallback = nil

                    subject.states {newStates in
                        receivedStates = newStates
                    }
                }

                it("should not immediately return") {
                    expect(receivedStates).to(beNil())
                }

                it("should kick off a request to the homeService for states") {
                    expect(homeService.statusCallback).toNot(beNil())
                }

                context("asking again for the states") {
                    var oldStatusCallback: (([State], NSError?) -> (Void))?

                    var secondRequestStates: [State]?

                    beforeEach {
                        oldStatusCallback = homeService.statusCallback

                        homeService.statusCallback = nil

                        subject.states { secondRequestStates = $0 }
                    }

                    it("does not make another call to the homeService") {
                        expect(homeService.statusCallback).to(beNil())
                    }

                    it("lets both know when the services get called back") {
                        oldStatusCallback?([], nil)

                        expect(receivedStates) == []
                        expect(secondRequestStates) == []
                    }
                }

                context("when the request suceeds") {
                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                    let states = [
                        State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                        State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                        State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off")
                    ]

                    beforeEach {
                        homeService.statusCallback?(states, nil)
                    }

                    it("should call the callback with the states") {
                        expect(receivedStates).to(equal(states))
                    }

                    it("should immediately returns with the states when we request them again") {
                        receivedStates = nil
                        homeService.statusCallback = nil
                        subject.states {newStates in
                            receivedStates = newStates
                        }
                        expect(receivedStates).to(equal(states))
                        expect(homeService.statusCallback).to(beNil())
                    }

                    it("breaks the cache if it's been more than a minute since the last refresh") {
                        subject.dateOfLastRefresh = NSDate(timeIntervalSinceNow: -301)
                        receivedStates = nil
                        homeService.statusCallback = nil
                        subject.states { newStates in
                            receivedStates = newStates
                        }
                        expect(receivedStates).to(beNil())
                        expect(homeService.statusCallback).toNot(beNil())
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        let error = NSError(domain: "", code: 0, userInfo: nil)
                        homeService.statusCallback?([], error)
                    }
                    
                    it("should immediately call the callback with no results") {
                        expect(receivedStates).to(equal(Array<State>()))
                    }
                }
            }
        }

        describe("getting all the services") {
            var receivedServices: [Service]?

            beforeEach {
                receivedServices = nil
            }

            context("when not logged in") {
                beforeEach {
                    subject.services { services in
                        receivedServices = services
                    }
                }

                it("makes no request") {
                    expect(homeService.servicesCallback).to(beNil())
                }

                it("immediately returns an empty array") {
                    expect(receivedServices) == []
                }
            }

            context("when logged in") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"

                    subject.services { services in
                        receivedServices = services
                    }
                }

                it("does not immediately return") {
                    expect(receivedServices).to(beNil())
                }

                it("kicks off a request to the homeService for services") {
                    expect(homeService.servicesCallback).toNot(beNil())
                }

                context("asking again for the services") {
                    var oldServiceCallback: (([Service], NSError?) -> (Void))?

                    var secondRequestServices: [Service]?

                    beforeEach {
                        oldServiceCallback = homeService.servicesCallback

                        homeService.servicesCallback = nil

                        subject.services { secondRequestServices = $0 }
                    }

                    it("does not make another call to the homeService") {
                        expect(homeService.servicesCallback).to(beNil())
                    }

                    it("lets both know when the services get called back") {
                        oldServiceCallback?([], nil)

                        expect(receivedServices) == []
                        expect(secondRequestServices) == []
                    }
                }

                context("when the request suceeds") {
                    let service1 = Service(domain: "home_assistant", methods: [
                        Service.Method(id: "turn_on", description: "", fields: [:]),
                        Service.Method(id: "turn_off", description: "", fields: [:])
                        ])
                    let service2 = Service(domain: "lights", methods: [
                        Service.Method(id: "turn_on", description: "", fields: [:]),
                        Service.Method(id: "turn_off", description: "", fields: [:])
                        ])

                    let services = [service1, service2]

                    beforeEach {
                        homeService.servicesCallback?(services, nil)
                    }

                    it("should call the callback with the states") {
                        expect(receivedServices).to(equal(services))
                    }
                    it("should immediately returns with the states when we request them again") {
                        receivedServices = nil
                        subject.services {newServices in
                            receivedServices = newServices
                        }
                        expect(receivedServices) == services
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        let error = NSError(domain: "", code: 0, userInfo: nil)
                        homeService.servicesCallback?([], error)
                    }

                    it("should immediately call the callback with no results") {
                        expect(receivedServices?.isEmpty) == true
                    }
                }
            }
        }

        describe("updating a service") {
            let service = Service(domain: "home_assistant", methods: [
                Service.Method(id: "turn_on", description: "", fields: [:]),
                Service.Method(id: "turn_off", description: "", fields: [:])
            ])
            let state = State(attributes: ["entity_id": "lights"], entityId: "group.lights", lastChanged: NSDate(), lastUpdated: NSDate(), state: "off")

            var receivedStates: [State]?
            var receivedError: NSError?

            beforeEach {
                receivedStates = nil
                receivedError = nil
            }

            context("when not logged in") {
                beforeEach {
                    subject.updateService(service, method: "turn_on", onEntity: state) { newStates, error in
                        receivedStates = newStates
                        receivedError = error
                    }
                }

                it("makes no request") {
                    expect(homeService.calledService).to(beNil())
                    expect(homeService.calledServiceDomain).to(beNil())
                    expect(homeService.calledServiceData).to(beNil())
                    expect(homeService.calledServiceCallback).to(beNil())
                }

                it("immediately returns an empty state list with no error") {
                    expect(receivedStates) == []
                    expect(receivedError).to(beNil())
                }
            }

            context("when logged in") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"
                    homeService.statusCallback = nil

                    subject.updateService(service, method: "turn_on", onEntity: state) { newStates, error in
                        receivedStates = newStates
                        receivedError = error
                    }
                }

                it("makes a call into the Service") {
                    expect(homeService.calledService) == "home_assistant"
                    expect(homeService.calledServiceDomain) == "turn_on"
                    expect(homeService.calledServiceData?.keys.count) == 1
                    expect(homeService.calledServiceData?["entity_id"] as? String) == "group.lights"
                    expect(homeService.calledServiceCallback).toNot(beNil())

                    expect(receivedStates).to(beNil())
                    expect(receivedError).to(beNil())
                }

                context("when the call succeeds") {
                    let updatedState = State(attributes: ["entity_id": "lights"], entityId: "group.lights", lastChanged: NSDate(), lastUpdated: NSDate(), state: "on")

                    beforeEach {
                        homeService.calledServiceCallback?([updatedState], nil)
                    }

                    it("tells the receiver") {
                        expect(receivedStates) == [updatedState]
                        expect(receivedError).to(beNil())
                    }

                    it("tries to update the status") {
                        expect(homeService.statusCallback).toNot(beNil())
                    }
                }

                context("when the call fails") {
                    let error = NSError(domain: "com.example.error", code: 20, userInfo: nil)

                    beforeEach {
                        homeService.calledServiceCallback?([], error)
                    }

                    it("tells the receiver") {
                        expect(receivedStates) == []
                        expect(receivedError) == error
                    }

                    it("does not try to update the status") {
                        expect(homeService.statusCallback).to(beNil())
                    }
                }
            }
        }
    }
}
