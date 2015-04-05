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

class LightsCard: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    var bulbs : [Bulb] = []

    lazy var tableView : UITableView = {
        let tv = UITableView(frame: self.contentView.bounds, style: .Grouped)
        tv.delegate = self
        tv.dataSource = self
        tv.registerClass(MKTableViewCell.self, forCellReuseIdentifier: "cell")
        tv.scrollEnabled = false

        let headerView = UIView(frame: CGRectMake(0, 0, 100, 40))
        let headerLabel = MKLabel()
        headerLabel.text = "Lights"

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

    func configure(bulbs: [Bulb]) {
        self.bulbs = bulbs

        self.tableView.reloadData()

        self.contentView.layer.cornerRadius = 5
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.clearColor()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bulbs.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MKTableViewCell
        let bulb = bulbs[indexPath.row]
        cell.selectionStyle = .None
        cell.textLabel?.text = bulb.name
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = bulb.color
        cell.rippleLayerColor = bulb.color.darkerColor()
        return cell
    }
}
