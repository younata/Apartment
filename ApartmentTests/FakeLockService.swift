import Foundation
import ApartKit

class FakeLockService: LockService {
    var didReceiveAllLocks: Bool = false
    var allLocksHandler: ([Lock]?, NSError?) -> (Void) = {_, _ in }
    override func allLocks(completionHandler: ([Lock]?, NSError?) -> (Void)) {
        didReceiveAllLocks = true
        allLocksHandler = completionHandler
    }

    var locksHandler: [String: (Lock?, NSError?) -> (Void)] = [:]
    override func lock(id: String, completionHandler: (Lock?, NSError?) -> (Void)) {
        locksHandler[id] = completionHandler
    }

    var locksUpdateHandler: [String: (Lock?, NSError?) -> (Void)] = [:]
    override func update_lock(lock: Lock, to_lock: Lock.LockStatus, completionHandler: (Lock?, NSError?) -> (Void)) {
        locksUpdateHandler[lock.id] = completionHandler
    }
}