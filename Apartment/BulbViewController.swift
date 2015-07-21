import UIKit
import PureLayout_iOS
import ApartKit

public class BulbViewController: UIViewController {

    lazy var lightsService : LightsService? = {
        return self.injector?.create(kLightsService) as? LightsService
    }()

    var bulb: Bulb! = nil

    public let titleField = UITextField()

    public let colorPicker = ColorPicker()

    public func configure(bulb: Bulb) {
        self.bulb = bulb
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let containerView = UIView()
        containerView.backgroundColor = UIColor.whiteColor()

        view.addSubview(containerView)

        edgesForExtendedLayout = .None

        containerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(20, 20, 0, 20), excludingEdge: .Bottom)
        containerView.autoSetDimension(.Height, toSize: 200)
        containerView.layer.cornerRadius = 5

        titleField.text = bulb.name
        titleField.backgroundColor = UIColor.clearColor()
        titleField.placeholder = NSLocalizedString("Name", comment: "")
        containerView.addSubview(titleField)

        titleField.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsMake(20, 20, 0, 20), excludingEdge: .Bottom)

        view.addSubview(colorPicker)
        colorPicker.hue = CGFloat(bulb.hue) / 65535.0
        colorPicker.saturation = CGFloat(bulb.saturation) / 254.0

        colorPicker.autoPinEdgeToSuperviewEdge(.Leading)
        colorPicker.autoPinEdgeToSuperviewEdge(.Trailing)
        colorPicker.autoSetDimension(.Height, toSize: 100)
        colorPicker.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleField, withOffset: 8)
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = false
    }
}
