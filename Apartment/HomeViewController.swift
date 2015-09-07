import UIKit
import Ra
import ApartKit
import PureLayout_iOS

public class HomeViewController: UIViewController {

    public enum HomeViewSection: Int, CustomStringConvertible {
        case Locks = 0
        case Lights = 1

        public var description: String {
            switch self {
            case .Locks:
                return "Locks"
            case .Lights:
                return "Lights"
            }
        }
    }

    public var bulbs = Array<Bulb>()
    public var locks = Array<Lock>()

    private var lightsService: LightsService {
        return self.injector!.create(kLightsService) as! LightsService
    }

    private var lockService: LockService {
        return self.injector!.create(kLockService) as! LockService
    }

    private lazy var tableViewController = UITableViewController()

    public var tableView: UITableView {
        return self.tableViewController.tableView
    }

    public var refreshControl: UIRefreshControl? {
        return self.tableViewController.refreshControl
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.lightGrayColor()

        self.addChildViewController(self.tableViewController)
        self.view.addSubview(self.tableView)
        self.tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        let lockSectionTitle = HomeViewSection.Locks.description
        let lightSectionTitle = HomeViewSection.Lights.description

        self.tableView.registerClass(LockTableViewCell.classForCoder(), forCellReuseIdentifier: lockSectionTitle)
        self.tableView.registerClass(BulbTableViewCell.classForCoder(), forCellReuseIdentifier: lightSectionTitle)

        self.getLights()
        self.getLocks()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Private

    private func getLights() {
        self.lightsService.allBulbs {bulbs, error in
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

    private func getLocks() {
        self.lockService.allLocks {locks, error in
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

extension HomeViewController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection sectionNumber: Int) -> Int {
        guard let section = HomeViewSection(rawValue: sectionNumber) else {
            return 0
        }
        switch section {
        case .Locks:
            return self.locks.count
        case .Lights:
            return self.bulbs.count
        }
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let section = HomeViewSection(rawValue: indexPath.section) {
            cell = tableView.dequeueReusableCellWithIdentifier(section.description, forIndexPath: indexPath)
            switch section {
            case .Locks:
                let lockCell = cell as! LockTableViewCell
                let lock = self.locks[indexPath.row]
                lockCell.lock = lock
                lockCell.delegate = self
            case .Lights:
                let bulbCell = cell as! BulbTableViewCell
                let bulb = self.bulbs[indexPath.row]
                bulbCell.bulb = bulb
                bulbCell.delegate = self
            }
        } else {
            return UITableViewCell()
        }
        cell.selectionStyle = .None
        return cell
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection sectionNumber: Int) -> String? {
        guard let section = HomeViewSection(rawValue: sectionNumber) else {
            return nil
        }
        return section.description
    }
}

extension HomeViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        guard let section = HomeViewSection(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .Locks:
            break;
        case .Lights:
            if let bulbViewController = self.injector?.create(BulbViewController.self) as? BulbViewController {
                self.navigationController?.pushViewController(bulbViewController, animated: true)
            }
        }
    }
}

extension HomeViewController: LockTableViewCellDelegate {
    func lockCell(lockCell: LockTableViewCell, shouldChangeLockStatus lockStatus: Lock.LockStatus, ofLock lock: Lock) {
        lockCell.animating = true
        self.lockService.update_lock(lock, to_lock: lockStatus) {updatedLock, error in
            if let _ = error {
                lockCell.lock = lock
            }
            lockCell.animating = false
        }
    }
}

extension HomeViewController: BulbTableViewCellDelegate {
    func bulbCell(bulbCell: BulbTableViewCell, shouldTurnOn on: Bool, ofBulb bulb: Bulb) {
        bulbCell.animating = true
        self.lightsService.update(bulb, attributes: ["on": on]) {updatedBulb, error in
            if let _ = error {
                bulbCell.bulb = bulb
            }
            bulbCell.animating = false
        }
    }
}
