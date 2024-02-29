//
//  ShortCodeItem.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

enum ShortCodeItem:String {
    case addTransaction = "addTransaction"
    case addReminder = "addReminder"
    case monthlyLimits = "monthlyLimits"
    
    static var allCases:[ShortCodeItem] = [.addTransaction, .addReminder, .monthlyLimits]
    var item:Item {
        switch self {
        case .addTransaction:
            return .init(title: "Add Transaction", subtitle: "", icon: "plusLined")
        case .addReminder:
            return .init(title: "Add Reminder", subtitle: "", icon: "reminder")
        case .monthlyLimits:
            return .init(title: "Spending limits", subtitle: "", icon: "monthlyLimits")
        }
    }
    struct Item {
        let title:String
        let subtitle:String
        let icon:String
    }
}
