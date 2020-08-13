//
//  mainVCcell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class mainVCcell: UITableViewCell {
    
    @IBOutlet weak var bigDate: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dailyTotalLabel: UILabel!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    
    func setupCell(_ data: TransactionsStruct, i: Int, tableData: [TransactionsStruct], selectedCell: IndexPath?) {
        if (Double(data.value) ?? 0.0) > 0 {
            valueLabel.textColor = K.Colors.category

        } else {
            valueLabel.textColor = K.Colors.negative
        }
        sectionView.layer.cornerRadius = 3
        
        commentLabel.isHidden = true
        
        let value = String(format:"%.0f", Double(data.value) ?? 0.0)
        let category = data.comment == "" ? data.category : "\(data.category)  ✎"
        valueLabel.text = value
        categoryLabel.text = category
        commentLabel.text = data.comment
        if selectedCell != nil {
            if selectedCell!.row == i && commentLabel.text != "" {
                commentLabel.isHidden = false
                categoryLabel.text = data.category
            }
        }
        
        if i != 0 {
            if tableData[i - 1].date != data.date {
                sectionView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                bigDate.text = "\(data.date)"
                dailyTotalLabel.text = "\(getDailyTotal(day: data.date, tableData: tableData))"
            } else {
                sectionView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                bigDate.text = ""
                dailyTotalLabel.text = ""
            }
        } else {
            sectionView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            bigDate.text = "\(data.date)"
            dailyTotalLabel.text = "\(self.getDailyTotal(day: data.date, tableData: tableData))"
        }
        
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
    
    func setupCell(_ totalBalance: Double, sumExpenses: Double, sumPeriodBalance: Double, sumIncomes: Double) {
        print("setupCell totalBalance", totalBalance)
        if totalBalance < Double(Int.max), sumExpenses < Double(Int.max), sumIncomes < Double(Int.max), sumPeriodBalance < Double(Int.max) {
            
            balanceLabel.text = "\(Int(totalBalance))"
            periodBalanceValueLabel.text = "\(Int(sumPeriodBalance))"
            expensesLabel.text = "\(Int(sumExpenses * -1))"
            incomeLabel.text = "\(Int(sumIncomes))"
        } else {
            balanceLabel.text = "\(totalBalance)"
            periodBalanceValueLabel.text = "\(sumPeriodBalance)"
            expensesLabel.text = "\(sumExpenses * -1)"
            incomeLabel.text = "\(sumIncomes)"
            
        }
        
        if totalBalance < 0.0 {
            balanceLabel.textColor = K.Colors.negative
            
        } else {
            balanceLabel.textColor = K.Colors.balanceV
        }
        
        if balanceLabel.text == periodBalanceValueLabel.text {
            periodStack.isHidden = true
            periodStack.alpha = 0
        } else {
            periodStack.isHidden = false
            periodStack.alpha = 1
        }
    }

}


class categoriesVCcell: UITableViewCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryPurposeLabel: UILabel!
    
}


class PlotCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var highValueView: UIView!
    
    func setupCell() {
        highValueView.layer.cornerRadius = 6
        highValueView.layer.shadowColor = UIColor.black.cgColor
        highValueView.layer.shadowOpacity = 0.2
        highValueView.layer.shadowOffset = .zero
        highValueView.layer.shadowRadius = 6
        categoryLabel.text = statisticBrain.maxExpenceName
        if statisticBrain.minValue < Double(Int.max) {
            valueLabel.text = "\(Int(statisticBrain.minValue))"
            
        } else {
            valueLabel.text = "\(statisticBrain.minValue)"
            
            
        }
    }
    
}


class StatisticCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}


class HistoryCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}


class HistoryCellTotal: UITableViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var perioudLabel: UILabel!
    
}

class FilterCell: UITableViewCell {
    
    @IBOutlet weak var backgroundCell: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
}

class CVCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundCell: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var cellTypeLabel: UILabel!
    
    func setupCell() {
        backgroundCell.layer.masksToBounds = true
        backgroundCell.layer.cornerRadius = backgroundCell.bounds.width / 2
    }
}
