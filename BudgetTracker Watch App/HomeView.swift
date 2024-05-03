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
    @ObservedObject var viewModel:ViewModelHomeView = .init()
    
    var body: some View {
        VStack {
            Text("\(viewModel.transactions.count ?? 0) - datacount")
            if viewModel.error != nil {
                StaticMessageView(message: viewModel.error ?? .init(title: "Unknown errir"))
            } else {
                if #available(watchOS 8.0, *) {
                    listView()
                    .refreshable {
                        self.viewModel.loadData()
                    }
                } else {
                    listView()
                }
            }
        }
        .padding()
        .onAppear(perform: {
            self.viewModel.loadData()
        })
    }
    
    func listView() -> some View {
        List {
            ForEach(viewModel.transactions ?? [], id:\.id) { item in
                HStack(content: {
                    Text(item.value)
                })
            }
        }
        .refreshable {
            self.viewModel.loadData()
        }
    }
    
}

#Preview {
    HomeView()
}
