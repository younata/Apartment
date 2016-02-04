import WatchKit
import Foundation
import ApartWatchKit

class SwitchTableRowController: NSObject {
    @IBOutlet var interfaceSwitch: WKInterfaceSwitch!

    var homeRepository: HomeRepository?

    var entity: State? {
        didSet {
            if let theEntity = entity where theEntity.isSwitch || theEntity.isLight {
                self.interfaceSwitch.setTitle(theEntity.displayName)
                self.interfaceSwitch.setOn(theEntity.switchState ?? false)
            } else {
                self.interfaceSwitch.setTitle(nil)
                self.interfaceSwitch.setOn(false)
            }
        }
    }

    @IBAction func switchWasToggled(on: Bool) {
        guard let homeRepository = self.homeRepository, entity = self.entity else { return }
        homeRepository.services { services in
            let method = on ? "turn_on" : "turn_off"
            if let service = self.serviceForDomain(entity.domain ?? "", services: services) {
                homeRepository.updateService(service, method: method, onEntity: entity) { _ in }
            }
        }
    }

    private func serviceForDomain(domain: String, services: [Service]) -> Service? {
        if let service = services.filter({
            $0.domain == domain
        }).first {
            return service
        }
        return services.filter {
            $0.domain == "homeassistant"
        }.first
    }
}

class ButtonTableRowController: NSObject {
    @IBOutlet var label: WKInterfaceLabel!

    var entity: State? {
        didSet {
            label.setText(entity?.displayName)
        }
    }
}

class GroupControllerContext {
    let group: (State, [State])
    let homeRepository: HomeRepository

    init(group: (State, [State]), homeRepository: HomeRepository) {
        self.group = group
        self.homeRepository = homeRepository
    }
}

class GroupInterfaceController: WKInterfaceController {
    var group: (State, [State])?
    var homeRepository: HomeRepository?

    @IBOutlet var table: WKInterfaceTable!

    private enum RowType: String {
        case Switch = "switchRow"
        case Label = "buttonRow"
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        let context = context as? GroupControllerContext

        self.group = context?.group
        self.homeRepository = context?.homeRepository

        if let group = self.group {
            self.setTitle(group.0.displayName)

            self.table.setRowTypes([RowType.Switch.rawValue, RowType.Label.rawValue])

            self.table.setNumberOfRows(0, withRowType: "")

            for (idx, entity) in group.1.enumerate() {
                let rowType = entity.isSwitch || entity.isLight ? RowType.Switch.rawValue : RowType.Label.rawValue
                self.table.insertRowsAtIndexes(NSIndexSet(index: idx), withRowType: rowType)
                let rowController = self.table.rowControllerAtIndex(idx)
                if let switchController = rowController as? SwitchTableRowController {
                    switchController.homeRepository = self.homeRepository
                    switchController.entity = entity
                } else if let labelController = rowController as? ButtonTableRowController {
                    labelController.entity = entity
                }
            }
        }
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if let entity = self.group?.1[rowIndex] where entity.isDeviceTracker || entity.isZone {
            let context = MapControllerContext(entity: entity)
            self.presentControllerWithName("mapController", context: context)
        }
    }
}
