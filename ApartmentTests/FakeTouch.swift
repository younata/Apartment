//
//  FakeTouch.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/11/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

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
