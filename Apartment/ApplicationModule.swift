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

class ApplicationModule {
    func configureInjector(injector: Ra.Injector) {
        injector.bind(kBackendService) {
            NSUserDefaults.standardUserDefaults().stringForKey(kBackendService) ?? "http://localhost:3000/"
        }

        let manager = Alamofire.Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        injector.bind(kNetworkManager, to: manager)

        injector.bind(kLightsService) {
            let manager = injector.create(kNetworkManager) as! Alamofire.Manager
            return LightsService(backendURL: injector.create(kBackendService) as! String, manager: manager)
        }
    }
}
