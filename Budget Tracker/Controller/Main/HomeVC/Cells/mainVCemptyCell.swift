//
//  mainVCemptyCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class mainVCemptyCell: UITableViewCell {
    
    @IBOutlet weak var mainBackgroundView: UIView!
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        mainBackgroundView.layer.cornerRadius = 9//ViewController.shared?.tableCorners ?? 9
    }
}
