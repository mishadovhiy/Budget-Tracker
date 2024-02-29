//
//  SideBardCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class SideBardCell: ClearCell {
    
    @IBOutlet weak var backgroundMainView: UIView!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var notificationsView: BasicView!
    @IBOutlet weak var proView: BasicView!
    @IBOutlet weak var optionIcon: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setSelectedColor(.clear)
       // selectedBackgroundView = backgroundMainView
        if !(AppDelegate.properties?.appData.symbolsAllowed ?? false) {
            optionIcon.isHidden = true
        }
    }
}
