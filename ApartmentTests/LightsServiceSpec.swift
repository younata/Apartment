import Quick
import Nimble
import Ra
import MockHTTP
import Alamofire

class LightsServiceSpec: QuickSpec {
    override func spec() {
        var subject : LightsService! = nil
        var injector : Ra.Injector! = nil
        var appModule : SpecApplicationModule! = nil

        beforeEach {
            injector = Ra.Injector()

            appModule = SpecApplicationModule()
            appModule.configureInjector(injector)

            subject = injector.create(kLightsService) as! LightsService
        }

        afterEach {
            appModule.afterTests()
        }

        describe("headers") {
            it("should have the authentication token correctly configured") {
                expect(subject.manager.session.configuration.HTTPAdditionalHeaders).toNot(beNil())
                if let headers = subject.manager.session.configuration.HTTPAdditionalHeaders {
                    expect(headers["Authentication"] is String).to(beTruthy())
                    if let authenticationHeader = headers["Authentication"] as? String {
                        expect(authenticationHeader).to(equal("Token token=HelloWorld"))
                    }
                }
            }
        }

        let singleBulbString = "{\"id\":3,\"changes\":{},\"name\":\"Hue Lamp 2\",\"on\":false,\"bri\":194,\"hue\":15051,\"sat\":137,\"xy\":[0.4,0.4],\"ct\":359,\"transitiontime\":10,\"colormode\":\"ct\",\"effect\":\"none\",\"reachable\":true,\"alert\":\"none\"}"

        describe("Getting all the bulbs") {
            var bulbsArray : [Bulb] = []
            beforeEach {
                let dictionary = NSJSONSerialization.JSONObjectWithData(NSString(string: singleBulbString).dataUsingEncoding(NSUTF8StringEncoding)!, options: .allZeros, error: nil) as! [String: AnyObject]
                let bulb = Bulb(json: dictionary)!

                bulbsArray = [bulb, bulb]
            }

            it("return all the bulbs") {
                let dictionary = NSJSONSerialization.JSONObjectWithData(NSString(string: singleBulbString).dataUsingEncoding(NSUTF8StringEncoding)!, options: .allZeros, error: nil) as! [String: AnyObject]
                let urlResponse = MockHTTP.URLResponse(json: [dictionary, dictionary], statusCode: 200, headers: [:])
                MockHTTP.registerResponse(urlResponse, forURL: NSURL(string: "http://localhost:3000/api/v1/bulbs")!)

                let expectation = self.expectationWithDescription("bulbs")
                subject.allBulbs {(result, error) in
                    expectation.fulfill()
                    expect(error).to(beNil())
                    expect(result).to(equal(bulbsArray))
                }

                self.waitForExpectationsWithTimeout(1) {(error) in
                    expect(error).to(beNil())
                }
            }

            it("should notify the user on error") {
                let failed = NSError(domain: "LightsServiceSpec", code: 1, userInfo: nil)
                let urlResponse = MockHTTP.URLResponse(error: failed, statusCode: 400, headers: [:])

                MockHTTP.registerResponse(urlResponse, forURL: NSURL(string: "http://localhost:3000/api/v1/bulbs")!)

                let expectation = self.expectationWithDescription("bulbs")
                subject.allBulbs {(result, error) in
                    expectation.fulfill()
                    expect(error).to(equal(failed))
                    expect(result).to(beNil())
                }

                self.waitForExpectationsWithTimeout(1) {(error) in
                    expect(error).to(beNil())
                }
            }
        }

        describe("Getting a single bulb") {
            var bulb: Bulb! = nil
            var foundResponse: MockHTTP.URLResponse! = nil
            var errorResponse: MockHTTP.URLResponse! = nil
            let error: NSError = NSError(domain: "LightsServiceSpec", code: 2, userInfo: nil)

            beforeEach {
                let dictionary = NSJSONSerialization.JSONObjectWithData(NSString(string: singleBulbString).dataUsingEncoding(NSUTF8StringEncoding)!, options: .allZeros, error: nil) as! [String: AnyObject]
                bulb = Bulb(json: dictionary)!

                foundResponse = MockHTTP.URLResponse(json: dictionary, statusCode: 200, headers: [:])
                errorResponse = MockHTTP.URLResponse(error: error, statusCode: 404, headers: [:])
            }

            context("By id number") {
                let url = NSURL(string: "http://localhost:3000/api/v1/bulb/3")!

                it("should return the bulb") {
                    MockHTTP.registerResponse(foundResponse, forURL: url)

                    let expectation = self.expectationWithDescription("bulbs")
                    subject.bulb(3) {(result, err) in
                        expectation.fulfill()
                        expect(err).to(beNil())
                        expect(result).to(equal(bulb))
                    }

                    self.waitForExpectationsWithTimeout(1) {(error) in
                        expect(error).to(beNil())
                    }
                }

                it("should notify the user on error") {
                    MockHTTP.registerResponse(errorResponse, forURL: url)

                    let expectation = self.expectationWithDescription("bulbs")
                    subject.bulb(3) {(result, err) in
                        expectation.fulfill()
                        expect(err).to(equal(error))
                        expect(result).to(beNil())
                    }

                    self.waitForExpectationsWithTimeout(1) {(error) in
                        expect(error).to(beNil())
                    }
                }
            }

            context("By name") {
                let url = NSURL(string: "http://localhost:3000/api/v1/bulb/Hue%20Lamp%202")!

                it("should return the bulb") {
                    MockHTTP.registerResponse(foundResponse, forURL: url)

                    let expectation = self.expectationWithDescription("bulbs")
                    subject.bulb("Hue Lamp 2") {(result, err) in
                        expectation.fulfill()
                        expect(err).to(beNil())
                        expect(result).to(equal(bulb))
                    }

                    self.waitForExpectationsWithTimeout(1) {(error) in
                        expect(error).to(beNil())
                    }
                }

                it("should notify the user on error") {
                    MockHTTP.registerResponse(errorResponse, forURL: url)

                    let expectation = self.expectationWithDescription("bulbs")
                    subject.bulb("Hue Lamp 2") {(result, err) in
                        expectation.fulfill()
                        expect(err).to(equal(error))
                        expect(result).to(beNil())
                    }

                    self.waitForExpectationsWithTimeout(1) {(error) in
                        expect(error).to(beNil())
                    }
                }
            }
        }

        describe("Updating a single bulb") {
            var bulb: Bulb! = nil
            beforeEach {
                bulb = Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                            saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                            effect: .none, reachable: true, alert: "none")
            }

            it("updates the bulb and returns a new (updated) bulb") {
                let updatedBulb = Bulb(id: 3, name: "Hue Lamp 2", on: true, brightness: 194, hue: 15051,
                    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                    effect: .none, reachable: true, alert: "none")
                let urlResponse = MockHTTP.URLResponse(json: updatedBulb.json, statusCode: 200, headers: [:])

                MockHTTP.registerResponse(urlResponse) {request in
                    if !(request.URLString.hasPrefix("http://localhost:3000/api/v1/bulb/3") && request.HTTPMethod == "PUT") {
                        return false
                    }
                    if let query = request.URL?.query {
                        println("\(query)")
                        return query == "colorMode=hs&on=1"
                    }
                    return false
                }

                let expectation = self.expectationWithDescription("bulbs")
                let attributes : [String: AnyObject] = ["on": true, "colorMode": Bulb.ColorMode.hue.rawValue]
                subject.update(bulb, attributes: attributes) {bulb, error in
                    expectation.fulfill()
                    expect(error).to(beNil())
                    expect(bulb).to(equal(updatedBulb))
                }
                self.waitForExpectationsWithTimeout(1) {error in
                    expect(error).to(beNil())
                }
            }
        }
    }
}
