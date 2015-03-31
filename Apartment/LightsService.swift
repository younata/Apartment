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
        Alamofire.request(.GET, self.backendURL + "api/v1/bulbs", parameters: nil, encoding: .JSON).response {(_, _, result, error) in
            if (error != nil) {
                completionHandler(nil, error)
            } else {
//                completionHandler(result, nil)
            }
        }
    }
}