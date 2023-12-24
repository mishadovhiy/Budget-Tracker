//
//  CategoriesStruct.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


struct NewCategories {
    var id: Int
    var name: String
    var icon: String
    var color: String
    let purpose: CategoryPurpose
    var dueDate: DateComponents?
    var amountToPay: Double? = nil
    var monthLimit:Double? = nil

    var transactions: [TransactionsStruct] {
        let db = AppDelegate.shared?.properties?.db
        return db?.transactions(for: self) ?? []
    }
    
    var monthlyProgress:CGFloat? {
        if monthLimit == nil {
            return nil
        }
        let manag = TransactionsManager()
        manag.daysBetween = (transactions).compactMap({ $0.date })
        let total = manag.total(transactions: transactions)
        let percent = total.positive / (monthLimit ?? 0)
        print(percent, " efweefrv cat ", name)
        return percent
    }
    
    enum CategoryPurpose:String {
        case expense = "Expenses"
        case income = "Incomes"
        case debt = "debt"
        
        var lastSelected:LastSelected.SelectedTypeEnum {
            switch self {
            case .expense:
                return .expense
            case .income:
                return .income
            case .debt:
                return .debt
            default:
                return .expense
            }
        }
    }
    static func stringToPurpose(_ string: String) -> CategoryPurpose {
        switch string {
        case K.income:
            return .income
        case K.expense:
            return .expense
        case "Debt":
            return .debt
        default:
            return .debt
        }
    }
    
    static func create(dict:[String:Any]) -> NewCategories? {
        if let id = dict["Id"] as? String {
            
            let name = dict["Name"] as? String ?? ""
            let icon = dict["Icon"] as? String ?? ""
            let color = dict["Color"] as? String ?? ""
            let purpose = dict["Purpose"] as? String ?? ""
            let amountToPay = dict["AmountToPay"] as? String ?? ""
            let dueDate = dict["DueDate"] as? String ?? ""
            
            let purp = NewCategories.stringToPurpose(purpose)
            var date: DateComponents? {
                let dateCo = DateComponents()
                return dueDate == "" ? nil : dateCo.stringToCompIso(s: dueDate)
            }
            return NewCategories(id: Int(id) ?? 0, name: name, icon: icon, color: color, purpose: purp, dueDate: date, amountToPay: purp == .debt ? Double(amountToPay) : nil, monthLimit: purp != .debt ? Double(amountToPay) : nil)
        }
        
        return nil
    }
    
    
    var dict:[String:Any] {
        let category = self
        var result:[String:Any] = [
            "Name":category.name,
            "Id":"\(category.id)",
            "Icon":category.icon,
            "Purpose":category.purpose.rawValue,
            "Color":category.color
        ]
        
        
        if let date = category.dueDate {
            result["DueDate"] = date.toIsoString()
        }
        
        if let amount = (category.amountToPay ?? category.monthLimit) {
            result["AmountToPay"] = "\(amount)"
        }
        
        return result
    }
    
    
    var apiData:String? {
        guard let username = AppDelegate.shared?.properties?.db.username, username != "" else { return nil }
        var amount:String {
            if let amount = self.amountToPay {
                return "&AmountToPay=\(amount)"
            } else if let amount = self.monthLimit {
                return "&AmountToPay=\(amount)"
            }
            return ""
        }
        
        var dueDate:String {
            if let date = self.dueDate {
                if let result = date.toIsoString() {
                    return "&DueDate=" + result
                }
            }
            return ""
        }

        return "&Nickname=\(username)" + "&Id=\(self.id)" + "&Name=\(self.name)" + "&Icon=\(self.icon)" + "&Color=\(self.color)" + "&Purpose=\(self.purpose.rawValue)" + amount + dueDate
    }
}

struct DebtsStruct {
    let name: String
    var amountToPay: String
    var dueDate: String
}



extension [NewCategories] {
    static var defaultCategories:[NewCategories] {
        return [
            .init(id: -4, name: "Work", icon: "briefcase.fill", color: "BlueColor", purpose: .income),
            .init(id: -5, name: "Project #1", icon: "globe.americas.fill", color: "PinkColor-1", purpose: .income),
            .init(id: -3, name: "Groceries", icon: "takeoutbag.and.cup.and.straw.fill", color: "OrangeColor-1", purpose: .expense),
            .init(id: -6, name: "Health", icon: "bandage.fill", color: "yellowColor2", purpose: .expense),
            .init(id: -7, name: "Bills", icon: "flame.fill", color: "RedColor", purpose: .expense),
            .init(id: -8, name: "Entertainment", icon: "theatermasks.fill", color: "PinkColor", purpose: .expense),
            .init(id: -9, name: "Clothing", icon: "tshirt.fill", color: "Brown", purpose: .expense),
            .init(id: -10, name: "Transport", icon: "car.fill", color: "PinkColor-1", purpose: .expense),
            .init(id: -11, name: "Restaurants", icon: "fork.knife", color: "PinkColor", purpose: .expense),
            
            .init(id: -12, name: "Gifts", icon: "gift.fill", color: "pinkColor2", purpose: .expense),
            .init(id: -14, name: "Travel", icon: "suitcase.cart.fill", color: "yellowColor2", purpose: .expense),
            .init(id: -13, name: "Housing", icon: "house.fill", color: "OrangeColor-1", purpose: .expense),
            .init(id: -15, name: "Subscriptions", icon: "gamecontroller.fill", color: "GreenColor-2", purpose: .expense),
            .init(id: -16, name: "Savings", icon: "dollarsign.circle.fill", color: "GreenColor", purpose: .expense),
            
        ]
    }
}

