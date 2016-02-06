import WatchKit
import Foundation
import ApartWatchKit

class MapControllerContext {
    let entity: State

    init(entity: State) {
        self.entity = entity
    }
}

class MapInterfaceController: WKInterfaceController {

    @IBOutlet var map: WKInterfaceMap!

    var entity: State?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.entity = (context as? MapControllerContext)?.entity
        self.setTitle(self.entity?.displayName)
        if let coordinate = self.entity?.trackerCoordinate {
            self.map.addAnnotation(coordinate, withPinColor: .Red)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            self.map.setRegion(MKCoordinateRegion(center: coordinate, span: span))
        }
    }
}
