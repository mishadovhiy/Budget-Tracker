//
//  mainFooterCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class mainFooterCell: UITableViewCell {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.cornerView.layer.cornerRadius = 15
        self.cornerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}
