//
//  LightsCard.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/4/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import MaterialKit
import Cartography

protocol LightsCardCallback {
    func didTapBulb(bulb: Bulb)

    func didTapSettings()
}

class LightsCard: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    var bulbs : [Bulb] = []

    lazy var tableView : UITableView = {
        let tv = UITableView(frame: self.contentView.bounds, style: .Grouped)
        tv.delegate = self
        tv.dataSource = self
        tv.registerClass(LightsTableViewCell.self, forCellReuseIdentifier: "cell")
        tv.scrollEnabled = false

        let headerView = UIView(frame: CGRectMake(0, 0, 100, 40))
        let headerLabel = MKLabel()
        headerLabel.text = NSLocalizedString("Lights", comment: "")

        headerView.addSubview(headerLabel)
        layout(headerLabel) {view in
            view.edges == inset(view.superview!.edges, 4, 16, 4, 16);
        }

        tv.tableHeaderView = headerView

        tv.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(tv)
        layout(tv) {view in
            view.edges == view.superview!.edges
        }

        return tv
    }()

    var delegate : LightsCardCallback? = nil

    func configure(bulbs: [Bulb], delegate: LightsCardCallback?) {
        self.bulbs = bulbs
        self.delegate = delegate

        self.tableView.reloadData()

        self.contentView.layer.cornerRadius = 5
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.clearColor()
    }

    func didTapSettings() {
        self.delegate?.didTapSettings()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bulbs.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LightsTableViewCell
        cell.bulb = bulbs[indexPath.row]
        return cell
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let settingsButton = MKButton()
        settingsButton.setTitle(NSLocalizedString("Settings", comment: ""), forState: .Normal)
        settingsButton.addTarget(self, action: "didTapSettings", forControlEvents: .TouchUpInside)
        settingsButton.rippleLayerColor = UIColor.whiteColor().darkerColor()
        settingsButton.backgroundColor = UIColor.whiteColor()
        settingsButton.setTitleColor(UIColor.blackColor(), forState: .Normal)

        let footerView = UIView(frame: CGRectMake(0, 0, 100, 40))
        footerView.addSubview(settingsButton)
        layout(settingsButton) {view in
            view.edges == view.superview!.edges
        }
        return footerView
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let bulb = bulbs[indexPath.row]
        if bulb.reachable {
            delegate?.didTapBulb(bulb)
        }
    }
}
