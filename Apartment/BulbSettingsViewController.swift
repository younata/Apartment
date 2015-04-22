//
//  BulbSettingsViewController.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/20/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import Cartography

class BulbSettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    lazy var collectionView : UICollectionView = {
        let cv = self.injector!.create(UICollectionView.self) as! UICollectionView
        cv.setTranslatesAutoresizingMaskIntoConstraints(false)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = UIColor.clearColor()
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0)
        }
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Bulb Settings"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = false
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.size.width - 20, 80.0 + (44.0 * 3))
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("lights", forIndexPath: indexPath) as! LightsCard
        return cell
    }
}
