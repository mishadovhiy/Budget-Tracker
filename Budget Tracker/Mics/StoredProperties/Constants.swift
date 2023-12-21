//
//  Constants.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct K {
    
    //segue
    //cellIdent
    static let calcCellIdent = "calcCellIdent"
    static let mainCellIdent = "TableViewCell"
    static let catCellIdent = "categoriesVCTableViewCell"
    static let settCellIdent = "settingsTableViewCell"
    static let redIndicator = "negativeValue"
    static let greenIndicator = "positiveValue"
    static let income = "Incomes"
    static let expense = "Expenses"
    static let quitVC = "quitTransitionVC"
    static let editVC = "goToEditVC"
    static let statisticSeque = "toStatisticVC"
    static let statisticCellIdent = "statisticCellIdent"
    static let historySeque = "toHistorySeque"
    static let historyCellIdent = "historyCellIdent"
    static let historyCellTotalIdent = "historyCellTotalIdent"
    static let goToEditVCSeq = "goToEditVC"
    static let toCalendar = "toCalendar"
    static let filterCell = "filterCell"
    static let quitFilterTVC = "quitFilterTVC"
    static let collectionCell = "collectionCell"
    static let calendarClosed = "CalendarClosed"
    static let fullDateFormat = "dd.MM.yyyy HH:mm:ss"
    
    struct Text {
        static let unknExpense = "Uncategorized Expense"
        static let unknIncome = "Uncategorized Income"
        static let unknCat = "Uncategorized Category"
        
        static let errorInternet = "Bad internet, you still can use app in offline mode"
        
        
        
    }
    
    struct Keys {
        static let localTrancations = "savedTransactions"
        static let localCategories = "savedCategories"
        static let localDebts = "savedDebts"
    }
    
    struct Colors {
        static let background = UIColor(named: "backgroundColor")
        static let popupBackground = UIColor.black.withAlphaComponent(0.7)

        static let balanceT = UIColor(named: "balanceTitleColor")
        static let balanceV = UIColor(named: "balanceValueColor")
        static let category = UIColor(named: "CategoryColor")
        static let negative = UIColor(named: "negativeColor")
        static let separetor = UIColor(named: "separetorColor")
        static var link:UIColor {
            UIColor(named: AppDelegate.shared?.properties?.db.linkColor ?? "") ?? (K.Colors.yellow ?? .white)
        }
        static let yellow = UIColor(named: "yellowColor")
        static let pink = UIColor(named: "pinkColor")
        
        static let loginColor = UIColor(named: "loginColor")
        static let notOnDBColor = UIColor(named: "notOnDBColor")
        static let darkTable = UIColor(named: "darkTableColor")
        
        
        static let textFieldPlaceholder = UIColor(named: "darkSeparetor") ?? .red
        static let darkSeparetor = UIColor(named: "darkSeparetor") ?? .red

        static let primaryBacground = UIColor(named: "PrimaryBackgroundColor") ?? .black
        static let secondaryBackground = UIColor(named: "SecondaryBacroundColor") ?? .black
        static let secondaryBackground2 = UIColor(named: "SecondaryBacroundColor2") ?? .black
        static let sectionBackground = secondaryBackground
    }
}

