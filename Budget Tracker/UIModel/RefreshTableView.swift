//
//  RefreshTableView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 07.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class RefreshTableView: UITableView {

    var refreshBackgroundColor:UIColor?
    private var _refreshAction:(()->())?
    var refreshAction:(()->())? {
        get {
            return _refreshAction
        }
        set {
            _refreshAction = newValue
            if self.refresh == nil && newValue != nil {
                self.refresh = UIRefreshControl()
                self.refresh?.addTarget(self, action: #selector(self.refreshed(_:)), for: .valueChanged)
                self.addSubview(self.refresh ?? UIRefreshControl())
                self.refresh?.tintColor = .white
                refresh?.backgroundColor = refreshBackgroundColor ?? .clear
                startAnimating()
            } else if newValue == nil {
                refresh?.removeFromSuperview()
                refresh = nil
            }
        }
    }
    
    func startAnimating() {
        refresh?.beginRefreshing()
    }
    
    override func reloadData() {
        super.reloadData()
        refresh?.endRefreshing()
    }
    
    @objc private func refreshed(_ sender:UIRefreshControl) {
        if let refreshAction = refreshAction {
            sender.beginRefreshing()
            refreshAction()
        }
    }
    
    var refresh:UIRefreshControl?

    override func removeFromSuperview() {
        super.removeFromSuperview()
        if moved {
            refreshAction = nil
        }
    }
    
    private var moved = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !moved {
            moved = true
        }
    }
}

