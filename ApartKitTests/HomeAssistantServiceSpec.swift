import Quick
import Nimble
@testable import ApartKit

class HomeAssistantServiceSpec: QuickSpec {
    override func spec() {
        var subject: HomeAssistantService! = nil
        var urlSession: FakeURLSession! = nil
        var mainQueue: FakeOperationQueue! = nil
        var receivedError: NSError? = nil

        beforeEach {
            receivedError = nil

            urlSession = FakeURLSession()
            mainQueue = FakeOperationQueue()

            subject = HomeAssistantService(urlSession: urlSession, mainQueue: mainQueue)

            subject.baseURL = NSURL(string: "http://localhost.com/api/")
            subject.apiKey = "blah"
        }


        sharedExamples("a properly configured request") {(sharedContext: SharedExampleContext) in
            it("should make a url request") {
                expect(urlSession.lastURLRequest).toNot(beNil())
                let urlString = sharedContext()["url"] as! String
                let url = NSURL(string: urlString)
                expect(urlSession.lastURLRequest?.URL).to(equal(url))
                let expectedMethod = sharedContext()["method"] as? String ?? "GET"
                expect(urlSession.lastURLRequest?.HTTPMethod).to(equal(expectedMethod))
            }

            it("should have the authentication token correctly configured") {
                let headers = urlSession.lastURLRequest?.allHTTPHeaderFields
                expect(headers?["x-ha-access"]).to(equal("blah"))
            }

            it("should notify the caller on network error") {
                let error = NSError(domain: "", code: 0, userInfo: [:])
                urlSession.lastCompletionHandler(nil, nil, error)
                mainQueue.runNextOperation()

                expect(receivedError).to(beIdenticalTo(error))
            }

            it("should notify the caller if the response code is 400-level") {
                let response = NSHTTPURLResponse(URL: NSURL(string: "http://google.com")!, statusCode: 400, HTTPVersion: "", headerFields: [:])
                urlSession.lastCompletionHandler(nil, response, nil)
                mainQueue.runNextOperation()

                expect(receivedError).toNot(beNil())
            }
        }

        describe("checking if the api is available") {
            var apiIsAvailable: Bool? = nil

            beforeEach {
                apiIsAvailable = nil
                subject.apiAvailable { apiIsAvailable = $0 }
            }

            it("makes a url request") {
                expect(urlSession.lastURLRequest).toNot(beNil())
                expect(urlSession.lastURLRequest?.URL) == NSURL(string: "http://localhost.com/api/")
                expect(urlSession.lastURLRequest?.HTTPMethod) == "GET"
            }

            it("should have the authentication token correctly configured") {
                let headers = urlSession.lastURLRequest?.allHTTPHeaderFields
                expect(headers?["x-ha-access"]).to(equal("blah"))
            }

            it("returns false on network error") {
                let error = NSError(domain: "", code: 0, userInfo: [:])
                urlSession.lastCompletionHandler(nil, nil, error)
                mainQueue.runNextOperation()

                expect(apiIsAvailable) == false
            }

            it("returns false if the response code is 400-level") {
                let response = NSHTTPURLResponse(URL: NSURL(string: "http://google.com")!, statusCode: 400, HTTPVersion: "", headerFields: [:])
                urlSession.lastCompletionHandler(nil, response, nil)
                mainQueue.runNextOperation()

                expect(apiIsAvailable) == false
            }

            it("returns true on success") {
                let data = NSString(string: "{\"message\": \"API running.\"}").dataUsingEncoding(NSUTF8StringEncoding)
                urlSession.lastCompletionHandler(data, nil, nil)
                mainQueue.runNextOperation()

                expect(apiIsAvailable) == true
            }
        }

        describe("events") {
            describe("Getting all the events") {
                var receivedEvents = Array<Event>()

                beforeEach {
                    subject.events {events, error in
                        receivedEvents = events
                        receivedError = error
                    }
                }

                itBehavesLike("a properly configured request") {
                    ["url": "http://localhost.com/api/events"]
                }

                it("returns all the events on success") {
                    let data = NSString(string: "[{\"event\":\"time_changed\",\"listener_count\":4},{\"event\":\"homeassistant_stop\",\"listener_count\":3},{\"event\":\"*\",\"listener_count\":1}]").dataUsingEncoding(NSUTF8StringEncoding)
                    urlSession.lastCompletionHandler(data, nil, nil)
                    mainQueue.runNextOperation()

                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                    let events = [
                        Event(name: "time_changed", listenerCount: 4),
                        Event(name: "homeassistant_stop", listenerCount: 3),
                        Event(name: "*", listenerCount: 1)
                    ]

                    expect(receivedEvents).to(equal(events))
                    expect(receivedError).to(beNil())
                }
            }

            describe("Firing an event") {
                var receivedMessage: String? = nil

                beforeEach {
                    subject.fireEvent("state_changed", data: nil) {message, error in
                        receivedMessage = message
                        receivedError = error
                    }
                }

                itBehavesLike("a properly configured request") {
                    [
                        "url": "http://localhost.com/api/events/state_changed",
                        "method": "POST"
                    ]
                }

                it("should add the data if it's there") {
                    expect(urlSession.lastURLRequest?.HTTPBody).to(beNil())

                    subject.fireEvent("state_changed", data: ["next_rising": "18:00:31 29-10-2013"]) {_ in}

                    expect(urlSession.lastURLRequest?.HTTPBody).toNot(beNil())
                    if let receivedData = urlSession.lastURLRequest?.HTTPBody,
                        receivedDataString = NSString(data: receivedData, encoding: NSUTF8StringEncoding) {
                            expect(receivedDataString).to(equal("{\"next_rising\":\"18:00:31 29-10-2013\"}"))
                    }
                }

                it("should report the message on success") {
                    let data = NSString(string: "{\"message\":\"Event state_changed fired.\"}").dataUsingEncoding(NSUTF8StringEncoding)
                    urlSession.lastCompletionHandler(data, nil, nil)
                    mainQueue.runNextOperation()

                    expect(receivedMessage).to(equal("Event state_changed fired."))
                    expect(receivedError).to(beNil())
                }
            }
        }

        describe("services") {
            describe("getting all the services") {
                var receivedServices = Array<Service>()
                beforeEach {
                    subject.services {services, error in
                        receivedServices = services
                        receivedError = error
                    }
                }

                itBehavesLike("a properly configured request") {
                    ["url": "http://localhost.com/api/services"]
                }

                it("returns all the services on success") {
                    let data = NSString(string: "[{\"domain\":\"switch\",\"services\":[\"turn_off\",\"turn_on\"]},{\"domain\":\"light\",\"services\":[\"turn_off\",\"turn_on\"]}]").dataUsingEncoding(NSUTF8StringEncoding)
                    urlSession.lastCompletionHandler(data, nil, nil)
                    mainQueue.runNextOperation()

                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                    let services = [
                        Service(domain: "switch", services: ["turn_off", "turn_on"]),
                        Service(domain: "light", services: ["turn_off", "turn_on"])
                    ]

                    expect(receivedServices).to(equal(services))
                    expect(receivedError).to(beNil())
                }
            }

            describe("calling a service") {
                var receivedStates = Array<State>()

                beforeEach {
                    subject.callService("turn_on", onDomain: "light", data: nil) {states, error in
                        receivedStates = states
                        receivedError = error
                    }
                }

                itBehavesLike("a properly configured request") {
                    [
                        "url": "http://localhost.com/api/services/light/turn_on",
                        "method": "POST"
                    ]
                }

                it("should add the data if it's there") {
                    expect(urlSession.lastURLRequest?.HTTPBody).to(beNil())

                    subject.callService("", onDomain: "", data: ["next_rising": "18:00:31 29-10-2013"]) {_ in}

                    expect(urlSession.lastURLRequest?.HTTPBody).toNot(beNil())
                    if let receivedData = urlSession.lastURLRequest?.HTTPBody,
                        receivedDataString = NSString(data: receivedData, encoding: NSUTF8StringEncoding) {
                            expect(receivedDataString).to(equal("{\"next_rising\":\"18:00:31 29-10-2013\"}"))
                    }
                }

                it("returns all the updated states on success") {
                    let data = NSString(string: "[{\"attributes\":{\"brightness\":254,\"friendly_name\":\"Bedroom\",\"xy_color\":[0.4499,0.408]},\"entity_id\":\"light.bedroom\",\"last_changed\":\"17:31:56 28-09-2015\",\"last_updated\":\"19:18:51 28-09-2015\",\"state\":\"on\"},{\"attributes\":{\"auto\":true,\"entity_id\":[\"light.bedroom\",\"light.hue_lamp\",\"light.living_room\"],\"friendly_name\":\"all lights\"},\"entity_id\":\"group.all_lights\",\"last_changed\":\"17:31:56 28-09-2015\",\"last_updated\":\"19:18:51 28-09-2015\",\"state\":\"on\"},{\"attributes\":{\"friendly_name\":\"internet switch\"},\"entity_id\":\"switch.internet_switch\",\"last_changed\":\"17:29:56 28-09-2015\",\"last_updated\":\"19:18:51 28-09-2015\",\"state\":\"off\"}]").dataUsingEncoding(NSUTF8StringEncoding)
                    urlSession.lastCompletionHandler(data, nil, nil)
                    mainQueue.runNextOperation()

                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                    let states = [
                        State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                        State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                        State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off")
                    ]

                    expect(receivedStates).to(equal(states))
                    expect(receivedError).to(beNil())
                }
            }
        }

        describe("states") {
            describe("Getting the current states of everything") {
                var receivedStates = Array<State>()
                beforeEach {
                    subject.status {states, error in
                        receivedStates = states
                        receivedError = error
                    }
                }

                itBehavesLike("a properly configured request") {
                    ["url": "http://localhost.com/api/states"]
                }

                it("returns all the current states on success") {
                    let data = NSString(string: "[{\"attributes\":{\"brightness\":254,\"friendly_name\":\"Bedroom\",\"xy_color\":[0.4499,0.408]},\"entity_id\":\"light.bedroom\",\"last_changed\":\"17:31:56 28-09-2015\",\"last_updated\":\"19:18:51 28-09-2015\",\"state\":\"on\"},{\"attributes\":{\"auto\":true,\"entity_id\":[\"light.bedroom\",\"light.hue_lamp\",\"light.living_room\"],\"friendly_name\":\"all lights\"},\"entity_id\":\"group.all_lights\",\"last_changed\":\"17:31:56 28-09-2015\",\"last_updated\":\"19:18:51 28-09-2015\",\"state\":\"on\"},{\"attributes\":{\"friendly_name\":\"internet switch\"},\"entity_id\":\"switch.internet_switch\",\"last_changed\":\"17:29:56 28-09-2015\",\"last_updated\":\"19:18:51 28-09-2015\",\"state\":\"off\"}]").dataUsingEncoding(NSUTF8StringEncoding)
                    urlSession.lastCompletionHandler(data, nil, nil)
                    mainQueue.runNextOperation()

                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                    let states = [
                        State(attributes: ["brightness": 254, "friendly_name": "Bedroom", "xy_color": [0.4499, 0.408]], entityId: "light.bedroom", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "on"),
                        State(attributes: ["auto": true, "entity_id": ["light.bedroom", "light.hue_lamp", "light.living_room"], "friendly_name": "all_lights"], entityId: "group.all_lights", lastChanged: df.dateFromString("17:31:56 28-09-2015")!, lastUpdated: df.dateFromString("17:31:56 28-09-2015")!, state: "on"),
                        State(attributes: ["friendly_name": "internet switch"], entityId: "switch.internet_switch", lastChanged: df.dateFromString("17:29:56 28-09-2015")!, lastUpdated: df.dateFromString("19:18:51 28-09-2015")!, state: "off")
                    ]

                    expect(receivedStates).to(equal(states))
                    expect(receivedError).to(beNil())
                }
            }

            describe("Getting the current state of an entity") {
                var receivedState: State? = nil
                beforeEach {
                    subject.status("sun.sun") {state, error in
                        receivedError = error
                        receivedState = state
                    }
                }

                itBehavesLike("a properly configured request") {
                    ["url": "http://localhost.com/api/states/sun.sun"]
                }

                it("returns the current state for that state on success") {
                    let data = NSString(string: "{\"attributes\":{\"next_rising\":\"07:04:15 29-10-2013\",\"next_setting\":\"18:00:31 29-10-2013\"},\"entity_id\":\"sun.sun\",\"last_changed\":\"23:24:33 28-10-2013\",\"last_updated\":\"23:24:33 28-10-2015\",\"state\":\"below_horizon\"}").dataUsingEncoding(NSUTF8StringEncoding)

                    urlSession.lastCompletionHandler(data, nil, nil)
                    mainQueue.runNextOperation()

                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                    let expectedState = State(attributes: ["next_rising": "07:04:15 29-10-2013", "next_setting": "18:00:31 29-10-2013"], entityId: "sun.sun", lastChanged: df.dateFromString("23:24:33 28-10-2013")!, lastUpdated: df.dateFromString("23:24:33 28-10-2015")!, state: "below_horizon")

                    expect(receivedState).to(equal(expectedState))
                    expect(receivedError).to(beNil())
                }
            }

            describe("Changing the current state of an entity") {
                var receivedState: State? = nil
                beforeEach {
                    subject.update("sun.sun", newStatus: "below_horizon") {state, error in
                        receivedState = state
                        receivedError = error
                    }
                }

                itBehavesLike("a properly configured request") {
                    [
                        "url": "http://localhost.com/api/states/sun.sun",
                        "method": "POST"
                    ]
                }

                it("returns the new state for that state on success") {
                    let data = NSString(string: "{\"attributes\":{\"next_rising\":\"07:04:15 29-10-2013\",\"next_setting\":\"18:00:31 29-10-2013\"},\"entity_id\":\"sun.sun\",\"last_changed\":\"23:24:33 28-10-2013\",\"last_updated\":\"23:24:33 28-10-2015\",\"state\":\"below_horizon\"}").dataUsingEncoding(NSUTF8StringEncoding)

                    urlSession.lastCompletionHandler(data, nil, nil)
                    mainQueue.runNextOperation()

                    let df = NSDateFormatter()
                    df.dateFormat = "HH:mm:ss dd-MM-yyyy"

                    let expectedState = State(attributes: ["next_rising": "07:04:15 29-10-2013", "next_setting": "18:00:31 29-10-2013"], entityId: "sun.sun", lastChanged: df.dateFromString("23:24:33 28-10-2013")!, lastUpdated: df.dateFromString("23:24:33 28-10-2015")!, state: "below_horizon")

                    expect(receivedState).to(equal(expectedState))
                    expect(receivedError).to(beNil())
                }
            }
        }
    }
}
