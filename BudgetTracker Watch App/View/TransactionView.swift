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
         deletePressed:@escaping()->(),
         isPresented:Binding<Bool>
    ) {
        viewModel = .init(transaction: transaction, categories: categories, donePressed: donePressed, isPresented: isPresented, deletePressed: deletePressed)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                contentStack
            }
            .navigationTitle(viewModel.transaction.isNewTransaction ? "Add transaction" : "Edit transaction")
            .toolbar(content: {
                toolBar
            })
        }
    }
    
    private var toolBar: some View {
        HStack {
            Button(viewModel.transaction.isNewTransaction ? "Add" : "Change") {
                if viewModel.validateDonePressed {
                    self.viewModel.donePressed(self.viewModel.transaction)
                }
                viewModel.isPresented.wrappedValue = false
            }
            if !viewModel.transaction.isNewTransaction {
                Button("Delete") {
                    self.viewModel.deletePressed()
                    viewModel.isPresented.wrappedValue = false
                }
            }
        }

    }
    
    private var contentStack: some View {
        VStack {
            NavigationLink(destination: EnterValueView(enteringValue: .init(type: .numbers({ newValue in
                viewModel.transaction.value = "\(newValue)"
            }), value: viewModel.transaction.value))) {
                cellView(title: "Value", value: viewModel.transaction.value)
            }
            NavigationLink(destination:
                ListView(didSelect: { id in
                    self.viewModel.transaction.categoryID = id
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    let last = LastSelected()
                    last.sett(value: id, valueType: self.viewModel.transaction.category.purpose == .expense ? .expense : .income)
                }
                }, tableData: viewModel.categories.compactMap({
                    .init(title: $0.name, id: "\($0.id)")
                })), label: {
                cellView(title: "Category", value: viewModel.transaction.category.name)
            })
            if #available(watchOS 10.0, *) {
                DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .frame(height: 60)
            }
            TextField("Comment", text: $viewModel.enteringComment)
        }
    }
    
    private func cellView(title:String, value:String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }
}
