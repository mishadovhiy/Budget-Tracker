//
//  TransactionStruct.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


struct TransactionsStruct {
    var value: String
    var categoryID: String
    var date: String
    var comment: String
    var isNewTransaction:Bool = false
    var reminder:[String:Any]? = nil
    
    init(value: String = "", categoryID: String = "", date: String = "", comment: String = "", reminder: [String : Any]? = nil) {
        self.value = value
        self.categoryID = categoryID
        self.date = date
        self.comment = comment
        self.reminder = reminder
    }
    
    static func newTransaction(type:LastSelected.SelectedTypeEnum, completion:@escaping(_ new:Self)->()) {
        let appDelegate = AppDelegate.properties
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let db = appDelegate?.db
            let cat = db?.lastSelected.gett(valueType: type)
            var new:Self = .init(categoryID: cat ?? "", date: db?.transactionDate ?? (Date().toDateComponents().toShortString() ?? ""))
            new.isNewTransaction = true
            DispatchQueue.main.async {
                completion(new)
            }
        }
    }
    
    let id:UUID = .init()
    func compToIso(dateStringOp:String? = nil) -> DateComponents?  {
        let date = dateStringOp ?? self.date
        let dateCo = DateComponents()
        return date == "" ? nil : dateCo.stringToCompIso(s: date)
    }
    
    
    
    var category:NewCategories {
        let db = AppDelegate.properties?.db
        return db?.category(categoryID) ?? NewCategories(id: -1, name: "Unknown", icon: "", color: "", purpose: .expense)
    }
    
    static func create(dictt:[String:Any]?) -> TransactionsStruct? {
        if let dict = dictt {
            if let id = dict["CategoryId"] as? String {
                let amount = dict["Amount"] as? String ?? ""
                let date = dict["Date"] as? String ?? ""
                let comment = dict["Comment"] as? String ?? ""
                let reminder = dict["Reminder"] as? [String:Any] ?? [:]
                return TransactionsStruct(value: amount, categoryID: id, date: date, comment: comment, reminder: reminder)
            }
        }
        return nil
    }
    
    var dict:[String:Any] {
        var result:[String:Any] = [
            "CategoryId":categoryID,
            "Amount":value,
            "Date":date,
            "Comment":comment
        ]
        if let reminder = reminder {
            result.updateValue(reminder, forKey: "Reminder")
        }
        return result
    }
    
    var dictLocal:[String:Any] {
        #if os(iOS)
        let date = self.date.stringToCompIso().textDate
        #else
        let date = self.date.description
        #endif
        var result:[String:Any] = [
            "CategoryId":categoryID,
            "Amount":value,
            "Date":date,
            "Comment":comment
        ]
        if let reminder = reminder {
            result.updateValue(reminder, forKey: "Reminder")
        }
        return result
    }
    
    var apiData:String? {
        guard let username = AppDelegate.properties?.db.username, username != "" else {
            return nil
        }
        return "&Nickname=\(username)" + "&CategoryId=\(self.categoryID)" + "&Amount=\(self.value)" + "&Date=\(self.date)" + "&Comment=\(self.comment)"
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
