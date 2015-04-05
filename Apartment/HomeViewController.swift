//
//  HomeViewController.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/3/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import Ra
import Cartography

let bulb1 = Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
    effect: .none, reachable: true, alert: "none")

let bulb2 = Bulb(id: 2, name: "Hue Lamp 1", on: false, brightness: 194, hue: 15051,
    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .hue,
    effect: .none, reachable: true, alert: "none")

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var bulbs : [Bulb] = []

    lazy var collectionView : UICollectionView = {
        let cv = self.injector!.create(UICollectionView.self) as! UICollectionView
        cv.setTranslatesAutoresizingMaskIntoConstraints(false)
        cv.registerClass(LightsCard.self, forCellWithReuseIdentifier: "lights")
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

        view.backgroundColor = UIColor.lightGrayColor()

        view.addSubview(collectionView)
        layout(collectionView) {view in
            view.edges == view.superview!.edges
        }

        getLights()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.size.width - 20, 40.0 + (44.0 * CGFloat(bulbs.count)))
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("lights", forIndexPath: indexPath) as! LightsCard
        cell.configure(bulbs)
        return cell
    }

    private func getLights() {
        if let lightsService = self.injector?.create(kLightsService) as? LightsService {
            lightsService.allBulbs {bulbs, error in
                if let bulbs = bulbs {
                    self.bulbs = bulbs
                    self.collectionView.reloadData()
                } else if let error = error {
                    let alert = UIAlertController(title: "Error getting lights", message: error.localizedDescription, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: {_ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
