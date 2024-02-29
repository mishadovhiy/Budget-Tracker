//
//  RefreshTableView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 07.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class RefreshTableView: UITableView {

    private var activityIndicator:UIActivityIndicatorView?
    
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
    
    /**
     - to animate UIRefreshControll
     - UIRefreshControll located on top of the UITableView
     */
    func startRefreshing() {
        activityIndicator?.startAnimating()
    }
    
    /**
     - to animate UIActivityIndicatorView
     - UIActivityIndicatorView located in the middle of the UITableView
     */
    func startAnimating() {
        refresh?.beginRefreshing()
    }
    
    private var reloadCalled = false
    override func reloadData() {
        super.reloadData()
        if !reloadCalled {
            reloadCalled = true
        } else if moved {
            refresh?.endRefreshing()
            activityIndicator?.stopAnimating()
        }
       
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
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    private var moved = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !moved {
            moved = true
            addActivityView()
        }
    }
    
    private func addActivityView() {
        if activityIndicator != nil {
            return
        }
        activityIndicator = .init(style: .medium)
        activityIndicator?.tintColor = K.Colors.category
        self.addSubview(activityIndicator!)
        activityIndicator?.addConstaits([.centerX:0, .centerY:0], superV: self)
        activityIndicator?.startAnimating()
    }
}

