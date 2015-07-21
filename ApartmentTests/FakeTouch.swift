import UIKit

class FakeTouch: UITouch {

    var location: CGPoint = CGPointZero
    var previousLocation: CGPoint = CGPointZero

    override func locationInView(view: UIView?) -> CGPoint {
        return location
    }

    override func previousLocationInView(view: UIView?) -> CGPoint {
        return previousLocation
    }
}
