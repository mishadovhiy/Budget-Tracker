//
//  dbModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 30.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit


//send unsended here!


struct LoadFromDB {
    
    func Transactions(completion: @escaping ([[String]], String) -> ()) {
        
        var loadedData: [[String]] = []
        load(urlPath: "https://www.dovhiy.com/apps/budget-tracker-db/transactions.php") { (jsonResult, error) in
            if let error = error {
                completion([], "Internet Error!")
            } else {
                var jsonElement = NSDictionary()
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    if appData.username != "" {
                        if appData.username == (jsonElement["Nickname"] as? String ?? "") {
                            if let name = jsonElement["Nickname"] as? String,
                               let category = jsonElement["Category"] as? String,
                               let date = jsonElement["Date"] as? String,
                               let value = jsonElement["Value"] as? String,
                               let comment = jsonElement["Comment"] as? String
                            {
                                loadedData.append([name, category, date, value, comment])
                            }
                        }
                    }
                    
                }
                completion(loadedData, "")
            }
        }
    }
    func Debts(completion: @escaping ([[String]], String) -> ()) {
        
        var loadedData: [[String]] = []
        load(urlPath: "https://www.dovhiy.com/apps/budget-tracker-db/debts.php") { (jsonResult, error) in
            if let error = error {
                completion([], "Internet Error!")
            } else {
                var jsonElement = NSDictionary()
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary

                    if appData.username != "" {
                        if appData.username == (jsonElement["Nickname"] as? String ?? "") {
                            if let username = jsonElement["Nickname"] as? String,
                               let name = jsonElement["name"] as? String,
                               let amountToPay = jsonElement["amountToPay"] as? String,
                               let dueDate = jsonElement["dueDate"] as? String
                            {
                                loadedData.append([username, name, amountToPay, dueDate])
                            }
                        }
                    }
                    
                }
                completion(loadedData, "")
            }
        }
    }
    
    private func load(urlPath: String, completion: @escaping (NSArray, error?) -> ()) {

        let url: URL = URL(string: urlPath)!
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
    }
    
    func Categories(completion: @escaping ([[String]], String) -> ()) {
        
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/categories.php"
        let url: URL = URL(string: urlPath)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                completion([], "Error loading categories")
                return
                
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
                    completion([], "Error!")
                    return
                }
                
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary

                    if appData.username != "" {
                        if appData.username == (jsonElement["Nickname"] as? String ?? "") {
                            if let name = jsonElement["Nickname"] as? String,
                               let title = jsonElement["Title"] as? String,
                               let purpose = jsonElement["Purpose"] as? String,
                               let isExpecting = jsonElement["ExpectingPayment"] as? String
                            {
                                loadedData.append([name, title, purpose, isExpecting])
                            }
                        }
                    } 
                    
                }

                completion(loadedData, "")
            
            }
            
        }

        DispatchQueue.main.async {
            task.resume()
        }
        
    }
    
    let db = DataBase()
    
    enum error {
        case internet
        case other
        case none
    }
    
    
    
    
    func newCategories(otherUser: String? = nil, completion: @escaping ([NewCategories], error) -> ()) {
        let user = otherUser == nil ? appData.username : otherUser!
        if user == "" {
            let local = db.categories
            print(local, "locallocallocallocal")
            completion(local, .none)
        } else {
            var loadedData: [NewCategories] = []
            load(urlPath: "https://www.dovhiy.com/apps/budget-tracker-db/NewCategories.php") { jsonResult, error in
                print(jsonResult, "jsonResultjsonResult")
                if let error = error {
                    let local = db.categories
                    print(local, "locallocallocallocal")
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
                    if otherUser == nil {
                        db.categories = loadedData
                    }
                    completion(loadedData, .none)
                }
            }
        }
        
    }
    
    
    
    func newTransactions(otherUser: String? = nil, completion: @escaping ([TransactionsStruct], error) -> ()) {
        let user = otherUser == nil ? appData.username : otherUser!
        if user == "" {
            let local = db.transactions
            print(local, "locallocallocallocal")
            completion(local, .none)
        } else {
            var loadedData: [TransactionsStruct] = []
            load(urlPath: "https://www.dovhiy.com/apps/budget-tracker-db/newTransactions.php") { jsonResult, error in
                print(jsonResult, "jsonResultjsonResult")
                if let error = error {
                    let local = db.transactions
                    print(local, "locallocallocallocal")
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
                    if otherUser == nil {
                        db.transactions = loadedData
                    }
                    
                    completion(loadedData, .none)
                }
            }
        }
    }
    
    
    
    func Users(completion: @escaping ([[String]], Bool) -> ()) {
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/users.php"
        let url: URL = URL(string: urlPath)!
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




struct SaveToDB {
    let db = DataBase()
    enum dataType {
        case transactions
        case categories
        case non
    }

    
    func Transactions(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-transaction.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    func Categories(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-category.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    
    func newTransaction(_ transaction: TransactionsStruct, toDataString:String? = nil, completion: @escaping (Bool) -> ()) {
        if appData.username == "" {
            db.transactions.append(transaction)
            completion(false)
        } else {

            let data = toDataString != nil ? toDataString! : "&Nickname=\(appData.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-NewTransaction.php", toDataString: data, error: { (error) in
                if error {
                    if let toDataString = toDataString {
                        appData.unsendedData.append(["transactionNew": toDataString])
                    }
                    
                }
                if toDataString == nil {
                    db.transactions.append(transaction)
                }
                
                completion(error)
            })
        }
    }
    //param: dont append and dont send to unsended when toDataString!= nil
    func newCategories(_ category: NewCategories, toDataString:String? = nil, completion: @escaping (Bool) -> ()) {
        if appData.username == "" {
            db.categories.append(category)
            completion(false)
        } else {
            let pupose = purposeToString(category.purpose)
            
            var amount:String {
                if let amount = category.amountToPay {
                    return "&AmountToPay=\(amount)"
                }
                return ""
            }
            
            var dueDate:String {
                if let date = category.dueDate {
                    if let result = dateCompToIso(isoComp: date) {
                        return "&DueDate=" + result
                    }
                }
                return ""
            }
            print(category.color, "category.colorcategory.colorcategory.color")
            let data = toDataString != nil ? toDataString! : "&Nickname=\(appData.username)" + "&Id=\(category.id)" + "&Name=\(category.name)" + "&Icon=\(category.icon)" + "&Color=\(category.color)" + "&Purpose=\(pupose)" + amount + dueDate
            save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-NewCategory.php", toDataString: data, error: { (error) in
                if error {
                    if let toDataString = toDataString {
                        appData.unsendedData.append(["categoryNew": toDataString])
                    }
                    
                }
                if toDataString == nil {
                    db.categories.append(category)
                }
               
                completion(error)
            })
        }
        
    }
    
    
    
    
    func Debts(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-debts.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    
    func Users(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-user.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    func NewPassword(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/user-password.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    func sendCode(toDataString: String, completion: @escaping (Bool) -> ()) {
        //https://www.dovhiy.com/apps/budget-tracker-db/test.php?emailTo=hi@dovhiy.com&Nickname=huii&resetCode=1233
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/sendCode.php?\(toDataString)", toDataString: "", error: { (error) in
            completion(error)
        })
    }

    private func save(dbFileURL: String, httpMethod: String = "POST", toDataString: String, error: @escaping (Bool) -> ()) {
        
        let url = NSURL(string: dbFileURL)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = httpMethod
        var dataToSend = "secretWord=44fdcv8jf3"
                
        dataToSend = dataToSend + toDataString
        let dataD = dataToSend.data(using: .utf8)
        
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
            
    }
    
}






struct DeleteFromDB {
    let db = DataBase()
    func Transactions(toDataString: String, completion: @escaping (Bool) -> ()) {
        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-transaction.php", toDataString: toDataString, error: { (error) in
               completion(error)
           })
    }
    
    func User(toDataString: String, completion: @escaping (Bool) -> ()) {
        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-user.php", toDataString: toDataString, error: { (error) in
               completion(error)
           })
    }
    
    func Categories(toDataString: String, completion: @escaping (Bool) -> ()) {
        print(toDataString, "toDataStringtoDataStringtoDataStringtoDataStringtoDataString")
        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-category.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    func updateLocalCategory(category: NewCategories) {
        let all = db.categories
        var new: [NewCategories] = []
        for i in 0..<all.count {
            if all[i].id != category.id {
                new.append(all[i])
            }
        }
        db.categories = new
    }
    
    
    
    func CategoriesNew(category: NewCategories, toDataString: String? = nil, completion: @escaping (Bool) -> ()) {
        if appData.username == "" {
            updateLocalCategory(category: category)
            completion(false)
        } else {
            let pupose = purposeToString(category.purpose)
            var amount:String {
                if let amount = category.amountToPay {
                    return "&AmountToPay=\(amount)"
                }
                return ""
            }
            
            var dueDate:String {
                if let date = category.dueDate {
                    if let result = dateCompToIso(isoComp: date) {
                        return "&DueDate=" + result
                    }
                }
                return ""
            }
            
            let data = toDataString != nil ? toDataString! : "&Nickname=\(appData.username)" + "&Id=\(category.id)" + "&Name=\(category.name)" + "&Icon=\(category.icon)" + "&Color=\(category.color)" + "&Purpose=\(pupose)" + amount + dueDate
            delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-NewCategory.php", toDataString: data, error: { (error) in
                if error {
                    if let toDataString = toDataString {
                        appData.unsendedData.append(["deleteCategoryNew": toDataString])
                    }
                    
                }
                if toDataString == nil {
                    updateLocalCategory(category: category)
                }
                
                completion(error)
            })
        }
        
    }
    
    func newTransaction(_ transaction: TransactionsStruct, toDataString:String? = nil, completion: @escaping (Bool) -> ()) {
        if appData.username == "" {
            var all = db.transactions
            for i in 0..<all.count {
                if all[i].categoryID == transaction.categoryID && all[i].comment == transaction.comment && all[i].date == transaction.date && all[i].value == transaction.value {
                    all.remove(at: i)
                }
            }
            db.transactions = all
            completion(false)
        } else {

            let data = toDataString != nil ? toDataString! : "&Nickname=\(appData.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-NewTransaction.php", toDataString: data, error: { (error) in
                if error {
                    if let toDataString = toDataString {
                        appData.unsendedData.append(["deleteTransactionNew": toDataString])
                    }
                    
                }
                if toDataString == nil {
                    let all = db.transactions
                    var new:[TransactionsStruct] = []
                    for i in 0..<all.count {
                        if all[i].categoryID == transaction.categoryID && all[i].comment == transaction.comment && all[i].date == transaction.date && all[i].value == transaction.value {
                        } else {
                            new.append(all[i])
                        }
                    }
                    db.transactions = new
                }
                
                completion(error)
            })
        }
    }

    func Debts(toDataString: String, completion: @escaping (Bool) -> ()) {
        print(toDataString, "toDataStringtoDataStringtoDataStringtoDataStringtoDataString")
        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-debt.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    
    private func delete(dbFileURL: String, toDataString: String, error: @escaping (Bool) -> ()) {
        let url = NSURL(string: dbFileURL)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        var dataString = "secretWord=44fdcv8jf3"
                
        //send
        dataString = dataString + toDataString
                
        let dataD = dataString.data(using: .utf8)
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
            
    }
    
}
