import UIKit
import MapKit
import Ra
import ApartKit
import PureLayout

public class MapViewController: UIViewController, MKMapViewDelegate {
    public private(set) var devices = [State]() {
        didSet {
            for device in devices {
                guard let coordinate = device.trackerCoordinate else { continue }
                let pin = MKPointAnnotation()
                pin.coordinate = coordinate
                pin.title = device.displayName
                pin.subtitle = device.state.desnake
                self.map.addAnnotation(pin)
            }
        }
    }
    public private(set) var zones = [State]() {
        didSet {
            for zone in zones {
                guard let coordinate = zone.zoneCoordinate else { continue }
                let circle = MKCircle(centerCoordinate: coordinate, radius: Double(zone.zoneRadius ?? 100))
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

        let coordinates = self.map.annotations.map({ $0.coordinate }) + self.map.overlays.map({ $0.coordinate })
        self.zoomToCoordinates(coordinates)
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

    private func zoomToCoordinates(coordinates: [CLLocationCoordinate2D]) {
        let amount = Double(coordinates.count)
        let summed = coordinates.reduce((0.0, 0.0)) {
            return ($0.0 + $1.latitude, $0.1 + $1.longitude)
        }
        let center = CLLocationCoordinate2D(latitude: summed.0 / amount, longitude: summed.1 / amount)

        var latitudeDelta: CLLocationDegrees = 0
        var longitudeDelta: CLLocationDegrees = 0

        for coordinate in coordinates {
            latitudeDelta = max(fabs(center.latitude - coordinate.latitude), latitudeDelta)
            longitudeDelta = max(fabs(center.longitude - coordinate.longitude), longitudeDelta)
        }

        latitudeDelta = max(latitudeDelta * 1.75, 1e-3)
        longitudeDelta = max(longitudeDelta * 1.75, 1e-3)

        self.map.setRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)), animated: true)
    }
}