import Foundation

public protocol StatusSubscriber {
    func didUpdateBulbs(bulbs: [Bulb])
}

public class StatusRepository {
    public internal(set) lazy var lightsService: LightsService = {
        return LightsService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")
    }()

    var bulbs: [Bulb] = []
    var lastRetreivedBulbs: NSDate? = nil

    public var backendURL = "" {
        didSet {
            self.lightsService.backendURL = backendURL
        }
    }
    public var authenticationToken = "" {
        didSet {
            self.lightsService.authenticationToken = authenticationToken
        }
    }

    private var subscribers = Array<StatusSubscriber>()

    public func addSubscriber(subscriber: StatusSubscriber) {
        self.subscribers.append(subscriber)
        self.updateBulbs()
    }

    private var updateBulbsRequested = false
    public func updateBulbs() {
        if (lastRetreivedBulbs?.timeIntervalSinceNow > -300) {
            for statusSubscriber in self.subscribers {
                statusSubscriber.didUpdateBulbs(self.bulbs)
            }
            return
        }
        if (!updateBulbsRequested) {
            lightsService.allBulbs {result, _ in
                self.bulbs = result ?? []
                for statusSubscriber in self.subscribers {
                    statusSubscriber.didUpdateBulbs(self.bulbs)
                }
                self.updateBulbsRequested = false
                self.lastRetreivedBulbs = NSDate()
            }
            updateBulbsRequested = true
        }
    }

    public init() {}
}
