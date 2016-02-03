import UIKit
import PureLayout

public class SwitchTableViewCell: UITableViewCell {
    public var onSwitchChange: ((Bool) -> (Void))? = nil

    public let cellSwitch = UISwitch(forAutoLayout: ())

    private let _textLabel = UILabel(forAutoLayout: ())

    public override var textLabel: UILabel? {
        return self._textLabel
    }

    public override func prepareForReuse() {
        self.onSwitchChange = nil
    }

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.cellSwitch)
        self.cellSwitch.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 16), excludingEdge: .Leading)

        self.cellSwitch.addTarget(self, action: Selector("didTapSwitch"), forControlEvents: .ValueChanged)

        self.contentView.addSubview(self._textLabel)
        self._textLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 0), excludingEdge: .Trailing)
        self._textLabel.autoPinEdge(.Trailing, toEdge: .Leading, ofView: self.cellSwitch)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    @objc private func didTapSwitch() {
        self.onSwitchChange?(self.cellSwitch.on)
    }
}