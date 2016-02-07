import UIKit
import ApartKit

public class GraphViewController: UIViewController {
    public var entity: State?
    private lazy var homeRepository: HomeRepository = {
        return self.injector!.create(HomeRepository)!
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
    }
}
