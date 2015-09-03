import UIKit
import Ra
import ApartKit

public class HomeViewController: UIViewController {
    public var bulbs = Array<Bulb>()
    public var locks = Array<Lock>()

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.lightGrayColor()

        getLights()
        getLocks()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }

    // MARK: Private

    private func getLights() {
        if let lightsService = self.injector?.create(kLightsService) as? LightsService {
            lightsService.allBulbs {bulbs, error in
                if let bulbs = bulbs {
                    self.bulbs = bulbs
                } else if let error = error {
                    let alert = UIAlertController(title: "Error getting lights", message: error.localizedDescription, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: {_ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func getLocks() {
        if let lockService = self.injector?.create(kLockService) as? LockService {
            lockService.allLocks {locks, error in
                if let locks = locks {
                    self.locks = locks
                } else if let error = error {
                    let alert = UIAlertController(title: "Error getting locks", message: error.localizedDescription, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: {_ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
