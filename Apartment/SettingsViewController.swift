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

    private let complicationView: SettingsWatchEntityView = {
        let view = SettingsWatchEntityView(frame: CGRectZero)
        view.titleLabel.text = "Watch Complication Entity"
        return view
    }()

    private let glanceView: SettingsWatchEntityView = {
        let view = SettingsWatchEntityView(frame: CGRectZero)
        view.titleLabel.text = "Watch Glance Entity"
        return view
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()

        self.title = "Settings"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: Selector("dismiss"))

        self.view.addSubview(self.stackView)
        self.stackView.autoPinEdgeToSuperviewMargin(.Leading)
        self.stackView.autoPinEdgeToSuperviewMargin(.Trailing)
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0))

        self.stackView.addArrangedSubview(self.complicationView)
        self.stackView.addArrangedSubview(self.glanceView)

        for view in [self.complicationView, self.glanceView] {
            view.autoPinEdgeToSuperviewMargin(.Leading)
            view.autoPinEdgeToSuperviewMargin(.Trailing)
        }

        let complicationTap = UITapGestureRecognizer(target: self, action: Selector("didTapComplicationView"))
        self.complicationView.addGestureRecognizer(complicationTap)

        let glanceTap = UITapGestureRecognizer(target: self, action: Selector("didTapGlanceView"))
        self.glanceView.addGestureRecognizer(glanceTap)

        let button = UIButton(type: .System)
        button.setTitle("Logout", forState: .Normal)
        button.addTarget(self, action: Selector("didTapLogout"), forControlEvents: .TouchUpInside)
        self.stackView.addArrangedSubview(button)

        self.view.addSubview(self.versionLabel)

        self.stackView.autoPinEdge(.Bottom, toEdge: .Top, ofView: self.versionLabel, withOffset: 8, relation: .LessThanOrEqual)
        self.view.addConstraint(NSLayoutConstraint(item: self.versionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0))
        self.versionLabel.autoPinEdgeToSuperviewMargin(.Leading)
        self.versionLabel.autoPinEdgeToSuperviewMargin(.Trailing)

        self.homeRepository.configuration { config in
            if let config = config {
                self.versionLabel.text = "version \(config.version)"
            }
        }

        self.homeRepository.watchComplicationEntity {
            self.complicationView.entity = $0
        }
        self.homeRepository.watchGlanceEntity {
            self.glanceView.entity = $0
        }
    }

    @objc private func didTapComplicationView() {
        let settingsEntityTableViewController = SettingsEntityTableViewController()
        settingsEntityTableViewController.configure(self.homeRepository)
        settingsEntityTableViewController.onFinish = { state in
            self.homeRepository.watchComplicationEntityId = state?.entityId
        }
        self.showViewController(settingsEntityTableViewController, sender: self)
    }

    @objc private func didTapGlanceView() {
        let settingsEntityTableViewController = SettingsEntityTableViewController()
        settingsEntityTableViewController.configure(self.homeRepository)
        settingsEntityTableViewController.onFinish = { state in
            self.homeRepository.watchGlanceEntityId = state?.entityId
        }
        self.showViewController(settingsEntityTableViewController, sender: self)
    }

    @objc private func didTapLogout() {
        self.homeRepository.logout()
    }

    @objc private func dismiss() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}