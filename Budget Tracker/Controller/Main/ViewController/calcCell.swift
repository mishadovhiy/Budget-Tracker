//
//  calcCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

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
