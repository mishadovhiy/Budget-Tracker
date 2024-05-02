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
    let lastSelected = LastSelected()

    static var _db:[String:Any]?
    var db:[String:Any] {
        get {
            if let db = DataBase._db {
                return db
            } else {
                let dbDict = AppDelegate.properties?.coreDataManager?.fetch(.general)?.data?.toDict ?? [:]
                DataBase._db = dbDict
                AppDelegate.properties?.appData.threadCheck(shouldMainThread: false)
print(dbDict, " dbdata")
                return dbDict
            }
            
        }
        set {
            if newValue.containsNil {
                print("db contains nill")
                return
            }
            DataBase._db = newValue
            AppDelegate.properties?.appData.threadCheck(shouldMainThread: false)

            if let core:Data = .create(from: newValue) {
                print("updating core data")
                AppDelegate.properties?.coreDataManager?.update(.init(db: core))
            }
        }
    }
    

    var proEnabeled:Bool {
        let result = proTrial || proVersion
        return devMode ? !(forceNotPro ?? !result) : result
    }
    
    var randomColorName: String {
        return db["SelectedTintColor"] as? String ?? "yellowColor"
    }
    
    var devMode:Bool {
        #if os(iOS)
        if userEmailHolder.contains("dovhiy.com") {
            return true
        } else {
            let id = UIDevice.current.identifierForVendor?.uuidString ?? ""
            if testIds.contains(id) {
                return true
            } else {
                return false
            }
        }
        #else
        return false
        #endif
        
    }
    
    private let testIds:[String] = [
        "092BAEA3-9810-4A80-ADEF-53ABC78F9CA0",
        "C2F525EB-3192-4483-9F29-50F1DA63BECF",
        "B7BC8C6F-505C-4836-B240-3326CBDD0AC2",
        "E4636FA3-660C-4562-9D4B-999056448BB7",
        "6F2934F2-80F9-49D2-88D3-62A51BE1933D"
    ]


    
    var proVersion: Bool {
        get{
            let result = !purchasedOnThisDevice ? (db["proVersion"] as? Bool ?? false) : purchasedOnThisDevice
            return result
        }
        set(value){
            let was = !purchasedOnThisDevice ? (db["proVersion"] as? Bool ?? false) : purchasedOnThisDevice
            db.updateValue(value, forKey: "proVersion")
            if was && !value {
#if os(iOS)
                DispatchQueue.main.async {
                    AppDelegate.properties?.banner.createBanner()
                }
                #endif
            } else if !was && value {
#if os(iOS)
                DispatchQueue.main.async {
                    AppDelegate.properties?.banner.hide(remove: true, ios13Hide: true)
                }
                #endif
            }
            
        }
    }
    
    var unsendedData:[[String: [String:Any]]] {
        //0 - type (delete transaction)
        //1 - toDataString
        get {
            return db[ "unsendedData"] as? [[String: [String:Any]]] ?? []
        }
        set(value){
            db.updateValue(value, forKey: "unsendedData")
        }
    }
    
    
    var purchasedOnThisDevice: Bool {
        get{
            return db["purchasedOnThisDevice"] as? Bool ?? false
        }
        set(value){
            db.updateValue(value, forKey: "purchasedOnThisDevice")
        }
    }
    
    var trialDate: String {
        get{
            return db["trialDate"] as? String ?? ""
        }
        set(value){
            db.updateValue(value, forKey: "trialDate")
        }
    }
    
    var proTrial: Bool {
        get{
            return db["proTrial"] as? Bool ?? false
        }
        set(value){
            db.updateValue(value, forKey: "proTrial")
        }
    }
    
    var transactionDate:String? {
        get{
            return db["transactionDate"] as? String ?? ""
        }
        set(value){
            if let value {
                db.updateValue(value, forKey: "transactionDate")
            } else {
                db.removeValue(forKey: "transactionDate")
            }
        }
    }
    
    
    
    

    
    
    func emailFromLoadedDataPurch(_ data:[[String]]) -> String? {
        //get user email
        //loadedData.append([name, email, password, registrationDate, pro, trialDate])
        if !purchasedOnThisDevice {
            let currnt = username
            var emailOptional:String?
            for i in 0..<data.count {
                if data[i][0] == currnt {
                    emailOptional = data[i][1]
                }
            }
            if let email = emailOptional {
                var dbPurch = false
                for i in 0..<data.count {
                    if !dbPurch {
                        if data[i][1] == email {
                            if data[i][4] == "1" {
                                dbPurch = true
                                break
                            }
                        }
                    }
                }
                if proVersion != dbPurch {
                    proVersion = dbPurch
                }
                print("dbPurch:", dbPurch)
                return email
            }
            
        }
        return nil
    }
    
    
    var appUrl:String? {

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
       username = ""
        AppDelegate.properties?.notificationManager.removeAll()

    }
    
    var linkColor: String {
        set {
            db.updateValue(newValue, forKey: "SelectedTintColor")
#if os(iOS)
            DispatchQueue.main.async {
                let window = UIApplication.shared.sceneKeyWindow ?? UIWindow()
                window.tintColor = .colorNamed(newValue)
            }
            #endif
        }
        get {
            return db["SelectedTintColor"] as? String ?? "Yellow"
        }
    }
    var filter:Filter {
        get {
            let dict = db["Filter"] as? [String : Any] ?? [:]
            return .init(dict: dict)
        }
        set {
            db.updateValue(newValue.dict, forKey: "Filter")
        }
    }
    var forceNotPro: Bool? {
        get{

            return nil//db.db["forcePro"] as? Bool
        }
        set(value){
            db.updateValue(value ?? false, forKey: "forcePro")
        }
    }
    

    
    var username: String {
        get{
            if let user = self.db["username"] as? String {
                return user
            } else {
#if os(iOS)
                return ""
                #else
                return UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.value(forKey: "username") as? String ?? ""
                #endif
            }
        }
        set(value){
            print("new username setted - \(value)")
            db.updateValue(value, forKey: "username")
            UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.setValue(value, forKey: "username")
        }
    }
    


    var password: String {
        get{
            if let user = db["password"] as? String {
                return user
            } else {
                return ""
            }
        }
        set(value){
            print("new password setted - \(value)")
            db.updateValue(value, forKey: "password")
        }
    }
    
    var userEmailHolder: String {
        get{
            if let user = db["userEmailHolder"] as? String {
                return user
            } else {
                return ""
            }
        }
        set(value){
            print("new password setted - \(value)")
            db.updateValue(value, forKey: "userEmailHolder")
        }
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
            if newValue.count != 0 {
                let result = transactionsToDict(newValue: newValue)
                db.updateValue(result, forKey: transactionsKey)
                print(result.count, " rhtgerfweg")
                UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.setValue(result, forKey: "transactionsDataNew")
            } else {
                db.removeValue(forKey: transactionsKey)
                UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.removeObject(forKey: "transactionsDataNew")
            }

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
    
    var categoriesHolder:[NewCategories] {
        let all = db[categoriesKey] as? [[String:Any]] ?? []
        return dictToCategories(all: all)
    }

    var categories: [NewCategories] {
        get {
            let all = db[categoriesKey] as? [[String:Any]] ?? []
            let result = dictToCategories(all: all)
            return result
        }
        
        set {
            if newValue.count != 0 {
                let result = categoriesToDict(newValue: newValue)
                db.updateValue(result, forKey: categoriesKey)
            } else {
                db.removeValue(forKey: categoriesKey)
            }
            
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


