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
        let selected = UIView(frame: .zero)
        selected.backgroundColor = color
        self.selectedBackgroundView = selected
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

