//
//  DataClass.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 28.11.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
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

    
}

class DataBase {
    
    

    
    
    func category(_ id: String) -> NewCategories? {
        
        let data = UserDefaults.standard.value(forKey: categoriesKey) as? [[String:Any]] ?? []
        for i in 0..<data.count {
            if (data[i]["Id"] as? String ?? "") == id {
                if let new = categoryFrom(data[i]) {
                    return new
                }
            }
        }
        return nil
    }
    
    
    func transactionFrom(_ dict:[String:Any]) -> TransactionsStruct? {
        if let id = dict["CategoryId"] as? String {
            print("bhjsdbhf", id)
            let amount = dict["Amount"] as? String ?? ""
            let date = dict["Date"] as? String ?? ""
            let comment = dict["Comment"] as? String ?? ""
            
            
            return TransactionsStruct(value: amount, categoryID: id, date: date, comment: comment)
        }
        return nil
    }
    func transactionToDict(_ transaction: TransactionsStruct) -> [String:Any] {
        print(transaction.categoryID, "transaction.categoryIDtransaction.categoryIDtransaction.categoryID")
        return [
            "CategoryId":transaction.categoryID,
            "Amount":transaction.value,
            "Date":transaction.date,
            "Comment":transaction.comment
        ]
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
                return dueDate == "" ? nil : stringToCompIso(s: dueDate)
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
            result["DueDate"] = dateCompToIso(isoComp: date)
        }
        
        if let amount = category.amountToPay {
            result["AmountToPay"] = "\(amount)"
        }
        
        return result
    }


    
    func deleteCategory(id:String) {
        let all = UserDefaults.standard.value(forKey: categoriesKey) as? [[String:Any]] ?? []
        var result:[[String:Any]] = []
        for i in 0..<all.count {
            if (all[i]["Id"] as? String ?? "") != "\(id)" {
                result.append(all[i])
            }
        }
        UserDefaults.standard.setValue(result, forKey: categoriesKey)
    }
    
    func update(_ category: NewCategories) {
        ///adds or updates (if not found) local storage
        var all = UserDefaults.standard.value(forKey: categoriesKey) as? [[String:Any]] ?? []
        var found = false
        let new = categoryToDict(category)
        for i in 0..<all.count {
            if (all[i]["Id"] as? String ?? "") == "\(category.id)" {
                found = true
                all[i] = new
            }
        }
        if found {
            UserDefaults.standard.setValue(all, forKey: categoriesKey)
        } else {
            all.append(new)
        }
        
    }
    
    
    
    
    
    
    
    
    func transactions(for category:NewCategories) -> [TransactionsStruct] {
        
        let trans = UserDefaults.standard.value(forKey: "transactionsData") as? [[String:Any]] ?? []
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
    
    
    
    var transactions:[TransactionsStruct] {
        get {
            let all = UserDefaults.standard.value(forKey: "transactionsData") as? [[String:Any]] ?? []
            var result: [TransactionsStruct] = []
            for i in 0..<all.count {
                if let new = transactionFrom(all[i]) {
                    result.append(new)
                }
                
            }
            return result
        }
        set {
            var result: [[String:Any]] = []
            for i in 0..<newValue.count {
                result.append(transactionToDict(newValue[i]))
            }
            UserDefaults.standard.setValue(result, forKey: "transactionsData")
        }
    }
    

    var categories: [NewCategories] {
        
        get {
            let all = UserDefaults.standard.value(forKey: categoriesKey) as? [[String:Any]] ?? []
            var result: [NewCategories] = []
            for i in 0..<all.count {
                if let new = categoryFrom(all[i]) {
                    result.append(new)
                }
                
            }
            return result
        }
        
        set {
            var result: [[String:Any]] = []
            for i in 0..<newValue.count {
                result.append(categoryToDict(newValue[i]))
            }
            UserDefaults.standard.setValue(result, forKey: categoriesKey)
        }
    }
    
    
}
