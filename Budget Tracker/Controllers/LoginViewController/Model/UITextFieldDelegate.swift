//
//  UITextFieldDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 26.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension LoginViewController: UITextFieldDelegate {
    
    
    func checkUsers(for email: String, password:String, completion: @escaping (Bool) -> ()) {
      //  DispatchQueue.main.async {
        //    self.ai.show { _ in
        
                self.enteredEmailUsers.removeAll()
                var resultUsers: [String] = []
                self.loadUsers { users in
                    
                    //check password for email
                    var passwordCurrect = false
                    var found = false
                    for n in 0..<users.count {
                        if email == users[n][1] {
                            found = true
                            if password == users[n][2] {
                                passwordCurrect = true
                                break
                            }
                            
                        }
                        
                    }
                    if passwordCurrect {
                        for i in 0..<users.count {
                            if users[i][1] == email {
                                resultUsers.append(users[i][0])
                            }
                        }
                        self.enteredEmailUsers = resultUsers
                        completion(found)
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toSelectUserVC", sender: self)
                        }
                    } else {
                        let notFound = "Email not found".localize + "!"
                        let text = !found ? notFound : "Wrong password".localize
                        DispatchQueue.main.async {
                            self.showAlert(title: text, error: true)
                        }
                    }

                    
                    
                }
         //   }
      //  }
        
    }
    
    
    func keyChainPassword(nick: String) {
        if let keychainPassword = KeychainService.loadPassword(service: "BudgetTrackerApp", account: nick) {
            self.textFieldValuesDict.updateValue(keychainPassword, forKey: "log.password")
            DispatchQueue.main.async {
                self.passwordLogLabel.isSecureTextEntry = false
                self.passwordLogLabel.text = keychainPassword
                self.nicknameLogLabel.endEditing(true)
            }
        } else {
            DispatchQueue.main.async {
                self.passwordLogLabel.becomeFirstResponder()
            }
        }
    }
    
    func validateEmail(_ email:String) -> Bool {
        return !email.contains("@") || !email.contains(".") ? false : true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //    DispatchQueue.main.async {
        let labelID = textField.accessibilityIdentifier ?? ""
        let emptyError = {
            DispatchQueue.main.async {
                self.newMessage.show(title:"All fields are required".localize, type: .error)
            }
        }
        if let text = textFieldValuesDict[labelID] {
            if text != "" {
                var goNext:(()->())?
                
                switch labelID {
                case "create.password.repeate":
                    if text == (textFieldValuesDict["create.password"] ?? "") {
                        self.createAccountPressed(self.createAccButton!)
                    } else {
                        DispatchQueue.main.async {
                            self.newMessage.show(title: "Passwords not match".localize, type: .error)
                        }
                    }
                    goNext = nil
                case "log.password":
                    DispatchQueue.main.async {
                        self.logInPressed(self.logInButton)
                    }
                    goNext = nil
                default:
                    goNext = {
                        DispatchQueue.main.async {
                            self.textfields[textField.tag + 1].becomeFirstResponder()
                        }
                    }
                    
                }
                
                if labelID.contains("email") {
                    if !self.validateEmail(text) {
                        goNext = nil
                        DispatchQueue.main.async {
                            self.newMessage.show(title: "Enter valid email".localize, type: .error)
                            return
                        }
                    }
                }
                if labelID.contains("log.user") {
                    self.enteredEmailUsers.removeAll()
                    self.keyChainPassword(nick: text)
                }
                if let next = goNext {
                    next()
                }
                
            } else {
                emptyError()
            }
        } else {
            emptyError()
        }

        return true
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        enteredEmailUsers.removeAll()
        return true
    }
}
