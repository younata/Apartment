//
//  BulbViewController.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/4/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import Cartography
import MaterialKit

class BulbViewController: UIViewController {

    lazy var lightsService : LightsService = {
        return self.injector!.create(kLightsService) as! LightsService
    }()

    var bulb: Bulb! = nil

    let titleField = MKTextField()

    let colorPicker = ColorPicker()


    func configure(bulb: Bulb) {
        self.bulb = bulb
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let containerView = UIView()
        containerView.backgroundColor = UIColor.whiteColor()

        view.addSubview(containerView)

        edgesForExtendedLayout = .None

        layout(containerView) {view in
            view.leading == view.superview!.leading + 20
            view.top == view.superview!.top + 20
            view.trailing == view.superview!.trailing - 20
            view.height == 200
        }
        containerView.layer.cornerRadius = 5

        titleField.text = bulb.name
        titleField.floatingPlaceholderEnabled = true
        titleField.backgroundLayerColor = UIColor.clearColor()
        titleField.placeholder = NSLocalizedString("Name", comment: "")
        containerView.addSubview(titleField)

        layout(titleField) {view in
            view.leading == view.superview!.leading + 20
            view.trailing == view.superview!.trailing - 20
            view.top == view.superview!.top + 20
        }

        view.addSubview(colorPicker)

        layout(titleField, colorPicker) {tf, cp in
            cp.top == tf.bottom + 8
            cp.leading == tf.leading
            cp.trailing == tf.trailing
            cp.height == 100
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = false
    }
}
