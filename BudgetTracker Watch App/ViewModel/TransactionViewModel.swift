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
     var isPresented:Binding<Bool>
    var selectedDate: Date = .init() {
        didSet {
            self.transaction.date
        }
    }
    
    init(transaction: TransactionsStruct,
         categories: [NewCategories],
         donePressed:@escaping donePressedAlias,
         isPresented:Binding<Bool>
    ) {
        self.transaction = transaction
        self.categories = categories
        self.donePressed = donePressed
        selectedDate = transaction.dateFromString
        self.isPresented = isPresented
    }

    typealias donePressedAlias = (_ editedTransaction:TransactionsStruct)->()
}
