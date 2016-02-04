import Quick
import Nimble
import UIKit
import ApartKit
import Apartment

class AppDelegateSpec: QuickSpec {
    override func spec() {
        var subject: AppDelegate!
        var userDefaults: FakeUserDefaults!
        var homeRepository: FakeHomeRepository!

        beforeEach {
            subject = AppDelegate()

            userDefaults = FakeUserDefaults()
            subject.anInjector.bind(NSUserDefaults.self, toInstance: userDefaults)

            homeRepository = FakeHomeRepository()
            subject.anInjector.bind(HomeRepository.self, toInstance: homeRepository)
        }

        describe("-application:didFinishLaunchingWithOptions:") {
            context("if we have not logged in yet") {
                beforeEach {
                    subject.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: ["test": true])
                }

                afterEach {
                    subject.window?.hidden = true
                }

                it("should create a window") {
                    expect(subject.window).toNot(beNil())
                    expect(subject.window?.keyWindow).to(beTruthy())
                }

                it("should assign a rootViewController") {
                    if let window = subject!.window {
                        expect(window.rootViewController).to(beAnInstanceOf(UINavigationController.self))
                        if let nc = window.rootViewController as? UINavigationController {
                            expect(nc.viewControllers.first).to(beAnInstanceOf(HomeViewController.self))
                        }
                    }
                }

                it("does not set the credentials for the HomeRepository") {
                    expect(homeRepository.backendPassword).to(beNil())
                    expect(homeRepository.backendURL).to(beNil())
                }
            }

            context("if we have logged in before") {
                beforeEach {
                    userDefaults.setURL(NSURL(string: "https://example.com"), forKey: "backendURL")
                    userDefaults.setObject("password", forKey: "backendPassword")

                    subject.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: ["test": true])
                }

                afterEach {
                    subject.window?.hidden = true
                }

                it("should create a window") {
                    expect(subject.window).toNot(beNil())
                    expect(subject.window?.keyWindow).to(beTruthy())
                }

                it("should assign a rootViewController") {
                    if let window = subject!.window {
                        expect(window.rootViewController).to(beAnInstanceOf(UINavigationController.self))
                        if let nc = window.rootViewController as? UINavigationController {
                            expect(nc.viewControllers.first).to(beAnInstanceOf(HomeViewController.self))
                        }
                    }
                }

                it("sets the credentials for the HomeRepository") {
                    expect(homeRepository.backendPassword) == "password"
                    expect(homeRepository.backendURL) == NSURL(string: "https://example.com")
                }
            }
        }
    }
}
