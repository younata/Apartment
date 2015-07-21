import UIKit

public extension UIColor {
    // http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/
    public convenience init(mired: CGFloat) {
        var red : CGFloat = 1.0
        var green : CGFloat = 1.0
        var blue : CGFloat = 1.0

        let temp = (1000000.0 / mired) / 100.0

        if temp <= 66 {
            green = 99.4708025861 * log(temp) - 161.1195681661
        } else {
            red = 329.698727446 * pow(temp - 60, -0.1332047592)
            green = 288.1221695283 * pow(temp - 60, -0.0755148492)
            blue = 138.5177312231 * log(temp - 10) - 305.0447927307
        }

        red = max(min(255, red), 0) / 255.0
        green = max(min(255, green), 0) / 255.0
        blue = max(min(255, blue), 0) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    public func darkerColor() -> UIColor {
        var hue : CGFloat = 1.0
        var sat : CGFloat = 1.0
        var brightness : CGFloat = 1.0
        var alpha : CGFloat = 1.0
        self.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: sat - 0.1, brightness: brightness - 0.1, alpha: alpha)
    }
}