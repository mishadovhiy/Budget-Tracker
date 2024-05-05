//
//  TransactionView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 04.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI

struct TransactionView: View {
    
    @State var viewModel:TransactionViewModel
    
    init(transaction:TransactionsStruct = .init(),
         categories:[NewCategories],
         donePressed:@escaping TransactionViewModel.donePressedAlias
    ) {
        viewModel = .init(transaction: transaction, categories: categories, donePressed: donePressed)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    NavigationLink(viewModel.transaction.value, destination: EnterValueView(enteringValue: .init(type: .numbers({ newValue in
                        print(newValue, " gyhujikol")
                        viewModel.transaction.value = "\(newValue)"
                    }), screenTitle: "Transaction Amount", value: viewModel.transaction.value)), isActive: $viewModel.presenting.value)
                    NavigationLink(destination:
                        ListView(didSelect: { id in
                            print(id, " gterfwdw")
                            self.viewModel.transaction.categoryID = id
                        }, tableData: viewModel.categories.compactMap({
                            .init(title: $0.name, id: "\($0.id)")
                        })), isActive: $viewModel.presenting.category, label: {
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(viewModel.transaction.category.name)
                        }
                    })
                    if #available(watchOS 10.0, *) {
                        DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                            .frame(height: 60)
                    }
                    NavigationLink(destination: EnterValueView(enteringValue: .init(type: .string({ newValue in
                        viewModel.transaction.comment = newValue
                    }))), isActive: $viewModel.presenting.comment, label: {
                        HStack {
                            Text("Comment")
                            Spacer()
                            Text(viewModel.transaction.comment)
                        }
                    })
                }
            }
            .navigationTitle(viewModel.transaction.categoryID == "" ? "Add category" : "Edit category")
        }
    }
}
