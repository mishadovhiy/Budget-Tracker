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





