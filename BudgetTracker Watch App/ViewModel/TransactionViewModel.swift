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
    var enteringComment:String {
        didSet {
            transaction.comment = enteringComment
        }
    }
    var valueText:String {
        if transaction.value != "" {
            return (transaction.category.purpose == .expense && !transaction.value.contains("-") ? "-" : "") + transaction.value
        } else {
            return "Empty"
        }
    }
    let categories:[NewCategories]
    let donePressed:donePressedAlias
    let deletePressed:()->()
    var isPresented:Binding<Bool>
    var selectedDate: Date = .init() {
        didSet {
            if let newDate = selectedDate.toDateComponents().toShortString() {
                self.transaction.date = newDate
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    AppDelegate.properties?.db.transactionDate = newDate
                }
            }
        }
    }
    
    init(transaction: TransactionsStruct,
         categories: [NewCategories],
         donePressed:@escaping donePressedAlias,
         isPresented:Binding<Bool>,
         deletePressed:@escaping()->()
    ) {
        self.transaction = transaction
        self.categories = categories
        self.donePressed = donePressed
        selectedDate = transaction.dateFromString
        self.enteringComment = transaction.comment
        self.isPresented = isPresented
        self.deletePressed = deletePressed
    }
    
    var validateDonePressed:Bool {
        return transaction.categoryID != "" && transaction.value != ""
    }
    
    typealias donePressedAlias = (_ editedTransaction:TransactionsStruct)->()
}
