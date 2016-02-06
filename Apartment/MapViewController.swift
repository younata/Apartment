import UIKit
import MapKit
import Ra
import ApartKit
import PureLayout

public class MapViewController: UIViewController {
    public private(set) var devices = [State]() {
        didSet {
            for device in devices {
                let pin = MKPointAnnotation()
                pin.coordinate = device.trackerCoordinate!
                pin.title = device.displayName
                pin.subtitle = device.state
                self.map.addAnnotation(pin)
            }
        }
    }
    public private(set) var zones = [State]() {
        didSet {
            for zone in zones {
                let pin = MKPointAnnotation() // todo: not a point annotation
                pin.coordinate = zone.zoneCoordinate!
                self.map.addAnnotation(pin)
            }
        }
    }

    public let map = MKMapView(forAutoLayout: ())

    public func configure(states: [State]) {
        self.map.removeAnnotations(self.map.annotations)

        let states = states.filter { $0.isDeviceTracker || $0.isZone }
        self.devices = states.filter { $0.isDeviceTracker }
        self.zones = states.filter { $0.isZone }

        if states.count == 1, let state = states.first {
            self.title = state.displayName
        } else {
            self.title = "Map"
        }

        self.map.showAnnotations(self.map.annotations, animated: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.map)
        self.map.autoPinEdgesToSuperviewEdges()
    }
}