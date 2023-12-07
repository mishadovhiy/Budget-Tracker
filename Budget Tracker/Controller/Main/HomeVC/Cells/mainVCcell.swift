//
//  mainVCcell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class mainVCcell: ClearCell {
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var commentImage: UIImageView!
    // @IBOutlet weak var bigDate: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
 //   @IBOutlet weak var dailyTotalLabel: UILabel!
 //   @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let selected = UIView(frame: .zero)
        selected.backgroundColor = .clear
        self.selectedBackgroundView = selected
        self.touchesBegunAction = { began in
            UIView.animate(withDuration: 0.2, animations: {
                self.mainBackgroundView.backgroundColor = (began ? K.Colors.link : K.Colors.darkTable) ?? K.Colors.darkTable!
            })
        }
    }
    
    var beginScrollPosition:CGFloat = 0
    @objc func cellSwipePan(_ sender: UIPanGestureRecognizer) {
        let finger = sender.location(in: self.contentView)
        if sender.state == .began {
            beginScrollPosition = finger.x
        }
        if sender.state == .began || sender.state == .changed {
            let newPosition = finger.x - beginScrollPosition
            self.mainBackgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, newPosition, 0, 0)
        } else {
            if sender.state == .ended {
                toggleCellActions(show: finger.x < beginScrollPosition ? true : false, animated: true)
            }
        }
    }
    
    var showingActions = false
    func toggleCellActions(show: Bool, animated: Bool) {
        showingActions = show
        DispatchQueue.main.async {
            UIView.animate(withDuration: animated ? 0.3 : 0) {
                self.mainBackgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? -100 : 0, 0, 0)
            } completion: { _ in
            }
        }
    }

    func setupCell(_ data: TransactionsStruct, i: Int, tableData: [TransactionsStruct], selectedCell: IndexPath?, indexPath: IndexPath) {

        valueLabel.textColor = (Double(data.value) ?? 0.0) > 0 ? K.Colors.link : K.Colors.category
       // commentLabel.isHidden = true
        
        let value = String(format:"%.0f", Double(data.value) ?? 0.0)
        valueLabel.text = Double(data.value) ?? 0.0 > 0.0 ? "+\(value)" : value
        let category = HomeVC.shared?.db.category(data.categoryID)
        if AppDelegate.shared!.symbolsAllowed {
            categoryImage.image = AppData.iconSystemNamed(category?.icon)
        } else {
            categoryImage.superview?.isHidden = true
        }
        
        categoryImage.tintColor = AppData.colorNamed(category?.color)
        categoryLabel.text = (category?.name ?? "Unknown category").localize
        commentLabel.text = data.comment
        commentImage.alpha = data.comment == "" ? 0 : 1
        commentLabel.isHidden = data.comment == "" ? true : false
     /*   if selectedCell != nil {
            if selectedCell == indexPath && commentLabel.text != "" {
                commentLabel.isHidden = false
                commentImage.alpha = 0
            }
        }*/

        
    }
    
    func getDailyTotal(day: String, tableData: [TransactionsStruct]) -> String {
        
        var total: Double = 0.0
        for i in 0..<tableData.count {
            if tableData[i].date == day {
                total = total + (Double(tableData[i].value) ?? 0.0)
            }
        }
        
        var amount = ""
        var intTotal = Int(total)
        if total > Double(Int.max) {
            amount = "\(total)"
            intTotal = 1
            return amount
        }
        
        if total > 0 {
            amount = "+\(intTotal)"
        } else {
            amount = "\(intTotal)"
        }
        
        return amount
    }
    
}

