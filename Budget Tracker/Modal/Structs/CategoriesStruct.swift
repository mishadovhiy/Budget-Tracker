//
//  CategoriesStruct.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


struct NewCategories {
    var id: Int
    var name: String
    var icon: String
    var color: String
    let purpose: CategoryPurpose
    var dueDate: DateComponents?
    var amountToPay: Double? = nil

    var transactions: [TransactionsStruct] {
        let db = DataBase()
        return db.transactions(for: self)
    }
    
    
    enum CategoryPurpose:String {
        case expense = "Expenses"
        case income = "Incomes"
        case debt = "debt"
    }
    static func stringToPurpose(_ string: String) -> CategoryPurpose {
        switch string {
        case K.income:
            return .income
        case K.expense:
            return .expense
        case "Debt":
            return .debt
        default:
            return .debt
        }
    }
}

struct DebtsStruct {
    let name: String
    var amountToPay: String
    var dueDate: String
}





