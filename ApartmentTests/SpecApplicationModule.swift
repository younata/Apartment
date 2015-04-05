//
//  SpecApplicationModule.swift
//  Apartment
//
//  Created by Rachel Brindle on 3/30/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import Ra
import MockHTTP
import Alamofire

class SpecApplicationModule : ApplicationModule {
    private var configuration : NSURLSessionConfiguration! = nil
    override func configureInjector(injector: Ra.Injector) {
        super.configureInjector(injector)

        configuration = injector.create(NSURLSessionConfiguration.self) as! NSURLSessionConfiguration
        MockHTTP.startMocking(configuration)
        injector.bind(NSURLSessionConfiguration.self, to: self.configuration)

        let defaultResponse = MockHTTP.URLResponse(statusCode: 404, headers: [:], body: nil, error: nil)
        injector.bind(kNetworkManager, to: Alamofire.Manager(configuration: self.configuration))
    }

    func afterTests() {
        MockHTTP.stopMocking(configuration)
    }
}