import WatchKit
import Foundation
import ApartWatchKit


class InterfaceController: WKInterfaceController {
    private var states = [State]()
    private var groups = [(State, [State])]()

    private var homeRepository: HomeRepository!

    private var timer: NSTimer?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.homeRepository = (WKExtension.sharedExtension().delegate as! ExtensionDelegate).homeRepository
        self.checkIfLoggedIn()
    }

    @objc private func checkIfLoggedIn() {
        self.homeRepository.apiAvailable {
            guard $0 else {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("checkIfLoggedIn"), userInfo: nil, repeats: false)
                return
            }
            self.timer?.invalidate()
            self.timer = nil
            self.homeRepository.services { _ in } // refresh the cache
            self.homeRepository.states { states in
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

                let contexts = self.groups.map { GroupControllerContext(group: $0, homeRepository: self.homeRepository) }
                let names: [String] = contexts.map { _ in "groupController" }
                WKInterfaceController.reloadRootControllersWithNames(names, contexts: contexts)
            }
        }
    }
}
