//
//  AttributedPreviewCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class AttributedPreviewCell:UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func set(_ data:NSAttributedString) {
        let atr = data
        let mutating = NSMutableAttributedString(string: "")
        mutating.append(atr)
        mutating.append(.init(string: " "))
        titleLabel.attributedText = mutating
    }
    
 
}
