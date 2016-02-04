import UIKit
import Ra
import ApartKit
import PureLayout

public class HomeViewController: UIViewController {
    private var states = [State]()
    private var groups = [(String, [State])]()

    private var services = [Service]()

    private lazy var homeRepository: HomeRepository = {
        return self.injector!.create(HomeRepository)!
    }()

    private lazy var tableViewController = UITableViewController(style: .Grouped)

    public var tableView: UITableView {
        return self.tableViewController.tableView
    }

    public var refreshControl: UIRefreshControl? {
        return self.tableViewController.refreshControl
    }

    private class TableViewCell: UITableViewCell {
        private override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        }

        private required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    private lazy var mapViewController: MapViewController = {
        return self.injector!.create(MapViewController)!
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.lightGrayColor()

        self.addChildViewController(self.tableViewController)
        self.view.addSubview(self.tableView)
        self.tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()

        self.title = "Apartment"

        self.tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: "switch")

        self.tableViewController.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("refresh"), forControlEvents: .ValueChanged)
    }

    public override func viewWillAppear(animated: Bool) {
        if self.homeRepository.configured {
            self.refreshControl?.beginRefreshing()
            self.refresh()
        } else {
            let loginViewController = self.injector!.create(LoginViewController)!
            loginViewController.onLogin = {
                self.refreshControl?.beginRefreshing()
                self.refresh()
            }
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
    }

    // MARK: Private

    @objc private func refresh() {
        self.homeRepository.states {states in
            self.states = states

            let groups = states.filter { $0.isGroup && $0.groupAutoCreated == false }
            var groupData = Array<(String, [State])>()
            for group in groups {
                if let entities = group.groupEntities {
                    let displayName = group.displayName
                    let groupStates = states.filter({ entities.contains($0.entityId) && !$0.hidden }).sort({$0.displayName < $1.displayName})
                    groupData.append((displayName, groupStates))
                }
            }

            self.groups = groupData.sort { $0.0.lowercaseString < $1.0.lowercaseString }
            let scenes = states.filter { $0.isScene && !$0.hidden }
            self.groups.insert(("scenes", scenes), atIndex: 0)
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()

            let mapItem = UIBarButtonItem(title: "Map", style: .Plain, target: self, action: Selector("showMap"))

            let spacer = { return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil) }

            self.toolbarItems = [spacer(), mapItem, spacer()]
        }

        self.homeRepository.services { self.services = $0 }
    }

    @objc private func showMap() {
        self.mapViewController.configure(self.states)
        self.showDetailViewController(self.mapViewController, sender: self)
    }
}

extension HomeViewController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.groups.count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection sectionNumber: Int) -> Int {
        return self.groups[sectionNumber].1.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let state = self.groups[indexPath.section].1[indexPath.row]
        let cellStyle = state.isLight || state.isSwitch ? "switch" : "cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellStyle, forIndexPath: indexPath)

        cell.textLabel?.text = state.displayName

        if let switchCell = cell as? SwitchTableViewCell {
            switchCell.cellSwitch.on = state.switchState ?? false
            switchCell.onSwitchChange = {newState in
                self.changeState(state, on: newState)
            }
        } else if !state.isScene {
            var text = state.state
            if let unit = state.sensorUnitOfMeasurement {
                text += " \(unit)"
            }
            cell.detailTextLabel?.text = text.desnake
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.groups[section].0
    }

    private func changeState(state: State, on: Bool) {
        let serviceForDomain: String -> Service? = { domain in
            if let service = self.services.filter({
                $0.domain == domain
            }).first {
                return service
            }
            return self.services.filter {
                $0.domain == "homeassistant"
            }.first
        }

        if let service = serviceForDomain(state.domain ?? "") {
            let method = on ? "turn_on" : "turn_off"
            self.homeRepository.updateService(service, method: method, onEntity: state) {states, error in
                self.refreshControl?.beginRefreshing()
                self.refresh()
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let state = self.groups[indexPath.section].1[indexPath.row]

        if state.isScene {
            self.changeState(state, on: true)
        } else if state.isDeviceTracker {
            self.mapViewController.configure([state])
            self.showDetailViewController(self.mapViewController, sender: self)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
