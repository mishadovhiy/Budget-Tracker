//
//  DataOptionCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class DataOptionCell: ClearCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textField: TextField!
    
    @IBOutlet weak var proView: UIView!

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.2, animations: {
                self.contentView.alpha = begun ? 0.8 : 1
            })
        }
    }
    
}
