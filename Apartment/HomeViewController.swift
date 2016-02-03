import UIKit
import Ra
import ApartKit
import PureLayout_iOS

public class HomeViewController: UIViewController {

    private var states = Array<State>()
    private var groups = Array<(String, [State])>()

    private var services = Array<Service>()

    private lazy var homeAssistantRepository: HomeAssistantRepository = {
        return self.injector!.create(HomeAssistantRepository.self) as! HomeAssistantRepository
    }()

    private lazy var homeAssistantRepository: HomeAssistantRepository = {
        return self.injector!.create(HomeAssistantRepository.self) as! HomeAssistantRepository
    }()

    private var homeAssistantService: HomeAssistantService {
        return self.homeAssistantRepository.homeService
    }

    private lazy var tableViewController = UITableViewController(style: .Grouped)

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
        self.tableView.tableFooterView = UIView()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: "switch")

        self.tableViewController.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("refresh"), forControlEvents: .ValueChanged)

        self.refreshControl?.beginRefreshing()
        self.refresh()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Private

    @objc private func refresh() {
        self.homeAssistantRepository.states(true) {states in
            self.states = states

            let groups = states.filter { $0.isGroup }
            var groupData = Array<(String, [State])>()
            for group in groups {
                if let entities = group.groupEntities, displayName = group.displayName {
                    let groupStates = states.filter({ entities.contains($0.entityId) }).sort({$0.entityId < $1.entityId})
                    groupData.append((displayName, groupStates))
                }
            }

            let scenes = states.filter { $0.isScene }
            groupData.append(("scenes", scenes))

            self.groups = groupData.sort { $0.0.lowercaseString < $1.0.lowercaseString }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
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
        if let name = state.displayName {
            cell.textLabel?.text = name
        }
        if let switchCell = cell as? SwitchTableViewCell {
            switchCell.cellSwitch.on = state.switchState ?? false
            switchCell.onSwitchChange = {newState in
                self.changeState(state, on: newState)
            }
        }
        return cell
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.groups[section].0
    }

    private func changeState(state: State, on: Bool) {
        let domains = self.services.map { $0.domain }

        if let domain = state.domain where domains.contains(domain) {
            let service = on ? "turn_on" : "turn_off"
            self.homeAssistantService.callService(service, onDomain: domain, data: ["entity_id": state.entityId]) {states, error in
                self.refreshControl?.beginRefreshing()
                self.refresh()
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let state = self.groups[indexPath.section].1[indexPath.row]

        if let lightState = state.lightState, domain = state.domain where domain == "scene" {
            self.changeState(state, on: !lightState)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
