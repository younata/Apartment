import Quick
import Nimble
import MaterialKit
import UIKit

class LightsCardSpec: QuickSpec {
    override func spec() {
        var subject: LightsCard! = nil

        beforeEach {
            subject = LightsCard()
            let bulb1 = Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                effect: .none, reachable: true, alert: "none")

            let bulb2 = Bulb(id: 2, name: "Hue Lamp 1", on: false, brightness: 194, hue: 15051,
                saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
                effect: .none, reachable: true, alert: "none")
            let bulbs = [bulb1, bulb2]
            subject.configure(bulbs, delegate: nil)
        }

        describe("tableView") {
            it("have a cell for each bulb it's configured with") {
                expect(subject.tableView.numberOfRowsInSection(0)).to(equal(2))
            }

            describe("cells") {
                it("should give the cell a title based on the bulb's name") {
                    let cell1 = subject.tableView(subject.tableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0))
                    expect(cell1.textLabel?.text).to(equal("Hue Lamp 2"))

                    let cell2 = subject.tableView(subject.tableView, cellForRowAtIndexPath:NSIndexPath(forRow: 1, inSection: 0))
                    expect(cell2.textLabel?.text).to(equal("Hue Lamp 1"))
                }
                it("should color the cell's background color based on the bulb's current color") {
                    let cell1 = subject.tableView(subject.tableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0))
                    var color = UIColor(mired: 359)
                    expect(cell1.contentView.backgroundColor).to(equal(color))

                    let cell2 = subject.tableView(subject.tableView, cellForRowAtIndexPath:NSIndexPath(forRow: 1, inSection: 0))
                    let hue = CGFloat(15051.0 / 65535.0)
                    let sat = CGFloat(137.0 / 254.0)
                    let bri = CGFloat(194.0 / 254.0)
                    color = UIColor(hue: hue, saturation: sat, brightness: bri, alpha: 1.0)
                    expect(cell2.contentView.backgroundColor).to(equal(color))
                }
                it("should give the cell's ripple layer color based on a darker version of the bulb's current color") {
                    let cell1 = subject.tableView(subject.tableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0)) as? MKTableViewCell
                    expect(cell1).toNot(beNil())
                    if let cell1 = cell1 {
                        let color = UIColor(mired: 359).darkerColor()
                        expect(cell1.rippleLayerColor).to(equal(color))
                    }

                    let cell2 = subject.tableView(subject.tableView, cellForRowAtIndexPath:NSIndexPath(forRow: 1, inSection: 0)) as? MKTableViewCell
                    expect(cell2).toNot(beNil())
                    if let cell2 = cell2 {
                        let hue = CGFloat(15051.0 / 65535.0)
                        let sat = CGFloat(137.0 / 254.0)
                        let bri = CGFloat(194.0 / 254.0)
                        let color = UIColor(hue: hue, saturation: sat, brightness: bri, alpha: 1.0).darkerColor()
                        expect(cell2.rippleLayerColor).to(equal(color))
                    }
                }
            }
        }
    }
}
