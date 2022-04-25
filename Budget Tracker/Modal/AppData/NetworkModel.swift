//
//  dbModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 30.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct LoadFromDB {

    static var shared = LoadFromDB()
    private func load(urlPath: String, completion: @escaping (NSArray, error?) -> ()) {

        if let url: URL = URL(string: urlPath) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    completion([], .internet)
                    return
                } else {
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    } catch let error as NSError {
                        completion([], .internet)
                        return
                    }

                    completion(jsonResult, nil)
                }
            }
            DispatchQueue.main.async {
                task.resume()
            }
        } else {
            completion([], .other)
        }
        
    }
    

    
    let db = DataBase()
    
    enum error {
        case internet
        case other
        case none
    }
    
    
    
    
    func newCategories(otherUser: String? = nil, saveLocally: Bool = true, completion: @escaping ([NewCategories], error) -> ()) {
        let user = otherUser == nil ? appData.username : otherUser!
        if user == "" {
            let local = db.categories
            completion(local, .none)
        } else {
            var loadedData: [NewCategories] = []
            load(urlPath: Keys.dbURL + "NewCategories.php") { jsonResult, error in
                if let error = error {
                    let local = db.categories
                    completion(local, error)
                } else {
                    var jsonElement = NSDictionary()
                    let myNik = user
                    
                    for i in 0..<jsonResult.count {
                        jsonElement = jsonResult[i] as! NSDictionary
                        
                        if myNik == (jsonElement["Nickname"] as? String ?? "") {
                            if let new = db.categoryFrom(jsonElement as! [String : Any]) {
                                loadedData.append(new)
                            }
                            
                        }
                        
                    }
                    if otherUser == nil && saveLocally {
                        db.categories = loadedData
                    }
                    completion(loadedData, .none)
                }
            }
        }
        
    }
    
    
    
    func newTransactions(otherUser: String? = nil, saveLocally: Bool = true, completion: @escaping ([TransactionsStruct], error) -> ()) {
        let user = otherUser == nil ? appData.username : otherUser!
        if user == "" {
            let local = db.transactions
            completion(local, .none)
        } else {
            var loadedData: [TransactionsStruct] = []
            load(urlPath: Keys.dbURL + "newTransactions.php") { jsonResult, error in
                if let error = error {
                    let local = db.transactions
                    completion(local, error)
                } else {
                    var jsonElement = NSDictionary()
                    let myNik = user
                    
                    for i in 0..<jsonResult.count {
                        jsonElement = jsonResult[i] as! NSDictionary
                        
                        if myNik == (jsonElement["Nickname"] as? String ?? "") {
                            if let new = db.transactionFrom(jsonElement as! [String : Any]) {
                                loadedData.append(new)
                            }
                            
                        }
                        
                    }
                    if otherUser == nil && saveLocally {
                        db.transactions = loadedData
                    }
                    
                    completion(loadedData, .none)
                }
            }
        }
    }
    
    
    
    func Users(completion: @escaping ([[String]], Bool) -> ()) {
        var loadedData: [[String]] = []
        let urlPath = Keys.dbURL + "users.php"
        if let url: URL = URL(string: urlPath) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                completion([], true)
                return
                
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
                    completion([], true)
                    return
                }
                
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary

                    if let name = jsonElement["Nickname"] as? String,
                       let email = jsonElement["Email"] as? String,
                       let password = jsonElement["Password"] as? String,
                       let registrationDate = jsonElement["Registration_Date"] as? String,
                       let pro = jsonElement["ProVersion"] as? String, //(0,1)
                       let trialDate = jsonElement["trialDate"] as? String
                    {
                        loadedData.append([name, email, password, registrationDate, pro, trialDate])
                    }
                    
                }

                completion(loadedData, false)
            
            }
            
        }

        DispatchQueue.main.async {
            task.resume()
        }
        }
        
    }
    
    
    
    
}




struct SaveToDB {
    let db = DataBase()
    enum dataType {
        case transactions
        case categories
        case non
    }

    static var shared = SaveToDB()
    
    func newTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if appData.username == "" {
            db.transactions.append(transaction)
            completion(false)
        } else {

            let data = "&Nickname=\(appData.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            save(dbFileURL: Keys.dbURL + "new-NewTransaction.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        appData.unsendedData.append(["transactionNew": db.transactionToDict(transaction)])
                    }
                    
                }
                if saveLocally {
                    db.transactions.append(transaction)
                }
                
                completion(error)
            })
        }
    }
    //param: dont append and dont send to unsended when toDataString!= nil
    func newCategories(_ category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if appData.username == "" {
            db.categories.append(category)
            completion(false)
        } else {
            let pupose = category.purpose.rawValue
            
            var amount:String {
                if let amount = category.amountToPay {
                    return "&AmountToPay=\(amount)"
                }
                return ""
            }
            
            var dueDate:String {
                if let date = category.dueDate {
                    if let result = date.toIsoString() {
                        return "&DueDate=" + result
                    }
                }
                return ""
            }
            let data = "&Nickname=\(appData.username)" + "&Id=\(category.id)" + "&Name=\(category.name)" + "&Icon=\(category.icon)" + "&Color=\(category.color)" + "&Purpose=\(pupose)" + amount + dueDate
            save(dbFileURL: Keys.dbURL + "new-NewCategory.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        appData.unsendedData.append(["categoryNew": db.categoryToDict(category)])
                    }
                    
                }
                if saveLocally {
                    db.categories.append(category)
                }
               
                completion(error)
            })
        }
        
    }
    

    
    
    func Users(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: Keys.dbURL + "new-user.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    func NewPassword(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: Keys.dbURL + "user-password.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    func sendCode(toDataString: String, completion: @escaping (Bool) -> ()) {
        //test.php?emailTo=hi@dovhiy.com&Nickname=huii&resetCode=1233
        save(dbFileURL: Keys.dbURL + "sendCode.php?\(toDataString)", toDataString: "", error: { (error) in
            completion(error)
        })
    }

    private func save(dbFileURL: String, httpMethod: String = "POST", toDataString: String, error: @escaping (Bool) -> ()) {
        if let urlData = dbFileURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        let url = NSURL(string: urlData)
        if let reqUrl = url as URL? {
        var request = URLRequest(url: reqUrl)
        request.httpMethod = httpMethod
        var dataToSend = "secretWord=" + Keys.secretKey
                
        dataToSend = dataToSend + toDataString
            
        let dataD = dataToSend.data(using: .utf8)
        appData.needDownloadOnMainAppeare = true
        do {
            print("dbModel: saving data", dbFileURL)
            print("dbModel: saving data", dataToSend)

            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, errr in
                
                if errr != nil {
                    print("save: internet error")
                    error(true)
                    return
                    
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)

                        if returnedData == "1" {
                            print("save: sended \(dataToSend)")
                            error(false)
                        } else {
                            let r = returnedData?.trimmingCharacters(in: .whitespacesAndNewlines)
                            if r == "1" {
                                print("save: sended \(dataToSend)")
                                error(false)
                            } else {
                                print("save: db error for (cats, etc)")
                                error(true)
                            }
                            
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            DispatchQueue.main.async {
                uploadJob.resume()
            }
        }
            } else {
                print("url data error")
                error(true)
            }
        } else {
            print("error creating url")
            error(true)
        }
            
    }
    
}






struct DeleteFromDB {
    let db = DataBase()
    static var shared = DeleteFromDB()
    
    func User(toDataString: String, completion: @escaping (Bool) -> ()) {
        delete(dbFileURL: Keys.dbURL + "delete-user.php", toDataString: toDataString, error: { (error) in
               completion(error)
           })
    }
    
    func CategoriesNew(category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if appData.username == "" {
            deleteCategory(category: category)
            completion(false)
        } else {
            let pupose = category.purpose.rawValue
            var amount:String {
                if let amount = category.amountToPay {
                    return "&AmountToPay=\(amount)"
                }
                return ""
            }
            
            var dueDate:String {
                if let date = category.dueDate {
                    if let result = date.toIsoString() {
                        return "&DueDate=" + result
                    }
                }
                return ""
            }
            
            let data = "&Nickname=\(appData.username)" + "&Id=\(category.id)" + "&Name=\(category.name)" + "&Icon=\(category.icon)" + "&Color=\(category.color)" + "&Purpose=\(pupose)" + amount + dueDate
            delete(dbFileURL: Keys.dbURL + "delete-NewCategory.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        appData.unsendedData.append(["deleteCategoryNew": db.categoryToDict(category)])
                    }
                    
                }
                if saveLocally {
                    deleteCategory(category: category)
                }
                
                completion(error)
            })
        }
        
    }
    private func deleteCategory(category: NewCategories) {
        let all = db.categories
        var new: [NewCategories] = []
        var deleted = false
        for i in 0..<all.count {
            if all[i].id != category.id || deleted {
                new.append(all[i])
            } else {
                deleted = true
            }
        }
        db.categories = new
    }
    
    func newTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if appData.username == "" {
            db.deleteTransaction(transaction: transaction)
            completion(false)
        } else {

            let data = "&Nickname=\(appData.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            delete(dbFileURL: Keys.dbURL + "delete-NewTransaction.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        appData.unsendedData.append(["deleteTransactionNew": db.transactionToDict(transaction)])
                    }
                    
                }
                if saveLocally {
                    db.deleteTransaction(transaction: transaction)
                }
                
                completion(error)
            })
        }
    }

    
    
    private func delete(dbFileURL: String, toDataString: String, error: @escaping (Bool) -> ()) {
        let url = NSURL(string: dbFileURL)
        if let reqUrl = url as URL? {
        var request = URLRequest(url: reqUrl)
        request.httpMethod = "POST"
        var dataString = "secretWord=" + Keys.secretKey
            appData.needDownloadOnMainAppeare = true
        //send
        dataString = dataString + toDataString
             print(dataString, "dataStringdataStringdataString delete")
        if let urlStringData = dataString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            let dataD = urlStringData.data(using: .utf8)
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, errr in
                    
                    if errr != nil {
                        error(true)
                        return
                        
                    } else {
                        if let unwrappedData = data {
                            let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                            if returnedData == "1" {
                                print("ok")
                                error(false)
                                return
                            } else {
                                print("delete: db error for (cats, etc)")
                                error(true)
                                return
                            }
                            
                        }
                        
                    }
                    
                }
                DispatchQueue.main.async {
                    uploadJob.resume()
                }
                
            }
        } else {
            error(true)
        }
        } else {
            error(true)
        }
            
    }
    
}


