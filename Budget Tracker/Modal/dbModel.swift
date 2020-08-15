//
//  dbModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 30.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct LoadFromDB {
    
    func showMessage(vc: UIViewController) {
        let message = MessageView(vc)
        message.showMessage(text: K.Text.errorInternet, type: .error, windowHeight: 50)
    }
    
    func Transactions(mainView: UIViewController?, completion: @escaping ([[String]]) -> ()) {
        
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/transactions.php"
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                appData.internetPresend = false
                if mainView != nil {
                    DispatchQueue.main.async {
                        self.showMessage(vc: mainView!)
                    }
                    return
                } else {
                    appData.unshowedErrors = "Transactions: " + K.Text.errorInternet
                    return
                }
                
            } else {
                appData.internetPresend = true
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
                }
                
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    if appData.username != "" {
                        if appData.username == (jsonElement["Nickname"] as? String ?? "") {
                            appData.defaults.setValue([], forKey: "transactionsData")
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
        
        DispatchQueue.main.async {
            task.resume()
        }

        
    }
    
    func Categories(mainView: UIViewController?, completion: @escaping ([[String]]) -> ()) {
        
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/categories.php"
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                appData.internetPresend = false
                if mainView != nil {
                    DispatchQueue.main.async {
                        self.showMessage(vc: mainView!)
                    }
                    return
                } else {
                    appData.unshowedErrors = "Categories: " + K.Text.errorInternet
                    return
                }
                
            } else {
                appData.internetPresend = true
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
                }
                
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    if appData.username != "" {
                        if appData.username == (jsonElement["Nickname"] as? String ?? "") {
                            appData.defaults.setValue([], forKey: "categoriesData")
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

        DispatchQueue.main.async {
            task.resume()
        }
        
    }
    
    func Users(mainView: UIViewController?, completion: @escaping ([[String]]) -> ()) {
        
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/users.php"
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                appData.internetPresend = false
                if mainView != nil {
                    DispatchQueue.main.async {
                        self.showMessage(vc: mainView!)
                    }
                    return
                } else {
                    appData.unshowedErrors = "User Data: " + K.Text.errorInternet
                    return
                }
                
            } else {
                appData.internetPresend = true
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
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

                completion(loadedData)
            
            }
            
        }

        DispatchQueue.main.async {
            task.resume()
        }
        
    }
    
}




struct SaveToDB {
    
    func showMessage(vc: UIViewController) {
        let message = MessageView(vc)
        message.showMessage(text: K.Text.errorInternet, type: .error, windowHeight: 50)
    }
    
    func Transactions(toDataString: String, mainView: UIViewController) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-transaction.php", toDataString: toDataString, mainView: mainView, errorLoading: "Transactions")
    }
    
    func Categories(toDataString: String, mainView: UIViewController) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-category.php", toDataString: toDataString, mainView: mainView, errorLoading: "Categories")
    }
    
    func Users(toDataString: String, mainView: UIViewController) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/new-user.php", toDataString: toDataString, mainView: mainView, errorLoading: "User Data")
    }
    
    func NewPassword(toDataString: String, mainView: UIViewController) {
        save(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/user-password.php", toDataString: toDataString, mainView: mainView, errorLoading: "User Data")
    }

    private func save(dbFileURL: String, toDataString: String, mainView: UIViewController?, errorLoading: String) {
        
        let url = NSURL(string: dbFileURL)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "POST"
        var dataToSend = "secretWord=44fdcv8jf3"
                
        dataToSend = dataToSend + toDataString
        let dataD = dataToSend.data(using: .utf8)
        do {
            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, error in
                
                if error != nil {
                    appData.internetPresend = false
                    if mainView != nil {
                        DispatchQueue.main.async {
                            self.showMessage(vc: mainView!)
                        }
                        return
                    } else {
                        appData.unshowedErrors = errorLoading + ": " + K.Text.errorInternet
                        return
                    }
                    
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        if returnedData == "1" {
                            appData.internetPresend = true
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
    
    func showMessage(vc: UIViewController) {
        let message = MessageView(vc)
        message.showMessage(text: K.Text.errorInternet, type: .error, windowHeight: 50)
    }
    
    func Transactions(toDataString: String, mainView: UIViewController?) {

        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-transaction.php", toDataString: toDataString, mainView: mainView, errorLoading: "Transactions")
    }
    
    func Categories(toDataString: String, mainView: UIViewController?) {

        delete(dbFileURL: "https://www.dovhiy.com/apps/budget-tracker-db/delete-category.php", toDataString: toDataString, mainView: mainView, errorLoading: "Categories")
    }
    
    private func delete(dbFileURL: String, toDataString: String, mainView: UIViewController?, errorLoading: String) {
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
                    if mainView != nil {
                        DispatchQueue.main.async {
                            self.showMessage(vc: mainView!)
                        }
                        return
                    } else {
                        appData.unshowedErrors = errorLoading + ": " + K.Text.errorInternet
                        return
                    }
                    
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        
                        if returnedData == "1" {
                            appData.internetPresend = true
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
