//
//  ListView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 05.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI

struct ListView: View {
    let didSelect:(_ id:String)->()
    let tableData:[TableData]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            ForEach(tableData, id: \.id) { item in
                Text("\(item.title)")
                    .onTapGesture {
                        self.didSelect(item.id)
                        self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

extension ListView {
    struct TableData {
        let title:String
        let id:String
    }
}
