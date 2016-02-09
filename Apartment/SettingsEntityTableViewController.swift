import UIKit
import ApartKit

public class SettingsEntityTableViewController: UITableViewController {
    public var onFinish: (State? -> Void)?

    public private(set) var homeRepository: HomeRepository!

    private var entities = [State]()

    public func configure(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository

        self.homeRepository.groups(includeScenes: false) { _, groups in
            self.entities = groups.map { $0.groupEntity }
            self.tableView.reloadData()
        }
    }

    private let cellIdentifier = "cell"

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - Table view data source

    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0: return 1
        case 1: return self.entities.count
        default: return 0
        }
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)

        switch (indexPath.section) {
        case 0: cell.textLabel?.text = "None"
        case 1: cell.textLabel?.text = self.entities[indexPath.row].displayName
        default: break
        }

        return cell
    }

    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.onFinish?(nil)
        } else {
            self.onFinish?(self.entities[indexPath.row])
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
