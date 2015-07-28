import Quick
import Nimble
@testable import ApartKit

class LockServiceSpec: QuickSpec {
    override func spec() {
        var subject: LockService! = nil
        var urlSession: FakeURLSession! = nil

        beforeEach {
            urlSession = FakeURLSession()

            subject = LockService(backendURL: "https://localhost.com/", urlSession: urlSession, authenticationToken: "HelloWorld")
        }

        var receivedError: NSError? = nil

        sharedExamples("a properly configured lock request") {(sharedContext: SharedExampleContext) in
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

        let singleLockString = "{\"uuid\":\"1234567890abcdef\",\"locked\":true}"

        describe("Getting all the locks") {
            var locksArray: [Lock] = []
            var receivedLocks: [Lock]? = nil

            beforeEach {
                receivedLocks = nil
                do {
                    let dictionary = try NSJSONSerialization.JSONObjectWithData(NSString(string: singleLockString).dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
                    let lock = Lock(json: dictionary)

                    locksArray = [lock, lock]
                } catch {}

                subject.allLocks {result, error in
                    receivedLocks = result
                    receivedError = error
                }
            }

            itBehavesLike("a properly configured lock request") { ["url": "https://localhost.com/api/v1/locks"] }

            it("returns all the locks on success") {
                let data = NSString(string: "[{\"uuid\":\"1234567890abcdef\",\"locked\":true},{\"uuid\":\"1234567890abcdef\",\"locked\":true}]").dataUsingEncoding(NSUTF8StringEncoding)!
                urlSession.lastCompletionHandler(data, nil, nil)

                expect(receivedLocks).to(equal(locksArray))
                expect(receivedError).to(beNil())
            }
        }

        describe("Getting a single lock") {
            var lock: Lock! = nil
            var receivedLock: Lock? = nil

            beforeEach {
                let dictionary = try! NSJSONSerialization.JSONObjectWithData(NSString(string: singleLockString).dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String: AnyObject]
                lock = Lock(json: dictionary)

                subject.lock(lock.id) {result, error in
                    receivedError = error
                    receivedLock = result
                }
            }

            itBehavesLike("a properly configured lock request") { ["url": "https://localhost.com/api/v1/locks/1234567890abcdef"] }

            it("should return the bulb") {
                let data = NSString(string: singleLockString).dataUsingEncoding(NSUTF8StringEncoding)
                urlSession.lastCompletionHandler(data, nil, nil)

                expect(receivedLock).to(equal(lock))
                expect(receivedError).to(beNil())
            }
        }

        describe("Updating a single bulb") {
            let lock = Lock(json: ["uuid": "1234567890abcdef", "locked": true])

            var receivedLock: Lock? = nil

            beforeEach {
                subject.update_lock(lock, to_lock: .Unlocked) {result, error in
                    receivedLock = result
                    receivedError = error
                }
            }

            itBehavesLike("a properly configured lock request") { ["url": "https://localhost.com/api/v1/locks/1234567890abcdef?locked=false", "method": "PUT"] }

            it("updates the lock and returns a new (updated) lock") {
                let json = NSString(string: "{\"uuid\":\"1234567890abcdef\",\"locked\":false}").dataUsingEncoding(NSUTF8StringEncoding)
                urlSession.lastCompletionHandler(json, nil, nil)

                let updatedLock = Lock(json: ["uuid": "1234567890abcdef", "locked": false])

                expect(receivedLock).to(equal(updatedLock))
                expect(receivedError).to(beNil())
            }
        }
    }
}