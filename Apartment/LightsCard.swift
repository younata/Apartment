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

class LightsCard : ListCardDelegate {
    var bulbs : [Bulb] = []
    var delegate : LightsCardCallback? = nil
    private var tableView : UITableView? = nil
    func configure(tableView: UITableView, bulbs: [Bulb], delegate: LightsCardCallback) {
        self.bulbs = bulbs
        self.delegate = delegate
        tableView.registerClass(LightsTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView = tableView

        let headerView = UIView(frame: CGRectMake(0, 0, 100, 40))
        let headerLabel = MKLabel()
        headerLabel.text = NSLocalizedString("Lights", comment: "")

        headerView.addSubview(headerLabel)
        layout(headerLabel) {view in
            view.edges == inset(view.superview!.edges, 4, 16, 4, 16);
        }

        tableView.tableHeaderView = headerView
    }

    func numberOfCells() -> Int {
        return bulbs.count
    }

    func cardHeight() -> CGFloat {
        return 44 * CGFloat(bulbs.count)
    }

    func heightForCell(index: Int) -> CGFloat {
        return 44
    }

    func cellAtIndex(index: Int) -> UITableViewCell {
        let cell = tableView?.dequeueReusableCellWithIdentifier("cell", forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as? LightsTableViewCell ?? LightsTableViewCell()
        cell.bulb = bulbs[index]
        return cell
    }

    func didTapCell(index: Int) {
        let bulb = bulbs[index]
        if bulb.reachable {
            delegate?.didTapBulb(bulb)
        }
    }

    func heightForFooter() -> CGFloat {
        return 40
    }

    func footerView() -> UIView {
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

    func didTapSettings() {
        delegate?.didTapSettings()
    }
}
