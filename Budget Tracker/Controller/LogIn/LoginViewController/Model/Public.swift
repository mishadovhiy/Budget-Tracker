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
            let regDate = AppDelegate.properties?.db.filter.getToday()
            if password == values["create.password.repeate"] ?? "" {
                if name != "" && !name.contains("@") && email != "" && password != "" {
                    let emailLimitOp = self.canAddForEmail(email, loadedData: loadedData)
                    if !self.userExists(name: name, loadedData: loadedData) && emailLimitOp == nil {
                        self.actionButtonsEnabled = true
                        if !email.contains("@") || !email.contains(".") {
                            self.obthervValues = true
                            DispatchQueue.main.async {
                                self.showWrongFields()
                                self.endAnimating()
                                self.ai?.showAlert(title: "Enter valid email address".localize, description: "With correct email address you could restore your password in the future".localize, appearence: .with({
                                    $0.type = .error
                                    $0.primaryButton = .with({
                                        $0.title = "Try again".localize
                                        $0.action = {
                                            self.emailLabel.becomeFirstResponder()
                                        }
                                    })
                                    $0.secondaryButton = .with({_ in})
                                }))
                                
                            }
                            
                        } else {
                            // let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate ?? "-")"
                            print(toDataString, "toDataStringtoDataStringtoDataString")
                            SaveToDB.shared.Users(toDataString: toDataString) { (error) in
                                if error {
                                    DispatchQueue.main.async {
                                        self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true, goToLogin: true)
                                    }
                                } else {
                                    let dat = (self.db.transactions, self.db.categories)
                                    self.userChanged()
                                    let prevUsere = AppDelegate.properties?.db.username
                                    self.db.db.updateValue(prevUsere, forKey: "prevUserName")
                                    KeychainService.savePassword(account: name, data: password)
                                    AppDelegate.properties?.db.username = name
                                    AppDelegate.properties?.db.password = password
                                    AppDelegate.properties?.db.userEmailHolder = email
                                    
                                    if prevUsere == "" && self.forceLoggedOutUser == "" {
                                        self.db.localTransactions = dat.0
                                        self.db.localCategories = dat.1
                                    }
                                    if self.forceLoggedOutUser == "" {
                                        self.forceLoggedOutUser = ""
                                        AppDelegate.properties?.appData.fromLoginVCMessage = "Wellcome".localize + ", \(AppDelegate.properties?.db.username ?? "-")"
                                    }
                                    
                                    
                                    if self.fromPro || self.forceLoggedOutUser != "" {
                                        DispatchQueue.main.async {
                                            self.endAnimating()
                                            self.dismiss(animated: true) {
                                                self.ai?.hide()
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                                            self.endAnimating()
                                            self.ai?.hide()
                                            self.performSegue(withIdentifier: "homeVC", sender: self)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.ai?.hide()
                        if let emailLimit = emailLimitOp {
                            if emailLimit == .totalError {
                                DispatchQueue.main.async {
                                    self.newMessage?.show(title: "You have reached the maximum amount of usernames".localize, type: .error)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    AppDelegate.properties?.appData.presentBuyProVC(selectedProduct: 3)
                                }
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
                    
                    DispatchQueue.main.async {
                        self.showWrongFields()
                        self.newMessage?.show(title: "All fields are required".localize, type: .error)
                        self.ai?.hide()
                    }
                    
                }
            } else {
                self.actionButtonsEnabled = true
                self.newMessage?.show(title: "Passwords not match".localize, type: .error)
                self.ai?.hide()
            }
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
                                self.ai?.hide()
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
                            let prevUserName = AppDelegate.properties?.db.username
                            
                            
                            if prevUserName != nickname {
                                let dat = (db.categories, db.transactions)
                                userChanged()
                                db.db.updateValue(prevUserName, forKey: "prevUserName")
                                
                                if prevUserName == "" && forceLoggedOutUser == "" {
                                    db.localCategories = dat.0
                                    db.localTransactions = dat.1
                                    
                                }
                                
                                if forceLoggedOutUser == "" {
                                    AppDelegate.properties?.appData.fromLoginVCMessage = "Wellcome".localize + ", \(AppDelegate.properties?.db.username ?? "")"
                                }
                                
                            }
                            AppDelegate.properties?.db.username = nickname
                            AppDelegate.properties?.db.password = password
                            AppDelegate.properties?.db.userEmailHolder = loadedData[i][DBEmailIndex]
                            
                            if !(AppDelegate.properties?.db.purchasedOnThisDevice ?? false) {
                                AppDelegate.properties?.db.proVersion = loadedData[i][4] == "1" ? true : (AppDelegate.properties?.db.proVersion ?? false)
                            }
                            if fromPro || self.forceLoggedOutUser != "" {
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true) {
                                        self.ai?.hide()
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.ai?.hide {
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
                        self.ai?.hide()
                    }
                    
                }
            }
            
        }
    }
}
