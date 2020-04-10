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
    
    func setupCell(_ data: Transactions, i: Int, tableData: [Transactions]) {
        if data.value > 0 {
            valueLabel.textColor = K.Colors.category
        } else {
            valueLabel.textColor = K.Colors.negative
        }
        valueLabel.text = "\(Int(data.value))"
        categoryLabel.text = "\(data.category ?? K.Text.unknCat)"
        sectionView.layer.cornerRadius = 3
        
        if selectedPeroud == "Today" {
            bigDate.text = ""
            sectionView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            dailyTotalLabel.text = ""
        } else {
            if i != 0 {
                if tableData[i - 1].date != data.date {
                    bigDate.text = "\(data.date ?? "")"
                    sectionView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    dailyTotalLabel.text = "\(getDailyTotal(day: data.date ?? "", tableData: tableData))"
                } else {
                    bigDate.text = ""
                    sectionView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                    dailyTotalLabel.text = ""
                }
            } else {
                bigDate.text = "\(data.date ?? "")"
                sectionView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                dailyTotalLabel.text = "\(getDailyTotal(day: data.date ?? "", tableData: tableData))"
            }
        }
        
    }
    
    func getDailyTotal(day: String, tableData: [Transactions]) -> String {
        
        var total: Double = 0.0
        for i in 0..<tableData.count {
            if tableData[i].date == day {
                total = total + tableData[i].value
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
    
    func setupCell(_ totalBalance: Double) {
        if totalBalance < Double(Int.max), appData.calculation.sumExpenses < Double(Int.max), appData.calculation.sumIncomes < Double(Int.max), appData.calculation.sumPeriodBalance < Double(Int.max) {
            balanceLabel.text = "\(Int(totalBalance))"
            periodBalanceValueLabel.text = "\(Int(appData.calculation.sumPeriodBalance))"
            expensesLabel.text = "\(Int(appData.calculation.sumExpenses * -1))"
            incomeLabel.text = "\(Int(appData.calculation.sumIncomes))"
        } else {
            balanceLabel.text = "\(totalBalance)"
            periodBalanceValueLabel.text = "\(appData.calculation.sumPeriodBalance)"
            expensesLabel.text = "\(appData.calculation.sumExpenses * -1)"
            incomeLabel.text = "\(appData.calculation.sumIncomes)"
        }
        
        if totalBalance < 0.0 {
            balanceLabel.textColor = K.Colors.negative
        } else {
            balanceLabel.textColor = K.Colors.balanceV
        }
        
        if balanceLabel.text == periodBalanceValueLabel.text {
            periodStack.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.periodStack.alpha = 0
            }
        } else {
            periodStack.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.periodStack.alpha = 1
            }
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
        } else { valueLabel.text = "\(statisticBrain.minValue)" }
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
