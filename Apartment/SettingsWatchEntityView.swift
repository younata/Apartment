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
        return label
    }()

    public let detailLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.textAlignment = .Right
        label.text = "Not Set"
        return label
    }()

    public var onTap: (Void -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.titleLabel)
        self.addSubview(self.detailLabel)

        self.titleLabel.autoPinEdgesToSuperviewMarginsExcludingEdge(.Trailing)
        self.detailLabel.autoPinEdgesToSuperviewMarginsExcludingEdge(.Leading)
        self.detailLabel.autoPinEdge(.Leading, toEdge: .Trailing, ofView: self.titleLabel)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didTap"))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    @objc private func didTap() {
        self.onTap?()
    }
}
