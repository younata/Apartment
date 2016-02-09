import UIKit
import PureLayout
import Ra
import ApartKit

public class SettingsViewController: UIViewController {
    private lazy var homeRepository: HomeRepository = {
        return self.injector!.create(HomeRepository)!
    }()

    public let versionLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.textAlignment = .Center
        return label
    }()

    public let stackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 8
        return stackView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()

        self.view.addSubview(self.stackView)
        self.stackView.autoPinEdgeToSuperviewMargin(.Leading)
        self.stackView.autoPinEdgeToSuperviewMargin(.Trailing)
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0))

        self.stackView.addArrangedSubview(UIView())
        self.stackView.addArrangedSubview(UIView())

        let button = UIButton(type: .System)
        button.setTitle("Logout", forState: .Normal)
        button.addTarget(self, action: Selector("didTapLogout"), forControlEvents: .TouchUpInside)
        self.stackView.addArrangedSubview(button)

        self.view.addSubview(self.versionLabel)

        self.stackView.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.versionLabel, withOffset: 8)
        self.view.addConstraint(NSLayoutConstraint(item: self.versionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0))
        self.versionLabel.autoPinEdgeToSuperviewMargin(.Leading)
        self.versionLabel.autoPinEdgeToSuperviewMargin(.Trailing)

        self.homeRepository.configuration { config in
            if let config = config {
                self.versionLabel.text = "version \(config.version)"
            }
        }
    }

    @objc private func didTapLogout() {
        self.homeRepository.logout()
    }
}