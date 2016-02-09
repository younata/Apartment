import UIKit
import PureLayout
import ApartKit

public class SettingsWatchEntityView: UIView {
    public var entity: State? {
        didSet {
            self.detailLabel.text = entity?.displayName ?? "Not Set"
        }
    }

    public let titleLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.textColor = UIColor(colorLiteralRed: 0, green: 0.48, blue: 1, alpha: 1)
        return label
    }()

    public let detailLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.textAlignment = .Right
        label.text = "Not Set"
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.titleLabel)
        self.addSubview(self.detailLabel)

        self.titleLabel.autoPinEdgesToSuperviewMarginsExcludingEdge(.Trailing)
        self.detailLabel.autoPinEdgesToSuperviewMarginsExcludingEdge(.Leading)
        self.detailLabel.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.titleLabel, withOffset: 0, relation: .GreaterThanOrEqual)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}
