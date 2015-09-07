import UIKit

public class ColorPicker: UIControl {

    public var hue : CGFloat = 0.0 {
        didSet {
            self.selectedPoint.x = self.hue * self.bounds.width
        }
    }

    public var saturation : CGFloat = 0.0 {
        didSet {
            self.selectedPoint.y = self.saturation * self.bounds.height
        }
    }

    public override var bounds : CGRect {
        didSet {
            self.selectedPoint.x = self.hue * self.bounds.width
            self.selectedPoint.y = self.saturation * self.bounds.height
        }
    }

    public private(set) var selectedPoint : CGPoint = CGPointZero

    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.setColorFromTouchSet(touches)
    }

    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.setColorFromTouchSet(touches)
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.setColorFromTouchSet(touches)
    }

    public override func drawRect(rect: CGRect) {
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

        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, rect.height), CGPointMake(rect.width, rect.height), CGGradientDrawingOptions(rawValue: 0))

        let top = UIColor(white: 1.0, alpha: 1.0).CGColor
        let bottom = UIColor(white: 1.0, alpha: 0.0).CGColor

        let verticalGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [top, bottom] as CFArrayRef, [0.0, 1.0])
        CGContextDrawLinearGradient(ctx, verticalGradient, CGPointMake(0, 0), CGPointMake(0, rect.height), CGGradientDrawingOptions(rawValue: 0))

        let largeRadius : CGFloat = 5.0
        let largeRect = CGRectMake(self.selectedPoint.x - largeRadius / 2.0, self.selectedPoint.y - largeRadius / 2.0, largeRadius, largeRadius)
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextStrokeEllipseInRect(ctx, largeRect)

        let smallRadius : CGFloat = 1.0
        let smallRect = CGRectMake(self.selectedPoint.x - smallRadius / 2.0, self.selectedPoint.y - smallRadius / 2.0, smallRadius, smallRadius)

        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor);
        CGContextStrokeEllipseInRect(ctx, smallRect)
    }

    private func setColorFromTouchSet(touches: Set<NSObject>) {
        if let touch = touches.first as? UITouch {
            let p = touch.locationInView(self)
            let point = CGPointMake(min(max(p.x, 0), self.bounds.width), min(max(p.y, 0), self.bounds.height))
            self.hue = point.x / self.bounds.width
            self.saturation = point.y / self.bounds.height

            sendActionsForControlEvents(.ValueChanged)
            setNeedsDisplay()
        }
    }
}
