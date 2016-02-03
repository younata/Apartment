import Foundation

public struct Event: Equatable {
    public let name: String
    public let listenerCount: Int

    public init(name: String, listenerCount: Int) {
        self.name = name
        self.listenerCount = listenerCount
    }
}

public func ==(a: Event, b: Event) -> Bool {
    return a.name == b.name && a.listenerCount == b.listenerCount
}
