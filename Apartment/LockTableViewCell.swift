import UIKit
import PureLayout_iOS
import ApartKit

internal protocol LockTableViewCellDelegate {
    func lockCell(lockCell: LockTableViewCell, shouldChangeLockStatus lockStatus: Lock.LockStatus, ofLock lock: Lock)
}

public class LockTableViewCell: UITableViewCell {
    internal var lock: Lock! = nil {
        didSet {
            self.lockStatus.on = self.lock.locked == Lock.LockStatus.Locked
            self.textLabel?.text = self.lock.name
        }
    }

    internal var delegate: LockTableViewCellDelegate? = nil

    internal var animating: Bool = false {
        didSet {
            if self.animating {
                self.contentView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            } else {
                self.contentView.backgroundColor = UIColor.clearColor()
            }
        }
    }

    public lazy var lockStatus: UISwitch = {
        let theSwitch = UISwitch(forAutoLayout: ())
        theSwitch.addTarget(self, action: "didTapSwitch", forControlEvents: .ValueChanged)
        self.contentView.addSubview(theSwitch)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        theSwitch.autoPinEdgesToSuperviewEdgesWithInsets(insets, excludingEdge: .Left)
        return theSwitch
    }()

    internal func didTapSwitch() {
        let desiredLockStatus: Lock.LockStatus
        if self.lock.locked == .Locked {
            desiredLockStatus = .Unlocked
        } else {
            desiredLockStatus = .Locked
        }
        self.delegate?.lockCell(self, shouldChangeLockStatus: desiredLockStatus, ofLock: self.lock)
    }
}
