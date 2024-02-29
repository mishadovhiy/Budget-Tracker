//
//  IconsCategoryCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class IconsCategoryCell:ClearCollectionCell {
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var catNameLabel: UILabel!
    func set(category:NewCategories) {
        catNameLabel.text = category.name
        catImageView.image = .init(category.icon)
            //.init(named: category.icon)
        catImageView.tintColor = .colorNamed(category.color)
        touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction, animations: {
                self.catNameLabel.superview?.superview?.backgroundColor = begun ? K.Colors.link : K.Colors.darkSeparetor
            })
        }
    }
}
