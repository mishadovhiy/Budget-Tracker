//
//  dbModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 30.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct LoadFromDB {
    
    func Transactions(completion: @escaping ([[String]], String) -> ()) {
        
        var loadedData: [[String]] = []
        load(urlPath: "https://www.dovhiy.com/apps/budget-tracker-db/transactions.php") { (jsonResult, error) in
            if error != "" {
                completion([], "Internet Error!")
            } else {
                var jsonElement = NSDictionary()
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    /*let arr = Array(appData.selectedUsernames)
                    for i in 0..<arr.count {
                        if arr[i] == (jsonElement["Nickname"] as? String ?? "") {
                            if let name = jsonElement["Nickname"] as? String,
                               let category = jsonElement["Category"] as? String,
                               let date = jsonElement["Date"] as? String,
                               let value = jsonElement["Value"] as? String,
                               let comment = jsonElement["Comment"] as? String
                            {
                                loadedData.append([name, category, date, value, comment])
                            }
                        }
                    }*///create one load with complition when jsonResult
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
            if error != "" {
                completion([], "Internet Error!")
            } else {
                var jsonElement = NSDictionary()
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                   /* let arr = Array(appData.selectedUsernames)
                    for i in 0..<arr.count {
                        if arr[i] == (jsonElement["Nickname"] as? String ?? "") {
                            if let username = jsonElement["Nickname"] as? String,
                               let name = jsonElement["name"] as? String,
                               let amountToPay = jsonElement["amountToPay"] as? String,
                               let dueDate = jsonElement["dueDate"] as? String
                            {
                                loadedData.append([username, name, amountToPay, dueDate])
                            }
                        }
                    }*/
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
    
    private func load(urlPath: String, completion: @escaping (NSArray, String) -> ()) {

        let url: URL = URL(string: urlPath)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                completion([], "Internet Error!")
                return
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    completion([], "Internet Error!")
                    return
                }

                completion(jsonResult, "")
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
                    /*let arr = Array(appData.selectedUsernames)
                    for i in 0..<arr.count {
                        if arr[i] == (jsonElement["Nickname"] as? String ?? "") {
                            if let name = jsonElement["Nickname"] as? String,
                               let title = jsonElement["Title"] as? String,
                               let purpose = jsonElement["Purpose"] as? String,
                               let isExpecting = jsonElement["ExpectingPayment"] as? String
                            {
                                loadedData.append([name, title, purpose, isExpecting])
                            }
                        }
                    }*/
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
