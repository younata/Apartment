//
//  ListCard.swift
//  Apartment
//
//  Created by Rachel Brindle on 4/20/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import UIKit
import Cartography

protocol ListCardDelegate {
    func numberOfCells() -> Int
    func heightForCell(index: Int) -> CGFloat

    func cellAtIndex(index: Int) -> UITableViewCell
    func didTapCell(index: Int)

    func heightForFooter() -> CGFloat
    func footerView() -> UIView
}

class ListCard: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView : UITableView = {
        let tv = UITableView(frame: self.contentView.bounds, style: .Grouped)
        tv.delegate = self
        tv.dataSource = self
        tv.scrollEnabled = false
        tv.setTranslatesAutoresizingMaskIntoConstraints(false)

        self.contentView.addSubview(tv)

        layout(tv) {view in
            view.edges == view.superview!.edges
        }

        return tv
    }()

    var delegate: ListCardDelegate! = nil

    func configure(delegate: ListCardDelegate) {
        self.delegate = delegate

        self.tableView.reloadData()

        self.backgroundColor = UIColor.whiteColor()

        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.numberOfCells()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return delegate.heightForCell(indexPath.row)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return delegate.cellAtIndex(indexPath.row)
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return delegate.heightForFooter()
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return delegate.footerView()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.didTapCell(indexPath.row)
    }
}
