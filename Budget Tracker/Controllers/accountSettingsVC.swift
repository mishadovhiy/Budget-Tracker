//
//  accountSettingsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

protocol accountSettingsVCDelegate {
    func logout()
    func dataLoaded()
    func dismissed()
}


class accountSettingsVC: SuperViewController {
    
    static var shared: accountSettingsVC? = nil
    var tableTopMargin:CGFloat = 0
    var delegate: accountSettingsVCDelegate?
    @IBOutlet weak var tableView: UITableView!
    var tableData: [tableStruct] = []
    
    func showAlert(title:String,text:String? = nil, error: Bool) {
        
        let okButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in

        }
        
        DispatchQueue.main.async {
            self.ai.completeWithActions(buttons: (okButton, nil), title: title, descriptionText: text, type: error ? .error : .standard)
        }

    }
    
    var loadscroll:CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        if appData.username != "" && appData.password == "" {
            appData.username = ""
        }
        accountSettingsVC.shared = self
        count = 0
        tableView.delegate = self
        tableView.dataSource = self
       // tableView.contentInset.top = self.view.frame.height / 2 + (self.view.frame.height / 8)
        loadscroll = tableView.contentOffset.y
        print(loadscroll, "bhjkbjkbnjk")
        loadScreen()
    }
    
    var webPurchuase:Bool?
    func loadScreen() {
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
                
                    
                
                let nextAction = {
                    self.ai.show { _ in
                    let newValue = EnterValueVC.shared?.textFieldText ?? ""
                    self.loadUsers { users in
                        var found = false
                        for i in 0..<users.count {
                            if users[i][0] == newValue {
                                found = true
                            }
                        }
                        
                        if !found {
                            self.showAlert(title: "User not found", text: nil, error: true)
                        } else {
                            appData.username = newValue
                            appData.password = ""
                            self.sendRestorationCode(toChange: .changePassword)
                        }
                        
                    }
                    }
                }
                
                self.enterValueVCScreenData = EnterValueVCScreenData(taskName: "Forgot password", title: "Enter your username", placeHolder: "Username", nextAction: nextAction)
            }
            
           /* DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toEnterValueVC", sender: self)
            }*/
        }
        let changePassword = {
            self.changePasswordTapped()
        }
        
        
        
        self.tableData = appData.username != "" ? [
            tableStruct(name: "Username", value: appData.username, needIndicator: false, action: self.breakAction),
            tableStruct(name: "Web purchase", value: webPurchuase == nil ? "" : (webPurchuase ?? false ? "Yes" : "No"), needIndicator: false, action: self.breakAction),
            tableStruct(name: "Device purchase", value: appData.purchasedOnThisDevice ? "Yes":"No", needIndicator: false, action: self.breakAction),
            tableStruct(name: "Account email", value: "", needIndicator: true, action: changeEmailAction),
            tableStruct(name: "Change password", value: "", needIndicator: true, action: changePassword),
            tableStruct(name: "Forgot password", value: "", needIndicator: true, action: forgotPassword),
            tableStruct(name: "Log out", value: "", needIndicator: true, action: logoutAction, isRed: true)
        ] : [
            tableStruct(name: "Device purchase", value: appData.purchasedOnThisDevice ? "Yes":"No", needIndicator: false, action: self.breakAction),
            tableStruct(name: "Forgot password", value: "", needIndicator: true, action: forgotPassword),
        ]

        DispatchQueue.main.async {
          //  self.delegate?.dataLoaded()
            self.tableView.reloadData()
        }
    }
    
    
    func loadUsers(completion:@escaping ([[String]]) -> ()) {
        let load = LoadFromDB()
        load.Users { (users, error) in
            if !error {
                completion(users)
            } else {
                self.showAlert(title: "Ошибка", text: "", error: true)
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        delegate?.dismissed()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    func changeEmailTapped() {
        ai.show { (_) in
            let load = LoadFromDB()
            load.Users { (users, error) in
                if error {
                    
                } else {
                    var emailToSend = ""
                    for i in 0..<users.count {
                        if users[i][0] == appData.username {
                            emailToSend = users[i][1]
                            break
                        }
                    }
                    let firstButton = IndicatorView.button(title: "No", style: .standart, close: true) { _ in
                                        
                    }
                    let secondButton = IndicatorView.button(title: "Send", style: .error, close: false) { _ in
                        self.sendRestorationCode(toChange: .changeEmail)
                    }
                                    
                    DispatchQueue.main.async {
                        self.ai.completeWithActions(buttons: (firstButton, secondButton), title: "Send code", descriptionText: "to change email we will have to send you a restoration code on email: \(emailToSend)", type: .standard)
                    }

                }
            }
            
        }
        
    }
    
    func changePasswordTapped() {
        print("changeEmailTapped")

        let username = appData.username
        if username != "" {
            self.ai.show { (_) in
                let load = LoadFromDB()
                load.Users { (allUsers, error) in
                    if !error {
                        var userData: [String] = []
                        for i in 0..<allUsers.count {
                            if allUsers[i][0] == username {
                                userData = allUsers[i]
                                break
                            }
                        }

                        //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {

                        
                        let nextAction = {
                            let new = EnterValueVC.shared?.textFieldText ?? ""
                            self.checkChangeOldPassword(new, dbPassword: userData[2], email: userData[1])
                        }
                        
                        let userrData:((String, String)?, (String, String)?)? = (("Email:", userData[1]),("Nickname:",userData[0]))
                        
                        self.enterValueVCScreenData = EnterValueVCScreenData(taskName: "Change password", title: "Enter your old password", subTitle: nil, placeHolder: "Old password", nextAction: nextAction, descriptionTable: userrData)
                       // }
                        
                    } else {
                        self.showAlert(title: "No internet", text: nil, error: true)
                    }
                }
            }
            
        }
    }
    
    func forgotPasswordTapped() {
        DispatchQueue.main.async {
            self.ai.show { (_) in
                let load = LoadFromDB()
                load.Users { (users, error) in
                    if error {
                        
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
                            let secondButton = IndicatorView.button(title: "Send", style: .standart, close: false) { _ in
                                self.sendRestorationCode(toChange: .changePassword)
                            }
                            DispatchQueue.main.async {
                                self.ai.completeWithActions(buttons: (firstButton, secondButton), title: "Send code", descriptionText: "to change password we will have to send you a restoration code on email: \(emailToSend)", type: .standard)
                            }
                        } else {
                            self.sendRestorationCode(toChange: .changePassword)
                        }
                        
                    }
                }
                
            }
        }
    }
    
    
  /*  func fhhf() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        
        
            
        })
        
        
        
        let changePassword = UIAlertAction(title: "Change password", style: .default) { (ac) in
            //ask old password
            //if dont know- send code on nickname and change password
            
            
            
        }
        
        
        let changeEmail = UIAlertAction(title: "Change email", style: .default) { (ac) in
            //send code on old email
            //change email if true
            
            
            
            
        }
        
        
        let logout = UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
            
        })
        

        alert.addAction(forgotPassword)
        if appData.username != "" {
            alert.addAction(changeEmail)
            alert.addAction(changePassword)
            alert.addAction(logout)
            //change email // enter code we send on your old email
            //get email
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        self.present(alert, animated: true)
    }*/

    let breakAction = {
        return
    }
    
    private func logout() {
        
        DispatchQueue.init(label: "LogOut").async {
            transactionAdded = true
            appData.username = ""
            appData.password = ""
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.delegate?.logout()
                }
            }
        }
    }
    
    var userEmail = ""
    func getData() {
        if appData.username != "" {
            
        
        let load = LoadFromDB()
        load.Users { (loadedData, error) in
            if error {
                
            } else {
                var loadedResult:[String] = ["","","","", ""]
                for i in 0..<loadedData.count {
                    if loadedData[i][0] == appData.username {
                        loadedResult = loadedData[i]
                        self.webPurchuase = loadedResult[4] == "1" ? true : false
                        self.userEmail = loadedResult[1]
                        self.loadScreen()
                        break
                    }
                }
                //let emailAct: () = self.changeEmailTapped()
                
            }
        }
        }
        else {
            loadScreen()
        }
    }
    func dataLoadedAnimation() {
        DispatchQueue.main.async {
          //  self.delegate?.dataLoaded()
            self.tableView.reloadData()
        }
    }
    
    
    var waitingType:waitingFor?
    enum waitingFor {
        case newPassword
        case nickname
        case code
    }
    
    var currectAnsware = ""
    var foundUsername: String?
    
    func checkChangeOldPassword(_ password: String, dbPassword: String, email: String){
        
        if password != dbPassword {
            self.message.showMessage(text: "Error", type: .error)
        } else {
            let repeateActionn = {
                let fromPrev = EnterValueVC.shared?.textFieldText ?? ""
                let repeatPasAction = {
                    let new = EnterValueVC.shared?.textFieldText ?? ""
                    if fromPrev != new {
                        self.showAlert(title: "Passwords not much!", text: nil, error: true)
                        EnterValueVC.shared?.clearAll(animated: true)
                    } else {
                        self.cangePasswordDB(username: appData.username, newPassword: new)
                    }
                }
                EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change password", title: "Repeate password", placeHolder: "Password", nextAction: repeatPasAction))
            }
            EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change password", title: "Create your new password", placeHolder: "Password", nextAction: repeateActionn))
        }
        

    }
    
    
    func seekingUser(enteredUsername: String, wasError: Bool = false) {
        
        
        ai.showTextField(type: .nickname, error: ("User not found", ""), title: "Enter your username", description: "You will receive 4-digits code on email asigned to this username") { (enteredUsername, _) in

            self.ai.show(appeareAnimation: true) { (_) in
                let load = LoadFromDB()
                load.Users { (allUsers, error) in
                    if !error {
                        
                        var found = false
                        for i in 0..<allUsers.count {
                            if allUsers[i][0] == enteredUsername {
                                found = true
                                break
                            }
                        }
                        
                        if found {
                            self.foundUsername = enteredUsername
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                self.sendRestorationCode(toChange: .changePassword)
                            }
                        } else {
                            self.seekingUser(enteredUsername: enteredUsername, wasError: true)
                            
                        }
                        
                    } else {
                        self.showAlert(title: "No internet", text: nil, error: true)
                    }
                }
            }
            
        }
        if wasError {
            self.seekingUser(enteredUsername: enteredUsername, wasError: true)
        }
    }
    
    
    func dbChangePassword(userData: (String, String)) {

        
        let repeateActionn = {
            
            let fromPrev = EnterValueVC.shared?.textFieldText ?? ""
            
            let repeatPasAction = {
                
                let new = EnterValueVC.shared?.textFieldText ?? ""
                if fromPrev != new {
                    self.showAlert(title: "Passwords not much!", text: nil, error: true)
                    EnterValueVC.shared?.clearAll(animated: true)
                } else {
                    self.cangePasswordDB(username: appData.username, newPassword: new)
                }
            }
            EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change password", title: "Repeate password", placeHolder: "Password", nextAction: repeatPasAction))
        }
        EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change password", title: "Create your new password", placeHolder: "Password", nextAction: repeateActionn))
    }
    
    func performChanageEmail(userData: (String, String), newEmail: String) {
        if !(newEmail).contains("@") || !(newEmail).contains(".") {
            self.dbChangeEmail(userData: userData, error: true)
        } else {
            self.loadUserData(username: userData.0) { (loadedData) in
                if let dbData = loadedData {
                    //here
                    let save = SaveToDB()
                    let toDataStringMian = "&Nickname=\(dbData[0])" + "&Email=\(newEmail)" + "&Password=\(dbData[2])" + "&Registration_Date=\(dbData[3])" + "&ProVersion=\(dbData[4])" + "&trialDate=\(dbData[5])"
                    save.Users(toDataString: toDataStringMian ) { (error) in
                        if error {
                            appData.unsendedData.append(["saveUser": toDataStringMian])
                        }
                        let delete = DeleteFromDB()
                        let dataStringDelete = "&Nickname=\(dbData[0])" + "&Email=\(dbData[1])" + "&Password=\(dbData[2])" + "&Registration_Date=\(dbData[3])" + "&ProVersion=\(dbData[4])" + "&trialDate=\(dbData[5])"
                        print(toDataStringMian)
                        delete.User(toDataString: dataStringDelete) { (errorr) in
                            if errorr {
                                appData.unsendedData.append(["deleteUser": dataStringDelete])
                            }
                            DispatchQueue.main.async {
                                self.dismiss(animated: true) {
                                    self.showAlert(title: "Your email has been changed", text: "", error: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func dbChangeEmail(userData: (String, String), error: Bool = false) {
        
        let emailAction = {
            let newEmail = EnterValueVC.shared?.textFieldText ?? ""
            if !(newEmail).contains("@") || !(newEmail).contains(".") {
                self.showAlert(title: "Enter valid email", error: true)
            } else {
                self.ai.show(title: nil) { _ in
                    self.performChanageEmail(userData: userData, newEmail: newEmail)
                }
            }
            
        }
        
        EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change email", title: "Enter your new email", placeHolder: "Email", nextAction: emailAction))
        
     /*   self.ai.showTextField(type: .email, error: error ? ("Enter valid email address","") : nil, title: "Enter your new email", description: nil, userData: userData) { (newEmail, _) in
            
         /*   self.ai.completeWithActions(buttonsTitles: ("Repeate", "Yes"), showCloseButton: true, leftButtonActon: { lef in
                
                self.dbChangeEmail(userData: userData, error: false)
                
            }, rightButtonActon: { rig in
                
                self.ai.show { _ in
                    self.performChanageEmail(userData: userData, newEmail: newEmail)
                }
                
            }, title: "Are you sure you wanna change email?", description: "Entered email: \(newEmail)", error: false)*/
            let firstButton = IndicatorView.button(title: "Repeate", style: .standart, close: false) { _ in
                self.dbChangeEmail(userData: userData, error: false)
            }
            let secondButton = IndicatorView.button(title: "Try again", style: .standart, close: false) { _ in
                self.performChanageEmail(userData: userData, newEmail: newEmail)
            }
            DispatchQueue.main.async {
                self.ai.completeWithActions(buttons: (firstButton, secondButton), title: "Are you sure you wanna change email?", descriptionText: "Entered email: \(newEmail)", type: .standard)
            }
            
            
        }*///NEWSCREEN
    }
    
    
    enum restoreCodeAction {
        case changePassword
        case changeEmail
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
        }
    }
    

    
    func cangePasswordDB(username: String, newPassword: String) {
        DispatchQueue.init(label: "DB").async {
            let load = LoadFromDB()
            load.Users { (loadedData, error) in
                if error {
                    self.showAlert(title: "No internet", text: nil, error: true)
                } else {
                    var userData: [String] = []
                    for i in 0..<loadedData.count {
                        if loadedData[i][0] == username {
                            userData = loadedData[i]
                            break
                        }
                    }
                    let save = SaveToDB()
                    let toDataStringMian = "&Nickname=\(userData[0])" + "&Email=\(userData[1])" + "&Password=\(newPassword)" + "&Registration_Date=\(userData[3])" + "&ProVersion=\(userData[4])" + "&trialDate=\(userData[5])"
                    save.Users(toDataString: toDataStringMian ) { (error) in
                        if error {
                            appData.unsendedData.append(["saveUser": toDataStringMian])
                        }
                        let delete = DeleteFromDB()
                        let dataStringDelete = "&Nickname=\(userData[0])" + "&Email=\(userData[1])" + "&Password=\(userData[2])" + "&Registration_Date=\(userData[3])" + "&ProVersion=\(userData[4])" + "&trialDate=\(userData[5])"
                        print(dataStringDelete)
                        delete.User(toDataString: dataStringDelete) { (errorr) in
                            if errorr {
                                appData.unsendedData.append(["deleteUser": dataStringDelete])
                            }
                            appData.password = newPassword
                            KeychainService.updatePassword(service: "BudgetTrackerApp", account: userData[0], data: newPassword)
                            EnterValueVC.shared?.closeVC(closeMessage: "Your password has been changed")
                        }
                    }
                    
                }
            }
        }
    }
    
    func loadUserData(username: String, completion: @escaping ([String]?) -> ()){
        
        let load = LoadFromDB()
        load.Users { (loadedData, error) in
            if error {
                self.showAlert(title: "No internet", text: nil, error: true)
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
    
    func getEmail(username: String) -> String {
        var result = ""
        var errorr = true
        let load = LoadFromDB()
        load.Users { (loadedData, error) in
            errorr = error
            for i in 0..<loadedData.count {
                if loadedData[i][0] == username {
                    result = loadedData[i][1]
                    break
                }
            }
        }
        
        if errorr {
            self.showAlert(title: "No internet", text: nil, error: true)
        } else {
            if result == "" {
                DispatchQueue.main.async {
                    self.ai.hideIndicator(fast: true) { (_) in
                        self.message.showMessage(text: "Username not found!", type: .error)
                    }
                }
            }
            
        }
        return result
        
        
    }
    
    func sendRestorationCode(toChange: restoreCodeAction) {

        let username = foundUsername != nil ? foundUsername! : appData.username
        if username != "" {
       //     print(username, "usernameusernameusernameusernameusernameusername")
            self.currectAnsware = ""


            self.ai.show(title: nil, appeareAnimation: true) { _ in
                DispatchQueue.init(label: "getEmail").async {
                    
                    let load = LoadFromDB()
                    load.Users { (loadedData, error) in
                        if error {

                            let firstButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in
                
                            }

                            DispatchQueue.main.async {
                                self.ai.completeWithActions(buttons: (firstButton, nil), title: "Internet error", descriptionText: "Try again later", type: .error)
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
                            let save = SaveToDB()
                            save.sendCode(toDataString: "emailTo=\(emailToSend)&Nickname=\(username)&resetCode=\(code)") { (codeError) in
                                if codeError {
                                    self.showAlert(title: "No internet", text: nil, error: true)
                                } else {
                                    self.currectAnsware = code
                                    self.waitingType = .code
                                    /*
                                    self.ai.showTextField(type: .code, title: "Restoration code", description: "We have sent 4-digit resoration code on your email", userData: (("username",username),("emailToSend",emailToSend)), showSecondTF: true) { code, not in
                                        self.checkRestoreCode(value: code, userData: (username, emailToSend), ifCorrect: toChange)
                                    }*/
                                    var taskNameTitle:String {
                                        switch toChange {
                                        case .changePassword:
                                            return "Change password"
                                        case .changeEmail:
                                            return "Change Email"
                                        }
                                    }
                                    
                                    let userData = (("Email",emailToSend),("Username",username))
                                    
                                    let nextAction = {
                                        if EnterValueVC.shared?.textFieldText.count ?? 0 == 4 {
                                            self.ai.show(title: nil) { _ in
                                                
                                                self.checkRestoreCode(value: EnterValueVC.shared?.textFieldText ?? "", userData: (username, emailToSend), ifCorrect: toChange)
                                            }
                                        } else {
                                            self.showAlert(title: "Wrong code!", text: "Enter 4 digits\n we have send you", error: true)
                                        }
                                        
                                    }
                                    
                                    self.enterValueVCScreenData = EnterValueVCScreenData(taskName: taskNameTitle, title: "Restoration code", subTitle: "We have sent 4-digit resoration code on your email", placeHolder: "Code", nextAction: nextAction, descriptionTable: userData)
                                    
                                    
                                }
                            }
                        }
                    }
                }
            }
    
            
            
            
        } else {

            let nextAction = {
                if appData.username != "" {
                    self.ai.show(title: nil) { _ in
                        let enteredUsername = EnterValueVC.shared?.textFieldText ?? ""
                        
                        let load = LoadFromDB()
                        load.Users { (users, error) in
                            
                            for i in 0..<users.count {
                                if enteredUsername == users[i][0] {
                                    self.sendRestorationCode(toChange: toChange)
                                }
                            }
                        }
                    }
                } else {
                    
                }
                
            }
            
            enterValueVCScreenData = EnterValueVCScreenData(taskName: "Forgot password", title: "Enter your username", subTitle: "You will receive restoration code", placeHolder: "Username", nextAction: nextAction)
            
           /* ai.showTextField(type: .nickname, title: "Enter your username", description: "You will receive 4-digits code on email asigned to this username") { (useer, _) in
                self.seekingUser(enteredUsername: useer)
            }*/
        }
    }
    
    var _enterValueVCScreenData:EnterValueVCScreenData?
    var enterValueVCScreenData: EnterValueVCScreenData? {
        get {
            return _enterValueVCScreenData
        }
        set {
            _enterValueVCScreenData = newValue
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toEnterValueVC", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toEnterValueVC":
            let vc = segue.destination as! EnterValueVC
            if let screenData = enterValueVCScreenData {
                vc.screenData = screenData
                
            }
            
        default:
            break
        }
    }
    
    
    
    
    
    struct tableStruct {
        let name: String
        let value: String
        let needIndicator: Bool
        let action: () -> Void
        var isRed: Bool = false
    }
    
    
  /*  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset, "vgujkmnbhj")
        
        if dragPos < -130 {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    
                }
            }
        }
    }*/
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dragPos = scrollView.contentOffset.y
        print(dragPos)
        let result = dragPos - loadscroll
        print(result, "ghuiknhjuilknjk")
        if result < -160  {
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
    
    var dragPos:CGFloat=0.0
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragPos = scrollView.contentOffset.y
        print(dragPos)
        let result = dragPos - loadscroll
        print(result, "ghuiknhjuilknjk")
        if result < -160  {
            //UIImpactFeedbackGenerator().impactOccurred()
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    
}


extension accountSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 1 ? tableData.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountSettingsCell", for: indexPath) as! accountSettingsCell
            
            cell.nameLabel.text = tableData[indexPath.row].name
            cell.valueLabel.text = tableData[indexPath.row].value
            cell.accessoryType = tableData[indexPath.row].needIndicator ? .disclosureIndicator : .none
            
            cell.nameLabel.textColor = !tableData[indexPath.row].needIndicator ? K.Colors.balanceT : (tableData[indexPath.row].isRed ? K.Colors.negative : K.Colors.darkTable)//K.Colors.darkTable
            cell.valueLabel.textColor = !tableData[indexPath.row].needIndicator ? K.Colors.balanceT : K.Colors.darkTable
            
            
            return cell
        } else {
            let cell = UITableViewCell()
            let selection = UIView()
            selection.backgroundColor = .clear
            cell.selectedBackgroundView = selection
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? ((self.view.frame.height / 2) + (self.view.frame.height / 8)) : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       /* if tableData[indexPath.row].action != nil {
            if let function = tableData[indexPath.row].action as? () {
                function
                print("dddd")
            }
        }*/
        if indexPath.section == 1 {
            tableData[indexPath.row].action()
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.dismiss(animated: true) {
                
            }
        }
    }
}


class accountSettingsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}

