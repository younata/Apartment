//
//  BulbViewController.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/4/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit

class BulbViewController: UIViewController {

    lazy var lightsService : LightsService = {
        return self.injector!.create(kLightsService) as! LightsService
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
