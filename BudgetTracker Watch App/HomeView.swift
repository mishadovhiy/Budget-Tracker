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
    @State var viewModel:ViewModelHomeView? = nil
    
    var body: some View {
        VStack {
            if viewModel?.error != nil {
                StaticMessageView(message: viewModel?.error ?? .init(title: "Unknown errir"))
            } else {
                if #available(watchOS 8.0, *) {
                    List {
                        ForEach(viewModel?.transactions ?? [], id:\.id) { item in
                            HStack(content: {
                                Text(item.value)
                            })
                        }
                    }
                    .refreshable {
                        self.viewModel?.loadData()
                    }
                } else {
                    List {
                        ForEach(viewModel?.transactions ?? [], id:\.id) { item in
                            HStack(content: {
                                Text(item.value)
                            })
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: {
            self.viewModel = .init()
        })
    }
    
}

#Preview {
    HomeView()
}
