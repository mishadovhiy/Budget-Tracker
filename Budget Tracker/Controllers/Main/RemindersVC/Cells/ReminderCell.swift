//
//  ReminderCell.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {

    
    @IBOutlet weak var expiredLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var actionsView: UIView!
    
    var addTransactionAction:(()->())?
    var igoneAction:(()->())?
    var deleteAction:(()->())?
    var editAction:(()->())?
    
    @IBAction func actionPressed(_ sender: Button) {
        switch sender.tag {
        case 0:
            if let acion = addTransactionAction {
                acion()
            }
        case 1:
            if let acion = igoneAction {
                acion()
            }
        case 2:
            if let acion = deleteAction {
                acion()
            }
        case 3:
            if let acion = editAction {
                acion()
            }
        default:
            break
        }
    }
    
    

}
