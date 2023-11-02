//
//  Cells.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 26.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class DebtDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var AlertDateStack: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var noAlertIndicator: UILabel!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var alertDateLabel: UILabel!
    @IBOutlet weak var alertMonthLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var expiredDaysCount: UILabel!
    @IBOutlet weak var expiredStack: UIStackView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var removeAction:(() -> ())?
    var changeAction:(() -> ())?
    var cellPressed = false
    var _expired = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        changeButton.layer.cornerRadius = changeButton.layer.frame.width / 2
        doneButton.layer.cornerRadius = doneButton.layer.frame.width / 2
        
    }
    
    @IBAction func changeDatePressed(_ sender: Any) {
        self.removeAction?()
    }
    
    @IBAction func doneDatePressed(_ sender: Any) {
        AppDelegate.shared?.ai.show { _ in
            self.changeAction?()
        }
    }
    
    var expired:Bool {
        get {
            return _expired
        }
        set {
            _expired = newValue
            DispatchQueue.main.async {
                self.changeButton.superview?.isHidden = newValue ? false : (self.cellPressed ? false : true)
            }
        }
    }
}
