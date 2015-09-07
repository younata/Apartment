import UIKit
import PureLayout_iOS
import ApartKit

internal protocol BulbTableViewCellDelegate {
    func bulbCell(bulbCell: BulbTableViewCell, shouldTurnOn on: Bool, ofBulb bulb: Bulb)
}

public class BulbTableViewCell: UITableViewCell {
    internal var bulb: Bulb! = nil {
        didSet {
            self.bulbStatus.on = self.bulb.on
            self.textLabel?.text = self.bulb.name
        }
    }

    internal var delegate: BulbTableViewCellDelegate? = nil

    internal var animating: Bool = false {
        didSet {
            if self.animating {
                self.contentView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            } else {
                self.contentView.backgroundColor = UIColor.clearColor()
            }
        }
    }

    public lazy var bulbStatus: UISwitch = {
        let theSwitch = UISwitch(forAutoLayout: ())
        theSwitch.addTarget(self, action: "didTapSwitch", forControlEvents: .ValueChanged)
        self.contentView.addSubview(theSwitch)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        theSwitch.autoPinEdgesToSuperviewEdgesWithInsets(insets, excludingEdge: .Left)
        return theSwitch
    }()

    internal func didTapSwitch() {
        self.delegate?.bulbCell(self, shouldTurnOn: !self.bulb.on, ofBulb: self.bulb)
    }
}
