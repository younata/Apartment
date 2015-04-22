//
//  LocationCard.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/20/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import MaterialKit

class LocationCard: ListCardDelegate {

    private var selectedIndex : Int? = nil

    private var tableView : UITableView? = nil
    func configure(tableView: UITableView) {
        tableView.registerClass(MKTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView = tableView
    }

    func numberOfCells() -> Int {
        return 2
    }

    func cardHeight() -> CGFloat {
        return selectedIndex == nil ? 120 : 280
    }

    func heightForCell(index: Int) -> CGFloat {
        if selectedIndex == index {
            return 200
        }
        return 40
    }

    func cellAtIndex(index: Int) -> UITableViewCell {
        let cell = tableView?.dequeueReusableCellWithIdentifier("cell", forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as? MKTableViewCell ?? MKTableViewCell()
        let text : String
        switch index {
        case 0:
            text = "Arriving"
        case 1:
            text = "Leaving"
        default:
            text = ""
        }
        cell.textLabel?.text = text
        return cell
    }

    var onTapCell : (Int) -> (Void) = {_ in }
    func didTapCell(index: Int) {
        if (selectedIndex == index) {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
        onTapCell(index)
        tableView?.beginUpdates()
        tableView?.endUpdates()
    }

    func heightForFooter() -> CGFloat {
        return 0
    }

    func footerView() -> UIView {
        return UIView()
    }
}