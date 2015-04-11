//
//  ColorPicker.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/9/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit

class ColorPicker: UIControl {

    var hue : CGFloat = 0.0 {
        didSet {
            selectedPoint.x = hue * bounds.width
        }
    }

    var saturation : CGFloat = 0.0 {
        didSet {
            selectedPoint.y = saturation * bounds.height
        }
    }

    var selectedPoint : CGPoint = CGPointZero

    override init(frame: CGRect) {
        super.init(frame: frame)

        // install a gesture recognizer.
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let ctx = UIGraphicsGetCurrentContext()

        var colors : [CGColorRef] = []
        var locations : [CGFloat] = []

        let maxValue = 20
        for i in 0...maxValue {
            let location = CGFloat(i) / CGFloat(maxValue)
            colors.append(UIColor(hue: location, saturation: 1, brightness: 1, alpha: 1).CGColor)
            locations.append(location)
        }

        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors as CFArrayRef, locations)

        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, rect.height), CGPointMake(rect.width, rect.height), .allZeros)

        let top = UIColor(white: 1.0, alpha: 1.0).CGColor
        let bottom = UIColor(white: 1.0, alpha: 0.0).CGColor

        let verticalGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [top, bottom] as CFArrayRef, [0.0, 1.0])
        CGContextDrawLinearGradient(ctx, verticalGradient, CGPointMake(0, 0), CGPointMake(0, rect.height), .allZeros)
    }
}
