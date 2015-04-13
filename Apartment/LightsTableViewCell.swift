//
//  LightsTableViewCell.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/12/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import MaterialKit
import Cartography

class LightsTableViewCell: MKTableViewCell {

    var bulb : Bulb? = nil {
        didSet {
            if let bulb = bulb {

            } else {

            }
        }
    }

    var lightsService : LightsService? = nil

    let nameLabel = UILabel()
    let brightnessSlider = UISlider()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        contentView.addSubview(nameLabel)
        contentView.addSubview(brightnessSlider)

        layout(nameLabel, brightnessSlider) {nl, bs in
            nl.leading == nl.superview!.leading + 8
            nl.top == nl.superview!.top + 4
            nl.bottom == nl.superview!.bottom + 4
            nl.trailing == bs.leading + 8

            bs.trailing == bs.superview!.trailing - 8
            bs.top == bs.superview!.top + 4
            bs.bottom == bs.superview!.top + 4
            bs.width == bs.superview!.width / 2
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
