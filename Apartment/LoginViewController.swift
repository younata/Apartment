import UIKit
import Ra
import ApartKit
import PureLayout

public class LoginViewController: UIViewController {
    private lazy var homeRepository: HomeRepository = {
        return self.injector!.create(HomeRepository)!
    }()

    private lazy var userDefaults: NSUserDefaults = {
        return self.injector!.create(NSUserDefaults)!
    }()

    public var onLogin: (Void -> Void)?

    public private(set) lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.hidden = true
        label.numberOfLines = 0
        label.text = "Unable to verify credentials (incorrect credentials or unreachable network)"
        return label
    }()

    public private(set) lazy var urlField: UITextField = {
        let field = UITextField()
        field.delegate = self
        return field
    }()

    public private(set) lazy var passwordField: UITextField = {
        let field = UITextField()
        field.secureTextEntry = true
        field.delegate = self
        return field
    }()

    public private(set) lazy var loginButton: UIButton = {
        let button = UIButton(type: .System)
        button.enabled = false

        button.addTarget(self, action: Selector("didTapLogin"), forControlEvents: .TouchUpInside)
        return button
    }()

    private var urlString: String = ""
    private var password: String = ""

    public override func viewDidLoad() {
        super.viewDidLoad()

        let centerGuide = UIStackView(forAutoLayout: ())
        centerGuide.axis = .Vertical

        self.view.addSubview(centerGuide)

        centerGuide.autoPinEdgeToSuperviewMargin(.Leading)
        centerGuide.autoPinEdgeToSuperviewMargin(.Trailing)
        centerGuide.autoAlignAxisToSuperviewAxis(.Vertical)

        let label = UILabel(forAutoLayout: ())
        centerGuide.addSubview(label)
        label.text = "Login"

        centerGuide.addArrangedSubview(self.errorLabel)
        centerGuide.addArrangedSubview(self.urlField)
        centerGuide.addArrangedSubview(self.passwordField)
        centerGuide.addArrangedSubview(self.loginButton)
    }

    @objc private func didTapLogin() {
        self.homeRepository.backendPassword = self.password
        self.homeRepository.backendURL = NSURL(string: urlString)

        self.loginButton.enabled = false
        self.errorLabel.hidden = true

        self.homeRepository.apiAvailable { available in
            self.loginButton.enabled = true
            if available {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                self.userDefaults.setObject(self.homeRepository.backendPassword, forKey: "backendPassword")
                self.userDefaults.setURL(self.homeRepository.backendURL, forKey: "backendURL")
                self.onLogin?()
            } else {
                self.errorLabel.hidden = false
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = NSString(string: textField.text ?? "").stringByReplacingCharactersInRange(range, withString: string)
        if textField == self.urlField {
            self.urlString = text
        } else if textField == self.passwordField {
            self.password = text
        }

        if !self.urlString.isEmpty && !self.password.isEmpty {
            self.loginButton.enabled = true
        }

        return true
    }
}
