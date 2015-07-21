import Quick
import Nimble
import UIKit
import Apartment

class TouchResponder: NSObject {
    var wasCalled = false
    func willRespond() {
        wasCalled = true
    }
}

class ColorPickerSpec: QuickSpec {
    override func spec() {
        var subject : ColorPicker! = nil

        beforeEach {
            subject = ColorPicker(frame: CGRectMake(0, 0, 100, 100))
        }

        describe("Setting hue") {
            it("sets the selectedPoint's x value") {
                subject.hue = 0.4
                expect(subject.selectedPoint.x).to(equal(40.0))
            }
        }

        describe("Setting saturation") {
            it("sets the selectedPoint's y value") {
                subject.saturation = 0.6
                expect(subject.selectedPoint.y).to(equal(60.0))
            }
        }

        describe("Touching") {
            var touchResponder : TouchResponder! = nil

            beforeEach {
                touchResponder = TouchResponder()

                subject.addTarget(touchResponder, action: "willRespond", forControlEvents: .ValueChanged)
            }

            describe("outside the bounds") {
                beforeEach {
                    let touch = FakeTouch()

                    touch.location = CGPointMake(-20, 130)

                    subject.touchesBegan(Set([touch]), withEvent: UIEvent())
                }

                it("should clamp to bounds") {
                    expect(subject.selectedPoint).to(equal(CGPointMake(0, 100)))
                }
            }

            describe("Initial touches") {
                beforeEach {
                    let touch = FakeTouch()

                    touch.location = CGPointMake(20, 30)

                    subject.touchesBegan(Set([touch]), withEvent: UIEvent())
                }

                it("should change the hue/saturation") {
                    expect(subject.hue).to(equal(0.2))
                    expect(subject.saturation).to(equal(0.3))
                }

                it("should send notifications to the target/action") {
                    expect(touchResponder.wasCalled).to(beTruthy())
                }
            }

            describe("Moving touch") {
                beforeEach {
                    let touch = FakeTouch()

                    touch.location = CGPointMake(40, 60)

                    subject.touchesMoved(Set([touch]), withEvent: UIEvent())
                }

                it("should change the hue/saturation") {
                    expect(subject.hue).to(equal(0.4))
                    expect(subject.saturation).to(equal(0.6))
                }

                it("should send notifications to the target/action") {
                    expect(touchResponder.wasCalled).to(beTruthy())
                }
            }

            describe("Finishing touch") {
                beforeEach {
                    let touch = FakeTouch()

                    touch.location = CGPointMake(10, 50)

                    subject.touchesEnded(Set([touch]), withEvent: UIEvent())
                }

                it("should change the hue/saturation") {
                    expect(subject.hue).to(equal(0.1))
                    expect(subject.saturation).to(equal(0.5))
                }

                it("should send notifications to the target/action") {
                    expect(touchResponder.wasCalled).to(beTruthy())
                }
            }
        }
    }
}
