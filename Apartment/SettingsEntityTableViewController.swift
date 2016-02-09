import UIKit
import ApartKit

public class SettingsEntityTableViewController: UITableViewController {
    public var onFinish: (State? -> Void)?

    private var homeRepository: HomeRepository!

    private var entities = [State]()

    func configure(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository

        self.homeRepository.groups(includeScenes: false) { _, groups in
            self.entities = groups.map { $0.groupEntity }
        }
    }


    public override func viewDidLoad() {
        super.viewDidLoad()
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

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.onFinish?(nil)
        } else {
            self.onFinish?(self.entities[indexPath.row])
        }
    }
}
