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
    
}

struct DebtsStruct {
    let name: String
    var amountToPay: String
    var dueDate: String
}
