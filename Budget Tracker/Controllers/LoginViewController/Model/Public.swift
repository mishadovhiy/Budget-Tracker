//
//  Public.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 26.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import AlertViewLibrary

extension LoginViewController {
    func createAccoun(loadedData: [[String]]) {
        hideKeyboard()
        let values = textFieldValuesDict
     //   DispatchQueue.main.async {
            if let name = values["create.username"],
               let email = values["create.email"],
                let password = values["create.password"] {
            let regDate = appData.filter.getToday()
            if password == values["create.password.repeate"] ?? "" {
                if name != "" && !name.contains("@") && email != "" && password != "" {
                    let emailLimitOp = self.canAddForEmail(email, loadedData: loadedData)
                    if !self.userExists(name: name, loadedData: loadedData) && emailLimitOp == nil {
                        self.actionButtonsEnabled = true
                        if !email.contains("@") || !email.contains(".") {
                            self.obthervValues = true
                            self.showWrongFields()
                            
                            
                            let firstButton:AlertViewLibrary.button = .init(title: "Try again".localize, style: .regular, close: true) { _ in
                                self.emailLabel.becomeFirstResponder()
                            }
                            DispatchQueue.main.async {
                                self.ai.showAlert(buttons: (firstButton, nil), title: "Enter valid email address".localize, description: "With correct email address you could restore your password in the future".localize, type: .error)
                                
                            }

                        } else {
                           // let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate)"
                            print(toDataString, "toDataStringtoDataStringtoDataString")
                            SaveToDB.shared.Users(toDataString: toDataString) { (error) in
                                if error {
                                    DispatchQueue.main.async {
                                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                                    }
                                } else {
                                    let prevUsere = appData.username
                                    UserDefaults.standard.setValue(prevUsere, forKey: "prevUserName")
                                    KeychainService.savePassword(service: "BudgetTrackerApp", account: name, data: password)
                                    appData.username = name
                                    appData.password = password
                                    appData.userEmailHolder = email
                                    if prevUsere == "" && self.forceLoggedOutUser == "" {
                                        let db = DataBase()
                                        db.localTransactions = db.transactions
                                        db.localCategories = db.categories
                                    }
                                    if self.forceLoggedOutUser == "" {
                                        self.forceLoggedOutUser = ""
                                        appData.fromLoginVCMessage = "Wellcome".localize + ", \(appData.username)"
                                    }
                                    
                                    self.userChanged()
                                    if self.fromPro || self.forceLoggedOutUser != "" {
                                        DispatchQueue.main.async {
                                                self.dismiss(animated: true) {
                                                    self.ai.fastHide()
                                                }
                                        }
                                    } else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                                            self.ai.fastHide { _ in
                                                self.performSegue(withIdentifier: "homeVC", sender: self)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.ai.fastHide()
                        if let emailLimit = emailLimitOp {
                            if emailLimit == .totalError {
                                DispatchQueue.main.async {
                                    self.newMessage.show(title: "You have reached the maximum amount of usernames".localize, type: .error)
                                }
                            } else {
                                appData.presentBuyProVC(selectedProduct: 3)
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                    self.newMessage.show(title: "You have reached the maximum amount of usernames".localize, description: "Update to Pro".localize + " " + "to create new username".localize, type: .standart)
                                }
                            }
                            
                        } else {
                            self.actionButtonsEnabled = true
                            DispatchQueue.main.async {
                                self.newMessage.show(title: "Username".localize + " '\(name)' " + "already exists".localize, type: .error)
                            }
                        }
                        
                    }
                
                } else {
                    self.actionButtonsEnabled = true
                    self.obthervValues = true
                    self.showWrongFields()

                  //  DispatchQueue.main.async {
                    self.newMessage.show(title: "All fields are required".localize, type: .error)
                        self.ai.fastHide()
                 //   }
                  
                }
            } else {
                self.actionButtonsEnabled = true
         //       DispatchQueue.main.async {
                self.newMessage.show(title: "Passwords not match".localize, type: .error)
                    self.ai.fastHide()
              //  }
            }
     //   }
    }
    
    
    
        func logInPerf(nickname:String, password:String,  loadedData: [[String]]) {
        
        let DBusernameIndex = 0
        let DBpasswordIndex = 2
        let DBEmailIndex = 1
        var psswordFromDB = ""
 
        if userExists(name: nickname, loadedData: loadedData) {
            for i in 0..<loadedData.count {
                if loadedData[i][DBusernameIndex] == nickname {
                    print(loadedData[i], "loadedData[i]loadedData[i]loadedData[i]")
                    psswordFromDB = loadedData[i][DBpasswordIndex]
                    print(psswordFromDB, "psswordFromDBpsswordFromDBpsswordFromDBpsswordFromDB")
                    if password != psswordFromDB {
                        self.actionButtonsEnabled = true
                        let messageTitle = "Wrong".localize + " " + "password".localize
                        DispatchQueue.main.async {
                            self.newMessage.show(title: messageTitle, type: .error)
                            self.ai.fastHide()
                        }
                        return
                    } else {
                        if let keycheinPassword = KeychainService.loadPassword(service: "BudgetTrackerApp", account: nickname) {
                            if keycheinPassword != password {
                                KeychainService.updatePassword(service: "BudgetTrackerApp", account: nickname, data: password)
                            }
                        } else {
                            KeychainService.savePassword(service: "BudgetTrackerApp", account: nickname, data: password)
                        }
                        let prevUserName = appData.username
                        
                        appData.username = nickname
                        appData.password = password
                        appData.userEmailHolder = loadedData[i][DBEmailIndex]
                        if prevUserName != nickname {
                            userChanged()
                            UserDefaults.standard.setValue(prevUserName, forKey: "prevUserName")

                            if prevUserName == "" && forceLoggedOutUser == "" {
                                let db = DataBase()
                                db.localCategories = db.categories
                                db.localTransactions = db.transactions
                                
                            }
                            
                            if forceLoggedOutUser == "" {
                                appData.fromLoginVCMessage = "Wellcome".localize + ", \(appData.username)"
                            }
                            
                        }
                        
                        
                        if !appData.purchasedOnThisDevice {
                            appData.proVersion = loadedData[i][4] == "1" ? true : appData.proVersion
                        }
                        if fromPro || self.forceLoggedOutUser != "" {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true) {
                                    self.ai.fastHide()
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.ai.fastHide { _ in
                                    self.performSegue(withIdentifier: "homeVC", sender: self)
                                }
                            }

                        }
                        
                    }
                    return
                }
            }
        } else {
            self.actionButtonsEnabled = true
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.newMessage.show(title: "User not found".localize, type: .error)
                    self.ai.fastHide()
                }

            }
        }
        
    }
    }
}
