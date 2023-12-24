//
//  NetworkTestView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct NetworkTestView: View {
    
    @StateObject var viewModel:NetworkTestViewViewModel = .init()

    var body: some View {
        Text("transaction \(viewModel.viewData.transCount)")
        Text("categories \(viewModel.viewData.catsCount)")

        List(viewModel.data.indices, id: \.self, selection: $viewModel.requestTypeSelected) { i in
            Text(viewModel.data[i].rawValue)
        }
    }
}

class NetworkTestViewViewModel:ObservableObject {
    struct ViewData {
        var transCount:Int = 0
        var catsCount:Int = 0
    }
    
    var data:[ServerResponse.RequestType] = [
        .loadCategories, .loadTransaction
    ]
    @Published var viewData:ViewData = .init()
    
    var requestTypeSelected:Int? = nil {
        didSet {
            guard let i = requestTypeSelected,
                  i <= self.data.count - 1
            else { return }
            AppDelegate.shared?.properties?.ai.showLoading() {
                self.dataSelected(type: self.data[i])
            }
        }
    }
    
    @MainActor func requestCompleted(data:Int) {
        AppDelegate.shared?.properties?.ai.hide()
    }
    
    private func dataSelected(type:ServerResponse.RequestType) {
        switch type {
        case .loadTransaction:
            Task {
                let data = await NetworkModel.loadTransactions()
                self.viewData.transCount = data.count
                await self.requestCompleted(data: data.count)
                return data
            }
        case .loadCategories:
            Task {
                let data = await NetworkModel.loadCategories()
                self.viewData.catsCount = data.count
                await self.requestCompleted(data: data.count)
                return data
            }
        }
    }
    
    
}

@available(iOS 14.0, *)
#Preview {
    NetworkTestView()
}
