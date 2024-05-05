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
         donePressed:@escaping TransactionViewModel.donePressedAlias,
         isPresented:Binding<Bool>
    ) {
        viewModel = .init(transaction: transaction, categories: categories, donePressed: donePressed, isPresented: isPresented)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    NavigationLink(viewModel.transaction.value, destination: EnterValueView(enteringValue: .init(type: .numbers({ newValue in
                        print(newValue, " gyhujikol")
                        viewModel.transaction.value = "\(newValue)"
                    }), screenTitle: "Transaction Amount", value: viewModel.transaction.value)))
                    NavigationLink(destination:
                        ListView(didSelect: { id in
                            print(id, " gterfwdw")
                            self.viewModel.transaction.categoryID = id
                        }, tableData: viewModel.categories.compactMap({
                            .init(title: $0.name, id: "\($0.id)")
                        })), label: {
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
                    }))), label: {
                        HStack {
                            Text("Comment")
                            Spacer()
                            Text(viewModel.transaction.comment)
                        }
                    })
                }
            }
            .navigationTitle(viewModel.transaction.categoryID == "" ? "Add category" : "Edit category")
            .toolbar {
                Button("add") {
                    self.viewModel.donePressed(self.viewModel.transaction)
                    viewModel.isPresented.wrappedValue = false
                }
                Button("c") {
                    viewModel.isPresented.wrappedValue = false
                }
            }
        }
    }
}
