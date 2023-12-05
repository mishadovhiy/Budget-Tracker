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
                let regDate = AppDelegate.shared?.appData.filter.getToday()
            if password == values["create.password.repeate"] ?? "" {
                if name != "" && !name.contains("@") && email != "" && password != "" {
                    let emailLimitOp = self.canAddForEmail(email, loadedData: loadedData)
                    if !self.userExists(name: name, loadedData: loadedData) && emailLimitOp == nil {
                        self.actionButtonsEnabled = true
                        if !email.contains("@") || !email.contains(".") {
                            self.obthervValues = true
                            DispatchQueue.main.async {
                                self.showWrongFields()
                            }
                            
                            
                            let firstButton:AlertViewLibrary.button = .init(title: "Try again".localize, style: .regular, close: true) { _ in
                                self.emailLabel.becomeFirstResponder()
                            }
                            DispatchQueue.main.async {
                                self.endAnimating()
                                self.ai?.showAlert(buttons: (firstButton, nil), title: "Enter valid email address".localize, description: "With correct email address you could restore your password in the future".localize, type: .error)
                                
                            }

                        } else {
                           // let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate ?? "-")"
                            print(toDataString, "toDataStringtoDataStringtoDataString")
                            SaveToDB.shared.Users(toDataString: toDataString) { (error) in
                                if error {
                                    DispatchQueue.main.async {
                                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                                    }
                                } else {
                                    let dat = (self.db.transactions, self.db.categories)
                                    self.userChanged()
                                    let prevUsere = AppDelegate.shared?.appData.username
                                    self.db.db.updateValue(prevUsere, forKey: "prevUserName")
                                    KeychainService.savePassword(account: name, data: password)
                                    AppDelegate.shared?.appData.username = name
                                    AppDelegate.shared?.appData.password = password
                                    AppDelegate.shared?.appData.userEmailHolder = email
                                    
                                    if prevUsere == "" && self.forceLoggedOutUser == "" {
                                        let db = DataBase()
                                        db.localTransactions = dat.0
                                        db.localCategories = dat.1
                                    }
                                    if self.forceLoggedOutUser == "" {
                                        self.forceLoggedOutUser = ""
                                        AppDelegate.shared?.appData.fromLoginVCMessage = "Wellcome".localize + ", \(AppDelegate.shared?.appData.username ?? "-")"
                                    }
                                    
                                    
                                    if self.fromPro || self.forceLoggedOutUser != "" {
                                        DispatchQueue.main.async {
                                            self.endAnimating()
                                                self.dismiss(animated: true) {
                                                    self.ai?.fastHide()
                                                }
                                        }
                                    } else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                                            self.endAnimating()
                                            self.ai?.fastHide()
                                            self.performSegue(withIdentifier: "homeVC", sender: self)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.ai?.fastHide()
                        if let emailLimit = emailLimitOp {
                            if emailLimit == .totalError {
                                DispatchQueue.main.async {
                                    self.newMessage?.show(title: "You have reached the maximum amount of usernames".localize, type: .error)
                                }
                            } else {
                                AppDelegate.shared?.appData.presentBuyProVC(selectedProduct: 3)
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                    self.newMessage?.show(title: "You have reached the maximum amount of usernames".localize, description: "Update to Pro".localize + " " + "to create new username".localize, type: .standart)
                                }
                            }
                            
                        } else {
                            self.actionButtonsEnabled = true
                            DispatchQueue.main.async {
                                self.newMessage?.show(title: "Username".localize + " '\(name)' " + "already exists".localize, type: .error)
                            }
                        }
                        
                    }
                
                } else {
                    self.actionButtonsEnabled = true
                    self.obthervValues = true
                    self.showWrongFields()

                    DispatchQueue.main.async {
                    self.newMessage?.show(title: "All fields are required".localize, type: .error)
                        self.ai?.fastHide()
                    }
                  
                }
            } else {
                self.actionButtonsEnabled = true
         //       DispatchQueue.main.async {
                self.newMessage?.show(title: "Passwords not match".localize, type: .error)
                    self.ai?.fastHide()
              //  }
            }
     //   }
            } else {
                DispatchQueue.main.async {
                    self.showError(title: "all fields are required")
                }
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
                            self.newMessage?.show(title: messageTitle, type: .error)
                            self.ai?.fastHide()
                        }
                        return
                    } else {
                        if let keycheinPassword = KeychainService.loadPassword(account: nickname) {
                            if keycheinPassword != password {
                                KeychainService.updatePassword(account: nickname, data: password)
                            }
                        } else {
                            KeychainService.savePassword(account: nickname, data: password)
                        }
                        let prevUserName = AppDelegate.shared?.appData.username
                        
                        
                        if prevUserName != nickname {
                            let dat = (db.categories, db.transactions)
                            userChanged()
                            db.db.updateValue(prevUserName, forKey: "prevUserName")
                            
                            if prevUserName == "" && forceLoggedOutUser == "" {
                                let db = DataBase()
                                db.localCategories = dat.0
                                db.localTransactions = dat.1
                                
                            }
                            
                            if forceLoggedOutUser == "" {
                                AppDelegate.shared?.appData.fromLoginVCMessage = "Wellcome".localize + ", \(AppDelegate.shared?.appData.username ?? "")"
                            }
                            
                        }
                        AppDelegate.shared?.appData.username = nickname
                        AppDelegate.shared?.appData.password = password
                        AppDelegate.shared?.appData.userEmailHolder = loadedData[i][DBEmailIndex]
                        
                        if !(AppDelegate.shared?.appData.purchasedOnThisDevice ?? false) {
                            AppDelegate.shared?.appData.proVersion = loadedData[i][4] == "1" ? true : (AppDelegate.shared?.appData.proVersion ?? false)
                        }
                        if fromPro || self.forceLoggedOutUser != "" {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true) {
                                    self.ai?.fastHide()
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.ai?.fastHide { _ in
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
                    self.newMessage?.show(title: "User not found".localize, type: .error)
                    self.ai?.fastHide()
                }

            }
        }
        
    }
    }
}
