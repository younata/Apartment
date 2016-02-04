import Foundation
import CoreLocation

public struct State: Equatable {
    public let attributes: [String: AnyObject]
    public let entityId: String
    public let lastChanged: NSDate
    public let lastUpdated: NSDate
    public let state: String

    public init(attributes: [String: AnyObject], entityId: String, lastChanged: NSDate, lastUpdated: NSDate, state: String) {
        self.attributes = attributes
        self.entityId = entityId
        self.lastChanged = lastChanged
        self.lastUpdated = lastUpdated
        self.state = state
    }
}

extension State {
    public var displayName: String {
        return self.attributes["friendly_name"] as? String ?? self.entityId
    }

    public var domain: String? {
        return self.entityId.componentsSeparatedByString(".").first
    }

    public var hidden: Bool {
        return self.attributes["hidden"] as? Bool == true
    }
}

extension State: CustomStringConvertible {
    public var description: String {
        return "<State: entityId: \(self.entityId), state: \(self.state)>"
    }
}

// MARK: - Serializable

extension State {
    public var jsonObject: [String: AnyObject] {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return [
            "attributes": self.attributes,
            "entity_id": self.entityId,
            "last_changed": dateFormatter.stringFromDate(self.lastChanged),
            "last_updated": dateFormatter.stringFromDate(self.lastUpdated),
            "state": self.state
        ]
    }

    public static func NewFromJSON(jsonObject: [String: AnyObject]) -> State? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        if let attributes = jsonObject["attributes"] as? [String: AnyObject],
            entityId = jsonObject["entity_id"] as? String,
            lastChangedStr = jsonObject["last_changed"] as? String,
            lastChanged = dateFormatter.dateFromString(lastChangedStr),
            lastUpdatedStr = jsonObject["last_updated"] as? String,
            lastUpdated = dateFormatter.dateFromString(lastUpdatedStr),
            state = jsonObject["state"] as? String {
                return State(attributes: attributes, entityId: entityId, lastChanged: lastChanged, lastUpdated: lastUpdated, state: state)
        }
        return nil
    }
}

// MARK: - Sensor

extension State {
    public var isSensor: Bool {
        return self.entityId.hasPrefix("sensor")
    }

    public var sensorUnitOfMeasurement: String? {
        return self.attributes["unit_of_measurement"] as? String
    }

    public var sensorState: Double? {
        let number = NSNumberFormatter().numberFromString(self.state)
        return number?.doubleValue
    }
}

// MARK: - Group

extension State {
    public var isGroup: Bool {
        return self.entityId.hasPrefix("group")
    }

    public var groupEntities: [String]? {
        return self.attributes["entity_id"] as? [String]
    }

    public var groupAutoCreated: Bool? {
        return self.attributes["auto"] as? Bool
    }
}

// MARK: - Scene

extension State {
    public var isScene: Bool {
        return self.entityId.hasPrefix("scene")
    }

    public var sceneEntities: [String]? {
        return self.groupEntities
    }

    public var sceneActiveRequested: Bool? {
        return self.attributes["active_requested"] as? Bool
    }
}

// MARK: - Switch

extension State {
    public var isSwitch: Bool {
        return self.entityId.hasPrefix("switch")
    }

    public var switchState: Bool? {
        return self.lightState
    }
}

// MARK: - Light

extension State {
    public var isLight: Bool {
        return self.entityId.hasPrefix("light")
    }

    public var lightBrightness: Int? {
        return self.attributes["brightness"] as? Int
    }

    public var lightXYColor: [Double] {
        return self.attributes["xy_color"] as? [Double] ?? []
    }

    public var lightState: Bool? {
        if self.state == "on" {
            return true
        } else if self.state == "off" {
            return false
        }
        return nil
    }
}

// MARK: - Device Tracker

extension State {
    public var isDeviceTracker: Bool {
        return self.entityId.hasPrefix("device_tracker")
    }

    public var trackerLatitude: Double? {
        return self.attributes["latitude"] as? Double
    }

    public var trackerLongitude: Double? {
        return self.attributes["longitude"] as? Double
    }

    public var trackerBattery: Int? {
        return self.attributes["battery"] as? Int
    }

    public var trackerAccuracy: Int? {
        return self.attributes["gps_accuracy"] as? Int
    }

    public var trackerCoordinate: CLLocationCoordinate2D? {
        if let latitude = self.trackerLatitude, longitude = self.trackerLatitude where self.isDeviceTracker {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
}

// MARK: - Zone

extension State {
    public var isZone: Bool {
        return self.entityId.hasPrefix("zone")
    }

    public var iconUrl: NSURL? {
        return nil
    }

    public var zoneLatitude: Double? {
        return self.trackerLatitude
    }

    public var zoneLongitude: Double? {
        return self.trackerLongitude
    }

    public var zoneCoordinate: CLLocationCoordinate2D? {
        return self.trackerCoordinate
    }

    public var zoneRadius: Int? {
        return self.attributes["radius"] as? Int
    }
}

// MARK: - Sun

extension State {
    public var isSun: Bool {
        return self.entityId.hasPrefix("sun")
    }

    public var sunNextRising: NSDate? {
        if let nextRisingStr = self.attributes["next_rising"] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"

            return dateFormatter.dateFromString(nextRisingStr)
        }
        return nil
    }

    public var sunNextSetting: NSDate? {
        if let nextSettingStr = self.attributes["next_setting"] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"

            return dateFormatter.dateFromString(nextSettingStr)
        }
        return nil
    }
}

public func ==(a: State, b: State) -> Bool {
    return a.entityId == b.entityId && a.lastChanged == b.lastChanged && a.state == b.state
}