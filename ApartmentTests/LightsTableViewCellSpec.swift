import Quick
import Nimble
import UIKit
import Alamofire

class LightsTableViewCellSpec: QuickSpec {
    override func spec() {
        var subject : LightsTableViewCell! = nil

        beforeEach {
            subject = LightsTableViewCell(style: .Default, reuseIdentifier: nil)
        }

        describe("Setting bulb to a bulb object") {
            context("that is on") {
                let bulb = Bulb(id: 2, name: "Hue Lamp 1", on: true, brightness: 194, hue: 15051,
                    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                    effect: .none, reachable: true, alert: "none")

                beforeEach {
                    subject.bulb = bulb
                }

                it("should set the nameLabel") {
                    expect(subject.nameLabel.text).to(equal("Hue Lamp 1"))
                }

                it("should set the background color") {
                    let color = UIColor(hue: 15051.0 / 65535.0, saturation: 137.0 / 254.0, brightness: 1.0, alpha: 1.0)
                    expect(subject.contentView.backgroundColor).to(equal(color))
                }

                it("should set the rippleLayerColor") {
                    let color = UIColor(hue: 15051.0 / 65535.0, saturation: 137.0 / 254.0, brightness: 1.0, alpha: 1.0).darkerColor()
                    expect(subject.rippleLayerColor).to(equal(color))
                }

                it("should enable the brightnessSlider and set it correctly") {
                    expect(subject.brightnessSlider.enabled).to(beTruthy())
                    expect(subject.brightnessSlider.value).to(equal(194.0 / 254.0))
                }
            }

            context("that is off") {
                let bulb = Bulb(id: 2, name: "Hue Lamp 1", on: false, brightness: 194, hue: 15051,
                    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                    effect: .none, reachable: true, alert: "none")

                beforeEach {
                    subject.bulb = bulb
                }

                it("should set the nameLabel") {
                    expect(subject.nameLabel.text).to(equal("Hue Lamp 1"))
                }

                it("should set the background color") {
                    let color = UIColor(hue: 15051.0 / 65535.0, saturation: 137.0 / 254.0, brightness: 1.0, alpha: 1.0)
                    expect(subject.contentView.backgroundColor).to(equal(color))
                }

                it("should set the rippleLayerColor") {
                    let color = UIColor(hue: 15051.0 / 65535.0, saturation: 137.0 / 254.0, brightness: 1.0, alpha: 1.0).darkerColor()
                    expect(subject.rippleLayerColor).to(equal(color))
                }

                it("should enable the brightnessSlider and set it to zero") {
                    expect(subject.brightnessSlider.enabled).to(beTruthy())
                    expect(subject.brightnessSlider.value).to(equal(0.0))
                }
            }

            context("that is unreachable") {
                let bulb = Bulb(id: 2, name: "Hue Lamp 1", on: true, brightness: 194, hue: 15051,
                    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                    effect: .none, reachable: false, alert: "none")

                beforeEach {
                    subject.bulb = bulb
                }

                it("should set the nameLabel") {
                    expect(subject.nameLabel.text).to(equal("Hue Lamp 1"))
                }

                it("should set the background color") {
                    let color = UIColor(hue: 15051.0 / 65535.0, saturation: 137.0 / 254.0, brightness: 1.0, alpha: 1.0)
                    expect(subject.contentView.backgroundColor).to(equal(color))
                }

                it("should set the rippleLayerColor") {
                    let color = UIColor(hue: 15051.0 / 65535.0, saturation: 137.0 / 254.0, brightness: 1.0, alpha: 1.0).darkerColor()
                    expect(subject.rippleLayerColor).to(equal(color))
                }

                it("should disable the brightness slider") {
                    expect(subject.brightnessSlider.enabled).to(beFalsy())
                    expect(subject.brightnessSlider.value).to(equal(194.0 / 254.0))
                }
            }
        }

        describe("Changing the brightness slider") {
            var service : FakeLightsService! = nil

            beforeEach {
                service = FakeLightsService(backendURL: "", manager: Manager.sharedInstance)
                subject.lightsService = service
            }

            context("on a bulb that is on") {
                beforeEach {
                    subject.bulb = Bulb(id: 2, name: "Hue Lamp 1", on: true, brightness: 194, hue: 15051,
                        saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                        effect: .none, reachable: true, alert: "none")
                }

                context("to another on value") {
                    beforeEach {
                        subject.brightnessSlider.value = 0.2
                        subject.brightnessSlider.sendActionsForControlEvents(.ValueChanged)
                    }

                    it("should make a call to the service") {
                        let called = service.bulbsUpdateHandler[2]
                        expect(called).toNot(beNil())
                        if let (attributes, handler) = called {
                            let newBulb = Bulb(id: 2, name: "Hue Lamp 1", on: true, brightness: 51, hue: 15051,
                                saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                                effect: .none, reachable: true, alert: "none")
                            handler(newBulb, nil)

                            expect(attributes.count).to(equal(1))

                            let brightness: Int? = attributes["bri"] as? Int
                            expect(brightness).toNot(beNil())
                            if let bri = brightness {
                                expect(bri).to(equal(51))
                            }
                        }
                    }
                }

                context("to 0") {
                    beforeEach {
                        subject.brightnessSlider.value = 0.0
                        subject.brightnessSlider.sendActionsForControlEvents(.ValueChanged)
                    }

                    it("should make a call to the service") {
                        let called = service.bulbsUpdateHandler[2]
                        expect(called).toNot(beNil())
                        if let (attributes, handler) = called {
                            let newBulb = Bulb(id: 2, name: "Hue Lamp 1", on: true, brightness: 51, hue: 15051,
                                saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                                effect: .none, reachable: true, alert: "none")
                            handler(newBulb, nil)

                            expect(attributes.count).to(equal(1))

                            let on: Bool? = attributes["on"] as? Bool
                            expect(on).to(beFalsy())
                        }
                    }
                }
            }

            context("on a bulb that is off") {
                beforeEach {
                    subject.bulb = Bulb(id: 2, name: "Hue Lamp 1", on: false, brightness: 194, hue: 15051,
                        saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                        effect: .none, reachable: true, alert: "none")

                    subject.brightnessSlider.value = 0.2
                    subject.brightnessSlider.sendActionsForControlEvents(.ValueChanged)
                }

                it("should make a call to the service") {
                    let called = service.bulbsUpdateHandler[2]
                    expect(called).toNot(beNil())
                    if let (attributes, handler) = called {
                        let newBulb = Bulb(id: 2, name: "Hue Lamp 1", on: true, brightness: 51, hue: 15051,
                            saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                            effect: .none, reachable: true, alert: "none")
                        handler(newBulb, nil)

                        expect(attributes.count).to(equal(2))

                        let brightness: Int? = attributes["bri"] as? Int
                        expect(brightness).toNot(beNil())
                        if let bri = brightness {
                            expect(bri).to(equal(51))
                        }

                        let on: Bool? = attributes["on"] as? Bool
                        expect(on).to(beTruthy())
                    }
                }
            }
        }
    }
}
