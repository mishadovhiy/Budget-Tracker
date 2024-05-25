//
//  UITextFieldDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 26.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension LoginViewController: UITextFieldDelegate {

    func keyChainPassword(nick: String) {
        if let keychainPassword = KeychainService.loadPassword(account: nick) {
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
                self.newMessage?.show(title:"All fields are required".localize, type: .error)
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
                            self.newMessage?.show(title: "Passwords not match".localize, type: .error)
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
                            self.newMessage?.show(title: "Enter valid email".localize, type: .error)
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
