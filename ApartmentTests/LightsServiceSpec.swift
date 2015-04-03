import Quick
import Nimble
import Ra
import MockHTTP
import Alamofire

class LightsServiceSpec: QuickSpec {
    override func spec() {
        var subject : LightsService! = nil
        var injector : Ra.Injector! = nil

        beforeEach {
            injector = Ra.Injector()

            SpecApplicationModule().configureInjector(injector)

            subject = injector.create(kLightsService) as! LightsService
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

        describe("Getting all the bulbs") {
            var bulbsArray : [Bulb] = []
            beforeEach {
                let singleBulbString = "{\"id\":3,\"changes\":{},\"name\":\"Hue Lamp 2\",\"on\":false,\"bri\":194,\"hue\":15051,\"sat\":137,\"xy\":[0.4,0.4],\"ct\":359,\"transitiontime\":10,\"colormode\":\"ct\",\"effect\":\"none\",\"reachable\":true,\"alert\":\"none\"}"
                let dictionary = NSJSONSerialization.JSONObjectWithData(NSString(string: singleBulbString).dataUsingEncoding(NSUTF8StringEncoding)!, options: .allZeros, error: nil) as! [String: AnyObject]
                let bulb = Bulb(json: dictionary)!

                bulbsArray = [bulb, bulb]

                let urlResponse = MockHTTP.URLResponse(json: [dictionary, dictionary], statusCode: 200, headers: [:])

                MockHTTP.registerURL(NSURL(string: "http://localhost:3000/api/v1/bulbs")!, withResponse: urlResponse)
            }
            it("return all the bulbs") {
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

                MockHTTP.registerURL(NSURL(string: "http://localhost:3000/api/v1/bulbs")!, withResponse: urlResponse)

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
    }
}
