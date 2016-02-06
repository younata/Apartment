import UIKit
import MapKit
import Ra
import ApartKit
import PureLayout

public class MapViewController: UIViewController, MKMapViewDelegate {
    public private(set) var devices = [State]() {
        didSet {
            for device in devices {
                let pin = MKPointAnnotation()
                pin.coordinate = device.trackerCoordinate!
                pin.title = device.displayName
                pin.subtitle = device.state.desnake
                self.map.addAnnotation(pin)
            }
        }
    }
    public private(set) var zones = [State]() {
        didSet {
            for zone in zones {
                let circle = MKCircle(centerCoordinate: zone.zoneCoordinate!, radius: Double(zone.zoneRadius ?? 100))
                circle.title = zone.displayName
                self.map.addOverlay(circle)
            }
        }
    }

    public let map = MKMapView(forAutoLayout: ())

    public func configure(states: [State]) {
        self.map.removeAnnotations(self.map.annotations)
        self.map.removeOverlays(self.map.overlays)

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
        self.map.delegate = self
    }

    public func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.fillColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.8)
            renderer.lineWidth = 1
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}