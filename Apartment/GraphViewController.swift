import UIKit
import ApartKit

public class GraphViewController: UIViewController {
    public var entity: State? {
        didSet {
            self.title = entity?.displayName
            self.retrieveHistory()
        }
    }

    private lazy var homeRepository: HomeRepository = {
        return self.injector!.create(HomeRepository)!
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    private func retrieveHistory() {
        if let entity = self.entity {
            self.homeRepository.history(entity) { states in
                if states.isEmpty {
                    self.unableToRetrieveHistory()
                }
            }
        }
    }

    private func unableToRetrieveHistory() {
        let alert = UIAlertController(title: "Unable to retrieve history", message: nil, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "Try again", style: .Default) { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.retrieveHistory()
        })

        alert.addAction(UIAlertAction(title: "Oh well", style: .Cancel) { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        })

        self.presentViewController(alert, animated: true, completion: nil)
    }
}
