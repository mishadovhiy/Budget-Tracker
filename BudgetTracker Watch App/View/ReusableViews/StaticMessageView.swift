//
//  StaticMessageView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 02.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI


struct StaticMessageView: View {
    let message:MessageContent?
    var isLoading:Bool = false
    
    var body: some View {
        if !isLoading {
            ProgressView(message?.title ?? "")
        } else {
            VStack {
                Text(message?.title ?? "Unknown Error")
                Text(message?.description ?? "")
            }
        }
        
    }
}
