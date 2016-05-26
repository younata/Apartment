import UIKit
import Ra
import ApartKit
import PureLayout

public class HomeViewController: UIViewController, Injectable {
    private var states = [State]()
    private var groups = [Group]()

    private var services = [Service]()

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
    private let homeRepository: HomeRepository
    private let mapViewController: Void -> MapViewController
    private let graphViewController: Void -> GraphViewController
    private let settingsViewController: Void -> SettingsViewController

    public init(homeRepository: HomeRepository,
                            mapViewController: Void -> MapViewController,
                            graphViewController: Void -> GraphViewController,
                            settingsViewController: Void -> SettingsViewController) {
        self.homeRepository = homeRepository
        self.mapViewController = mapViewController
        self.graphViewController = graphViewController
        self.settingsViewController = settingsViewController
        super.init(nibName: nil, bundle: nil)
    }

    public required convenience init(injector: Injector) {
        self.init(
            homeRepository: injector.create(HomeRepository)!,
            mapViewController: { injector.create(MapViewController)! },
            graphViewController: { injector.create(GraphViewController)! },
            settingsViewController: { injector.create(SettingsViewController)! }
        )
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: #selector(HomeViewController.didTapSettings))

        self.tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: "switch")

        self.tableViewController.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(HomeViewController.refresh), forControlEvents: .ValueChanged)
    }

    public override func viewWillAppear(animated: Bool) {
        self.refreshControl?.beginRefreshing()
        self.refresh()
        self.homeRepository.configuration { configuration in
            if let configuration = configuration {
                self.title = configuration.name
            }
        }
    }

    @objc private func didTapSettings() {
        let navController = UINavigationController(rootViewController: self.settingsViewController())
        self.presentViewController(navController, animated: true, completion: nil)
    }

    @objc private func refresh() {
        self.homeRepository.groups(includeScenes: true) {states, groups in
            self.states = states
            self.groups = groups

            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()

            let mapItem = UIBarButtonItem(title: "Map", style: .Plain, target: self, action: #selector(HomeViewController.showMap))

            let spacer = { return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil) }

            self.toolbarItems = [spacer(), mapItem, spacer()]
        }

        self.homeRepository.services { self.services = $0 }
    }

    @objc private func showMap() {
        let mapViewController = self.mapViewController()
        mapViewController.configure(self.states)
        self.showDetailViewController(mapViewController, sender: self)
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
        let graphViewController = self.graphViewController()
        graphViewController.entity = entity
        self.showDetailViewController(graphViewController, sender: self)
    }
}

extension HomeViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let entity = self.entityAtIndexPath(indexPath)

        if entity.isScene {
            self.changeState(entity, on: true)
        } else if entity.isDeviceTracker {
            let mapViewController = self.mapViewController()
            mapViewController.configure([entity])
            self.showDetailViewController(mapViewController, sender: self)
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
