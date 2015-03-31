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

struct Bulb {
    var id: Int
    var name: String
    var on: Bool

    var brightness: Int
    var hue: Int
    var saturation: Int
    var colorTemperature: Int
    var transitionTime: Int?

    var colorMode: String
    var effect: String

    var reachable: Bool
    var alert: String

    init?(json: [String: AnyObject]) {
        transitionTime = json["transitiontime"] as? Int
        if let id = json["id"] as? Int,
           let name = json["name"] as? String,
           let on = json["on"] as? Bool,
           let brightness = json["bri"] as? Int,
           let hue = json["hue"] as? Int,
           let saturation = json["sat"] as? Int,
           let colorTemperature = json["ct"] as? Int,
           let colorMode = json["colormode"] as? String,
           let effect = json["effect"] as? String,
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
            return nil
        }
    }
}