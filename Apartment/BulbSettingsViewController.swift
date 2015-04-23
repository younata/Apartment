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
        cv.registerClass(ListCard.self, forCellWithReuseIdentifier: "cell")
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0)
        }
        return cv
    }()

    let locationCard = LocationCard()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Bulb Settings"

        self.view.addSubview(collectionView)

        layout(collectionView) {view in
            view.edges == view.superview!.edges
        }

        locationCard.onTapCell = {idx in
            self.collectionView.performBatchUpdates(nil, completion: nil)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = false
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height : CGFloat
        if indexPath.item == 0 {
            height = locationCard.cardHeight()
        } else {
            height = 0
        }
        return CGSizeMake(view.bounds.size.width - 20, height)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ListCard
        if (indexPath.item == 0) {
            cell.configure(locationCard)
            locationCard.configure(cell.tableView)
        }
        return cell
    }
}
