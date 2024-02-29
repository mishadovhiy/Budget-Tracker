//
//  SelectImageCollectionCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 28.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class SelectImageCollectionCell:UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    private var deletePressedAction:(()->())?

    func set(str:String, deletePressed:@escaping()->()) {
        titleLabel.text = str
        deletePressedAction = deletePressed
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        deletePressedAction?()
    }
}
