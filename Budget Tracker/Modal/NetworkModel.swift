//
//  dbModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 30.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct LoadFromDB {
    var appData:AppData {
        return AppDelegate.shared?.properties?.appData ?? .init()
    }
    static var shared = LoadFromDB()
    private func load(urlPath: String, completion: @escaping (NSArray, error?) -> ()) {
        if Thread.isMainThread && appData.db.devMode {
            AppDelegate.shared?.properties?.ai.showAlertWithOK(title:"main thread error ", text: "\(#function)", error: true)
        }
        print(urlPath, " urlPathurlPathurlPath")
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
                        print(error.description, " bhgcftyuijknbvgcfjhj")
                        completion([], .internet)
                        return
                    }
                    if Thread.isMainThread {
                        print("!!!!!!!!!!!errororor api")
                        if (AppDelegate.shared?.properties?.appData.db.devMode ?? false) {
                            AppDelegate.shared?.properties?.newMessage.show(title:"fatal error, from main", type: .error)
                        }
                    }
                    completion(jsonResult, nil)
                }
            }
      //      DispatchQueue.main.async {
                task.resume()
      //      }
        } else {
            completion([], .other)
        }
        
    }
    

    
    var db:DataBase {
        return AppDelegate.shared?.properties?.db ?? .init()
    }
    
    enum error {
        case internet
        case other
        case none
    }
    
    
    
    private func performAddCategory(otherUser: String? = nil, saveLocally: Bool = true, local:Bool = false, completion: @escaping ([NewCategories], error) -> ()) {
        let user = otherUser == nil ? appData.db.username : otherUser!
        if user == "" || local {
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
                            if let new = NewCategories.create(dict: jsonElement as? [String : Any] ?? [:]) {
                                loadedData.append(new)
                            }
                            
                        }
                        
                    }
                    if otherUser == nil && saveLocally {
                        db.categories = loadedData
                    }
                    print(loadedData, " newCategoriesnewCategoriesnewCategories")
                    completion(loadedData, .none)
                }
            }
        }
    }
    
    
    func newCategories(otherUser: String? = nil, saveLocally: Bool = true, local:Bool = false, completion: @escaping ([NewCategories], error) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performAddCategory(otherUser: otherUser, saveLocally: saveLocally, local: local, completion: completion)
            }
        } else {
            performAddCategory(otherUser: otherUser, saveLocally: saveLocally, local: local, completion: completion)
        }
        
    }
    
    private func performnewTransactions(otherUser: String? = nil, saveLocally: Bool = true, completion: @escaping ([TransactionsStruct], error) -> (), local:Bool = false) {
        let user = otherUser == nil ? appData.db.username : otherUser!
        if user == "" || local {
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
                            if let new = TransactionsStruct.create(dictt: jsonElement as? [String : Any] ?? [:]) {
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
    
    func newTransactions(otherUser: String? = nil, saveLocally: Bool = true, completion: @escaping ([TransactionsStruct], error) -> (), local:Bool = false) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performnewTransactions(otherUser: otherUser, saveLocally: saveLocally, completion: completion, local: local)

            }
        } else {
            self.performnewTransactions(otherUser: otherUser, saveLocally: saveLocally, completion: completion, local: local)
        }
        
    }
    
    private func performLoadUsers(completion: @escaping ([[String]], Bool) -> ()) {

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
    
    func Users(completion: @escaping ([[String]], Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performLoadUsers(completion: completion)
            }
        } else {
            performLoadUsers(completion: completion)
        }
        
    }
    
    
    
    static func checkPassword(from loadedData:[[String]], nickname:String?, password:String?) -> (Bool, [String]?) {
        guard let password, let nickname else {
            return (true, nil)
        }
        var wrongPassword = true
        var userData:[String]?
        for i in 0..<loadedData.count {
            if loadedData[i][0] == nickname {
                print(loadedData[i], "loadedData[i]loadedData[i]loadedData[i]")
                let psswordFromDB = loadedData[i][2]
                
                if password == psswordFromDB {
                    wrongPassword = false
                    userData = loadedData[i]
                    break
                } else {
                    userData = loadedData[i]
                }
            }
        }
        return (wrongPassword, userData)
    }
    
    
    
    
}




struct SaveToDB {
    var appData:AppData {
        return AppDelegate.shared?.properties?.appData ?? .init()
    }
    var db:DataBase {
        return appData.db
    }
    enum dataType {
        case transactions
        case categories
        case non
    }

    static var shared = SaveToDB()
    
    func performnewTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performnewTransaction(transaction, saveLocally: saveLocally, completion: completion)
            }
        } else {
            performnewTransaction(transaction, saveLocally: saveLocally, completion: completion)
        }
    }
    
    func newTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if appData.db.username == "" {
            db.transactions.append(transaction)
            completion(false)
        } else {

            let data = "&Nickname=\(appData.db.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            save(dbFileURL: Keys.dbURL + "new-NewTransaction.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        appData.db.unsendedData.append(["transactionNew": transaction.dict])
                    }
                    
                }
                if saveLocally {
                    db.transactions.append(transaction)
                }
                
                completion(error)
            })
        }
    }
    
    private func performnewCategories(_ category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if appData.db.username == "" {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.db.categories.append(category)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
        } else {
            let pupose = category.purpose.rawValue
            
            var amount:String {
                if let amount = category.amountToPay {
                    return "&AmountToPay=\(amount)"
                } else if let amount = category.monthLimit {
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
            let data = "&Nickname=\(appData.db.username)" + "&Id=\(category.id)" + "&Name=\(category.name)" + "&Icon=\(category.icon)" + "&Color=\(category.color)" + "&Purpose=\(pupose)" + amount + dueDate
            save(dbFileURL: Keys.dbURL + "new-NewCategory.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        appData.db.unsendedData.append(["categoryNew": category.dict])
                    }
                    
                }
                if saveLocally {
                    db.categories.append(category)
                }
               
                completion(error)
            })
        }
    }
    //param: dont append and dont send to unsended when toDataString!= nil
    func newCategories(_ category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        
        DispatchQueue(label: "api", qos: .userInitiated).async {
            self.performnewCategories(category, saveLocally: saveLocally, completion: completion)
        }
    }
    

    
    
    func Users(toDataString: String, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.save(dbFileURL: Keys.dbURL + "new-user.php", toDataString: toDataString, error: { (error) in
                    completion(error)
                })
            }
        } else {
            save(dbFileURL: Keys.dbURL + "new-user.php", toDataString: toDataString, error: { (error) in
                completion(error)
            })
        }
    }
    
    func NewPassword(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: Keys.dbURL + "user-password.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    func sendCode(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: Keys.dbURL + "sendCode.php?\(toDataString)", toDataString: "", error: { (error) in
            completion(error)
        })
    }
    
    func sendAnalytics(data:String, completion:@escaping (Bool) -> ()) {
        let doDataString = "applicationName=BudgetTracker&data=\(data)"
        let url = Keys.analyticsURL + "newAnalytic.php?"
        save(dbFileURL: url, toDataString: doDataString, secretWord: false, error: completion)
    }

    private func save(dbFileURL: String, httpMethod: String = "POST", toDataString: String, secretWord:Bool = true, error: @escaping (Bool) -> ()) {
        if let urlData = dbFileURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        let url = NSURL(string: urlData)
        if let reqUrl = url as URL? {
        var request = URLRequest(url: reqUrl)
        request.httpMethod = httpMethod
            var dataToSend = secretWord ? ("secretWord=" + Keys.secretKey) : ""
                
        dataToSend = dataToSend + toDataString
            
        let dataD = dataToSend.data(using: .utf8)
        appData.needDownloadOnMainAppeare = true
        do {
            print("dbModel: dbFileURL", dbFileURL)
            print("dbModel: dataToSend", dataToSend)

            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, errr in
                
                if errr != nil {
                    print("save: internet error")
                    error(true)
                    return
                    
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        print(Thread.isMainThread, " apithreaddd")
                        if Thread.isMainThread {
                            print("!!!!!!!!!!!errororor api")
                            if (AppDelegate.shared?.properties?.appData.db.devMode ?? false) {
                                AppDelegate.shared?.properties?.newMessage.show(title:"fatal error, from main", type: .error)
                            }
                        }
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
    var appData:AppData {
        return AppDelegate.shared?.properties?.appData ?? .init()
    }
    var db:DataBase {
        return appData.db
    }
    static var shared = DeleteFromDB()
    
    func User(toDataString: String, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.delete(dbFileURL: Keys.dbURL + "delete-user.php", toDataString: toDataString, error: { (error) in
                       completion(error)
                   })
            }
        } else {
            delete(dbFileURL: Keys.dbURL + "delete-user.php", toDataString: toDataString, error: { (error) in
                   completion(error)
               })
        }
    }
    

    func performCategoriesNew(category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if appData.db.username == "" {
            deleteCategory(category: category)
            completion(false)
        } else {
            let pupose = category.purpose.rawValue
            var amount:String {
                if let amount = category.amountToPay {
                    return "&AmountToPay=\(amount)"
                } else if let amount = category.monthLimit {
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
            
            let data = "&Nickname=\(appData.db.username)" + "&Id=\(category.id)" + "&Name=\(category.name)" + "&Icon=\(category.icon)" + "&Color=\(category.color)" + "&Purpose=\(pupose)" + amount + dueDate
            delete(dbFileURL: Keys.dbURL + "delete-NewCategory.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        appData.db.unsendedData.append(["deleteCategoryNew": category.dict])
                    }
                    
                }
                if saveLocally {
                    deleteCategory(category: category)
                }
                
                completion(error)
            })
        }
    }
    
    
    func CategoriesNew(category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performCategoriesNew(category: category, saveLocally: saveLocally, completion: completion)
            }
        } else {
            performCategoriesNew(category: category, saveLocally: saveLocally, completion: completion)
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
        if !deleted {
            print("category:", category, " fvdsdaefwrg not found to delete")
        }
        db.categories = new
    }
    
    func performnewTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if appData.db.username == "" {
            db.deleteTransaction(transaction: transaction)
            completion(false)
        } else {

            let data = "&Nickname=\(appData.db.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            delete(dbFileURL: Keys.dbURL + "delete-NewTransaction.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        appData.db.unsendedData.append(["deleteTransactionNew": transaction.dict])
                    }
                    
                }
                if saveLocally {
                    db.deleteTransaction(transaction: transaction)
                }
                
                completion(error)
            })
        }
    }
    
    func newTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performnewTransaction(transaction, saveLocally: saveLocally, completion: completion)
            }
        } else {
            performnewTransaction(transaction, saveLocally: saveLocally, completion: completion)
        }
    }

    func deleteAccount(completion: @escaping (Bool) -> ()) {
        if appData.db.username == "" {
            completion(false)
        } else {

          /*  let data = "&Nickname=\(appData.db.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            delete(dbFileURL: Keys.dbURL + "delete-NewTransaction.php", toDataString: data, error: { (error) in
                if error {

                    
                }

                
                completion(error)
            })*/
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
                        print(Thread.isMainThread, " apithreaddd")
                        if Thread.isMainThread {
                            print("!!!!!!!!!!!errororor api")
                            if (AppDelegate.shared?.properties?.appData.db.devMode ?? false) {
                                AppDelegate.shared?.properties?.newMessage.show(title:"fatal error, from main", type: .error)
                            }
                        }
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


