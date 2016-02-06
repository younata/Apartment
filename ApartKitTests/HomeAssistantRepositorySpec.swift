import Quick
import Nimble
import WatchConnectivity
@testable import ApartKit

private class FakeHomeRepositorySubscriber: NSObject, HomeRepositorySubscriber {
    var states: [State]? = nil
    private func didUpdateStates(states: [State]) {
        self.states = states
    }
}

class HomeAssistantRepositorySpec: QuickSpec {
    override func spec() {
        var subject: HomeAssistantRepository! = nil
        var homeService: FakeHomeAssistantService! = nil
        var subscriber: FakeHomeRepositorySubscriber! = nil

        beforeEach {
            homeService = FakeHomeAssistantService()

            subscriber = FakeHomeRepositorySubscriber()

            subject = HomeAssistantRepository(homeService: homeService)

            subject.addSubscriber(subscriber)
        }

        it("returns nil as the backendURL until it is set") {
            expect(subject.backendURL).to(beNil())
        }

        it("returns nil as the backendPassword until it is set") {
            expect(subject.backendPassword).to(beNil())
        }

        describe("testing if the api is available") {
            var apiIsAvailable: Bool?
            beforeEach {
                apiIsAvailable = nil
            }

            it("immediately returns false if the backendURL is not set") {
                subject.backendPassword = "hello"
                subject.apiAvailable { apiIsAvailable = $0 }

                expect(apiIsAvailable) == false
                expect(homeService.apiAvailableCallback).to(beNil())
            }

            it("immediately returns false if the backendPassword is not set") {
                subject.backendURL = NSURL(string: "https://example.com")
                subject.apiAvailable { apiIsAvailable = $0 }

                expect(apiIsAvailable) == false
                expect(homeService.apiAvailableCallback).to(beNil())
            }

            context("when both the backendURL and the backendPassword are set") {
                beforeEach {
                    subject.backendURL = NSURL(string: "https://example.com")
                    subject.backendPassword = "hello"
                    subject.apiAvailable { apiIsAvailable = $0 }
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

        describe("updating states") {
            var receivedStates: [State]? = nil
            beforeEach {
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

                it("should inform any subscribers") {
                    expect(subscriber.states).to(equal(states))
                }

                it("should immediately returns with the states when we request them again, without informing subscribers") {
                    receivedStates = nil
                    subscriber.states = nil
                    subject.states {newStates in
                        receivedStates = newStates
                    }
                    expect(receivedStates).to(equal(states))

                    expect(subscriber.states).to(beNil())
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

                it("does not inform any subscribers") {
                    expect(subscriber.states).to(beNil())
                }
            }
        }

        describe("getting all the services") {
            var receivedServices: [Service]?
            beforeEach {
                receivedServices = nil

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
                receivedError = nil;

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
