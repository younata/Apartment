import Quick
import Nimble
@testable import ApartKit

class LightsServiceSpec: QuickSpec {
    override func spec() {
        var subject: LightsService! = nil
        var urlSession: FakeURLSession! = nil

        beforeEach {
            urlSession = FakeURLSession()

            subject = LightsService(backendURL: "https://localhost.com/", urlSession: urlSession, authenticationToken: "HelloWorld")
        }

        var receivedError: NSError? = nil

        sharedExamples("a properly configured light request") {(sharedContext: SharedExampleContext) in
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
                expect(headers?["Authentication"]).to(equal("Token token=HelloWorld"))
            }

            it("should notify the caller on network error") {
                let error = NSError(domain: "", code: 0, userInfo: [:])
                urlSession.lastCompletionHandler(nil, nil, error)
                expect(receivedError).to(beIdenticalTo(error))
            }

            it("should notify the caller if the response code is not 200-level") {
                let response = NSHTTPURLResponse(URL: NSURL(string: "http://google.com")!, statusCode: 400, HTTPVersion: "", headerFields: [:])
                urlSession.lastCompletionHandler(nil, response, nil)
                expect(receivedError).toNot(beNil())
            }
        }

        let singleBulbString = "{\"id\":3,\"changes\":{},\"name\":\"Hue Lamp 2\",\"on\":false,\"bri\":194,\"hue\":15051,\"sat\":137,\"xy\":[0.4,0.4],\"ct\":359,\"transitiontime\":10,\"colormode\":\"ct\",\"effect\":\"none\",\"reachable\":true,\"alert\":\"none\"}"

        describe("Getting all the bulbs") {
            var bulbsArray: [Bulb] = []
            var receivedBulbs: [Bulb]? = nil
            beforeEach {
                do {
                    let dictionary = try NSJSONSerialization.JSONObjectWithData(NSString(string: singleBulbString).dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
                    let bulb = Bulb(json: dictionary)!

                    bulbsArray = [bulb, bulb]
                } catch {}

                subject.allBulbs {result, error in
                    receivedBulbs = result
                    receivedError = error
                }
            }

            itBehavesLike("a properly configured light request") { ["url": "https://localhost.com/api/v1/bulbs"] }

            it("return all the bulbs on success") {
                let multiBulbData = try! NSJSONSerialization.dataWithJSONObject(bulbsArray.map({$0.json}), options: NSJSONWritingOptions(rawValue: 0))
                urlSession.lastCompletionHandler(multiBulbData, nil, nil)

                expect(receivedBulbs).to(equal(bulbsArray))
                expect(receivedError).to(beNil())
            }
        }

        describe("Getting a single bulb") {
            var bulb: Bulb! = nil
            var receivedBulb: Bulb? = nil

            beforeEach {
                let dictionary = try! NSJSONSerialization.JSONObjectWithData(NSString(string: singleBulbString).dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
                bulb = Bulb(json: dictionary)!
            }

            context("By id number") {
                beforeEach {
                    subject.bulb(3) {result, error in
                        receivedError = error
                        receivedBulb = result
                    }
                }

                itBehavesLike("a properly configured light request") { ["url": "https://localhost.com/api/v1/bulbs/3"] }

                it("should return the bulb") {
                    let data = (singleBulbString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                    urlSession.lastCompletionHandler(data, nil, nil)
                    
                    expect(receivedBulb).to(equal(bulb))
                    expect(receivedError).to(beNil())
                }
            }

            context("By name") {
                beforeEach {
                    subject.bulb("Hue Lamp 2") {result, error in
                        receivedError = error
                        receivedBulb = result
                    }
                }

                itBehavesLike("a properly configured light request") { ["url": "https://localhost.com/api/v1/bulbs/Hue%20Lamp%202"] }

                it("should return the bulb") {
                    let data = (singleBulbString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                    urlSession.lastCompletionHandler(data, nil, nil)

                    expect(receivedBulb).to(equal(bulb))
                    expect(receivedError).to(beNil())
                }
            }
        }

        describe("Updating a single bulb") {
            let bulb = Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                effect: .none, reachable: true, alert: "none")
            let updatedBulb = Bulb(id: 3, name: "Hue Lamp 2", on: true, brightness: 194, hue: 15051,
                saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                effect: .none, reachable: true, alert: "none")

            var receivedBulb: Bulb? = nil

            beforeEach {
                let attributes : [String: AnyObject] = ["on": true, "colorMode": Bulb.ColorMode.hue.rawValue]
                subject.update(bulb, attributes: attributes) {result, error in
                    receivedBulb = result
                    receivedError = error
                }
            }

            itBehavesLike("a properly configured light request") { ["url": "https://localhost.com/api/v1/bulbs/3?colorMode=hs&on=1", "method": "PUT"] }

            it("updates the bulb and returns a new (updated) bulb") {
                let json = try! NSJSONSerialization.dataWithJSONObject(updatedBulb.json, options: NSJSONWritingOptions(rawValue: 0))
                urlSession.lastCompletionHandler(json, nil, nil)

                expect(receivedBulb).to(equal(updatedBulb))
                expect(receivedError).to(beNil())
            }
        }
    }
}
