import WatchKit
import Foundation
import ApartWatchKit

class InterfaceTableController: NSObject {
    @IBOutlet var label: WKInterfaceLabel!
}

class InterfaceController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable!

    private var locks = Array<Lock>()
    private var bulbs = Array<Bulb>()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.table.setRowTypes(["row"])
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
//        if rowIndex < self.bulbs.count {
//            let bulb = self.bulbs[rowIndex]
//        } else {
//            let idx = rowIndex - self.bulbs.count
//            let lock = self.locks[idx]
//        }
    }
}

extension InterfaceController: StatusSubscriber {
    func didUpdateLocks(locks: [Lock]) {
        self.locks = locks
        self.table.setNumberOfRows(locks.count, withRowType: "locks")

        for i in self.bulbs.count..<locks.count {
            let rowController = self.table.rowControllerAtIndex(i) as? InterfaceTableController
            let lock = locks[i-self.bulbs.count]
            let locked: String
            if let lockStatus = lock.locked {
                switch (lockStatus) {
                case .Locked:
                    locked = "locked"
                case .Unlocked:
                    locked = "unlocked"
                }
            } else {
                locked = "unknown"
            }
            rowController?.label.setText("Lock \(lock.name): \(locked)")
        }
    }

    func didUpdateBulbs(bulbs: [Bulb]) {
        self.bulbs = bulbs
        self.table.setNumberOfRows(bulbs.count, withRowType: "bulbs")

        for i in 0..<bulbs.count {
            let rowController = self.table.rowControllerAtIndex(i) as? InterfaceTableController
            let bulb = bulbs[i]
            let bulbOn: String = bulb.on ? "on" : "off"

            rowController?.label.setText("Light \(bulb.name): \(bulbOn)")

        }
    }
}
