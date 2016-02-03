import WatchKit
import Foundation
import ApartWatchKit

class InterfaceTableController: NSObject {
    @IBOutlet var label: WKInterfaceLabel!
}

class InterfaceController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.table.removeRowsAtIndexes(NSIndexSet(index: 0))
        self.table.setRowTypes(["bulb", "lock"])
    }

    @IBAction func didTapTurnLightsOff() {
    }

    @IBAction func didTapTurnLightsOn() {
    }

    @IBAction func didTapLockAllLocks() {
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    }
}
