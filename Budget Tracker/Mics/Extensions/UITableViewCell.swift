//
//  UITableView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 17.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UITableViewCell {
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        setSelectedColor(K.Colors.secondaryBackground2)
    }

    func setSelectedColor(_ color:UIColor) {
        if self.selectedBackgroundView?.layer.name != "setSelectedColor" {
            let selected = UIView(frame: .zero)
            selected.layer.name = "setSelectedColor"
            selected.backgroundColor = color
            self.selectedBackgroundView = selected
        } else {
            self.selectedBackgroundView?.backgroundColor = color
        }
    
    }
    
    func setCornered(indexPath:IndexPath, dataCount:Int, for view:UIView, needCorners:Bool = true, value:CGFloat = 16) {
        let needCorners = needCorners ? (indexPath.row == 0 || indexPath.row == (dataCount - 1)) : false
        let isFullyCornered = dataCount == 1
        let topRadius = indexPath.row == 0
        
        if needCorners {
            if isFullyCornered {
                view.layer.cornerRadius = value
                view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                view.layer.cornerRadius(at: topRadius ? .top : .btn, value: value)
            }
            
        } else {
            view.layer.maskedCorners = []
        }
    }
}

extension UICollectionViewCell {
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        setSelectedColor(K.Colors.secondaryBackground2)
    }

    func setSelectedColor(_ color:UIColor) {
        let selected = UIView(frame: .zero)
        selected.backgroundColor = color
        self.selectedBackgroundView = selected
    }
}

extension UIContextualAction {
    
    func editType() {
        self.image = .init("pencil.yellow")
        self.backgroundColor = K.Colors.primaryBacground
    }
    
    func deleteType() {
        self.image = .init("trash.red")
        self.backgroundColor = K.Colors.primaryBacground
    }
}
