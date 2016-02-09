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
        field.autocapitalizationType = .None
        field.autocorrectionType = .No
        field.spellCheckingType = .No
        field.textAlignment = .Center
        field.placeholder = "Home Assistant URL"
        return field
    }()

    public private(set) lazy var passwordField: UITextField = {
        let field = UITextField()
        field.secureTextEntry = true
        field.delegate = self
        field.textAlignment = .Center
        field.placeholder = "Home Assistant Password"
        return field
    }()

    public private(set) lazy var loginButton: UIButton = {
        let button = UIButton(type: .System)
        button.enabled = false
        button.setTitle("Login", forState: .Normal)
        button.addTarget(self, action: Selector("didTapLogin"), forControlEvents: .TouchUpInside)
        return button
    }()

    private var urlString: String = ""
    private var password: String = ""

    public override func viewDidLoad() {
        super.viewDidLoad()

        let centerGuide = UIStackView(forAutoLayout: ())
        centerGuide.axis = .Vertical
        centerGuide.alignment = .Center
        centerGuide.spacing = 8

        self.view.addSubview(centerGuide)

        centerGuide.autoPinEdgeToSuperviewMargin(.Leading)
        centerGuide.autoPinEdgeToSuperviewMargin(.Trailing)
        centerGuide.autoAlignAxisToSuperviewAxis(.Horizontal)

        let label = UILabel(forAutoLayout: ())
        centerGuide.addArrangedSubview(label)
        label.text = "Login"

        centerGuide.addArrangedSubview(self.errorLabel)
        centerGuide.addArrangedSubview(self.urlField)
        self.urlField.autoPinEdgeToSuperviewMargin(.Leading)
        self.urlField.autoPinEdgeToSuperviewMargin(.Trailing)
        centerGuide.addArrangedSubview(self.passwordField)
        self.passwordField.autoPinEdgeToSuperviewMargin(.Leading)
        self.passwordField.autoPinEdgeToSuperviewMargin(.Trailing)
        centerGuide.addArrangedSubview(self.loginButton)
        self.view.backgroundColor = UIColor.whiteColor()
    }

    @objc private func didTapLogin() {
        self.loginButton.enabled = false
        self.errorLabel.hidden = true

        self.homeRepository.login(url: NSURL(string: urlString)!, password: self.password) { available in
            self.loginButton.enabled = true
            if available {
                self.userDefaults.setObject(self.homeRepository.backendPassword, forKey: "backendPassword")
                self.userDefaults.setURL(self.homeRepository.backendURL, forKey: "backendURL")
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
        } else {
            self.loginButton.enabled = false
        }

        return true
    }
}
