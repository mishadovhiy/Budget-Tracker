//
//  dbModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 30.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct LoadFromDB {
    
    func Transactions(completion: @escaping ([[String]]) -> ()) {
        appData.defaults.setValue([], forKey: "transactionsData")
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/transactions.php"
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("downloadItems - Failed to download data from server")
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
                }
                
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    if appData.username() != "" {
                        if appData.username() == (jsonElement["Nickname"] as? String ?? "") {
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

                completion(loadedData)
            
            }
            
        }

        task.resume()
        
    }
    
    func Categories(completion: @escaping ([[String]]) -> ()) {
        
        appData.defaults.setValue([], forKey: "categoriesData")
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/categories.php"
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("downloadItems - Failed to download data from server")
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
                }
                
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    if appData.username() != "" {
                        if appData.username() == (jsonElement["Nickname"] as? String ?? "") {
                            if let name = jsonElement["Nickname"] as? String,
                               let title = jsonElement["Title"] as? String,
                               let purpose = jsonElement["Purpose"] as? String
                            {
                                loadedData.append([name, title, purpose])
                            }
                            
                        }
                    }
                    
                }

                completion(loadedData)
            
            }
            
        }

        task.resume()
        
    }
    
    func Users(completion: @escaping ([[String]]) -> ()) {
        
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/users.php"
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("downloadItems - Failed to download data from server")
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
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

                completion(loadedData)
            
            }
            
        }

        task.resume()
        
    }
    
}




struct SaveToDB {
    
    func Transactions(toDataString: String) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-transaction.php", toDataString: toDataString)
    }
    
    func Categories(toDataString: String) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-category.php", toDataString: toDataString)
    }
    
    func Users(toDataString: String) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-user.php", toDataString: toDataString)
    }
    
    func NewPassword(toDataString: String) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/user-password.php", toDataString: toDataString)
    }

    private func save(dbFileURL: String, toDataString: String) {
        
        let url = NSURL(string: dbFileURL)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        var dataToSend = "secretWord=44fdcv8jf3"
                
        dataToSend = dataToSend + toDataString
        let dataD = dataToSend.data(using: .utf8)
        do {
            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, error in
                
                if error != nil {
                    print("no internet")
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        if returnedData == "1" {
                            print("ok")
                        } else {
                            print("db error for (cats, etc), developer fault")
                        }
                        
                    }
                    
                }
                
            }
            uploadJob.resume()
        }
            
    }
    
}




struct DeleteFromDB {
    
    func Transactions(toDataString: String) {
        
        let Nickname = "Misha"
        let Category = "inapp"
        let Date = "12.12.2020"
        let Value = "981"
        let Comment = ""
        let test = "&Nickname=\(Nickname)" + "&Category=\(Category)" + "&Date=\(Date)" + "&Value=\(Value)" + "&Comment=\(Comment)"
        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-transaction.php", toDataString: test)
    }
    
    func Categories() {

        let Nickname = "Misha"
        let Title = "Projects"
        let Purpose = "Income"
        let test = "&Nickname=\(Nickname)" + "&Title=\(Title)" + "&Purpose=\(Purpose)"
        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-category.php", toDataString: test)
    }
    
    private func delete(dbFileURL: String, toDataString: String) {
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
                    print("no internet")
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        if returnedData == "1" {
                            print("ok")
                        } else {
                            print("db error for (cats, etc), developer fault")
                        }
                        
                    }
                    
                }
                
            }
            uploadJob.resume()
        }
            
    }
    
}
