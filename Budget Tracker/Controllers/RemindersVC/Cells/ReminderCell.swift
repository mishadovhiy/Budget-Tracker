//
//  ReminderCell.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {

    
    @IBOutlet weak var repeatedIndicator: UIImageView!
    @IBOutlet weak var dayNumLabel: Label!
    @IBOutlet weak var expiredLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var unseenIndicator: View!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var actionsView: UIView!
    
    var row:Int = 0
    
    var addTransactionAction:((_ row:Int)->())?
    var deleteAction:((_ row:Int)->())?
    var editAction:((_ row:Int)->())?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let selected = UIView(frame: .zero)
        selected.backgroundColor = .clear
        self.selectedBackgroundView = selected
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchView = touches.first?.view ?? UIView()
        if touchView != self.contentView {
            if !animating {
                print(row, "rowrowrow")
                let isSelected = RemindersVC.shared?.tableData[row].selected ?? false
                RemindersVC.shared?.tableData[row].selected = !isSelected
                setSelectedAnimationg(!isSelected)
            }
        }
    }
    
    private var animating = false
    private func setSelectedAnimationg(_ selected:Bool, completion:((Bool) -> ())? = nil) {
        
        if let id = RemindersVC.shared?.tableData[row].id {
            Notifications.removeNotification(id: id)
        }
        animating = true
        let hide = !selected
        DispatchQueue.main.async {
            if self.actionsView.isHidden != hide {
                RemindersVC.shared?.tableView.beginUpdates()
                UIView.animate(withDuration: 0.19) {
                    self.actionsView.isHidden = hide
                    if self.unseenIndicator.isHidden != true {
                        self.unseenIndicator.isHidden = true
                    }
                } completion: { _ in
                    RemindersVC.shared?.tableView.endUpdates()
                    self.animating = false
                    DispatchQueue.main.async {
                        if let completion = completion {
                            completion(true)
                        }
                    }
                }
            } else {
                self.animating = false
            }
        }
    }
    
    @IBAction private func actionPressed(_ sender: Button) {
        switch sender.tag {
        case 0:
            if let acion = addTransactionAction {
                setSelectedAnimationg(false) { _ in
                    acion(self.row)
                }
            }
        case 2:
            if let acion = deleteAction {
                setSelectedAnimationg(false) { _ in
                    acion(self.row)
                }
            }
        case 3:
            if let acion = editAction {
                setSelectedAnimationg(false) { _ in
                    acion(self.row)
                }
            }
        default:
            break
        }
    }
    
    

}