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
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/transactions.php"
        let url: URL = URL(string: urlPath)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                completion([], "error")
                return
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    completion([], "error")
                    return
                }
                print(data, "datadatadatadata")
                print(jsonResult, "jsonResultjsonResultjsonResultjsonResult")
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    if appData.username != "" {
                        if appData.username == (jsonElement["Nickname"] as? String ?? "") {
                           //20.08 - 9:43pm appData.defaults.setValue([], forKey: "transactionsData")
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
                completion([], "error")
                return
                
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
                    completion([], "error")
                    return
                }
                
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    if appData.username != "" {
                        if appData.username == (jsonElement["Nickname"] as? String ?? "") {
                         //20.08 - 9:43pm appData.defaults.setValue([], forKey: "categoriesData")
                            if let name = jsonElement["Nickname"] as? String,
                               let title = jsonElement["Title"] as? String,
                               let purpose = jsonElement["Purpose"] as? String
                            {
                                loadedData.append([name, title, purpose])
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
                appData.internetPresend = true
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
                       let registrationDate = jsonElement["Registration_Date"] as? String
                    {
                        loadedData.append([name, email, password, registrationDate])
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

    
    func Transactions(transactionStruct: TransactionsStruct, mainView: UIViewController?,completion: @escaping (Bool) -> ()) {
        let toDataString = "&Nickname=\(appData.username)" + "&Category=\(transactionStruct.category)" + "&Date=\(transactionStruct.date)" + "&Value=\(transactionStruct.value)" + "&Comment=\(transactionStruct.comment)"
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-transaction.php", toDataString: toDataString, errorLoading: "Transactions", dataType: .categories, completion: { (error) in
            completion(error)
        })
    }
    
    func Categories(toDataString: String, completion: @escaping (Bool) -> ()) {
        //в этой функции вместо toDataString принимать categoriesStruct
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-category.php", toDataString: toDataString, errorLoading: "Categories", dataType: .categories, completion: { (error) in
            completion(error)
        })
    }
    
    func Users(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-user.php", toDataString: toDataString, errorLoading: "User Data", dataType: .non, completion: { (error) in
            completion(error)
        })
    }
    
    func NewPassword(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/user-password.php", toDataString: toDataString, errorLoading: "User Data", dataType: .non, completion: { (error) in
            completion(error)
        })
    }

    private func save(dbFileURL: String, toDataString: String, errorLoading: String, dataType: dataType, completion: @escaping (Bool) -> ()) {
        
        let url = NSURL(string: dbFileURL)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        var dataToSend = "secretWord=44fdcv8jf3"
                
        dataToSend = dataToSend + toDataString
        let dataD = dataToSend.data(using: .utf8)
        do {
            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, error in
                
                if error != nil {
                    print("save: internet error")
                    completion(true)
                    return
                    
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        if returnedData == "1" {
                            appData.internetPresend = true
                            print("save: sended \(dataToSend)")
                            completion(false)
                        } else {
                            appData.internetPresend = false
                            print("save: db error for (cats, etc), developer fault")
                            completion(true)
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
    
    func showMessage(vc: UIViewController, error: Bool = true) {
        let message = MessageView(vc)
        DispatchQueue.main.async {
            message.showMessage(text: K.Text.errorInternet, type: error == true ?  .error : .succsess, windowHeight: 50)
        }
        
    }
    
    func Transactions(toDataString: String, mainView: UIViewController?, showSucssess: Bool = false) {

        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-transaction.php", toDataString: toDataString, mainView: mainView, errorLoading: "Transactions", showSuscssess: showSucssess)
    }
    
    func Categories(toDataString: String, mainView: UIViewController?, showSucssess: Bool = false) {

        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-category.php", toDataString: toDataString, mainView: mainView, errorLoading: "Categories", showSuscssess: showSucssess)
    }
    
    private func delete(dbFileURL: String, toDataString: String, mainView: UIViewController?, errorLoading: String, showSuscssess: Bool) {
        let url = NSURL(string: dbFileURL)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        var dataString = "secretWord=44fdcv8jf3"
                
        //send
        dataString = dataString + toDataString
                
        let dataD = dataString.data(using: .utf8)
        do {
            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, error in
                
                if error != nil {
                    appData.internetPresend = false
                    //or let
                    let r = appData.unsendedData
                    appData.unsendedData.append(["delete", dataString])
                    if mainView != nil {
                        self.showMessage(vc: mainView!)
                    }
                    return
                    
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        if returnedData == "1" {
                            appData.internetPresend = true
                            if showSuscssess {
                                if mainView != nil {
                                    self.showMessage(vc: mainView!, error: false)
                                }
                                
                            }
                        } else {
                            print("db error for (cats, etc), developer fault")
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
