//
//  TransactionStruct.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


struct TransactionsStruct {
    let value: String
    var categoryID: String
    var date: String
    let comment: String
    
    var reminder:[String:Any]? = nil
    
    func compToIso(dateStringOp:String? = nil) -> DateComponents?  {
        let date = dateStringOp ?? self.date
        let dateCo = DateComponents()
        return date == "" ? nil : dateCo.stringToCompIso(s: date)
    }
    
    
    
    var category:NewCategories {
        let db = DataBase()
        return db.category(categoryID) ?? NewCategories(id: -1, name: "Unknown", icon: "", color: "", purpose: .expense)
    }
}

extension TransactionsStruct {
    
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,]
        return formatter
    }()

    var dateFromString: Date {
        let dateString = date.components(separatedBy: ".").reversed().joined(separator: ".")
        if TransactionsStruct.isoFormatter.date(from: dateString) == nil {
            return Date.init(timeIntervalSince1970: 1)
        } else {
            return TransactionsStruct.isoFormatter.date(from: dateString)!
        }
    }
    
}
