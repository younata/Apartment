import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var doorButton: WKInterfaceButton!
    @IBOutlet var lightsButton: WKInterfaceButton!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
