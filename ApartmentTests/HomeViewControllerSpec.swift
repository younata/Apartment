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
        var lightsService: FakeLightsService! = nil
        var lockService: FakeLockService! = nil
        var navigationController: UINavigationController! = nil
        var appModule: SpecApplicationModule! = nil

        beforeEach {
            injector = Ra.Injector()

            appModule = SpecApplicationModule()
            appModule.configureInjector(injector)

            lightsService = FakeLightsService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")
            injector.bind(kLightsService, to: lightsService)

            lockService = FakeLockService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")
            injector.bind(kLockService, to: lockService)

            subject = injector.create(HomeViewController.self) as! HomeViewController
            navigationController = UINavigationController(rootViewController: subject)
        }

        describe("on view load") {
            beforeEach {
                expect(subject.view).toNot(beNil())
            }

            describe("on view will appear") {
                beforeEach {
                    subject.viewWillAppear(false)
                }

                it("should hide the navigation bar") {
                    expect(navigationController.navigationBarHidden).to(beTruthy())
                }
            }

            describe("Getting all bulbs") {
                it("should ask for all bulbs") {
                    expect(lightsService.didReceiveAllBulbs).to(beTruthy())
                }

                describe("on all bulbs return") {
                    let bulbs : [Bulb] = [Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                        saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                        effect: .none, reachable: true, alert: "none")]
                    beforeEach {
                        lightsService.allBulbsHandler(bulbs, nil)
                    }

                    it("should set the bulbs value") {
                        expect(subject.bulbs).to(equal(bulbs))
                    }
                }

                describe("on all bulbs error") {
                    let errorString = "Unknown error"
                    var window : UIWindow? = nil
                    beforeEach {
                        window = UIWindow()
                        window?.makeKeyAndVisible()
                        window?.rootViewController = subject
                        let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString])
                        lightsService.allBulbsHandler(nil, error)
                        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 1))
                    }

                    it("show an error") {
                        expect(subject.presentedViewController).to(beAnInstanceOf(UIAlertController.self))
                        if let alert = subject.presentedViewController as? UIAlertController {
                            expect(alert.title).to(equal("Error getting lights"))
                            expect(alert.message).to(equal(errorString))
                            expect(alert.actions.count).to(equal(1))
                            let dismiss = alert.actions[0]
                            expect(dismiss.title).to(equal("Ok"))
                        }
                    }
                }
            }

            describe("Getting all the locks") {
                it("should ask for all locks") {
                    expect(lockService.didReceiveAllLocks).to(beTruthy())
                }

                describe("on all locks return") {
                    let locks : [Lock] = [Lock(id: "", locked: Lock.LockStatus.Locked)]
                    beforeEach {
                        lockService.allLocksHandler(locks, nil)
                    }

                    it("should set the locks value") {
                        expect(subject.locks).to(equal(locks))
                    }
                }

                describe("on all locks error") {
                    let errorString = "Unknown error"
                    var window : UIWindow? = nil
                    beforeEach {
                        window = UIWindow()
                        window?.makeKeyAndVisible()
                        window?.rootViewController = subject
                        let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString])
                        lockService.allLocksHandler(nil, error)
                        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 1))
                    }

                    it("show an error") {
                        expect(subject.presentedViewController).to(beAnInstanceOf(UIAlertController.self))
                        if let alert = subject.presentedViewController as? UIAlertController {
                            expect(alert.title).to(equal("Error getting locks"))
                            expect(alert.message).to(equal(errorString))
                            expect(alert.actions.count).to(equal(1))
                            let dismiss = alert.actions[0]
                            expect(dismiss.title).to(equal("Ok"))
                        }
                    }
                }
            }
        }
    }
}
