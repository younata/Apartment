import CoreLocation

public struct HomeConfiguration: Equatable, CustomStringConvertible {
    public let components: [String]
    public let coordinate: CLLocationCoordinate2D
    public let name: String
    public let temperatureUnit: String
    public let timeZone: NSTimeZone
    public let version: String

    public var description: String {
        return "<HomeConfiguration name: \(self.name), coordinate: \(self.coordinate), temperatureUnit: \(self.temperatureUnit), timeZone: \(self.timeZone), version: \(self.version), components: \(self.components)>"
    }

    public init(components: [String], coordinate: CLLocationCoordinate2D, name: String, temperatureUnit: String, timeZone: NSTimeZone, version: String) {
        self.components = components
        self.coordinate = coordinate
        self.name = name
        self.temperatureUnit = temperatureUnit
        self.timeZone = timeZone
        self.version = version
    }
}

public func ==(a: HomeConfiguration, b: HomeConfiguration) -> Bool {
    return a.components == b.components && a.coordinate == b.coordinate && a.name == b.name &&
        a.temperatureUnit == b.temperatureUnit && a.timeZone == b.timeZone && a.version == b.version
}

extension CLLocationCoordinate2D: Equatable {}

public func ==(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> Bool {
    return fabs(a.longitude - b.longitude) < 1e-6 && fabs(a.latitude - b.latitude) < 1e-6
}