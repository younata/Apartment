import Quick
import Nimble
import UIKit
import MapKit
import Ra
import Apartment
import ApartKit

class MapViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: MapViewController!

        let tracker = State(attributes: ["battery": 75, "friendly_name": "my phone", "gps_accuracy": 65, "latitude": 37, "longitude": 122], entityId: "device_tracker.my_phone", lastChanged: NSDate(), lastUpdated: NSDate(), state: "home")
        let zone = State(attributes: [
            "friendly_name": "Home",
            "icon": "mdi:home",
            "latitude": 37,
            "longitude": -122.2,
            "radius": 100
            ], entityId: "zone.home", lastChanged: NSDate(), lastUpdated: NSDate(), state: "zoning")

        beforeEach {
            subject = MapViewController()

            subject.view.layoutIfNeeded()
        }

        context("when configured with a device tracker") {
            beforeEach {
                subject.configure([tracker])
            }

            it("configures the title with the display name of the tracker") {
                expect(subject.title) == "my phone"
            }

            it("shows a pin annotation for that device") {
                expect(subject.map.annotations.count) == 1
                expect(subject.map.annotations.first is MKPointAnnotation) == true
                if let pin = subject.map.annotations.first as? MKPointAnnotation {
                    expect(pin.title) == "my phone"
                    expect(pin.subtitle) == "home"
                }
            }
        }

        context("when configured with a zone") {
            beforeEach {
                subject.configure([zone])
            }

            it("configures the title with the display name of the tracker") {
                expect(subject.title) == "Home"
            }

            it("shows some other kind of annotation for that device") {
                expect(subject.map.annotations.count) == 1
            }
        }

        context("when configured with multiple trackers, zones, or both") {
            beforeEach {
                subject.configure([tracker, zone])
            }

            it("configures the title with just 'Map'") {
                expect(subject.title) == "Map"
            }

            it("zooms out to show all of the annotations") {
                expect(subject.map.annotations.count) == 2
            }
        }
    }
}
