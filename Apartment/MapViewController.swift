import UIKit
import MapKit
import Ra
import ApartKit
import PureLayout

public class MapViewController: UIViewController {
    public private(set) var devices = [State]()
    public private(set) var zones = [State]()

    private let map = MKMapView(forAutoLayout: ())

    public func configure(states: [State]) {
        let states = states.filter { $0.isDeviceTracker || $0.isZone }
        self.devices = states.filter { $0.isDeviceTracker }
        self.zones = states.filter { $0.isZone }

        if states.count == 1, let state = states.first {
            self.title = state.displayName
        } else {
            self.title = "Map"
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.map)
        self.map.autoPinEdgesToSuperviewEdges()
    }
}