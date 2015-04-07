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
            if error != nil {
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
                    let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert \(result) to array of Bulb objects"])
                    completionHandler(nil, error)
                }
            }
        }
    }

    func bulb(id: Int, completionHandler: (Bulb?, NSError?) -> (Void)) {
        self.bulb("\(id)", completionHandler: completionHandler)
    }

    func bulb(name: String, completionHandler: (Bulb?, NSError?) -> (Void)) {
        if let id = name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
            self.manager.request(.GET, self.backendURL + "api/v1/bulb/" + id, parameters: nil, encoding: .JSON).responseJSON {(_, _, result, error) in
                if error != nil {
                    completionHandler(nil, error)
                } else if let result = result as? [String: AnyObject],
                          let bulb = Bulb(json: result) {
                    completionHandler(bulb, error)
                } else {
                    let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert \(result) to Bulb object"])
                    completionHandler(nil, error)
                }
            }
        }
    }

    func update(bulb: Bulb, attributes: [String: AnyObject], completionHandler: (Bulb?, NSError?) -> (Void)) {
        let id = bulb.id

        func generateQuery(parameters: [String: AnyObject]) -> String {
            var components: [(String, String)] = []
            for key in sorted(Array(parameters.keys), <) {
                let value : AnyObject = parameters[key]!
                components += [key: "\(value.description)"]
            }

            return join("&", components.map{"\($0)=\($1)"} as [String])
        }

        let query = "?" + generateQuery(attributes)

        self.manager.request(.PUT, self.backendURL + "api/v1/bulb/\(id)" + query).responseJSON {(_, _, result, error) in
            if error != nil {
//                completionHandler(nil, error)
            } else if let result = result as? [String: AnyObject],
                      let bulb = Bulb(json: result) {
                completionHandler(bulb, error)
            } else {
                let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert \(result) to Bulb object"])
                completionHandler(nil, error)
            }
        }
    }
}