//
//  BudgetTrackerApp.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 28.04.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI

@main
struct BudgetTracker_Watch_AppApp: App {
    
    let appDelegate = AppDelegate.init()
    @State var loggedIn:Bool = false
    
    var body: some Scene {
        WindowGroup {
            if !loggedIn {
                LoginView(loggedIn: $loggedIn)
            } else {
                HomeView()
            }
        }
    }
}
