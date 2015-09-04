import Foundation

public protocol StatusSubscriber {
    func didUpdateBulbs(bulbs: [Bulb])
    func didUpdateLocks(locks: [Lock])
}

public class StatusRepository {
    public internal(set) lazy var lightsService: LightsService = {
        return LightsService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "", mainQueue: NSOperationQueue.mainQueue())
    }()

    public internal(set) lazy var lockService: LockService = {
        return LockService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "", mainQueue: NSOperationQueue.mainQueue())
    }()

    public internal(set) var bulbs: [Bulb] = []
    public internal(set) var lastRetreivedBulbs: NSDate? = nil

    public internal(set) var locks: [Lock] = []
    public internal(set) var lastRetreivedLocks: NSDate? = nil

    public var backendURL = "" {
        didSet {
            self.lightsService.backendURL = backendURL
            self.lockService.backendURL = backendURL
        }
    }
    public var authenticationToken = "" {
        didSet {
            self.lightsService.authenticationToken = authenticationToken
            self.lockService.authenticationToken = authenticationToken
        }
    }

    private var subscribers = Array<StatusSubscriber>()

    public func addSubscriber(subscriber: StatusSubscriber) {
        self.subscribers.append(subscriber)
        self.updateBulbs()
        self.updateLocks()
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

    private var updateLocksRequested = false
    public func updateLocks() {
        if (lastRetreivedLocks?.timeIntervalSinceNow > -300) {
            for statusSubscriber in self.subscribers {
                statusSubscriber.didUpdateLocks(self.locks)
            }
            return
        }
        if (!updateLocksRequested) {
            lockService.allLocks {result, _ in
                self.locks = result ?? []
                for statusSubscriber in self.subscribers {
                    statusSubscriber.didUpdateLocks(self.locks)
                }
                self.updateLocksRequested = false
                self.lastRetreivedLocks = NSDate()
            }
            updateLocksRequested = true
        }
    }

    public init() {}
}
