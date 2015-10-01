import Quick
import Nimble
import WatchConnectivity
import ApartKit

private class HomeRepoSubscriber: NSObject, HomeRepositorySubscriber {
    var states: [State]? = nil
    private func didUpdateStates(states: [State]) {
        self.states = states
    }
}

class HomeAssistantRepositorySpec: QuickSpec {
    override func spec() {
        var subject: HomeAssistantRepository! = nil
        var homeService: FakeHomeAssistantService! = nil
        var subscriber: HomeRepoSubscriber! = nil

        beforeEach {
            homeService = FakeHomeAssistantService()

            subscriber = HomeRepoSubscriber()

            subject = HomeAssistantRepository(homeService: homeService)

            subject.addSubscriber(subscriber)
        }

        describe("updating states") {
            var receivedStates: [State]? = nil
            describe("when we don't have any prior knowledge of the states") {
                beforeEach {
                    subject.states(false) {newStates in
                        receivedStates = newStates
                    }
                }

                it("should not immediately return") {
                    expect(receivedStates).to(beNil())
                }

                it("should kick off a request to the homeService for states") {
                    expect(homeService.statusCallback).toNot(beNil())
                }

                describe("when the request returns successfully") {
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
                        subject.states(false) {newStates in
                            receivedStates = newStates
                        }
                        expect(receivedStates).to(equal(states))

                        expect(subscriber.states).to(beNil())
                    }

                    describe("when we force an update") {
                        beforeEach {
                            receivedStates = nil
                            homeService.statusCallback = nil
                            subject.states(true) {newStates in
                                receivedStates = newStates
                            }
                        }

                        it("should not immediately return") {
                            expect(receivedStates).to(beNil())
                        }

                        it("should kick off a request to the homeService for states") {
                            expect(homeService.statusCallback).toNot(beNil())
                        }

                        // we know how it goes...
                    }
                }

                describe("when the request fails") {
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
    }
}
