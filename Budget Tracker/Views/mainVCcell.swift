//
//  mainVCcell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class mainVCcell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func setupCell(_ data: Transactions) {
        if data.value > 0 {
            valueLabel.textColor = K.Colors.category
        } else {
            valueLabel.textColor = K.Colors.negative
        }
        valueLabel.text = "\(Int(data.value))"
        categoryLabel.text = "\(data.category ?? K.Text.unknCat)"
        dateLabel.text = data.date

    }
    
}

class calcCell: UITableViewCell {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var periodBalanceTitleLabel: UILabel!
    @IBOutlet weak var periodBalanceValueLabel: UILabel!
    
    
    func setupCell(_ totalBalance: Double) {
        if totalBalance < Double(Int.max), appData.sumExpenses < Double(Int.max), appData.sumIncomes < Double(Int.max), appData.sumPeriodBalance < Double(Int.max) {
            balanceLabel.text = "\(Int(totalBalance))"
            periodBalanceValueLabel.text = "\(Int(appData.sumPeriodBalance))"
            expensesLabel.text = "\(Int(appData.sumExpenses * -1))"
            incomeLabel.text = "\(Int(appData.sumIncomes))"
        } else {
            balanceLabel.text = "\(totalBalance)"
            periodBalanceValueLabel.text = "\(appData.sumPeriodBalance)"
            expensesLabel.text = "\(appData.sumExpenses * -1)"
            incomeLabel.text = "\(appData.sumIncomes)"
        }
        
        if totalBalance < 0.0 {
            balanceLabel.textColor = K.Colors.negative
        } else {
            balanceLabel.textColor = K.Colors.balanceV
        }
        
        //periodBalanceTitleLabel.text = "Balance for \(selectedPeroud):"
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
