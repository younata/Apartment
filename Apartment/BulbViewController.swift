//
//  BulbViewController.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/4/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import Cartography

class BulbViewController: UIViewController {

    lazy var lightsService : LightsService = {
        return self.injector!.create(kLightsService) as! LightsService
    }()

    var bulb: Bulb! = nil

    func configure(bulb: Bulb) {
        self.bulb = bulb
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let containerView = UIView()
        containerView.backgroundColor = UIColor.whiteColor()

        view.addSubview(containerView)

        layout(containerView) {view in
            view.edges == inset(view.superview!.edges, 20, 20, 20, 20)
        }
        containerView.layer.cornerRadius = 5


    }
}
