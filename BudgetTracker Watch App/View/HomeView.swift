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
            .navigationTitle("\(viewModel.month.stringMonth)")
        }
    }
    
    private var listView: some View {
        List {
            tableHead
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
        .gesture(
            DragGesture()
                .onChanged { value in
                    viewModel.listViewOffset = value.translation.width
                }
                .onEnded { value in
                    viewModel.changeMonth(plus: !(value.translation.width < 0))
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
        HStack(content: {
            Text(item.category.name)
            Spacer()
            Text(item.value)
        })
    }
    
}

#Preview {
    HomeView()
}
