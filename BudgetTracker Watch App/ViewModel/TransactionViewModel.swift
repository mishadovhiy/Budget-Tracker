//
//  TransactionViewModel.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 05.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI

struct TransactionViewModel {
    var transaction:TransactionsStruct = .init()
    let categories:[NewCategories]
    let donePressed:donePressedAlias

    var selectedDate: Date = .init() {
        didSet {
            self.transaction.date
        }
    }
    var presenting = PresentingNavigation() {
        didSet {
            
        }
    }
    
    
    init(transaction: TransactionsStruct,
         categories: [NewCategories],
         donePressed:@escaping donePressedAlias
    ) {
        self.transaction = transaction
        self.categories = categories
        self.donePressed = donePressed
        selectedDate = transaction.dateFromString
    }
    
    struct PresentingNavigation:Codable {
        var value:Bool = false
        var category:Bool = false
        var comment:Bool = false
    }
    typealias donePressedAlias = (_ editedTransaction:TransactionsStruct)->()
}
