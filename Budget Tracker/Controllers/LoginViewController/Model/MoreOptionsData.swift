//
//  SettingsData.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import AlertViewLibrary


class MoreOptionsData {
    //[MoreVC.ScreenData]
    
    let vc:LoginViewController
    init(vc:LoginViewController) {
        self.vc = vc
        
    }
    deinit {
        print("deiniteeed")
    }
    lazy var ai = AppDelegate.shared!.ai
    func get() -> [MoreVC.ScreenData] {
        wrongCodeCount = 0
        forgotPasswordUsername = ""
     //   hideKeyboard()
        let appData = AppData()
        //get screen data

        let changeEmailAction = {
            self.changeEmailTapped()
        }
        let logoutAction = {
            self.vc.logout()
            print("lohoyt pressed")
        }
        let forgotPassword = {
            if appData.username != "" {
                self.forgotPasswordTapped()
            } else {
                
                    
                
                let nextAction: (String) -> () = { (newvalue2) in
                    self.ai.show { _ in
                   
                    self.loadUsers { users in
                        var found = false
                        for i in 0..<users.count {
                            if users[i][0] == newvalue2 {
                                found = true
                            }
                        }
                        
                        if !found {
                            self.showAlert(title: "User not found".localize, text: nil, error: true)
                        } else {
                           // appData.username = newValue
                           // appData.password = ""
                            self.forgotPasswordUsername = newvalue2
                            self.sendRestorationCode(toChange: .changePassword)
                        }
                        
                    }
                    }
                }
                
                let toEdit = EnterValueVC.EnterValueVCScreenData(taskName: "Forgot password".localize, title: "Enter your username".localize, placeHolder: "Username".localize, nextAction: nextAction, screenType: .password)
                self.toEnterValue(data: toEdit)
            }
            
        }
        let changePassword = {
            self.changePasswordTapped()
        }
        
        let transfareData = {
            self.transfereData()
        }
        
        
        let loggedUserData = [
           // MoreVC.ScreenData(name: "Username", description: "", action: nil),
           // MoreVC.ScreenData(name: "Web purchase", description: "", action: nil),
           // MoreVC.ScreenData(name: "Device purchase", description: "", action: nil),
            MoreVC.ScreenData(name: "Change Email".localize, description: vc.userEmail, action: changeEmailAction),
            MoreVC.ScreenData(name: "Change password".localize, description: "", action: changePassword),
            MoreVC.ScreenData(name: "Forgot password".localize, description: "", action: forgotPassword),
            MoreVC.ScreenData(name: "Transfer data".localize, description: "", pro: appData.proEnabeled, action: transfareData),
            MoreVC.ScreenData(name: "Log out".localize, description: "", distructive: true, showAI: false, action: logoutAction),
        ]
        
        let notUserLogged = [
            //MoreVC.ScreenData(name: "Device purchase", description: appData.purchasedOnThisDevice ? "Yes":"No", action: nil),
            MoreVC.ScreenData(name: "Transfer data".localize, description: "", pro: appData.proEnabeled, action: transfareData),
            MoreVC.ScreenData(name: "Forgot password".localize, description: "", action: forgotPassword),
        ]
        
        return appData.username == "" ? notUserLogged : loggedUserData
    }
    
    var forgotPasswordUsername = ""
    
    
    
    func forgotPasswordTapped() {
     //   DispatchQueue.main.async {
            self.ai.show { (_) in
             //   let load = LoadFromDB()
                LoadFromDB.shared.Users { (users, error) in
                    if error {
                        DispatchQueue.main.async {
                            self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                        }
                    } else {
                        if appData.username != "" {
                            var emailToSend = ""
                            for i in 0..<users.count {
                                if users[i][0] == appData.username {
                                    emailToSend = users[i][1]
                                    break
                                }
                            }

                            let firstButton:AlertViewLibrary.button  = .init(title: "Cancel".localize, style: .regular, close: true) { _ in
                            }
                            let secondButton:AlertViewLibrary.button = .init(title: "Send".localize, style: .link, close: false) { _ in
                                self.sendRestorationCode(toChange: .changePassword)
                            }
                            let text = "Restoration code would be sent on: ".localize + emailToSend
                            DispatchQueue.main.async {
                                self.ai.showAlert(buttons: (secondButton, firstButton), title: "Send code".localize, description: text, type: .standard)
                            }
                        } else {
                            self.sendRestorationCode(toChange: .changePassword)
                        }
                        
                    }
                }
                
            }
   //     }
    }
    
    
    
    func changeEmailTapped() {
        ai.show { (_) in
         //   let load = LoadFromDB()
            LoadFromDB.shared.Users { (users, error) in
                if error {
                    DispatchQueue.main.async {
                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                    }
                } else {
                    var emailToSend = ""
                    for i in 0..<users.count {
                        if users[i][0] == appData.username {
                            emailToSend = users[i][1]
                            break
                        }
                    }
                    let firstButton:AlertViewLibrary.button  = .init(title: "Cancel".localize, style: .regular, close: true) { _ in
                                        
                    }
                    let secondButton:AlertViewLibrary.button  = .init(title: "Send".localize, style: .link, close: false) { _ in
                        self.sendRestorationCode(toChange: .changeEmail)
                    }
                    let text = "Restoration code would be sent on: ".localize + emailToSend
                    DispatchQueue.main.async {
                        self.ai.showAlert(buttons: (secondButton, firstButton), title: "Send code".localize, description: text, type: .standard)
                    }

                }
            }
            
        }
        
    }

    
    
    
    func loadUsers(completion:@escaping ([[String]]) -> ()) {
      //  let load = LoadFromDB()
        LoadFromDB.shared.Users { (users, error) in
            if !error {
                completion(users)
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                }
            }
        }
    }
    
    func transfereData() {
        let chechUsername: (String) -> () = { (enteredUsss) in
            let enteredUser = enteredUsss
            var dbPassword = ""
            self.loadUsers { users in
                var found = false
                for i in 0..<users.count {
                    if users[i][0] == enteredUser {
                        dbPassword = users[i][2]
                        found = true
                    }
                }
                
                if found {
                    let checkPassword: (String) -> () = { (newPass) in
                        let enteredPassword = newPass
                        if enteredPassword == dbPassword {
                            
                            
                            
                            
                            LoadFromDB.shared.newTransactions(otherUser: enteredUser) { loadedTransactions, errorTransactions in
                                if errorTransactions == .none {
                                    //loadTransactionsCategories
                                    
                                    LoadFromDB.shared.newCategories(otherUser: enteredUser) { loaedCategories, categoriesError in
                                        if categoriesError == .none {
                                            
                                            let vcc = self.vc as! LoginViewController
                                            vcc.transferingData = LoginViewController.TransferingData(nickname: enteredUser, categories: loaedCategories, transactions: loadedTransactions)
                                            DispatchQueue.main.async {
                                                self.vc.performSegue(withIdentifier: "toTransfareData", sender: self)
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                                            }
                                        }
                                    }
                                    
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                                    }
                                }
                            }
                            
                            
                            
                            
                        } else {
                            DispatchQueue.main.async {
                                AppDelegate.shared!.newMessage.show(title: "Wrong password".localize, type: .error)
                            }
                        }
                    }
                    

                    let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Transfer data".localize, title: "Enter password".localize, placeHolder: "Password".localize, nextAction: checkPassword, screenType: .string)
                    self.toEnterValue(data: screenData)
                } else {
                    DispatchQueue.main.async {
                        AppDelegate.shared?.newMessage.show(title: "User not found".localize, description: "'\(enteredUser)'", type: .error)
                    }
                }
            }
        }

        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Transfer data".localize, title: "Enter username".localize, subTitle: nil, placeHolder: "Username".localize, nextAction: chechUsername, screenType: .string)
        toEnterValue(data: screenData)
    }
    
    
    
    
    
    
    
    
    
    func dbChangePassword(userData: (String, String)) {

        let repeateActionn: (String) -> () = { (fromPrev) in

            let repeatPasAction: (String) -> () = { (new) in
                if fromPrev != new {
                    self.showAlert(title: "Wrong password!".localize, text: nil, error: true)
                   // EnterValueVC.shared?.clearAll(animated: true)
                } else {

                    let newUser = self.forgotPasswordUsername == "" ? appData.username : self.forgotPasswordUsername
                    appData.username = newUser
                    self.cangePasswordDB(username: newUser, newPassword: new)
                }
            }
            let screenDataRep = EnterValueVC.EnterValueVCScreenData(taskName: "Change password".localize, title: "Repeat password".localize, placeHolder: "Password".localize, nextAction: repeatPasAction, screenType: .password)
            self.toEnterValue(data: screenDataRep)
        }
        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Change password".localize, title: "Create new password".localize, placeHolder: "Password".localize, nextAction: repeateActionn, screenType: .password)
        toEnterValue(data: screenData)
        
    }
    
    func loadUserData(username: String, completion: @escaping ([String]?) -> ()){
        
  //      let load = LoadFromDB()
        LoadFromDB.shared.Users { (loadedData, error) in
            if error {
                DispatchQueue.main.async {
                    self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                }
                completion(nil)
            } else {
                var userData: [String] = []
                for i in 0..<loadedData.count {
                    if loadedData[i][0] == username {
                        userData = loadedData[i]
                        break
                    }
                }
                completion(userData)
                
            }
        }

    }
    
    func performChanageEmail(userData: (String, String), newEmail: String) {
        if !(newEmail).contains("@") || !(newEmail).contains(".") {
            self.dbChangeEmail(userData: userData, error: true)
        } else {
            self.loadUserData(username: userData.0) { (loadedData) in
                if let dbData = loadedData {
                    //let save = SaveToDB()
                    let toDataStringMian = "&Nickname=\(dbData[0])" + "&Email=\(newEmail)" + "&Password=\(dbData[2])" + "&Registration_Date=\(dbData[3])" + "&ProVersion=\(dbData[4])" + "&trialDate=\(dbData[5])"
                    SaveToDB.shared.Users(toDataString: toDataStringMian ) { (error) in
                        if error {
                            DispatchQueue.main.async {
                                self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                            }
                        }
                        let delete = DeleteFromDB()
                        let dataStringDelete = "&Nickname=\(dbData[0])" + "&Email=\(dbData[1])" + "&Password=\(dbData[2])" + "&Registration_Date=\(dbData[3])" + "&ProVersion=\(dbData[4])" + "&trialDate=\(dbData[5])"
                        print(toDataStringMian)
                        delete.User(toDataString: dataStringDelete) { (errorr) in
                            if errorr {
                                DispatchQueue.main.async {
                                    self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Your email has been changed".localize, text: "", error: false, goToLogin: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func dbChangeEmail(userData: (String, String), error: Bool = false) {
        
        let emailAction: (String) -> () = { (newEmail) in
      
          
            if !(newEmail).contains("@") || !(newEmail).contains(".") {
                AppDelegate.shared?.newMessage.show(title: "Enter valid email".localize, type: .error)
            } else {
                self.ai.show(title: nil) { _ in
                    self.performChanageEmail(userData: userData, newEmail: newEmail)
                }
            }
            
        }
        
        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Change email".localize, title: "Enter your new email".localize, placeHolder: "Email".localize, nextAction: emailAction, screenType: .email)
        toEnterValue(data: screenData)
        

    }
    
    func checkRestoreCode(value: String, userData: (String, String), ifCorrect: restoreCodeAction) {
        print("value:", value)
        print("curcode:", self.currectAnsware)
        if value == self.currectAnsware {
            self.waitingType = .newPassword
            switch ifCorrect {
            case .changePassword:
                self.dbChangePassword(userData: userData)
            case .changeEmail:
                self.dbChangeEmail(userData: userData)
            }
            
        } else {
            showAlert(title: "Wrong code!".localize, text: "You have entered: ".localize + value, error: true)
            if wrongCodeCount < 4 {
                wrongCodeCount += 1
                
            } else {
                DispatchQueue.main.async {
                    self.vc.navigationController?.popToViewController(self.vc, animated: true)
                }
            }
            
        }
    }
    
    var wrongCodeCount = 0
    
    
    func sendRestorationCode(toChange: restoreCodeAction) {

        let userHolder = appData.username == "" ? forgotPasswordUsername : appData.username
        let username = foundUsername != nil ? foundUsername! : userHolder
        if username != "" {
            self.currectAnsware = ""


            self.ai.show(title: nil, appeareAnimation: true) { _ in
                DispatchQueue.init(label: "getEmail").async {
                    
                   // let load = LoadFromDB()
                    LoadFromDB.shared.Users { (loadedData, error) in
                        if error {

                            DispatchQueue.main.async {
                                self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                            }
                        } else {
                            var emailToSend = ""
                            for i in 0..<loadedData.count {
                                if loadedData[i][0] == username {
                                    emailToSend = loadedData[i][1]
                                    break
                                }
                            }
                            
                            let code = "\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))"
                            print("RESTORATION CODE:", code)
                            //let save = SaveToDB()
                            SaveToDB.shared.sendCode(toDataString: "emailTo=\(emailToSend)&Nickname=\(username)&resetCode=\(code)") { (codeError) in
                                if codeError {
                                    DispatchQueue.main.async {
                                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                                    }
                                } else {
                                    self.currectAnsware = code
                                    self.waitingType = .code
    
                                    var taskNameTitle:String {
                                        switch toChange {
                                        case .changePassword:
                                            return "Change password".localize
                                        case .changeEmail:
                                            return "Change Email".localize
                                        }
                                    }
                                    
                                    let userData = (("Email".localize,emailToSend),("Username".localize,username))
                                    
                                    let nextAction: (String) -> () = { (newVal) in
                                        if newVal.count == 4 {
                                            self.ai.show(title: nil) { _ in
                                                
                                                self.checkRestoreCode(value: newVal, userData: (username, emailToSend), ifCorrect: toChange)
                                            }
                                        } else {
                                            self.showAlert(title: "Wrong code!".localize, text: "We have sent 4-digit resoration code on your email".localize, error: true)
                                            if self.wrongCodeCount < 4 {
                                                self.wrongCodeCount += 1
                                                
                                            } else {
                                                DispatchQueue.main.async {
                                                    self.vc.navigationController?.popToViewController(self.vc, animated: true)
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    let screenData = EnterValueVC.EnterValueVCScreenData(taskName: taskNameTitle, title: "Restoration code".localize, subTitle: "We have sent 4-digit resoration code on your email".localize, placeHolder: "Code".localize, nextAction: nextAction, screenType: .code, descriptionTable: userData)
                                    self.toEnterValue(data: screenData)
                                    
                                }
                            }
                        }
                    }
                }
            }
    
            
            
            
        } else {

            let nextAction: (String) -> () = { (newvalue) in
                if appData.username != "" {
                    self.ai.show(title: nil) { _ in
                    //    let load = LoadFromDB()
                        LoadFromDB.shared.Users { (users, error) in
                            
                            for i in 0..<users.count {
                                if newvalue == users[i][0] {
                                    self.sendRestorationCode(toChange: toChange)
                                }
                            }
                        }
                    }
                } else {
                    
                }
                
            }
            
            let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Forgot password".localize, title: "Enter your username".localize, subTitle: "You will receive restoration code".localize, placeHolder: "Username".localize, nextAction: nextAction, screenType: .password)
            toEnterValue(data: screenData)

        }
    }
    
    
    func toEnterValue(data:EnterValueVC.EnterValueVCScreenData?) {
        if let data = data {
            DispatchQueue.main.async {
                if let nav = self.vc.navigationController {
                    EnterValueVC.shared.presentScreen(in: nav, with: data, defaultValue:nil)
                    
                }
            }
        } else {
            
            DispatchQueue.main.async {
                self.vc.navigationController?.popToViewController(self.vc, animated: true)
                
            }
        }
    }
    var currectAnsware = ""
    var foundUsername: String?
    
    
    
    
    func cangePasswordDB(username: String, newPassword: String) {
        DispatchQueue.init(label: "DB").async {
           // let load = LoadFromDB()
            LoadFromDB.shared.Users { (loadedData, error) in
                if error {
                    DispatchQueue.main.async {
                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                    }
                } else {
                    var userData: [String] = []
                    for i in 0..<loadedData.count {
                        if loadedData[i][0] == username {
                            userData = loadedData[i]
                            break
                        }
                    }
                    //let save = SaveToDB()
                    let toDataStringMian = "&Nickname=\(userData[0])" + "&Email=\(userData[1])" + "&Password=\(newPassword)" + "&Registration_Date=\(userData[3])" + "&ProVersion=\(userData[4])" + "&trialDate=\(userData[5])"
                    SaveToDB.shared.Users(toDataString: toDataStringMian ) { (error) in
                        if error {
                            DispatchQueue.main.async {
                                self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                            }
                        }
                        let delete = DeleteFromDB()
                        let dataStringDelete = "&Nickname=\(userData[0])" + "&Email=\(userData[1])" + "&Password=\(userData[2])" + "&Registration_Date=\(userData[3])" + "&ProVersion=\(userData[4])" + "&trialDate=\(userData[5])"
                        print(dataStringDelete)
                        delete.User(toDataString: dataStringDelete) { (errorr) in
                            if errorr {
                                DispatchQueue.main.async {
                                    self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                                }
                            } else {
                                appData.username = userData[0]
                                appData.password = newPassword
                                KeychainService.updatePassword(service: "BudgetTrackerApp", account: userData[0], data: newPassword)
                                //EnterValueVC.shared?.closeVC(closeMessage: "Your password has been changed")
                                self.toEnterValue(data: nil)
                                self.showAlert(title:"Your password has been changed".localize, error: false)
                            }
                            
                        }
                    }
                    
                }
            }
        }
    }
    
    func checkChangeOldPassword(_ password: String, dbPassword: String, email: String){
        
        if password != dbPassword {
            showAlert(title: "Wrong password!".localize, error: true)
        } else {
            let repeateActionn: (String) -> () = { (fromPrev) in
            
                let repeatPasAction: (String) -> () = { (new) in
                    if fromPrev != new {
                        self.showAlert(title: "Passwords not match".localize + "!", text: nil, error: true)
                  //      EnterValueVC.shared?.clearAll(animated: true)
                    } else {
                        self.cangePasswordDB(username: appData.username, newPassword: new)
                    }
                }
                let screenDataRep = EnterValueVC.EnterValueVCScreenData(taskName: "Change password".localize, title: "Repeat password".localize, placeHolder: "Password".localize, nextAction: repeatPasAction, screenType: .password)
                self.toEnterValue(data: screenDataRep)
            }
            let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Change password".localize, title: "Create your new password".localize, placeHolder: "Password".localize, nextAction: repeateActionn, screenType: .password)
            toEnterValue(data: screenData)
        }
        

    }
    
    func changePasswordTapped() {
        print("changeEmailTapped")

        let username = appData.username
        if username != "" {
            self.ai.show { (_) in
            //    let load = LoadFromDB()
                LoadFromDB.shared.Users { (allUsers, error) in
                    if !error {
                        var userData: [String] = []
                        for i in 0..<allUsers.count {
                            if allUsers[i][0] == username {
                                userData = allUsers[i]
                                break
                            }
                        }

                        //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {

                        
                        let nextAction: (String) -> () = { (new) in
                            self.checkChangeOldPassword(new, dbPassword: userData[2], email: userData[1])
                        }
                        
                        let userrData:((String, String)?, (String, String)?)? = (("Email".localize, userData[1]),("Nickname".localize,userData[0]))
                        
                        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Change password".localize, title: "Enter your old password".localize, subTitle: nil, placeHolder: "Old password".localize, nextAction: nextAction, screenType: .string, descriptionTable: userrData)
                        self.toEnterValue(data: screenData)
                       // }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                        }
                    }
                }
            }
            
        }
    }
    
    
    var waitingType:waitingFor?
}




extension MoreOptionsData {
    func showAlert(title:String? = nil,text:String? = nil, error: Bool, goToLogin: Bool = false) {
        
        let resultTitle = title == nil ? (error ? Text.Error.error : Text.success) : title!
        DispatchQueue.main.async {
            self.ai.showAlertWithOK(title: resultTitle, text: text, error: error) { _ in
                if goToLogin {
                    DispatchQueue.main.async {
                        self.vc.navigationController?.popToViewController(self.vc, animated: true)
                    }
                }
            }
        }

    }
    
    
    
    enum waitingFor {
        case newPassword
        case nickname
        case code
    }
    enum restoreCodeAction {
        case changePassword
        case changeEmail
    }
}
