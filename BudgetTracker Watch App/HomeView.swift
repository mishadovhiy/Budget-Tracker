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
            ForEach(viewModel.transactions ?? [], id:\.id) { item in
                HStack(content: {
                    Text(item.category.name)
                    Spacer()
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
