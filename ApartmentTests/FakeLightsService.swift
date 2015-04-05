//
//  FakeLightsService.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/4/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import Foundation

class FakeLightsService : LightsService {
    var didReceiveAllBulbs: Bool = false
    var allBulbsHandler : ([Bulb]?, NSError?) -> (Void) = {(_, _) in }

    override func allBulbs(completionHandler: ([Bulb]?, NSError?) -> (Void)) {
        allBulbsHandler = completionHandler
        didReceiveAllBulbs = true
    }

    var bulbsIDHandler : [Int: (Bulb?, NSError?) -> (Void)] = [:]
    override func bulb(id: Int, completionHandler: (Bulb?, NSError?) -> (Void)) {
        bulbsIDHandler[id] = completionHandler
    }

    var bulbsNameHandler : [String: (Bulb?, NSError?) -> (Void)] = [:]
    override func bulb(name: String, completionHandler: (Bulb?, NSError?) -> (Void)) {
        bulbsNameHandler[name] = completionHandler
    }
}