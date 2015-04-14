//
//  Bulb.swift
//  Apartment
//
//  Created by Rachel Brindle on 3/31/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

/*
[{"id":3,
"changes":{},
"name":"Hue Lamp 2",
"on":false,
"bri":194,
"hue":15051,
"sat":137,
"xy":[0.4,0.4],
"ct":359,
"transitiontime":null,
"colormode":"ct",
"effect":"none",
"reachable":true,
"alert":"none"}]
*/

import UIKit

class Bulb : Equatable, Printable {
    let id: Int
    let name: String
    let on: Bool

    let brightness: Int
    let hue: Int
    let saturation: Int
    let colorTemperature: Int
    let transitionTime: Int?

    enum ColorMode : String {
        case colorTemperature = "ct"
        case hue = "hs"
        case xy = "xy"
    }

    enum Effect : String {
        case none = "none"
        case colorloop = "colorloop"
    }

    let colorMode: ColorMode
    let effect: Effect

    let reachable: Bool
    let alert: String

    var color : UIColor {
        if colorMode == .colorTemperature {
            return UIColor(mired: CGFloat(colorTemperature))
        } else if colorMode == .hue {
            let saturation = CGFloat(self.saturation) / 254.0
            let hue = CGFloat(self.hue) / 65535.0
            return UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
        } else if colorMode == .xy {
            // not supported yet.
        }
        return UIColor.whiteColor()
    }

    var description: String {
        let a = "id: \(id), name: \(name), on: \(on), brightness: \(brightness), hue: \(hue), saturation: \(saturation), "
        let b = "ct: \(colorTemperature), transitionTime: \(transitionTime), colorMode: \(colorMode.rawValue), effect: \(effect.rawValue), "
        let c = "reachable: \(reachable), alert: \(alert)"

        return a + b + c
    }

    var json: [String: AnyObject] {
        var ret : [String: AnyObject] = [:]
        ret["id"] = id
        ret["name"] = name
        ret["on"] = on
        ret["bri"] = brightness
        ret["hue"] = hue
        ret["sat"] = saturation
        ret["ct"] = colorTemperature
        ret["colormode"] = colorMode.rawValue
        ret["effect"] = effect.rawValue
        ret["reachable"] = reachable
        ret["alert"] = alert
        if transitionTime != nil {
            ret["transitiontime"] = transitionTime
        }

        return ret
    }

    init(id: Int, name: String, on: Bool, brightness: Int, hue: Int,
         saturation: Int, colorTemperature: Int, transitionTime: Int?,
         colorMode: ColorMode, effect: Effect, reachable: Bool, alert: String) {
            self.id = id
            self.name = name
            self.on = on

            self.brightness = brightness
            self.hue = hue
            self.saturation = saturation
            self.colorTemperature = colorTemperature
            self.transitionTime = transitionTime

            self.colorMode = colorMode
            self.effect = effect

            self.reachable = reachable
            self.alert = alert
    }

    init?(json: [String: AnyObject]) {
        transitionTime = json["transitiontime"] as? Int
        if let id = json["id"] as? Int,
           let name = json["name"] as? String,
           let on = json["on"] as? Bool,
           let brightness = json["bri"] as? Int,
           let hue = json["hue"] as? Int,
           let saturation = json["sat"] as? Int,
           let colorTemperature = json["ct"] as? Int,
           let colorModeString = json["colormode"] as? String,
           let colorMode = ColorMode(rawValue: colorModeString),
           let effectString = json["effect"] as? String,
           let effect = Effect(rawValue: effectString),
           let reachable = json["reachable"] as? Bool,
           let alert = json["alert"] as? String {
            self.id = id
            self.name = name
            self.on = on
            self.brightness = brightness
            self.hue = hue
            self.saturation = saturation
            self.colorTemperature = colorTemperature
            self.colorMode = colorMode
            self.effect = effect
            self.reachable = reachable
            self.alert = alert
        } else {
            self.id = -1
            self.name = ""
            self.on = false
            self.brightness = -1
            self.hue = -1
            self.saturation = -1
            self.colorTemperature = -1
            self.colorMode = .hue
            self.effect = .none
            self.reachable = false
            self.alert = ""
            return nil
        }
    }
}

func == (a: Bulb, b: Bulb) -> Bool {
    return a.id == b.id && a.name == b.name && a.on == b.on && a.brightness == b.brightness && a.hue == b.hue &&
           a.saturation == b.saturation && a.colorTemperature == b.colorTemperature && a.colorMode == b.colorMode &&
           a.transitionTime == b.transitionTime && a.effect == b.effect && a.reachable == b.reachable && a.alert == b.alert
}