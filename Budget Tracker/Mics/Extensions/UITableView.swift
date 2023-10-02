//
//  UITableView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 25.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UITableView {

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        self.contentInset.bottom = AppDelegate.shared?.banner.size ?? 0
    }
    
    func shadows(opasity:Float = 0.15, radius:CGFloat = 12) {
        DispatchQueue.main.async {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = opasity
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = radius
        }
    }
    func registerCell(_ types:[XibCell]) {
        types.forEach({
            self.register(UINib(nibName: $0.rawValue, bundle: nil), forCellReuseIdentifier: $0.rawValue)
        })
    }
    
    enum XibCell:String {
        case amount = "AmountToPayCell"
    }
    
}

extension UICollectionView {
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.contentInset.bottom = AppDelegate.shared?.banner.size ?? 0
    }
}
