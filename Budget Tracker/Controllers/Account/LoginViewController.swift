//
//  LoginViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
var needFullReload = false

extension LoginViewController {
    func userChanged() {
        actionButtonsEnabled = true
        needFullReload = true
        lastSelectedDate = nil
        AppDelegate.shared?.center.removeAllPendingNotificationRequests()
        AppDelegate.shared?.center.removeAllDeliveredNotifications()
        appData.deliveredNotificationIDs = []
        UserDefaults.standard.setValue(nil, forKey: "lastSelected")
        UserDefaults.standard.setValue(true, forKey: "checkTrialDate")
        UserDefaults.standard.setValue(false, forKey: "trialPressed")
        UserDefaults.standard.setValue(nil, forKey: "trialToExpireDays")
        appData.proTrial = false
        _categoriesHolder.removeAll()
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {//morepressed
        wrongCodeCount = 0
        forgotPasswordUsername = ""
        hideKeyboard()
        let appData = AppData()
        //get screen data

        let changeEmailAction = {
            self.changeEmailTapped()
        }
        let logoutAction = {
            self.logout()
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
                            self.showAlert(title: "User not found", text: nil, error: true)
                        } else {
                           // appData.username = newValue
                           // appData.password = ""
                            self.forgotPasswordUsername = newvalue2
                            self.sendRestorationCode(toChange: .changePassword)
                        }
                        
                    }
                    }
                }
                
                let toEdit = EnterValueVC.EnterValueVCScreenData(taskName: "Forgot password", title: "Enter your username", placeHolder: "Username", nextAction: nextAction, screenType: .password)
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
            MoreVC.ScreenData(name: "Change Email", description: userEmail, action: changeEmailAction),
            MoreVC.ScreenData(name: "Change password", description: "", action: changePassword),
            MoreVC.ScreenData(name: "Forgot password", description: "", action: forgotPassword),
            MoreVC.ScreenData(name: "Transfare data", description: "", pro: appData.proVersion || appData.proTrial, action: transfareData),
            MoreVC.ScreenData(name: "Log out", description: "", distructive: true, showAI: false, action: logoutAction),
        ]
        
        let notUserLogged = [
            //MoreVC.ScreenData(name: "Device purchase", description: appData.purchasedOnThisDevice ? "Yes":"No", action: nil),
            MoreVC.ScreenData(name: "Transfare data", description: "", action: transfareData),
            MoreVC.ScreenData(name: "Forgot password", description: "", action: forgotPassword),
        ]
        
        appData.presentMoreVC(currentVC: self, data: appData.username == "" ? notUserLogged : loggedUserData, proIndex: 1)

    }
    
    
    func forgotPasswordTapped() {
     //   DispatchQueue.main.async {
            self.ai.show { (_) in
             //   let load = LoadFromDB()
                LoadFromDB.shared.Users { (users, error) in
                    if error {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
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

                            let firstButton = IndicatorView.button(title: "Cancel", style: .standart, close: true) { _ in
                            }
                            let secondButton = IndicatorView.button(title: "Send", style: .success, close: false) { _ in
                                self.sendRestorationCode(toChange: .changePassword)
                            }
                            let text = "Restoration code would be sent on: \(emailToSend)"
                            DispatchQueue.main.async {
                                self.ai.completeWithActions(buttons: (secondButton, firstButton), title: "Send code", descriptionText: text, type: .standard)
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
                        self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                    }
                } else {
                    var emailToSend = ""
                    for i in 0..<users.count {
                        if users[i][0] == appData.username {
                            emailToSend = users[i][1]
                            break
                        }
                    }
                    let firstButton = IndicatorView.button(title: "Cancel", style: .standart, close: true) { _ in
                                        
                    }
                    let secondButton = IndicatorView.button(title: "Send", style: .success, close: false) { _ in
                        self.sendRestorationCode(toChange: .changeEmail)
                    }
                    let text = "Restoration code would be sent on: \(emailToSend)"
                    DispatchQueue.main.async {
                        self.ai.completeWithActions(buttons: (secondButton, firstButton), title: "Send code", descriptionText: text, type: .standard)
                    }

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
                                            
                                            self.transferingData = TransferingData(nickname: enteredUser, categories: loaedCategories, transactions: loadedTransactions)
                                            DispatchQueue.main.async {
                                                self.performSegue(withIdentifier: "toTransfareData", sender: self)
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                                            }
                                        }
                                    }
                                    
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                                    }
                                }
                            }
                            
                            
                            
                            
                        } else {
                            DispatchQueue.main.async {
                                self.newMessage.show(title: "Wrong password", type: .error)
                            }
                        }
                    }
                    

                    let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Transfer data", title: "Enter password", placeHolder: "Password", nextAction: checkPassword, screenType: .password)
                    self.toEnterValue(data: screenData)
                } else {
                    DispatchQueue.main.async {
                        self.newMessage.show(title: "User not found", description: "'\(enteredUser)'", type: .error)
                    }
                }
            }
        }

        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Transfer data", title: "Enter username or email", subTitle: nil, placeHolder: "Username or email", nextAction: chechUsername, screenType: .email)
        toEnterValue(data: screenData)
    }
}



class LoginViewController: SuperViewController {

    ///!!!! bug when saved app data username != "" (when password changed)
    
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var logIn: UIStackView!
    @IBOutlet weak var createAcount: UIStackView!
    
    @IBOutlet weak var createOrLogLabel: UILabel!
    @IBOutlet weak var createOrLogButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var createAccButton: UIButton!
    
    @IBOutlet weak var nicknameLabelCreate: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UITextField!
    
    @IBOutlet weak var nicknameLogLabel: UITextField!
    @IBOutlet weak var passwordLogLabel: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var titleLabels: [UILabel]!
    
    var canUseThisName: Bool = true
    enum screenTypee {
        case createAccount
        case singIn
    }
    var selectedScreen: screenTypee = .createAccount
    var fromPro = false
    

    var messagesFromOtherScreen = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()

        DispatchQueue.main.async {
            self.title = appData.username == "" ? "Sing In" : appData.username
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let nik = appData.username
        if nik != "" {
            loadUsers { users in
                for i in 0..<users.count {
                    if users[i][0] == nik {
                        self.userEmail = users[i][1]
                        return
                    }
                }
            }
        }
    }
    var forgotPasswordUsername = ""
    var userEmail = ""
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    func loadUsers(completion:@escaping ([[String]]) -> ()) {
      //  let load = LoadFromDB()
        LoadFromDB.shared.Users { (users, error) in
            if !error {
                completion(users)
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                }
            }
        }
    }
    
    
    enum restoreCodeAction {
        case changePassword
        case changeEmail
    }
    
    var waitingType:waitingFor?
    enum waitingFor {
        case newPassword
        case nickname
        case code
    }
    
    var currectAnsware = ""
    var foundUsername: String?
    
    func dbChangePassword(userData: (String, String)) {

        let repeateActionn: (String) -> () = { (fromPrev) in

            let repeatPasAction: (String) -> () = { (new) in
                if fromPrev != new {
                    self.showAlert(title: "Wrong password!", text: nil, error: true)
                   // EnterValueVC.shared?.clearAll(animated: true)
                } else {

                    let newUser = self.forgotPasswordUsername == "" ? appData.username : self.forgotPasswordUsername
                    appData.username = newUser
                    self.cangePasswordDB(username: newUser, newPassword: new)
                }
            }
            let screenDataRep = EnterValueVC.EnterValueVCScreenData(taskName: "Change password", title: "Repeat password", placeHolder: "Password", nextAction: repeatPasAction, screenType: .password)
            self.toEnterValue(data: screenDataRep)
        }
        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Change password", title: "Create new password", placeHolder: "Password", nextAction: repeateActionn, screenType: .password)
        toEnterValue(data: screenData)
        
    }
    
    func loadUserData(username: String, completion: @escaping ([String]?) -> ()){
        
  //      let load = LoadFromDB()
        LoadFromDB.shared.Users { (loadedData, error) in
            if error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
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
                                self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                            }
                        }
                        let delete = DeleteFromDB()
                        let dataStringDelete = "&Nickname=\(dbData[0])" + "&Email=\(dbData[1])" + "&Password=\(dbData[2])" + "&Registration_Date=\(dbData[3])" + "&ProVersion=\(dbData[4])" + "&trialDate=\(dbData[5])"
                        print(toDataStringMian)
                        delete.User(toDataString: dataStringDelete) { (errorr) in
                            if errorr {
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Your email has been changed", text: "", error: false, goToLogin: true)
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
                self.newMessage.show(title: "Enter valid email", type: .error)
            } else {
                self.ai.show(title: nil) { _ in
                    self.performChanageEmail(userData: userData, newEmail: newEmail)
                }
            }
            
        }
        
        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Change email", title: "Enter your new email", placeHolder: "Email", nextAction: emailAction, screenType: .email)
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
            showAlert(title: "Wrong code!", text: "You have entered: \(value)", error: true)
            if wrongCodeCount < 4 {
                wrongCodeCount += 1
                
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
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
                                self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
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
                                        self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                                    }
                                } else {
                                    self.currectAnsware = code
                                    self.waitingType = .code
    
                                    var taskNameTitle:String {
                                        switch toChange {
                                        case .changePassword:
                                            return "Change password"
                                        case .changeEmail:
                                            return "Change Email"
                                        }
                                    }
                                    
                                    let userData = (("Email",emailToSend),("Username",username))
                                    
                                    let nextAction: (String) -> () = { (newVal) in
                                        if newVal.count == 4 {
                                            self.ai.show(title: nil) { _ in
                                                
                                                self.checkRestoreCode(value: newVal, userData: (username, emailToSend), ifCorrect: toChange)
                                            }
                                        } else {
                                            self.showAlert(title: "Wrong code!", text: "Enter 4 digits\n we have sent you", error: true)
                                            if self.wrongCodeCount < 4 {
                                                self.wrongCodeCount += 1
                                                
                                            } else {
                                                DispatchQueue.main.async {
                                                    self.navigationController?.popViewController(animated: true)
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    let screenData = EnterValueVC.EnterValueVCScreenData(taskName: taskNameTitle, title: "Restoration code", subTitle: "We have sent 4-digit resoration code on your email", placeHolder: "Code", nextAction: nextAction, screenType: .code, descriptionTable: userData)
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
            
            let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Forgot password", title: "Enter your username", subTitle: "You will receive restoration code", placeHolder: "Username", nextAction: nextAction, screenType: .password)
            toEnterValue(data: screenData)

        }
    }
    
    
    func toEnterValue(data:EnterValueVC.EnterValueVCScreenData?) {
        if let data = data {
            DispatchQueue.main.async {
                if let nav = self.navigationController {
                    EnterValueVC.shared.presentScreen(in: nav, with: data, defaultValue:nil)
                    
                }
            }
        } else {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(self, animated: true)
            }
        }
    }
    
    
    
    func cangePasswordDB(username: String, newPassword: String) {
        DispatchQueue.init(label: "DB").async {
           // let load = LoadFromDB()
            LoadFromDB.shared.Users { (loadedData, error) in
                if error {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
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
                                self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                            }
                        }
                        let delete = DeleteFromDB()
                        let dataStringDelete = "&Nickname=\(userData[0])" + "&Email=\(userData[1])" + "&Password=\(userData[2])" + "&Registration_Date=\(userData[3])" + "&ProVersion=\(userData[4])" + "&trialDate=\(userData[5])"
                        print(dataStringDelete)
                        delete.User(toDataString: dataStringDelete) { (errorr) in
                            if errorr {
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                                }
                            } else {
                                appData.username = userData[0]
                                appData.password = newPassword
                                KeychainService.updatePassword(service: "BudgetTrackerApp", account: userData[0], data: newPassword)
                                //EnterValueVC.shared?.closeVC(closeMessage: "Your password has been changed")
                                self.toEnterValue(data: nil)
                                self.showAlert(title:"Your password has been changed", error: false)
                            }
                            
                        }
                    }
                    
                }
            }
        }
    }
    
    func checkChangeOldPassword(_ password: String, dbPassword: String, email: String){
        
        if password != dbPassword {
            showAlert(title: "Wrong password!", error: true)
        } else {
            let repeateActionn: (String) -> () = { (fromPrev) in
            
                let repeatPasAction: (String) -> () = { (new) in
                    if fromPrev != new {
                        self.showAlert(title: "Passwords not much!", text: nil, error: true)
                  //      EnterValueVC.shared?.clearAll(animated: true)
                    } else {
                        self.cangePasswordDB(username: appData.username, newPassword: new)
                    }
                }
                let screenDataRep = EnterValueVC.EnterValueVCScreenData(taskName: "Change password", title: "Repeat password", placeHolder: "Password", nextAction: repeatPasAction, screenType: .password)
                self.toEnterValue(data: screenDataRep)
            }
            let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Change password", title: "Create your new password", placeHolder: "Password", nextAction: repeateActionn, screenType: .password)
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
                        
                        let userrData:((String, String)?, (String, String)?)? = (("Email:", userData[1]),("Nickname:",userData[0]))
                        
                        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Change password", title: "Enter your old password", subTitle: nil, placeHolder: "Old password", nextAction: nextAction, screenType: .password, descriptionTable: userrData)
                        self.toEnterValue(data: screenData)
                       // }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                        }
                    }
                }
            }
            
        }
    }
    
    
    
    
    
    @IBOutlet weak var moreButton: UIButton!
    var aai:UIActivityIndicatorView?
    
    
    
    var transferingData:TransferingData?
    
    struct TransferingData {
        let nickname: String
        let categories: [NewCategories]
        let transactions: [TransactionsStruct]
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "toSelectUserVC":
            let vc = segue.destination as! SelectUserVC
            vc.delegate = self
            vc.users = enteredEmailUsers
            DispatchQueue.main.async {
                self.nicknameLogLabel.endEditing(true)
            }
        case "toTransfareData":
            let vc = segue.destination as! CategoriesVC
            vc.screenType = .localData
            vc.transfaringCategories = transferingData
        default:
            break
        }
    }
    

    func showAlert(title:String? = nil,text:String? = nil, error: Bool, goToLogin: Bool = false) {
        
        let resultTitle = title == nil ? (error ? "Error" : "Succsess!") : title!
        
        let okButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in
            if goToLogin {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        DispatchQueue.main.async {
            
       //     EnterValueVC.shared?.valueTextField.endEditing(true)
            self.ai.completeWithActions(buttons: (okButton, nil), title: resultTitle, descriptionText: text, type: error ? .error : .standard)
        }

    }
    
    
    func updateUI() {
        toggleScreen(options: .createAccount, animation: 0.0)
        DispatchQueue.main.async {
            
        }
        
        
        let hideKeyboardGestureSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboardSwipped))
        hideKeyboardGestureSwipe.direction = .down
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //let usernameHolder = UserDefaults.standard.value(forKey: "UsernameHolder") as? String
        DispatchQueue.main.async {
            self.nicknameLogLabel.text = self.forceLoggedOutUser != "" ? self.forceLoggedOutUser :  appData.username
            self.passwordLogLabel.text = appData.username == "" ? "" : appData.password
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(hideKeyboardGestureSwipe)
        }
        self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height * (-2), 0)
        self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height * (-2), 0)
        
        
        
    }


    var sbvsLoaded = false
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !sbvsLoaded {
            sbvsLoaded = true
            DispatchQueue.main.async {
                if #available(iOS 13.0, *) {
                    
                } else {
                    self.moreButton.setTitle("more", for: .normal)
                }
                
                let tfs = Array(self.textfields)
                for i in 0..<tfs.count {
                    tfs[i].delegate = self
                    tfs[i].addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
                    tfs[i].layer.masksToBounds = true
                    tfs[i].layer.cornerRadius = 6
                    
                    tfs[i].setPaddings(5)
                    tfs[i].placeholder = self.placeHolder[i]
                    tfs[i].setPlaceHolderColor(K.Colors.textFieldPlaceholder)
                    tfs[i].tag = i
                    self.textFieldToID.updateValue("\(i)", forKey: tfs[i].accessibilityIdentifier ?? "")
                }
            }
            
        }
        
    }
    
    var textFieldToID:[String:String] = [:]
    
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.helperNavView?.removeFromSuperview()
        }
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    var actionButtonsEnabled : Bool {
        set {
            DispatchQueue.main.async {
                self.logInButton.isEnabled = newValue
                self.logInButton.isUserInteractionEnabled = newValue
                self.createAccButton.isEnabled = newValue
                self.createAccButton.isUserInteractionEnabled = newValue
            }
        }
        get {
            return false
        }
    }
    
   // let load = LoadFromDB()
    @IBAction func logInPressed(_ sender: UIButton) {
        print("LOGINPRESSED")
        transactionAdded = true
        actionButtonsEnabled = false
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }

        self.ai.show(title: "Logging in") { (_) in
            self.hideKeyboard()
            LoadFromDB.shared.Users { (loadedData, Error) in
                if !Error {
                    DispatchQueue.main.async {
                        let name = self.nicknameLogLabel.text ?? ""
                        let password = self.passwordLogLabel.text ?? ""
                        if name != "" && password != "" {
                            if !name.contains("@") {
                                self.logIn(nickname: name, password: password, loadedData: loadedData)
                            } else {
                                self.checkUsers(for: name, password: password) { _ in
                                    self.actionButtonsEnabled = true
                                }
                            }
                            
                        } else {
                            self.actionButtonsEnabled = true
                            DispatchQueue.main.async {
                                self.newMessage.show(title: "All fields are required", type: .error)
                                self.ai.hideIndicator(fast: true) { (_) in
                                    
                                }
                                
                            }
                            self.obthervValues = true
                            self.showWrongFields()
                        }
                    }
                } else {
                    print("error!!!")
                    self.actionButtonsEnabled = true
                    DispatchQueue.main.async {
                        self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                    }
                }
            }
        }
        
        
        
    }
    

    
    
    func logIn(nickname: String, password: String, loadedData: [[String]]) {
        let DBusernameIndex = 0
        let DBpasswordIndex = 2
        var psswordFromDB = ""
 
        if userExists(name: nickname, loadedData: loadedData) {
            for i in 0..<loadedData.count {
                if loadedData[i][DBusernameIndex] == nickname {
                    print(loadedData[i], "loadedData[i]loadedData[i]loadedData[i]")
                    psswordFromDB = loadedData[i][DBpasswordIndex]
                    print(psswordFromDB, "psswordFromDBpsswordFromDBpsswordFromDBpsswordFromDB")
                    if password != psswordFromDB {
                        self.actionButtonsEnabled = true
                        DispatchQueue.main.async {
                            self.newMessage.show(title: "Wrong password!", type: .error)
                            self.ai.fastHide { _ in
                                
                            }
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
                        if prevUserName != nickname {
                            userChanged()
                            UserDefaults.standard.setValue(prevUserName, forKey: "prevUserName")

                            if prevUserName == "" && forceLoggedOutUser == "" {
                                let db = DataBase()
                                db.localCategories = db.categories
                                db.localTransactions = db.transactions
                                
                            }
                            
                            if forceLoggedOutUser == "" {
                                appData.fromLoginVCMessage = "Wellcome, \(appData.username)"
                            }
                            
                        }
                        
                        
                        if !appData.purchasedOnThisDevice {
                            appData.proVersion = loadedData[i][4] == "1" ? true : appData.proVersion
                        }
                        if fromPro || self.forceLoggedOutUser != "" {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true) {
                                    self.ai.fastHide { _ in
                                    }
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
                    self.newMessage.show(title: "User not found", type: .error)
                    self.ai.hideIndicator(fast: true) { (_) in
                        
                    }
                }

            }
        }
    }

    
    
    
    
    
    
    @IBAction func createAccountPressed(_ sender: Any) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }


        self.ai.show(title: "Creating an account") { (_) in
            self.hideKeyboard()
            LoadFromDB.shared.Users { (loadedData, Error) in
                if !Error {
                    self.createAccoun(loadedData: loadedData)
                } else {
                    self.actionButtonsEnabled = true
                    DispatchQueue.main.async {
                        self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                    }
                }
            }
        }
        
    }
    
    func createAccoun(loadedData: [[String]]) {
        hideKeyboard()
        DispatchQueue.main.async {
            let name = self.nicknameLabelCreate.text ?? ""
            let email = self.emailLabel.text ?? ""
            let password = self.passwordLabel.text ?? ""
            let regDate = appData.filter.getToday(appData.filter.filterObjects.currentDate)
            if password == self.confirmPasswordLabel.text ?? "" {
                if name != "" && !name.contains("@") && email != "" && password != "" {
                    let emailLimitOp = self.canAddForEmail(email, loadedData: loadedData)
                    if !self.userExists(name: name, loadedData: loadedData) && emailLimitOp == nil {
                        self.actionButtonsEnabled = true
                        if !email.contains("@") || !email.contains(".") {
                            self.obthervValues = true
                            self.showWrongFields()
                            
                            
                            let firstButton = IndicatorView.button(title: "Try again", style: .standart, close: true) { _ in
                                self.emailLabel.becomeFirstResponder()
                            }
                            DispatchQueue.main.async {
                                self.ai.completeWithActions(buttons: (firstButton, nil), title: "Enter valid email address", descriptionText: "With correct email address you could restore your password in the future", type: .error)
                            }

                        } else {
                           // let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate)"
                            SaveToDB.shared.Users(toDataString: toDataString) { (error) in
                                if error {
                                    DispatchQueue.main.async {
                                        self.showAlert(title: "Internet error", text: "Try again later", error: true, goToLogin: true)
                                    }
                                } else {
                                    let prevUsere = appData.username
                                    UserDefaults.standard.setValue(prevUsere, forKey: "prevUserName")
                                    KeychainService.savePassword(service: "BudgetTrackerApp", account: name, data: password)
                                    appData.username = name
                                    appData.password = password

                                    if prevUsere == "" && self.forceLoggedOutUser == "" {
                                        let db = DataBase()
                                        db.localTransactions = db.transactions
                                        db.localCategories = db.categories
                                    }
                                    if self.forceLoggedOutUser == "" {
                                        appData.fromLoginVCMessage = "Wellcome, \(appData.username)"
                                    }
                                    
                                    self.userChanged()
                                    if self.fromPro || self.forceLoggedOutUser != "" {
                                        DispatchQueue.main.async {
                                            

                                                self.dismiss(animated: true) {
                                                    self.ai.fastHide { _ in
                                                    }
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
                            }
                        }
                    } else {
                        self.ai.hideIndicator(fast: true) { (_) in
                        }
                        if let emailLimit = emailLimitOp {
                            if emailLimit == .totalError {
                                self.newMessage.show(title: "You have reached the maximum amount of usernames", type: .error)
                            } else {
                                appData.presentBuyProVC(currentVC: self, selectedProduct: 2)
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                    self.newMessage.show(title: "You have reached the maximum amount of usernames", description: "Update to Pro to create new username", type: .standart)
                                }
                            }
                            
                        } else {
                            self.actionButtonsEnabled = true
                            DispatchQueue.main.async {
                                self.newMessage.show(title: "Username '\(name)' already exists", type: .error)
                            }
                        }
                        
                    }
                
                } else {
                    self.actionButtonsEnabled = true
                    self.obthervValues = true
                    self.showWrongFields()

                  //  DispatchQueue.main.async {
                        self.newMessage.show(title: "All fields are required", type: .error)
                        self.ai.hideIndicator(fast: true) { (_) in
                            
                        }
                 //   }
                  
                }
            } else {
                self.actionButtonsEnabled = true
         //       DispatchQueue.main.async {
                    self.newMessage.show(title: "Passwords not match", type: .error)
                    self.ai.hideIndicator(fast: true) { (_) in
                        
                    }
              //  }
            }
        }
    }

      
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        hideKeyboard()
    }
    
    
// other
    
    var timers: [Timer] = []
    
    func invalidateTimers() {
        for i in 0..<timers.count {
            timers[i].invalidate()
        }
    }
    
    var fromSettings = false
    var usernameHolder = ""
    override func viewWillDisappear(_ animated: Bool) {
        let usernameHolder = UserDefaults.standard.value(forKey: "UsernameHolder") as? String
        if usernameHolder != nil {
            UserDefaults.standard.setValue(nil, forKey: "UsernameHolder")
        }
        invalidateTimers()
        if fromSettings {
            DispatchQueue.main.async {
                let window = UIApplication.shared.keyWindow ?? UIWindow()
                self.helperNavView?.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: appData.safeArea.0)
                window.addSubview(self.helperNavView ?? UIView())
            }
        }
    }
    var helperNavView: UIView?
    func userExists(name: String, loadedData: [[String]]) -> Bool {
        var userExists = false
        //load users
        for i in 0..<loadedData.count {
            if loadedData[i][0] == name {
                userExists = true
                return userExists
            }
        }
        return userExists
    }
    func canAddForEmail(_ email: String, loadedData: [[String]]) -> EmailLimit? {
        var count = 0
        let maxCount = appData.proVersion ? 15 : 3
        for i in 0..<loadedData.count {
            if loadedData[i][1] == email {
                count += 1
            }
        }
        
        return maxCount > count ? nil : (!appData.proVersion ? .canUpdate : .totalError)
    }
    enum EmailLimit {
    case totalError
        case canUpdate
    }
    
    var forceLoggedOutUser = ""
    var obthervValues = false
    func showWrongFields() {
    //test if working
        for i in 0..<self.textfields.count {
            DispatchQueue.main.async {
                if self.textfields[i] == self.emailLabel {
                    if self.emailLabel.text != "" {
                        UIView.animate(withDuration: 0.3) {
                            self.textfields[i].backgroundColor = !(self.emailLabel.text ?? "").contains("@") ? K.Colors.negative : K.Colors.secondaryBackground
                        }
                    }
                }
                UIView.animate(withDuration: 0.3) {
                    self.textfields[i].backgroundColor = self.textfields[i].text == "" ? K.Colors.negative : K.Colors.secondaryBackground
                }
            }
        }
        
    }
    
    
    @objc func hideKeyboardSwipped(_ sender: UISwipeGestureRecognizer? = nil) {
        hideKeyboard()
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func hideKeyboard() {
        for i in 0..<textfields.count {
            DispatchQueue.main.async {
                self.textfields[i].endEditing(true)
            }
        }
    }
    
    func toggleScreen(options: screenTypee, animation: TimeInterval = 0.6) {
        
        let bounds = UIScreen.main.bounds
        let height = bounds.height
        let secondAnimation = animation == 0 ? 0 : animation - 0.4
        let thirdAnimation = animation == 0 ? 0 : animation + 0.5
        selectedScreen = options

        switch options {
        case .createAccount:
            DispatchQueue.main.async {
                UIView.animate(withDuration: animation) {
                    self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, height * (-2), 0)
                    self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                }
                UIView.animate(withDuration: secondAnimation) {
                    self.createAcount.alpha = 0
                }
                UIView.animate(withDuration: thirdAnimation) {
                    self.logIn.alpha = 1
                }
                self.createOrLogLabel.text = "Don't have an account?"
                self.createOrLogButton.setTitle("Create", for: .normal)
            }
            createOrLogButton.tag = 0
            
        case .singIn:
            DispatchQueue.main.async {
                UIView.animate(withDuration: animation) {
                    self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                    self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, height * (2), 0)
                }
                UIView.animate(withDuration: secondAnimation) {
                    self.logIn.alpha = 0
                }
                UIView.animate(withDuration: thirdAnimation) {
                    self.createAcount.alpha = 1
                }
                self.createOrLogLabel.text = "Already have an account?"
                self.createOrLogButton.setTitle("Log in", for: .normal)
            }
            createOrLogButton.tag = 1
        }
        
        for i in 0..<textfields.count {
            textfields[i].backgroundColor = K.Colors.secondaryBackground
        }
        obthervValues = false
        
        hideKeyboard()
        if messagesFromOtherScreen != "" {
            let message = messagesFromOtherScreen
            messagesFromOtherScreen = ""
            DispatchQueue.main.async {
                self.newMessage.show(title: message, type: .error)
            }
        }
        
    }

    @IBAction func toggleScreen(_ sender: UIButton) {
        switch sender.tag {
        case 0: toggleScreen(options: .singIn)
        case 1: toggleScreen(options: .createAccount)
        default:
            toggleScreen(options: .singIn)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if keyboardHeight > 1.0 {
             //   if let index = selectedTextfield {
                DispatchQueue.main.async {
                    let selectedTextfieldd = self.selectedScreen == .createAccount ? self.logIn : self.createAcount
                    //textfields[index]
                    print(selectedTextfieldd?.frame.maxY ?? "____________________________________ERROR")
                    let dif = self.view.frame.height - CGFloat(keyboardHeight) - ((selectedTextfieldd?.frame.maxY ?? 0) + 5)
                    if dif < 20 {

                        
                        
                            UIView.animate(withDuration: 0.3) {
                                //self.view.layer.frame = CGRect(x: 0, y: dif - 20, width: self.view.layer.frame.width, height: self.view.layer.frame.height)
                                //self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif - 20, 0)
                                if self.selectedScreen == .createAccount {
                                    self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif - 20, 0)
                                } else {
                                    if self.selectedScreen == .singIn {
                                        self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif - 20, 0)
                                    }
                                }
                               // self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif - 20, 0)
                            }
                        }
                    }
             //   }
            }
        }
        
    }

    @objc func keyboardWillHide(_ notification: Notification) {
    //    if self.view.layer.frame.minY != 0 {

            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {

                    if self.selectedScreen == .createAccount {
                        self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                    } else {
                        if self.selectedScreen == .singIn {
                            self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                        }
                    }
                }
            }
    //    }
    }
       
    
    var textFieldValuesDict:[String:String] = [:]
    
    @objc func textfieldValueChanged(_ textField: UITextField) {
         //  message.hideMessage()
        
        textFieldValuesDict.updateValue(textField.text ?? "", forKey: textField.accessibilityIdentifier ?? "")
        print(textFieldValuesDict)
           if obthervValues {
               showWrongFields()
           }
    }

    var textfields: [UITextField] {
        return [nicknameLabelCreate, emailLabel, passwordLabel, confirmPasswordLabel, nicknameLogLabel, passwordLogLabel]
    }
    var placeHolder: [String] {
        return ["Create username", "Enter your email", "Create password", "Confirm password", "Username or email", "Password"]
    }
    
    var _enteredEmailUsers: [String] = []
    var enteredEmailUsers: [String] {
        get {
            return _enteredEmailUsers
        }
        set {
            _enteredEmailUsers = newValue
            
            
            let hideUserButton = newValue.count == 0 ?  true : false
            DispatchQueue.main.async {
                if self.usersButton.isHidden != hideUserButton {
                    UIView.animate(withDuration: 0.3) {
                        self.usersButton.isHidden = hideUserButton
                    } completion: { _ in
                        
                    }
                }
                

            }
        }
    }

    
    @IBAction func emailUsersPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toSelectUserVC", sender: self)
        }
    }
}

// extentions

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
                        let text = !found ? "Email not found!" : "Wrong password"
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
                self.newMessage.show(title:"All fields are required", type: .error)
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
                            self.newMessage.show(title: "Passwords not match", type: .error)
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
                            self.newMessage.show(title: "Enter valid email", type: .error)
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



extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        DispatchQueue.main.async {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        DispatchQueue.main.async {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.rightView = paddingView
            self.rightViewMode = .always
        }
        
    }
}




extension LoginViewController {
    func logout() {
        if !appData.purchasedOnThisDevice {
            appData.proVersion = false
            appData.proTrial = false
        }
        appData.username = ""
        appData.password = ""
        lastSelectedDate = nil
        //_debtsHolder.removeAll()
        UserDefaults.standard.setValue(nil, forKey: "lastSelected")
        _categoriesHolder.removeAll()

        DispatchQueue.main.async {
            self.title = "Sing in"
            self.passwordLabel.text = ""
            self.passwordLogLabel.text = ""
            self.nicknameLogLabel.text = ""
            self.ai.fastHide { _ in
                
            }
        }
    }
    
    func dataLoaded() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
             //   self.view.alpha = 0.2
                
                self.navigationController?.navigationBar.alpha = 0.2
            } completion: {_ in
                self.aai?.removeFromSuperview()
            }

            
            /*self.loadingIndicator.fastHide { _ in
                accountSettingsVC.shared?.dataLoadedAnimation()
            }*/
            
        }
    }
    
    func dismissed() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.alpha = 1
            } completion: {_ in
            
            }
        }
    }
}





extension LoginViewController: SelectUserVCDelegate {
    func selected(user: String) {
        keyChainPassword(nick: user)
        DispatchQueue.main.async {
            self.nicknameLogLabel.text = user
        }
    }
    
    
}
