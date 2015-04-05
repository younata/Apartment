//
//  HomeViewController.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/3/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import Ra
import MaterialKit
import Cartography

class HomeViewController: UIViewController {

    var bulbs : [Bulb] = []

    lazy var collectionView : UICollectionView? = {
        if let cv = self.injector?.create(UICollectionView.self) as? UICollectionView {
            cv.setTranslatesAutoresizingMaskIntoConstraints(false)
            return cv
        }
        return nil
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let collectionView = collectionView {
            view.addSubview(collectionView)
            layout(collectionView) {view in
                view.edges == view.superview!.edges
            }
        }
    }
}
