//
//  mainVCcell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class mainVCcell: UITableViewCell {
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var commentImage: UIImageView!
    // @IBOutlet weak var bigDate: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
 //   @IBOutlet weak var dailyTotalLabel: UILabel!
 //   @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    //let db = DataBase()
    

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let selected = UIView(frame: .zero)
        selected.backgroundColor = .clear
        self.selectedBackgroundView = selected
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
        let category = ViewController.shared?.db.category(data.categoryID)
        if AppDelegate.shared!.symbolsAllowed {
            categoryImage.image = AppData.iconSystemNamed(category?.icon)
        } else {
            categoryImage.superview?.isHidden = true
        }
        
        categoryImage.tintColor = AppData.colorNamed(category?.color)
        categoryLabel.text = category?.name ?? "Unknown category".localize
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


class calcCell: UITableViewCell {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var periodBalanceTitleLabel: UILabel!
    @IBOutlet weak var periodStack: UIStackView!
    @IBOutlet weak var periodBalanceValueLabel: UILabel!
    @IBOutlet weak var unsesndedTransactionsLabel: UILabel!
    @IBOutlet weak var savedTransactionsLabel: UILabel!
    @IBOutlet weak var prevAcountDataLabel: UILabel!
    

    func setup(calculations: (Double, Double, Double, Double)) {
       // let unsendedCount = (appData.defaults.value(forKey: "unsavedTransactions") as? [[String]] ?? []) + (appData.defaults.value(forKey: "unsavedCategories") as? [[String]] ?? [])

        //if totalBalance < Double(Int.max), sumExpenses < Double(Int.max), sumIncomes < Double(Int.max), sumPeriodBalance < Double(Int.max) {
        if calculations.0 < Double(Int.max), calculations.1 < Double(Int.max), calculations.2 < Double(Int.max), calculations.3 < Double(Int.max) {
            
            balanceLabel.text = "\(Int(calculations.0))"
            periodBalanceValueLabel.text = "\(Int(calculations.3))"
            expensesLabel.text = "\(Int(calculations.1 * -1))"
            incomeLabel.text = "\(Int(calculations.2))"
        } else {
            balanceLabel.text = "\(calculations.0)"
            periodBalanceValueLabel.text = "\(calculations.3)"
            expensesLabel.text = "\(calculations.1 * -1)"
            incomeLabel.text = "\(calculations.2)"
            
        }

        periodStack.isHidden = calculations.0 == calculations.3 ? true : false
        balanceLabel.textColor = calculations.0 < 0.0 ? K.Colors.negative : K.Colors.balanceV
        
        
        
    }

}







class StatisticCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let selected = UIView(frame: .zero)
        selected.backgroundColor = K.Colors.secondaryBackground
        self.selectedBackgroundView = selected
    }
}


class HistoryCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}







class FilterCell: UITableViewCell {
    
    @IBOutlet weak var backgroundCell: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 6
        self.tintColor = K.Colors.link
    }
}

class CVCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundCell: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var cellTypeLabel: UILabel!

}




class EmptyCell:UITableViewCell {
    
}