import WatchKit
import Foundation
import ApartWatchKit

class GlanceController: WKInterfaceController, HomeRepositorySubscriber {
    @IBOutlet var titleLabel: WKInterfaceLabel!

    @IBOutlet var detailLabel: WKInterfaceLabel!

    var homeRepository: HomeRepository?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.homeRepository = (WKExtension.sharedExtension().delegate as! ExtensionDelegate).homeRepository
        self.homeRepository?.addSubscriber(self)
        self.refreshGlanceEntity()
    }

    func refreshGlanceEntity() {
        self.homeRepository?.watchGlanceEntity { entity in
            self.titleLabel.setText(entity?.displayName ?? "N/A")
            self.detailLabel.setText(entity?.state.desnake ?? "Glance State Not Set")
        }
    }

    func didChangeLoginStatus(loggedIn: Bool) {
        if loggedIn {
            self.refreshGlanceEntity()
        } else {
            self.titleLabel.setText("N/A")
            self.detailLabel.setText("Not Logged In")
        }
    }
}
