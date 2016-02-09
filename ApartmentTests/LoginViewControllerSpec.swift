import Quick
import Nimble
import UIKit
import Ra
import Apartment
import ApartKit
import UIKit_PivotalSpecHelper

class LoginViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: LoginViewController!
        var injector: Injector!
        var homeRepository: FakeHomeRepository!
        var userDefaults: FakeUserDefaults!

        beforeEach {
            injector = Injector()

            homeRepository = FakeHomeRepository()
            injector.bind(HomeRepository.self, toInstance: homeRepository)

            userDefaults = FakeUserDefaults()
            injector.bind(NSUserDefaults.self, toInstance: userDefaults)

            subject = injector.create(LoginViewController)!
        }

        it("initially makes the 'login' button disabled") {
            expect(subject.loginButton.enabled) == false
        }

        it("hides the error label") {
            expect(subject.errorLabel.hidden) == true
        }

        func changeTextInTextField(textField: UITextField, string: String) {
            textField.text = string
            textField.delegate?.textField?(textField, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: "")
        }

        it("enables 'login' button only after the url and password are set") {
            changeTextInTextField(subject.urlField, string: "https://example.com")
            expect(subject.loginButton.enabled) == false

            changeTextInTextField(subject.urlField, string: "")
            changeTextInTextField(subject.passwordField, string: "password")
            expect(subject.loginButton.enabled) == false

            changeTextInTextField(subject.urlField, string: "https://example.com")
            changeTextInTextField(subject.passwordField, string: "password")
            expect(subject.loginButton.enabled) == true

            changeTextInTextField(subject.passwordField, string: "")
            expect(subject.loginButton.enabled) == false
        }

        describe("tapping 'login'") {
            beforeEach {
                changeTextInTextField(subject.urlField, string: "https://example.com")
                changeTextInTextField(subject.passwordField, string: "password")

                subject.loginButton.sendActionsForControlEvents(.TouchUpInside)
            }

            it("updates the home repository credentials") {
                expect(homeRepository.backendURL) == NSURL(string: "https://example.com")
                expect(homeRepository.backendPassword) == "password"
            }

            it("checks if the api is up and that our credentials are good") {
                expect(homeRepository.apiAvailableCallback).toNot(beNil())
            }

            it("disables the login button so while we wait for the network") {
                expect(subject.loginButton.enabled) == false
            }

            context("and if our credentials are good") {
                beforeEach {
                    homeRepository.apiAvailableCallback?(true)
                }

                it("saves the url and password to user defaults") {
                    expect(userDefaults.URLForKey("backendURL")) == NSURL(string: "https://example.com")
                    expect(userDefaults.stringForKey("backendPassword")) == "password"
                }
            }

            context("and if our credentials are bad") {
                beforeEach {
                    homeRepository.apiAvailableCallback?(false)
                }

                it("re-enables the login button") {
                    expect(subject.loginButton.enabled) == true
                }

                it("tells the user that they dun goof'd") {
                    expect(subject.errorLabel.hidden) == false
                }

                context("when the user tries again") {
                    beforeEach {
                        subject.loginButton.sendActionsForControlEvents(.TouchUpInside)
                    }

                    it("hides the error label again") {
                        expect(subject.errorLabel.hidden) == true
                    }
                }
            }
        }
    }
}