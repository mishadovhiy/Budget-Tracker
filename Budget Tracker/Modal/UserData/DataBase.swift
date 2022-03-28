//
//  DataClass.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 28.11.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit




class DataBase {

    func paymentReminders() -> [TransactionsStruct] {
        let data = UserDefaults.standard.value(forKey: "PaymentReminder") as? [[String:Any]] ?? []
        var result:[TransactionsStruct] = []
        for item in data {
            if let new = transactionFrom(item) {
                result.append(new)
            }
            
        }
        print(data, " paymentReminders")
        return result
    }
    
    func saveReminder(transaction:TransactionsStruct, time:DateComponents?, completion: @escaping (Bool) -> ()) {
        let notifications = Notifications()
        let body = transaction.value + " " + "for category".localize + ": " + transaction.category.name
        if let date = time?.createDateComp(date: transaction.date, time: time) {
            
            notifications.addLocalNotification(date: date, title: "Payment reminder", id: "paymentReminder", body: body) { added in
                if added {
                    var allReminders = UserDefaults.standard.value(forKey: "PaymentReminder") as? [[String:Any]] ?? []
                    allReminders.append(self.transactionToDict(transaction))
                    UserDefaults.standard.setValue(allReminders, forKey: "PaymentReminder")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
        
    }
    
    
    func category(_ id: String, local: Bool = false) -> NewCategories? {
        //localCategories
        let data = UserDefaults.standard.value(forKey: !local ? categoriesKey : K.Keys.localCategories) as? [[String:Any]] ?? []
        for i in 0..<data.count {
            if (data[i]["Id"] as? String ?? "") == id {
                if let new = categoryFrom(data[i]) {
                    return new
                }
            }
        }
        return nil
    }
    
    
    func transactionFrom(_ dictt:[String:Any]?) -> TransactionsStruct? {
        if let dict = dictt {
            if let id = dict["CategoryId"] as? String {
                print("bhjsdbhf", id)
                let amount = dict["Amount"] as? String ?? ""
                let date = dict["Date"] as? String ?? ""
                let comment = dict["Comment"] as? String ?? ""
                let reminder = dict["Reminder"] as? [String:Any] ?? [:]
                return TransactionsStruct(value: amount, categoryID: id, date: date, comment: comment, reminder: reminder)
            }
        }
        return nil
    }
    func transactionToDict(_ transaction: TransactionsStruct) -> [String:Any] {
        print(transaction.categoryID, "transaction.categoryIDtransaction.categoryIDtransaction.categoryID")
        var result:[String:Any] = [
            "CategoryId":transaction.categoryID,
            "Amount":transaction.value,
            "Date":transaction.date,
            "Comment":transaction.comment
        ]
        if let reminder = transaction.reminder {
            result.updateValue(reminder, forKey: "Reminder")
        }
        return result
    }
    
    
    private let categoriesKey = "categoriesDataNew"
    //[TransactionsStruct]
    func categoryFrom(_ dict:[String:Any]) -> NewCategories? {
        if let id = dict["Id"] as? String {
            
            let name = dict["Name"] as? String ?? ""
            let icon = dict["Icon"] as? String ?? ""
            let color = dict["Color"] as? String ?? ""
            let purpose = dict["Purpose"] as? String ?? ""
            let amountToPay = dict["AmountToPay"] as? String ?? ""
            let dueDate = dict["DueDate"] as? String ?? ""
            
            let purp = stringToPurpose(purpose)
            var date: DateComponents? {
                let dateCo = DateComponents()
                return dueDate == "" ? nil : dateCo.stringToCompIso(s: dueDate)
            }
            return NewCategories(id: Int(id) ?? 0, name: name, icon: icon, color: color, purpose: purp, dueDate: date, amountToPay: Double(amountToPay))
        }
        
        return nil
    }
    
    
    

    func categoryToDict(_ category: NewCategories) -> [String:Any] {
        
        let pupose = purposeToString(category.purpose)
        var result:[String:Any] = [
            "Name":category.name,
            "Id":"\(category.id)",
            "Icon":category.icon,
            "Purpose":pupose,
            "Color":category.color
        ]
        
        
        if let date = category.dueDate {
            result["DueDate"] = date.toIsoString() 
        }
        
        if let amount = category.amountToPay {
            result["AmountToPay"] = "\(amount)"
        }
        
        return result
    }


    
    func deleteCategory(id:String, local: Bool = false) {
        let all = UserDefaults.standard.value(forKey: local ? K.Keys.localCategories : categoriesKey) as? [[String:Any]] ?? []
        var result:[[String:Any]] = []
        for i in 0..<all.count {
            if (all[i]["Id"] as? String ?? "") != "\(id)" {
                result.append(all[i])
            }
        }
        UserDefaults.standard.setValue(result, forKey: local ? K.Keys.localCategories : categoriesKey)
    }
    
    func update(_ category: NewCategories, local: Bool = false) {
        ///adds or updates (if not found) local storage
        var all = UserDefaults.standard.value(forKey: local ? K.Keys.localCategories : categoriesKey) as? [[String:Any]] ?? []
        var found = false
        let new = categoryToDict(category)
        for i in 0..<all.count {
            if (all[i]["Id"] as? String ?? "") == "\(category.id)" {
                found = true
                all[i] = new
            }
        }
        if found {
            UserDefaults.standard.setValue(all, forKey: local ? K.Keys.localCategories : categoriesKey)
        } else {
            all.append(new)
        }
        
    }
    
    
    
    
    
    
    let transactionsKey = "transactionsDataNew"
    
    func transactions(for category:NewCategories, local: Bool = false) -> [TransactionsStruct] {
        
        let trans = UserDefaults.standard.value(forKey: !local ? transactionsKey : K.Keys.localTrancations) as? [[String:Any]] ?? []
        var result:[TransactionsStruct] = []
        for t in 0..<trans.count {
            if (trans[t]["CategoryId"] as? String ?? "") == "\(category.id)" {
                if let transaction = transactionFrom(trans[t]) {
                    result.append(transaction)
                }
                
            }
        }
        return result
    }
    
    
    func deleteTransaction(transaction:TransactionsStruct, local: Bool = false) {
        let all = Array(UserDefaults.standard.value(forKey: !local ? transactionsKey : K.Keys.localTrancations) as? [[String:Any]] ?? [])
        var new:[TransactionsStruct] = []
        var found = false
        for i in 0..<all.count {
            if let trans = transactionFrom(all[i]) {
                if trans.categoryID == transaction.categoryID && trans.comment == transaction.comment && trans.date == transaction.date && trans.value == transaction.value && !found {
                    print("found!!!!")
                    found = true
                } else {
                    new.append(trans)
                }
            }
            
        }
        if local {
            localTransactions = new
        } else {
            transactions = new
        }
        
    }
    
    var totalTransactionBalance: Int {
        var result = 0
        let all = UserDefaults.standard.value(forKey: transactionsKey) as? [[String:Any]] ?? []
        for i in 0..<all.count {
            if let value = all[i]["Amount"] as? String {
                result += (Int(Double(value) ?? 0.0))
            }
        }
        return result
    }
    
    var transactions:[TransactionsStruct] {
        get {
            let all = UserDefaults.standard.value(forKey: transactionsKey) as? [[String:Any]] ?? []
            let result = dictToTransactions(all: all)
            return result
        }
        set {
            let result = transactionsToDict(newValue: newValue)
            UserDefaults.standard.setValue(result, forKey: transactionsKey)
        }
    }
    var localTransactions:[TransactionsStruct] {
        get {
            let all = UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String:Any]] ?? []
            let result = dictToTransactions(all: all)
            return result
        }
        set {
            let result = transactionsToDict(newValue: newValue)
            UserDefaults.standard.setValue(result, forKey: K.Keys.localTrancations)
        }
    }
    private func dictToTransactions(all:[[String:Any]]) -> [TransactionsStruct] {
        var result: [TransactionsStruct] = []
        for i in 0..<all.count {
            if let new = transactionFrom(all[i]) {
                result.append(new)
            }
            
        }
        return result
    }
    private func transactionsToDict(newValue:[TransactionsStruct]) -> [[String:Any]] {
        var result: [[String:Any]] = []
        for i in 0..<newValue.count {
            result.append(transactionToDict(newValue[i]))
        }
        return result
    }
    
    

    var categories: [NewCategories] {
        get {
            let all = UserDefaults.standard.value(forKey: categoriesKey) as? [[String:Any]] ?? []
            let result = dictToCategories(all: all)
            return result
        }
        
        set {
            let result = categoriesToDict(newValue: newValue)
            UserDefaults.standard.setValue(result, forKey: categoriesKey)
        }
    }
    var localCategories: [NewCategories] {
        get {
            let all = UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String:Any]] ?? []
            let result = dictToCategories(all: all)
            return result
        }
        
        set {
            let result = categoriesToDict(newValue: newValue)
            UserDefaults.standard.setValue(result, forKey: K.Keys.localCategories)
        }
    }
    private func dictToCategories(all:[[String:Any]]) -> [NewCategories] {
        var result: [NewCategories] = []
        let a = Array(all)
        for i in 0..<a.count {
            if let new = categoryFrom(a[i]) {
                result.append(new)
            }
            
        }
        return result
    }
    private func categoriesToDict(newValue:[NewCategories]) -> [[String:Any]] {
        var result: [[String:Any]] = []
        for i in 0..<newValue.count {
            result.append(categoryToDict(newValue[i]))
        }
        return result
    }
    
    
    
    
    //K.Keys.localTrancations
    var debts: [NewCategories] {
        let all = UserDefaults.standard.value(forKey: categoriesKey) as? [[String:Any]] ?? []
        let result = debts(all: all)
        return result
    }
    private func debts(all: [[String:Any]]) -> [NewCategories] {
        var result: [NewCategories] = []
        for i in 0..<all.count {
            if let new = categoryFrom(all[i]) {
                if new.purpose == .debt {
                    result.append(new)
                }
                
            }
            
        }
        return result
    }
    
}


struct NewCategories {
    var id: Int
    var name: String
    var icon: String
    var color: String
    let purpose: CategoryPurpose
    var dueDate: DateComponents?
    var amountToPay: Double? = nil

    var transactions: [TransactionsStruct] {
        let db = DataBase()
        return db.transactions(for: self)
    }
    
}

struct TransactionsStruct {
    let value: String
    var categoryID: String
    var date: String
    let comment: String
    
    var reminder:[String:Any]? = nil
    
    func compToIso() {
        
    }
    
    var category:NewCategories {
        let db = DataBase()
        return db.category(categoryID) ?? NewCategories(id: -1, name: "Unknown", icon: "", color: "", purpose: .expense)
    }
}

