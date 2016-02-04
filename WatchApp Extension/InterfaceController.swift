import WatchKit
import Foundation
import ApartWatchKit


class InterfaceController: WKInterfaceController {
    private var states = [State]()
    private var groups = [(State, [State])]()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        let homeRepository = (WKExtension.sharedExtension().delegate as! ExtensionDelegate).homeRepository
        homeRepository.apiAvailable {
            guard $0 else {
                print("api not available! probably not logged in ):")
                return
            }
            homeRepository.services { _ in } // refresh the cache
            homeRepository.states { states in
                self.states = states
                let groups = states.filter { $0.isGroup && $0.groupAutoCreated == false }
                var groupData = Array<(State, [State])>()
                for group in groups {
                    if let entities = group.groupEntities {
                        let groupStates = states.filter({ entities.contains($0.entityId) && !$0.hidden }).sort({$0.displayName < $1.displayName})
                        groupData.append((group, groupStates))
                    }
                }

                self.groups = groupData.sort { $0.0.displayName.lowercaseString < $1.0.displayName.lowercaseString }

                let contexts = self.groups.map { GroupControllerContext(group: $0, homeRepository: homeRepository) }
                let names: [String] = contexts.map { _ in "groupController" }
                WKInterfaceController.reloadRootControllersWithNames(names, contexts: contexts)
            }
        }
    }
}
