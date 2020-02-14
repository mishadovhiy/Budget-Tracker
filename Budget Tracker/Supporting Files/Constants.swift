//
//  Constants.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct K {
    
    static let mainCellIdent = "TableViewCell"
    static let catCellIdent = "categoriesVCTableViewCell"
    static let settCellIdent = "settingsTableViewCell"
    static let redIndicator = "negativeValue"
    static let greenIndicator = "positiveValue"
    static let income = "Incomes"
    static let expense = "Expenses"
    static let quitVC = "quitTransitionVC"
    static let editVC = "goToEditVC"
    
    struct Text {
        static let unknExpense = "Uncategorized Expense"
        static let unknIncome = "Uncategorized Income"
        static let unknCat = "Uncategorized Category"
    }
    struct Colors {
        static let background = UIColor(named: "backgroundColor")
        static let balanceT = UIColor(named: "balanceTitleColor")
        static let balanceV = UIColor(named: "balanceValueColor")
        static let category = UIColor(named: "CategoryColor")
        static let negative = UIColor(named: "negativeColor")
        static let separetor = UIColor(named: "separetorColor")
        static let yellow = UIColor(named: "yellowColor")
    }
}
