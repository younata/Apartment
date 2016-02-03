import Foundation
@testable import ApartKit

class FakeHomeAssistantService: HomeAssistantService {
    init() {
        super.init(baseURL: NSURL(string: "")!, apiKey: "", urlSession: NSURLSession.sharedSession(), mainQueue: NSOperationQueue.mainQueue())
    }

    override init(baseURL: NSURL, apiKey: String, urlSession: NSURLSession, mainQueue: NSOperationQueue) {
        super.init(baseURL: baseURL, apiKey: apiKey, urlSession: urlSession, mainQueue: mainQueue)
    }

    var eventsCallback: (([Event], NSError?) -> (Void))? = nil
    override func events(callback: ([Event], NSError?) -> (Void)) {
        self.eventsCallback = callback
    }

    var firedEvent: String? = nil
    var firedEventData: [String: AnyObject]? = nil
    var firedEventCallback: ((String?, NSError?) -> (Void))? = nil
    override func fireEvent(event: String, data: [String : AnyObject]?, callback: (String?, NSError?) -> (Void)) {
        self.firedEvent = event
        self.firedEventData = data
        self.firedEventCallback = callback
    }

    var servicesCallback: (([Service], NSError?) -> (Void))? = nil
    override func services(callback: ([Service], NSError?) -> (Void)) {
        self.servicesCallback = callback
    }

    var calledService: String? = nil
    var calledServiceDomain: String? = nil
    var calledServiceData: [String : AnyObject]? = nil
    var calledServiceCallback: (([State], NSError?) -> (Void))? = nil
    override func callService(service: String, onDomain domain: String, data: [String : AnyObject]?, callback: ([State], NSError?) -> (Void)) {
        self.calledService = service
        self.calledServiceDomain = domain
        self.calledServiceData = data
        self.calledServiceCallback = callback
    }

    var statusCallback: (([State], NSError?) -> (Void))? = nil
    override func status(callback: ([State], NSError?) -> (Void)) {
        self.statusCallback = callback
    }

    var statusEntity: String? = nil
    var statusEntityCallback: ((State?, NSError?) -> (Void))? = nil
    override func status(entityId: String, callback: (State?, NSError?) -> (Void)) {
        self.statusEntity = entityId
        self.statusEntityCallback = callback
    }

    var updatedEntity: String? = nil
    var updatedEntityStatus: String? = nil
    var updatedEntityCallback: ((State?, NSError?) -> (Void))? = nil
    override func update(entityId: String, newStatus: String, callback: (State?, NSError?) -> (Void)) {
        self.updatedEntity = entityId
        self.updatedEntityStatus = newStatus
        self.updatedEntityCallback = callback
    }
}