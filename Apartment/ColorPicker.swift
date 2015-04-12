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

    override var bounds : CGRect {
        didSet {
            selectedPoint.x = hue * bounds.width
            selectedPoint.y = saturation * bounds.height
        }
    }

    private(set) var selectedPoint : CGPoint = CGPointZero

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        setColorFromTouchSet(touches)
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        setColorFromTouchSet(touches)
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        setColorFromTouchSet(touches)
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

        let largeRadius : CGFloat = 5.0
        let largeRect = CGRectMake(selectedPoint.x - largeRadius / 2.0, selectedPoint.y - largeRadius / 2.0, largeRadius, largeRadius)
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextStrokeEllipseInRect(ctx, largeRect)

        let smallRadius : CGFloat = 1.0
        let smallRect = CGRectMake(selectedPoint.x - smallRadius / 2.0, selectedPoint.y - smallRadius / 2.0, smallRadius, smallRadius)

        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor);
        CGContextStrokeEllipseInRect(ctx, smallRect)
    }

    private func setColorFromTouchSet(touches: Set<NSObject>) {
        if let touch = touches.first as? UITouch {
            let p = touch.locationInView(self)
            let point = CGPointMake(min(max(p.x, 0), bounds.width), min(max(p.y, 0), bounds.height))
            hue = point.x / bounds.width
            saturation = point.y / bounds.height

            sendActionsForControlEvents(.ValueChanged)
            setNeedsDisplay()
        }
    }
}
