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
                nameLabel.text = bulb.name
                brightnessSlider.minimumTrackTintColor = bulb.color
                brightnessSlider.enabled = bulb.reachable
                brightnessSlider.value = !bulb.on ? 0 : Float(bulb.brightness) / 254.0
            } else {

            }
        }
    }

    var lightsService : LightsService? = nil

    let nameLabel = UILabel()
    let brightnessSlider = UISlider()

    func didChangeBrightness() {
        if let lightsService = lightsService,
           let bulb = bulb {
            var attributes: [String: AnyObject] = [:]
            if abs(brightnessSlider.value) < 1e-6 {
                attributes["on"] = false
            } else {
                attributes["bri"] = Int(round(brightnessSlider.value * 254))
                if !bulb.on {
                    attributes["on"] = true
                }
            }

            lightsService.update(bulb, attributes: attributes) {bulb, error in
                self.bulb = bulb
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        contentView.addSubview(nameLabel)
        contentView.addSubview(brightnessSlider)

        rippleLayerColor = UIColor.whiteColor().darkerColor()

        brightnessSlider.addTarget(self, action: "didChangeBrightness", forControlEvents: .ValueChanged)

        layout(nameLabel, brightnessSlider) {nl, bs in
            nl.leading == nl.superview!.leading + 8
            nl.top == nl.superview!.top + 4
            nl.bottom == nl.superview!.bottom + 4
            nl.trailing == bs.leading + 8

            bs.trailing == bs.superview!.trailing - 8
            bs.centerY == bs.superview!.centerY
            bs.width == bs.superview!.width / 2
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
