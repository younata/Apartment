//
//  ApplicationModule.swift
//  Apartment
//
//  Created by Rachel Brindle on 3/30/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import Foundation
import Ra
import Alamofire

let kBackendService = "kBackendService"
let kLightsService = "kLightsService"
let kNetworkManager = "kNetworkManager"
let kAuthenticationToken = "kAuthenticationToken"

class ApplicationModule {
    func configureInjector(injector: Ra.Injector) {
        injector.bind(kBackendService) {
            NSUserDefaults.standardUserDefaults().stringForKey(kBackendService) ?? "http://localhost:3000/"
        }

        injector.bind(NSURLSessionConfiguration.self) {
            let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
            let token = injector.create(kAuthenticationToken) as? String ?? "HelloWorld"
            conf.HTTPAdditionalHeaders = ["Authentication": "Token token=\(token)"]
            return conf
        }

        injector.bind(kNetworkManager) {
            Alamofire.Manager(configuration: injector.create(NSURLSessionConfiguration.self) as? NSURLSessionConfiguration)
        }

        injector.bind(kLightsService) {
            let manager = injector.create(kNetworkManager) as! Alamofire.Manager
            return LightsService(backendURL: injector.create(kBackendService) as! String, manager: manager)
        }
    }
}
