//
//  DataClass.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 28.11.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import Foundation


class DataBase {
    static var _db:[String:Any]?
    var db:[String:Any] {
        get {
            if let db = DataBase._db {
                return db
            } else {
                //let v = UserDefaults.standard.value(forKey: "DataBase") as? [String:Any] ?? [:]
                let v = AppDelegate.shared?.coreDataManager?.fetch(.general)?.data?.toDict ?? [:]
                DataBase._db = v
                print(Thread.isMainThread, " dbgetThread")
                if Thread.isMainThread {
                    if (AppDelegate.shared?.appData.devMode ?? false) {
                        AppDelegate.shared?.newMessage.show(title:"fatal error, from main", type: .error)
                    }
                    print("!!!!!!!!!!!errororor")
                }
                return v
            }
            
        }
        set {
            DataBase._db = newValue
            print(Thread.isMainThread, " dbsetThread")
            if Thread.isMainThread {
                print("!!!!!!!!!!!errororor set")
                if (AppDelegate.shared?.appData.devMode ?? false) {
                    AppDelegate.shared?.newMessage.show(title:"fatal error, from main", type: .error)
                }
            }
           // UserDefaults.standard.setValue(newValue, forKey: "DataBase")
            if let core:Data = .create(from: newValue) {
                print("updating core data")
                AppDelegate.shared?.coreDataManager?.update(.init(db: core))
            }
        }
    }
    
    var appUrl:String? {
      /*  get {
            return db["appUrl"] as? String ?? [:]
        }
        set {
            if let new = newValue {
                
            } ele {
                
            }
            db.updateValue(newValue, forKey: "appUrl")
        }*/
        get {
            return ""
        }
        set {
            print(newValue)
        }
    }
    
    func removeAll() {
        transactions = []
        categories = []
        localCategories = []
        localTransactions = []
        AppDelegate.shared?.appData.username = ""
        AppDelegate.shared?.appData.password = ""
//        let vcs = self.viewControllers
//        let url = self.appUrl
//        let lastSelected = self.db["lastSelected"] as? [String:String] ?? [:]
//        let password = UserSettings.Security.password
//        let passTimout = UserSettings.Security.timeOut
//        lastSelectedDate = nil
//        AppData.categoriesHolder = nil
//        self.db.removeAll()
//       
//        //old db
//        UserDefaults.standard.setValue(nil, forKey: "lastSelected")
//        UserDefaults.standard.setValue(true, forKey: "checkTrialDate")
//        UserDefaults.standard.setValue(false, forKey: "trialPressed")
//        UserDefaults.standard.setValue(nil, forKey: "trialToExpireDays")
//        UserDefaults.standard.setValue(nil, forKey: "username")
//        UserDefaults.standard.setValue(nil, forKey: "password")
//
//        self.appUrl = url
//        self.viewControllers = vcs
//        UserSettings.Security.password = password
//        UserSettings.Security.timeOut = passTimout
//        self.db.updateValue(lastSelected, forKey: "lastSelected")
    }
    
    func checkDBUpdated() -> Bool {
        if let oldDB = UserDefaults.standard.value(forKey: "DataBase") as? [String:Any] {
            UserDefaults.standard.removeObject(forKey: "DataBase")
            self.db = oldDB
            return false
        }
        return true
    }
    
    var viewControllers:ViewControllers {
        get {
            return .init(dict: db["ViewControllers"] as? [String:Any] ?? [:])
        }
        set {
            db.updateValue(newValue.dict, forKey: "ViewControllers")
        }
    }
    
    func category(_ id: String, local: Bool = false) -> NewCategories? {
        let data = Array(db[!local ? categoriesKey : K.Keys.localCategories] as? [[String:Any]] ?? [])
        for i in 0..<data.count {
            if (data[i]["Id"] as? String ?? "") == id {
                return .create(dict: data[i])
            }
        }
        return nil
    }

    
    let categoriesKey = "categoriesDataNew"

    func deleteCategory(id:String, local: Bool = false) {
        let key = local ? K.Keys.localCategories : categoriesKey
        let all = Array(db[key] as? [[String:Any]] ?? [])
        var result:[[String:Any]] = []
        for i in 0..<all.count {
            if (all[i]["Id"] as? String ?? "") != "\(id)" {
                result.append(all[i])
            }
        }
        db.updateValue(result, forKey: key)
    }
    
    func update(_ category: NewCategories, local: Bool = false) {
        ///adds or updates (if not found) local storage
        let key = local ? K.Keys.localCategories : categoriesKey
        var all = Array(db[key] as? [[String:Any]] ?? [])
        var found = false
        let new = category.dict
        for i in 0..<all.count {
            if (all[i]["Id"] as? String ?? "") == "\(category.id)" {
                found = true
                all[i] = new
            }
        }
        if found {
            db.updateValue(all, forKey: key)
        } else {
            all.append(new)
        }
        
    }
    
    
    
    
    
    
    let transactionsKey = "transactionsDataNew"
    
    func transactions(for category:NewCategories, local: Bool = false) -> [TransactionsStruct] {
        
        let trans = Array(db[!local ? transactionsKey : K.Keys.localTrancations] as? [[String:Any]] ?? [])
        var result:[TransactionsStruct] = []
        for t in 0..<trans.count {
            if (trans[t]["CategoryId"] as? String ?? "") == "\(category.id)" {
                if let new:TransactionsStruct = .create(dictt: trans[t]) {
                    result.append(new)
                }
            }
        }
        return result
    }
    
    
    func deleteTransaction(transaction:TransactionsStruct, local: Bool = false) {
        let key = !local ? transactionsKey : K.Keys.localTrancations
        let all = Array(db[key] as? [[String:Any]] ?? [])
        var new:[TransactionsStruct] = []
        var found = false
        for i in 0..<all.count {
            if let trans:TransactionsStruct = .create(dictt: all[i]) {
                if trans.categoryID == transaction.categoryID && trans.comment == transaction.comment && trans.date == transaction.date && trans.value == transaction.value && !found {
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
        let all = db[transactionsKey] as? [[String:Any]] ?? []
        for i in 0..<all.count {
            if let value = all[i]["Amount"] as? String {
                result += (Int(Double(value) ?? 0.0))
            }
        }
        return result
    }
    
    var transactions:[TransactionsStruct] {
        get {
            let t = UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.value(forKey: "transactionsDataNew") as? [[String:Any]] ?? []
            print(t.count, " yhtrgefd")
            let all = db[transactionsKey] as? [[String:Any]] ?? []
            let result = dictToTransactions(all: all)
            return result
        }
        set {
            let result = transactionsToDict(newValue: newValue)
            db.updateValue(result, forKey: transactionsKey)
            print(result.count, " rhtgerfweg")
            UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.setValue(result, forKey: "transactionsDataNew")
        }
    }
    var localTransactions:[TransactionsStruct] {
        get {
            let all = db[K.Keys.localTrancations] as? [[String:Any]] ?? []
            let result = dictToTransactions(all: all)
            return result
        }
        set {
            let result = transactionsToDict(newValue: newValue)
            db.updateValue(result, forKey:  K.Keys.localTrancations)
        }
    }
    private func dictToTransactions(all:[[String:Any]]) -> [TransactionsStruct] {
        var result: [TransactionsStruct] = []
        for i in 0..<all.count {
            if let new:TransactionsStruct = .create(dictt: all[i]) {
                result.append(new)
            }
            
        }
        return result
    }
    private func transactionsToDict(newValue:[TransactionsStruct]) -> [[String:Any]] {
        var result: [[String:Any]] = []
        for i in 0..<newValue.count {
            result.append(newValue[i].dict)
        }
        return result
    }
    
    

    var categories: [NewCategories] {
        get {
            let all = db[categoriesKey] as? [[String:Any]] ?? []
            let result = dictToCategories(all: all)
            return result
        }
        
        set {
            let result = categoriesToDict(newValue: newValue)
            db.updateValue(result, forKey: categoriesKey)
        }
    }
    var localCategories: [NewCategories] {
        get {
            let all = db[K.Keys.localCategories] as? [[String:Any]] ?? []
            let result = dictToCategories(all: all)
            return result
        }
        
        set {
            let result = categoriesToDict(newValue: newValue)
            db.updateValue(result, forKey: K.Keys.localCategories)
        }
    }
    private func dictToCategories(all:[[String:Any]]) -> [NewCategories] {
        var result: [NewCategories] = []
        let a = Array(all)
        for i in 0..<a.count {
            if let new:NewCategories = .create(dict: a[i]) {
                result.append(new)
            }
            
        }
        return result
    }
    private func categoriesToDict(newValue:[NewCategories]) -> [[String:Any]] {
        var result: [[String:Any]] = []
        for i in 0..<newValue.count {
            result.append(newValue[i].dict)
        }
        return result
    }
    
    
    
    
    //K.Keys.localTrancations
    var debts: [NewCategories] {
        let all = db[categoriesKey] as? [[String:Any]] ?? []
        let result = debts(all: all)
        return result
    }
    private func debts(all: [[String:Any]]) -> [NewCategories] {
        var result: [NewCategories] = []
        for i in 0..<all.count {
            if let new:NewCategories = .create(dict: all[i]) {
                if new.purpose == .debt {
                    result.append(new)
                }
                
            }
            
        }
        return result
    }

    
}


