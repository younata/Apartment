import Quick
import Nimble
@testable import ApartKit

class FakeStatusSubscriber: StatusSubscriber {
    var receivedBulbs: [Bulb]? = nil
    func didUpdateBulbs(bulbs: [Bulb]) {
        receivedBulbs = bulbs
    }

    var receivedLocks: [Lock]? = nil
    func didUpdateLocks(locks: [Lock]) {
        receivedLocks = locks
    }

    init() {}
}

class StatusRepositorySpec: QuickSpec {
    override func spec() {
        var subject: StatusRepository! = nil
        var lightsService: FakeLightsService! = nil
        var lockService: FakeLockService! = nil
        var statusSubscriber: FakeStatusSubscriber! = nil

        beforeEach {
            subject = StatusRepository()
            lightsService = FakeLightsService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")
            lockService = FakeLockService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")
            subject.lightsService = lightsService
            subject.lockService = lockService
            statusSubscriber = FakeStatusSubscriber()
        }

        describe("updating the authentication token") {
            beforeEach {
                subject.authenticationToken = "hello"
            }

            it("should update the authentication token of the lights service") {
                expect(lightsService.authenticationToken).to(equal("hello"))
            }

            it("should update the authentication token of the lock service") {
                expect(lockService.authenticationToken).to(equal("hello"))
            }
        }

        describe("updating the backendURL") {
            beforeEach {
                subject.backendURL = "hello"
            }

            it("should update the backend url of the lights service") {
                expect(lightsService.backendURL).to(equal("hello"))
            }

            it("should update the backend url of the lock service") {
                expect(lockService.backendURL).to(equal("hello"))
            }
        }

        describe("bulbs") {
            sharedExamples("making a request for bulbs") {(sharedContext: SharedExampleContext) in
                it("should make a request to the lights service") {
                    expect(lightsService.didReceiveAllBulbs).to(beTruthy())
                }

                context("making another request while the first one is in limbo") {
                    beforeEach {
                        lightsService.didReceiveAllBulbs = false
                        subject.updateBulbs()
                    }

                    it("should not make another request to the service") {
                        expect(lightsService.didReceiveAllBulbs).to(beFalsy())
                    }

                    it("should inform subscribers when the first call resolves") {
                        lightsService.allBulbsHandler([], nil)
                        expect(statusSubscriber.receivedBulbs).to(equal([]))
                    }
                }

                context("when the service comes back with bulbs") {
                    let expectedBulbs = [Bulb(id: 1, name: "Hue Lamp 1", on: false, brightness: 194, hue: 15051,
                        saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                        effect: .none, reachable: true, alert: "none"),
                                         Bulb(id: 2, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                        saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                        effect: .none, reachable: true, alert: "none")]
                    beforeEach {
                        lightsService.allBulbsHandler(expectedBulbs, nil)
                    }

                    it("should inform any subscribers with the bulbs") {
                        expect(statusSubscriber.receivedBulbs).to(equal(expectedBulbs))
                    }

                    describe("making another request") {
                        beforeEach {
                            statusSubscriber.receivedBulbs = nil
                            lightsService.didReceiveAllBulbs = false

                            subject.updateBulbs()
                        }

                        it("should not make another request") {
                            expect(lightsService.didReceiveAllBulbs).to(beFalsy())
                        }

                        it("should inform any subscribers") {
                            expect(statusSubscriber.receivedBulbs).to(equal(expectedBulbs))
                        }
                    }
                }

                context("when the service comes back with no bulbs") {
                    beforeEach {
                        lightsService.allBulbsHandler(nil, nil)
                    }

                    it("should call the completion handler with an empty array") {
                        expect(statusSubscriber.receivedBulbs).to(equal([]))
                    }
                }
            }

            context("adding a new subscriber when a request hasn't been made yet") {
                beforeEach {
                    subject.addSubscriber(statusSubscriber)
                }

                itBehavesLike("making a request for bulbs")
            }

            context("adding a new subscriber when a request was last made 5 minutes ago") {
                let cachedBulbs = [Bulb(id: 0, name: "Hue Lamp 1", on: false, brightness: 194, hue: 15051,
                    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                    effect: .none, reachable: true, alert: "none"),
                                   Bulb(id: 1, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                    effect: .none, reachable: true, alert: "none")]
                beforeEach {
                    subject.bulbs = cachedBulbs
                    subject.lastRetreivedBulbs = NSDate(timeIntervalSinceNow: -301)
                    subject.addSubscriber(statusSubscriber)
                }

                itBehavesLike("making a request for bulbs")
            }
        }

        describe("locks") {
            sharedExamples("making a request for locks") {(sharedContext: SharedExampleContext) in
                it("should make a request to the locks service") {
                    expect(lockService.didReceiveAllLocks).to(beTruthy())
                }

                context("making another request while the first one is in limbo") {
                    beforeEach {
                        lockService.didReceiveAllLocks = false
                        subject.updateLocks()
                    }

                    it("should not make another request to the service") {
                        expect(lockService.didReceiveAllLocks).to(beFalsy())
                    }

                    it("should inform subscribers when the first call resolves") {
                        lockService.allLocksHandler([], nil)
                        expect(statusSubscriber.receivedLocks).to(equal([]))
                    }
                }

                context("when the service comes back with locks") {
                    let expectedLocks = [Lock(id: "abc", locked: .Locked, name: ""),
                        Lock(id: "def", locked: .Unlocked, name: "")]
                    beforeEach {
                        lockService.allLocksHandler(expectedLocks, nil)
                    }

                    it("should inform any subscribers with the bulbs") {
                        expect(statusSubscriber.receivedLocks).to(equal(expectedLocks))
                    }

                    describe("making another request") {
                        beforeEach {
                            statusSubscriber.receivedLocks = nil
                            lockService.didReceiveAllLocks = false

                            subject.updateLocks()
                        }

                        it("should not make another request") {
                            expect(lockService.didReceiveAllLocks).to(beFalsy())
                        }

                        it("should inform any subscribers") {
                            expect(statusSubscriber.receivedLocks).to(equal(expectedLocks))
                        }
                    }
                }

                context("when the service comes back with no locks") {
                    beforeEach {
                        lockService.allLocksHandler(nil, nil)
                    }

                    it("should call the completion handler with an empty array") {
                        expect(statusSubscriber.receivedLocks).to(equal([]))
                    }
                }
            }

            context("adding a new subscriber when a request hasn't been made yet") {
                beforeEach {
                    subject.addSubscriber(statusSubscriber)
                }

                itBehavesLike("making a request for locks")
            }

            context("adding a new subscriber when a request was last made 5 minutes ago") {
                let cachedLocks = [Lock(id: "abc", locked: .Locked, name: ""),
                    Lock(id: "def", locked: .Unlocked, name: "")]
                beforeEach {
                    subject.locks = cachedLocks
                    subject.lastRetreivedLocks = NSDate(timeIntervalSinceNow: -301)
                    subject.addSubscriber(statusSubscriber)
                }

                itBehavesLike("making a request for locks")
            }
        }
    }
}
