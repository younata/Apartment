//
//  LightsService.swift
//  Apartment
//
//  Created by Rachel Brindle on 3/30/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import Alamofire

class LightsService {
    let backendURL : String
    let manager : Alamofire.Manager
    init(backendURL: String, manager: Alamofire.Manager) {
        self.backendURL = backendURL
        self.manager = manager
    }

    func allBulbs(completionHandler: ([Bulb]?, NSError?) -> (Void)) {
        self.manager.request(.GET, self.backendURL + "api/v1/bulbs", parameters: nil, encoding: .JSON).responseJSON {(_, _, result, error) in
            if (error != nil) {
                completionHandler(nil, error)
            } else if let result: AnyObject = result {
                if let res = result as? [String: AnyObject],
                    let bulb = Bulb(json: res) {
                        completionHandler([bulb], nil)
                } else if let res = result as? [[String: AnyObject]] {
                    let bulbs = res.reduce([Bulb]()) {(bulbs, json) in
                        if let bulb = Bulb(json: json) {
                            return bulbs + [bulb]
                        } else {
                            return bulbs
                        }
                    }
                    completionHandler(bulbs, nil)
                } else {
                    println("\(result)")
                    let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert \(result) to array of Bulb objects"])
                    completionHandler(nil, error)
                }
            }
        }
    }
}