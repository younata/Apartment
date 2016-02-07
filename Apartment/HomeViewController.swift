import UIKit
import Ra
import ApartKit
import PureLayout

public class HomeViewController: UIViewController {
    private var states = [State]()
    private var groups = [Group]()

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

    private lazy var graphViewController: GraphViewController = {
        return self.injector!.create(GraphViewController)!
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
            self.onLogin()
        } else {
            let loginViewController = self.injector!.create(LoginViewController)!
            loginViewController.onLogin = {
                self.onLogin()
            }
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
    }

    // MARK: Private

    private func onLogin() {
        self.refreshControl?.beginRefreshing()
        self.refresh()
        self.homeRepository.configuration { configuration in
            if let configuration = configuration {
                self.title = configuration.name
            }
        }
    }

    @objc private func refresh() {
        self.homeRepository.groups(includeScenes: true) {states, groups in
            self.states = states
            self.groups = groups

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

    private func entityAtIndexPath(indexPath: NSIndexPath) -> State {
        return self.groups[indexPath.section].entities[indexPath.row]
    }
}

extension HomeViewController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.groups.count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection sectionNumber: Int) -> Int {
        return self.groups[sectionNumber].entities.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let entity = self.entityAtIndexPath(indexPath)

        let cellStyle = entity.isLight || entity.isSwitch ? "switch" : "cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellStyle, forIndexPath: indexPath)

        cell.textLabel?.text = entity.displayName

        if let switchCell = cell as? SwitchTableViewCell {
            switchCell.cellSwitch.on = entity.switchState ?? false
            switchCell.onSwitchChange = {newState in
                self.changeState(entity, on: newState)
            }
        } else if !entity.isScene {
            var text = entity.state
            if let unit = entity.sensorUnitOfMeasurement {
                text += " \(unit)"
            }
            cell.detailTextLabel?.text = text.desnake
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.groups[section].groupEntity.displayName
    }

    private func changeState(entity: State, on: Bool) {
        if let service = serviceForDomain(entity.domain ?? "") {
            let method = on ? "turn_on" : "turn_off"
            self.refreshControl?.beginRefreshing()
            self.homeRepository.updateService(service, method: method, onEntity: entity) {states, error in
                if let _ = error {
                    self.refreshControl?.endRefreshing()
                } else {
                    self.refresh()
                }
            }
        }
    }

    private func serviceForDomain(domain: String) -> Service? {
        if let service = self.services.filter({
            $0.domain == domain
        }).first {
            return service
        }
        return self.services.filter {
            $0.domain == "homeassistant"
        }.first
    }

    private func showGraph(entity entity: State) {
        self.graphViewController.entity = entity
        self.showDetailViewController(self.graphViewController, sender: self)
    }
}

extension HomeViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let entity = self.entityAtIndexPath(indexPath)

        if entity.isScene {
            self.changeState(entity, on: true)
        } else if entity.isDeviceTracker {
            self.mapViewController.configure([entity])
            self.showDetailViewController(self.mapViewController, sender: self)
        } else if !(entity.isSwitch || entity.isLight), let domain = entity.domain, service = self.serviceForDomain(domain) where service.domain != "homeassistant" {
            let actionSheet = UIAlertController(title: entity.displayName, message: nil, preferredStyle: .ActionSheet)
            for method in service.methods {
                let action = UIAlertAction(title: method.id.desnake, style: .Default) { _ in
                    self.refreshControl?.beginRefreshing()
                    self.homeRepository.updateService(service, method: method.id, onEntity: entity) { _, error in
                        if let _ = error {
                            self.refreshControl?.endRefreshing()
                        } else {
                            self.refresh()
                        }
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                actionSheet.addAction(action)
            }
            actionSheet.addAction(UIAlertAction(title: "View History", style: .Default) { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.showGraph(entity: entity)
            })
            actionSheet.addAction(UIAlertAction(title: "Dismiss", style: .Cancel) { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            self.presentViewController(actionSheet, animated: true, completion: nil)
        } else {
            self.showGraph(entity: entity)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
