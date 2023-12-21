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
