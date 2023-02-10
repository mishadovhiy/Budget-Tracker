//
//  TableCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 08.02.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class TableCell: UITableViewCell {

    private var drwed = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !drwed {
            drwed = true
            draw()
        }
    }
    
    func draw() {
        
    }

}
