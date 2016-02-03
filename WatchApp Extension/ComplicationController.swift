import ClockKit
import ApartWatchKit

class ComplicationController: NSObject, CLKComplicationDataSource, HomeRepositorySubscriber {
    lazy var homeRepository: HomeRepository = {
        let repo = (WKExtension.sharedExtension().delegate as! ExtensionDelegate).homeRepository
        repo.addSubscriber(self)
        return repo
    }()

    var lights = Array<State>()

    func didUpdateStates(states: [State]) {
        self.lights = states.filter { $0.isLight }
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
        // Call the handler with the current timeline entry
        self.homeRepository.states {states in
            self.lights = states.filter { $0.isLight }
            let lightsOn = self.lights.filter { $0.lightState == true }.count
            let longText: String = "\(lightsOn) lights on"
            let shortText: String = "\(lightsOn) / \(self.lights.count)"

            let template : CLKComplicationTemplate?

            switch (complication.family) {
            case .ModularSmall:
                let textTemplate = CLKComplicationTemplateModularSmallSimpleText()
                textTemplate.textProvider = CLKSimpleTextProvider(text: longText, shortText: shortText)
                template = textTemplate
            case .ModularLarge:
                let textTemplate = CLKComplicationTemplateModularLargeStandardBody()
                textTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Apartment")
                textTemplate.body1TextProvider = CLKSimpleTextProvider(text: longText)
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
        handler(NSDate(timeIntervalSinceNow: 300));
    }
}
