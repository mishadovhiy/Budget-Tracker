//
//  ContentView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 28.04.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject var viewModel:HomeViewModel = .init()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.error != nil {
                    StaticMessageView(message: viewModel.error ?? .init(title: "Unknown errir"))
                } else {
                    listView
                }
            }
            .padding()
            .onAppear(perform: {
                self.viewModel.loadData()
            })
            .navigationTitle("\((viewModel.selectedDate.month ?? 0).stringMonth), \(viewModel.selectedDate.year ?? 0)")
        }
        .fullScreenCover(isPresented: $viewModel.presentingTransaction, content: {
            TransactionView(transaction: viewModel.selectedTransaction ?? .init(), categories: viewModel.categories, donePressed: {
                let old = viewModel.selectedTransaction
                if $0.isNewTransaction {
                    self.viewModel.changeTransaction(old!, to: $0)
                } else {
                    self.viewModel.addTransaction($0)
                }
            }, deletePressed: {
                if let transactions = viewModel.selectedTransaction {
                    viewModel.deleteTransaction(transactions)
                }                
            }, isPresented: $viewModel.presentingTransaction)
        })
    }
    
    private var listView: some View {
        List {
            tableHead
            if AppDelegate.properties?.db.username ?? "" == "" {
                Button("Ask username") {
                    viewModel.askUsername()
                }
            }

            Button("Add transaction") {
                TransactionsStruct.newTransaction(type: .expense) { new in
                    self.viewModel.selectedTransaction = new
                }
            }
            ForEach(viewModel.transactions, id:\.id) { item in
                transactionCell(item)
            }
        }
        .refreshable {
            self.viewModel.loadData()
        }
        .offset(x:viewModel.listViewOffset)
    }
    
    private var tableHead: some View {
        HStack {
            balanceView(.balance)
            Spacer()
            VStack {
                HStack {
                    balanceView(.expences)
                    balanceView(.income)
                }
                balanceView(.periodBalance)
            }
        }
        .offset(x: viewModel.listViewOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    viewModel.listViewOffset = value.translation.width
                }
                .onEnded { value in
                    viewModel.changeMonth(plus: (value.translation.width < 0))
                    viewModel.listViewOffset = 0
                }
        )
    }
    
    
    private func balanceView(_ type:HomeViewModel.BalanceViewType) -> some View {
        VStack {
            HStack {
                Text(type.title)
                    .font(.system(size: 9))
                    .foregroundStyle(.gray)
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                if type == .balance {
                    Spacer()
                }
            }
            HStack {
                if type != .balance {
                    Spacer()
                }
                Text("\(type.value(viewModel.calculations))")
                    .font(type.fontSize)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                if type == .balance {
                    Spacer()
                }
            }
        }
    }
    
    private func transactionCell(_ item:TransactionsStruct) -> some View {
        VStack(content: {
            HStack(content: {
                Text(item.category.name)
                Spacer()
                Text(item.value)
            })
            HStack {
                Text(item.date)
                    .font(.system(size: 9))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        })
        .padding()
        .gesture(
            TapGesture()
                .onEnded({ _ in
                    self.viewModel.selectedTransaction = item
                })
        )
    }
    
}

#Preview {
    HomeView()
}
