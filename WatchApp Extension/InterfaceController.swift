import WatchKit
import Foundation
import ApartWatchKit


class InterfaceController: WKInterfaceController {
    private var states = [State]()
    private var groups = [Group]()

    private var homeRepository: HomeRepository?

    private var timer: NSTimer?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.homeRepository = (WKExtension.sharedExtension().delegate as! ExtensionDelegate).homeRepository
        self.checkIfLoggedIn()
    }

    @objc private func checkIfLoggedIn() {
        self.homeRepository?.apiAvailable { loggedIn in
            guard loggedIn else {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("checkIfLoggedIn"), userInfo: nil, repeats: false)
                return
            }
            self.timer?.invalidate()
            self.timer = nil
            self.homeRepository!.services { _ in } // refresh the cache
            self.homeRepository!.groups(includeScenes: false) { states, groups in
                self.states = states
                self.groups = groups

                let contexts = self.groups.map { GroupControllerContext(group: $0, homeRepository: self.homeRepository!) }
                let names: [String] = contexts.map { _ in "groupController" }
                WKInterfaceController.reloadRootControllersWithNames(names, contexts: contexts)
            }
        }
    }
}
