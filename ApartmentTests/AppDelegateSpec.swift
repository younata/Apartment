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

                it("does not set the credentials for the HomeRepository") {
                    expect(homeRepository.backendPassword).to(beNil())
                    expect(homeRepository.backendURL).to(beNil())
                }

                it("should create a window") {
                    expect(subject.window).toNot(beNil())
                    expect(subject.window?.keyWindow).to(beTruthy())
                }

                it("assigns a LoginViewController as the root view controller") {
                    guard let window = subject!.window else { fail("precondition failed"); return }

                    expect(window.rootViewController).to(beAnInstanceOf(LoginViewController.self))
                }

                context("when the user logs in") {
                    beforeEach {
                        homeRepository.backendPassword = "hello"
                        homeRepository.backendURL = NSURL(string: "https://example.com")

                        for subscriber in homeRepository.subscribers {
                            subscriber.didChangeLoginStatus(true)
                        }
                    }

                    it("changes the assigned rootViewController") {
                        guard let window = subject!.window else { fail("precondition failed"); return }

                        expect(window.rootViewController).to(beAnInstanceOf(UISplitViewController.self))
                        if let sv = window.rootViewController as? UISplitViewController {
                            expect(sv.viewControllers.count) == 1
                            expect(sv.viewControllers.first).to(beAnInstanceOf(UINavigationController.self))
                            if let nc = sv.viewControllers.first as? UINavigationController {
                                expect(nc.viewControllers.first).to(beAnInstanceOf(HomeViewController.self))
                                expect(nc.toolbarHidden) == false
                            }
                        }
                    }
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

                it("sets the credentials for the HomeRepository") {
                    expect(homeRepository.backendPassword) == "password"
                    expect(homeRepository.backendURL) == NSURL(string: "https://example.com")
                }

                it("should create a window") {
                    expect(subject.window).toNot(beNil())
                    expect(subject.window?.keyWindow).to(beTruthy())
                }

                it("creates the logged in view hierarchy") {
                    guard let window = subject!.window else { fail("precondition failed"); return }

                    expect(window.rootViewController).to(beAnInstanceOf(UISplitViewController.self))
                    if let sv = window.rootViewController as? UISplitViewController {
                        expect(sv.viewControllers.count) == 1
                        expect(sv.viewControllers.first).to(beAnInstanceOf(UINavigationController.self))
                        if let nc = sv.viewControllers.first as? UINavigationController {
                            expect(nc.viewControllers.first).to(beAnInstanceOf(HomeViewController.self))
                            expect(nc.toolbarHidden) == false
                        }
                    }
                }

                context("when the user logs out") {
                    beforeEach {
                        homeRepository.backendPassword = nil
                        homeRepository.backendURL = nil

                        for subscriber in homeRepository.subscribers {
                            subscriber.didChangeLoginStatus(false)
                        }
                    }

                    it("assigns a LoginViewController as the root view controller") {
                        guard let window = subject!.window else { fail("precondition failed"); return }

                        expect(window.rootViewController).to(beAnInstanceOf(LoginViewController.self))
                    }
                }
            }

            describe("the navigation controller's delegate") {
                var navigationController: UINavigationController?

                beforeEach {
                    userDefaults.setURL(NSURL(string: "https://example.com"), forKey: "backendURL")
                    userDefaults.setObject("password", forKey: "backendPassword")

                    subject.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: ["test": true])

                    if let window = subject!.window {
                        if let sv = window.rootViewController as? UISplitViewController {
                            navigationController = sv.viewControllers.first as? UINavigationController
                        }
                    }
                }

                it("hides the toolbar when something other than the home view controller is shown") {
                    navigationController?.delegate?.navigationController?(navigationController!, willShowViewController: UIViewController(), animated: false)

                    expect(navigationController?.toolbarHidden) == true

                    navigationController?.popViewControllerAnimated(false)
                    navigationController?.delegate?.navigationController?(navigationController!, willShowViewController: navigationController!.viewControllers.first!, animated: false)

                    expect(navigationController?.toolbarHidden) == false
                }
            }
        }
    }
}
