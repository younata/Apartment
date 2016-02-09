import UIKit
import PureLayout
import Ra
import ApartKit

public class SettingsViewController: UIViewController {
    private lazy var homeRepository: HomeRepository = {
        return self.injector!.create(HomeRepository)!
    }()

    public let backendVersionLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.textAlignment = .Center
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        return label
    }()

    public let appVersionLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.textAlignment = .Center
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        let versionNumber = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        label.text = "App Version \(versionNumber)"
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
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 60))

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

        let versionStackView = UIStackView(arrangedSubviews: [self.appVersionLabel, self.backendVersionLabel])
        versionStackView.translatesAutoresizingMaskIntoConstraints = false
        versionStackView.axis = .Vertical
        versionStackView.alignment = .Center

        self.view.addSubview(versionStackView)

        self.stackView.autoPinEdge(.Bottom, toEdge: .Top, ofView: versionStackView, withOffset: 8, relation: .LessThanOrEqual)
        self.view.addConstraint(NSLayoutConstraint(item: versionStackView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: -20))
        versionStackView.autoPinEdgeToSuperviewMargin(.Leading)
        versionStackView.autoPinEdgeToSuperviewMargin(.Trailing)

        self.homeRepository.configuration { config in
            if let config = config {
                self.backendVersionLabel.text = "Home Assistant Version \(config.version)"
            }
        }
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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