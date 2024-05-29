//
//  IconsVCColorCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class IconsVCColorCell:UICollectionViewCell {
    
    
    @IBOutlet weak var colorView: UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 4
        colorView.layer.cornerRadius = colorView.layer.frame.width / 2
    }
    
}
