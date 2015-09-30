import Foundation

public struct Service: Equatable {
    public let domain: String
    public let services: [String]

    public init(domain: String, services: [String]) {
        self.domain = domain
        self.services = services
    }
}

public func ==(a: Service, b: Service) -> Bool {
    return a.domain == b.domain && a.services == b.services
}