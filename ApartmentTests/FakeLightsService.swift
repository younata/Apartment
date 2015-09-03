import Foundation
import ApartKit

class FakeLightsService: LightsService {
    var didReceiveAllBulbs: Bool = false
    var allBulbsHandler: ([Bulb]?, NSError?) -> (Void) = {(_, _) in }

    override func allBulbs(completionHandler: ([Bulb]?, NSError?) -> (Void)) {
        allBulbsHandler = completionHandler
        didReceiveAllBulbs = true
    }

    var bulbsIDHandler: [Int: (Bulb?, NSError?) -> (Void)] = [:]
    override func bulb(id: Int, completionHandler: (Bulb?, NSError?) -> (Void)) {
        bulbsIDHandler[id] = completionHandler
    }

    var bulbsNameHandler: [String: (Bulb?, NSError?) -> (Void)] = [:]
    override func bulb(name: String, completionHandler: (Bulb?, NSError?) -> (Void)) {
        bulbsNameHandler[name] = completionHandler
    }

    var bulbsUpdateHandler: [Int: (Bulb?, NSError?) -> (Void)] = [:]
    var bulbsUpdateStatus: [Int: [String: AnyObject]] = [:]
    override func update(bulb: Bulb, attributes: [String : AnyObject], completionHandler: (Bulb?, NSError?) -> (Void)) {
        bulbsUpdateStatus[bulb.id] = attributes
        bulbsUpdateHandler[bulb.id] = completionHandler
    }
}