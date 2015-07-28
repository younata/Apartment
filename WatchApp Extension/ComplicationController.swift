import ClockKit
import ApartWatchKit

class ComplicationController: NSObject, CLKComplicationDataSource, StatusSubscriber {

    private var bulbs = Array<Bulb>()
    
    lazy var lightsRepository = (WKExtension.sharedExtension().delegate as? ExtensionDelegate)?.statusRepository

    override init() {
        super.init()
        lightsRepository?.addSubscriber(self)
    }

    // MARK: - Timeline Configuration

    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
//        handler([.Forward, .Backward])
        handler([.None])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.HideOnLockScreen) // Don't want the world to know my door is unlocked.
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        self.lightsRepository?.updateBulbs()
        let on = self.bulbs.reduce(0) { $0 + ($1.on ? 1 : 0) }
        let plural = on == 1 ? "" : "s"
        let longText = "\(on) light\(plural) on"
        let shortText = "\(on)/\(self.bulbs.count)"

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
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }

    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        handler(nil)
    }

    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(NSDate(timeIntervalSinceNow: 300));
    }
    // MARK: - StatusSubscriber

    func didUpdateBulbs(bulbs: [Bulb]) {
        self.bulbs = bulbs
    }
}
