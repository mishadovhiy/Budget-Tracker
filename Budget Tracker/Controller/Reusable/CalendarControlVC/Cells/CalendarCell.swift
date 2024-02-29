//
//  CalendarCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class CalendarCell: ClearCollectionCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var backgroundMainView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundMainView.backgroundColor = begun ? K.Colors.link : .clear
            })
        }
    }
}
