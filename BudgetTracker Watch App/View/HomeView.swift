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
    }
    
    private var tableHead: some View {
        HStack {
            Button("<") {
                viewModel.changeMonth(plus: false)
            }
            .frame(width: 60)
            .background(.red)
            Spacer()
            Text("\(viewModel.month)")
            Spacer()
            Button(">") {
                viewModel.changeMonth(plus: true)
            }
            .frame(width: 60)
            .background(.red)
        }
        .background(.orange)
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
