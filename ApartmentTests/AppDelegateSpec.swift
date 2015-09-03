import Quick
import Nimble
import UIKit
import Apartment

class AppDelegateSpec: QuickSpec {
    override func spec() {
        var subject : AppDelegate! = nil

        beforeEach {
            subject = AppDelegate()
        }

        describe("-application:didFinishLaunchingWithOptions:") {
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
        }
    }
}
