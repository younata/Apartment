import WatchKit
import Foundation
import ApartWatchKit

class GlanceController: WKInterfaceController {
    lazy var statusRepository = (WKExtension.sharedExtension().delegate as? ExtensionDelegate)?.statusRepository

    @IBOutlet var locksLabel: WKInterfaceLabel!

    @IBOutlet var bulbsLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.statusRepository?.addSubscriber(self)
    }
}

extension GlanceController: StatusSubscriber {
    func didUpdateBulbs(bulbs: [Bulb]) {
        let numOnBulbs = bulbs.reduce(0) {
            return $0 + ($1.on ? 1 : 0)
        }

        if numOnBulbs == 0 {
            self.bulbsLabel.setText("All lights off")
        } else {
            self.bulbsLabel.setText("\(numOnBulbs) lights on")
        }
    }

    func didUpdateLocks(locks: [Lock]) {
        let numLocked = locks.reduce(0) {
            let locked = $1.locked == Lock.LockStatus.Locked
            return $0 + (locked ? 1 : 0)
        }

        if numLocked == locks.count {
            self.locksLabel.setText("All locked")
        } else {
            self.locksLabel.setText("\(locks.count - numLocked) locks unlocked")
        }
    }
}
