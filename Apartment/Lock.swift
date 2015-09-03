import Foundation

public class Lock: Equatable, CustomStringConvertible {
    public enum LockStatus {
        case Locked
        case Unlocked
    }

    public let id: String
    public let locked: LockStatus?
    public let name: String

    public var description: String {
        let lockStatus = locked == .Locked ? "Locked" : "Unlocked"
        return "id: \(id), locked: \(lockStatus)"
    }

    public init(json: [String: AnyObject]) {
        self.id = json["uuid"] as? String ?? ""
        self.name = ""
        if let locked = json["locked"] as? Bool {
            self.locked = locked ? LockStatus.Locked : LockStatus.Unlocked
        } else {
            self.locked = nil
        }
    }

    public init(id: String, locked: LockStatus, name: String) {
        self.id = id
        self.locked = locked
        self.name = name
    }
}

public func == (a: Lock, b: Lock) -> Bool {
    return a.id == b.id
}
