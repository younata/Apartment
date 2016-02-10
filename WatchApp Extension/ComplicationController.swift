import ClockKit
import ApartWatchKit

class ComplicationController: NSObject, CLKComplicationDataSource, HomeRepositorySubscriber {
    var homeRepository: HomeRepository?
    private var entity: State? {
        didSet {
            if oldValue != self.entity {
                self.askComplicationServerToReload()
            }
        }
    }

    override init() {
        super.init()

        self.homeRepository = (WKExtension.sharedExtension().delegate as! ExtensionDelegate).homeRepository
        self.homeRepository?.addSubscriber(self)
    }

    func didChangeLoginStatus(loggedIn: Bool) {
        if !loggedIn {
            self.entity = nil
        } else {
            self.reloadComplicationEntity()
        }
    }

    func reloadComplicationEntity() {
        self.homeRepository?.watchComplicationEntity {
            self.entity = $0
        }
    }

    func askComplicationServerToReload() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        for complication in complicationServer.activeComplications {
            complicationServer.reloadTimelineForComplication(complication)
        }
    }

    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.None])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.HideOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        guard let entity = self.entity else {
            handler(nil)
            return
        }

        let longText: String = entity.displayName
        let shortText: String = entity.state.desnake

        let template : CLKComplicationTemplate?

        switch (complication.family) {
        case .ModularSmall:
            let textTemplate = CLKComplicationTemplateModularSmallSimpleText()
            textTemplate.textProvider = CLKSimpleTextProvider(text: longText, shortText: shortText)
            template = textTemplate
        case .ModularLarge:
            let textTemplate = CLKComplicationTemplateModularLargeStandardBody()
            textTemplate.headerTextProvider = CLKSimpleTextProvider(text: longText)
            textTemplate.body1TextProvider = CLKSimpleTextProvider(text: shortText)
            template = textTemplate
        case .UtilitarianSmall:
            let textTemplate = CLKComplicationTemplateUtilitarianSmallRingText()
            textTemplate.textProvider = CLKSimpleTextProvider(text: shortText)
            template = textTemplate
        case .CircularSmall:
            let textTemplate = CLKComplicationTemplateCircularSmallSimpleText()
            textTemplate.textProvider = CLKSimpleTextProvider(text: longText, shortText: shortText)
            template = textTemplate
        default:
            template = nil
        }
        if let template = template {
            handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template))
        } else {
            handler(nil)
        }
    }

    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        handler(nil)
    }

    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        handler(nil)
    }

    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        handler(NSDate(timeIntervalSinceNow: 360))
    }

    func requestedUpdateDidBegin() {
        self.reloadComplicationEntity()
    }
}
