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


class accountSettingsVC: SuperViewController, UNUserNotificationCenterDelegate {
    
    static var shared: accountSettingsVC? = nil
    var tableTopMargin:CGFloat = 0
    var delegate: accountSettingsVCDelegate?
    @IBOutlet weak var tableView: UITableView!
    var tableData: [tableStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountSettingsVC.shared = self
        center.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = tableTopMargin + 10
        if appData.username == "" {
            let forgotPassword = {
                DispatchQueue.main.async {
                    self.forgotPasswordTapped()
                }
            }
            self.tableData = [
                tableStruct(name: "Device purchase", value: appData.purchasedOnThisDevice ? "Yes":"No", needIndicator: false, action: self.breakAction),
                tableStruct(name: "Forgot password", value: "", needIndicator: true, action: forgotPassword)
            ]

            DispatchQueue.main.async {
                self.delegate?.dataLoaded()
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if appData.username != "" {
            getData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        delegate?.dismissed()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    func changeEmailTapped() {
        self.loadingIndicator.show { (_) in
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.loadingIndicator.completeWithActions(buttonsTitles: ("Cancel", "Send"), leftButtonActon: { (_) in
                            self.loadingIndicator.fastHide { (_) in
                                
                            }
                        }, rightButtonActon: { (_) in
                            self.loadingIndicator.show(title: "Sending", appeareAnimation: true) { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                    self.sendRestorationCode(toChange: .changeEmail)
                                }
                            }
                        }, title: "Send code", description: "to change email we will have to send you a restoration code on email: \(emailToSend)", error: false)
                    }
                }
            }
            
        }
        
    }
    
    func changePasswordTapped() {
        print("changeEmailTapped")

        let username = appData.username
        if username != "" {
            self.loadingIndicator.show { (_) in
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

                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            self.loadingIndicator.showTextField(type: .password, title: "Enter your old password", userData: (username, userData[1])) { (enteredPassword, _) in
                                self.checkOldPassword(enteredPassword, dbPassword: userData[2], email: userData[1])
                            }
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.loadingIndicator.internetError()
                        }
                    }
                }
            }
            
        }
    }
    
    func forgotPasswordTapped() {
        DispatchQueue.main.async {
            self.loadingIndicator.show { (_) in
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
                            self.loadingIndicator.completeWithActions(buttonsTitles: ("Cancel", "Send"), leftButtonActon: { (_) in
                                self.loadingIndicator.fastHide { (_) in
                                    
                                }
                            }, rightButtonActon: { (_) in
                                self.foundUsername = nil
                                self.loadingIndicator.show(title: "Sending", appeareAnimation: true) { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                        self.sendRestorationCode(toChange: .changePassword)
                                    }
                                }
                                
                                
                            }, title: "Send code", description: "to change password we will have to send you a restoration code on email: \(emailToSend)", error: false)
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
    
    func getData() {
        
        let load = LoadFromDB()
        load.Users { (loadedData, error) in
            if error {
                
            } else {
                var loadedResult:[String] = ["","","","", ""]
                for i in 0..<loadedData.count {
                    if loadedData[i][0] == appData.username {
                        loadedResult = loadedData[i]
                        break
                    }
                }
                //let emailAct: () = self.changeEmailTapped()
                let changeEmailAction = {
                    self.changeEmailTapped()
                }
                let logoutAction = {
                    self.logout()
                }
                let forgotPassword = {
                    DispatchQueue.main.async {
                        self.forgotPasswordTapped()
                    }
                }
                let changePassword = {
                    self.changePasswordTapped()
                }
                
                self.tableData = [
                    tableStruct(name: "Username", value: appData.username, needIndicator: false, action: self.breakAction),
                    tableStruct(name: "Web purchase", value: loadedResult[4] == "1" ? "Yes": "No", needIndicator: false, action: self.breakAction),
                    tableStruct(name: "Device purchase", value: appData.purchasedOnThisDevice ? "Yes":"No", needIndicator: false, action: self.breakAction),
                    tableStruct(name: "Account email", value: loadedResult[1], needIndicator: true, action: changeEmailAction),
                    tableStruct(name: "Change password", value: "", needIndicator: true, action: changePassword),
                    tableStruct(name: "Forgot password", value: "", needIndicator: true, action: forgotPassword),
                    tableStruct(name: "Log out", value: "", needIndicator: true, action: logoutAction, isRed: true)
                ]

                DispatchQueue.main.async {
                    self.delegate?.dataLoaded()
                    self.tableView.reloadData()
                }
            }
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
    
    func checkOldPassword(_ password: String, dbPassword: String, email: String){
        if password != dbPassword {
            self.loadingIndicator.showTextField(type: .password, error: ("Wrong password",""), title: "Enter your old password", userData: (appData.username, email)) { (enteredPassword, _) in
                self.loadingIndicator.show { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.checkOldPassword(enteredPassword, dbPassword: dbPassword, email: email)
                    }
                }
            }
            /*DispatchQueue.main.async {
                self.loadingIndicator.showMessage(show: true, title: "Wrong password", helpAction: nil)
            }*/
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.loadingIndicator.showTextField(type: .password, title: "Create your new password", userData: (appData.username, email)) { (password, _) in
                    
                    self.loadingIndicator.show { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            self.loadingIndicator.showTextField(type: .password, title: "Repeat password", userData: (appData.username, email), showSecondTF: true) { (newPassword, passwordRepeat) in
                                print("")
                                self.loadingIndicator.show { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                        self.checkNewPassword(one: newPassword, two: passwordRepeat ?? "", userData: (appData.username, email))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func seekingUser(enteredUsername: String, wasError: Bool = false) {
        
        
        loadingIndicator.showTextField(type: .nickname, error: ("User not found", ""), title: "Enter your username", description: "You will receive 4-digits code on email asigned to this username") { (enteredUsername, _) in
           // self.loadingIndicator.show(appeareAnimation: true)
            self.loadingIndicator.show(appeareAnimation: true) { (_) in
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
                        DispatchQueue.main.async {
                            self.loadingIndicator.internetError()
                        }
                    }
                }
            }
            
        }
        if wasError {
            self.seekingUser(enteredUsername: enteredUsername, wasError: true)
        }
    }
    
    
    func dbChangePassword(userData: (String, String)) {
        self.loadingIndicator.showTextField(type: .password, title: "Create your new password", userData: userData) { (password, notUsing) in
            
            self.loadingIndicator.show { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.loadingIndicator.showTextField(type: .password, title: "Repeat password", userData: userData, showSecondTF: true) { (newPassword, passwordRepeat) in
                        
                        self.loadingIndicator.show { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                self.checkNewPassword(one: newPassword, two: passwordRepeat ?? "", userData: userData)
                            }
                        }
                    }
                }
            }
        }
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
                        print(dataStringDelete)
                        delete.User(toDataString: dataStringDelete) { (errorr) in
                            if errorr {
                                appData.unsendedData.append(["deleteUser": dataStringDelete])
                            }
                            DispatchQueue.main.async {
                                self.loadingIndicator.hideIndicator(title: "Your email has been changed") { (_) in
                                    self.dismiss(animated: true) {
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func dbChangeEmail(userData: (String, String), error: Bool = false) {
        
        self.loadingIndicator.showTextField(type: .email, error: error ? ("Enter valid email address","") : nil, title: "Enter your new email", description: nil, userData: userData) { (newEmail, _) in
            
            self.loadingIndicator.completeWithActions(buttonsTitles: ("Repeate", "Yes"), showCloseButton: true, leftButtonActon: { lef in
                
                self.dbChangeEmail(userData: userData, error: false)
                
            }, rightButtonActon: { rig in
                
                self.loadingIndicator.show { _ in
                    self.performChanageEmail(userData: userData, newEmail: newEmail)
                }
                
            }, title: "Are you sure you wanna change email?", description: "Entered email: \(newEmail)", error: false)
            
            
        }
    }
    
    
    enum restoreCodeAction {
        case changePassword
        case changeEmail
    }
    
    func checkRestoreCode(value: String, userData: (String, String), ifCorrect: restoreCodeAction) {
        if value == self.currectAnsware {
            self.currectAnsware = ""
            self.waitingType = .newPassword
            switch ifCorrect {
            case .changePassword:
                DispatchQueue.main.async {
                    self.dbChangePassword(userData: userData)
                }
            case .changeEmail:
                self.dbChangeEmail(userData: userData)
            }
            
        } else {
            DispatchQueue.main.async {
                //self.loadingIndicator.showMessage(show: true, title: "Wrong code!", description: "You have entered: \(value)", helpAction: nil)
                self.loadingIndicator.showTextField(type: .code, error: ("Wrong code!","You have entered: \(value)"), title: "Repeate code", dontChangeText: true) { (code, notUsing) in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.checkRestoreCode(value: code, userData: userData, ifCorrect: ifCorrect)
                    }
                }
            }
        }
    }
    
    
    
    func checkNewPassword(one: String, two: String, userData: (String, String)) {
        print("checkNewPassword:", "one:", one, "  ", "two:", two)
        if one == two {
            //send new password
            DispatchQueue.main.async {
                self.loadingIndicator.show(appeareAnimation: true) { (_) in
                    self.cangePasswordDB(username: userData.0, newPassword: two)
                }
                
            }
        } else {
           // self.loadingIndicator.showMessage(show: true, title: "Psswords not much", helpAction: nil)
            self.loadingIndicator.showTextField(type: .password, error: ("Psswords not much",""), title: "Repeat password", userData: userData, showSecondTF: true) { (newPassword, passwordRepeat) in
                
                self.loadingIndicator.show { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.checkNewPassword(one: newPassword, two: passwordRepeat ?? "", userData: userData)
                    }
                }
            }
        }
    }
    
    func cangePasswordDB(username: String, newPassword: String) {
        DispatchQueue.init(label: "DB").async {
            let load = LoadFromDB()
            load.Users { (loadedData, error) in
                if error {
                    DispatchQueue.main.async {
                        self.loadingIndicator.internetError()
                    }
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
                            DispatchQueue.main.async {
                                self.loadingIndicator.hideIndicator(title: "Your password has been changed") { (_) in
                                    
                                }
                            }
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
                DispatchQueue.main.async {
                    self.loadingIndicator.internetError()
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
            DispatchQueue.main.async {
                self.loadingIndicator.internetError()
            }
        } else {
            if result == "" {
                DispatchQueue.main.async {
                    self.loadingIndicator.hideIndicator(fast: true) { (_) in
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


            self.loadingIndicator.show(title: "Sending", appeareAnimation: true) { _ in
                DispatchQueue.init(label: "getEmail").async {
                    
                    let load = LoadFromDB()
                    load.Users { (loadedData, error) in
                        if error {
                            DispatchQueue.main.async {
                                self.loadingIndicator.completeWithActions(buttonsTitles: (nil, "OK"), rightButtonActon: { (_) in
                                    self.loadingIndicator.hideIndicator(fast: true) { (co) in
                                    }
                                }, title: "Internet error", description: "Try again later", error: true)
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
                                    DispatchQueue.main.async {
                                        self.loadingIndicator.internetError()
                                    }
                                } else {
                                    self.currectAnsware = code
                                    self.waitingType = .code
                                    self.loadingIndicator.showTextField(type: .code, title: "Restoration code", description: "We have sent 4-digit resoration code on your email", userData: (username, emailToSend)) { (code, not) in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                            self.checkRestoreCode(value: code, userData: (username, emailToSend), ifCorrect: toChange)
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
    
            
            
            
        } else {

            loadingIndicator.showTextField(type: .nickname, title: "Enter your username", description: "You will receive 4-digits code on email asigned to this username") { (useer, _) in
                self.seekingUser(enteredUsername: useer)
            }
        }
    }
    
    
    struct tableStruct {
        let name: String
        let value: String
        let needIndicator: Bool
        let action: () -> Void
        var isRed: Bool = false
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset, "vgujkmnbhj")
        
        if dragPos < -130 {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    
                }
            }
        }
    }
    
    var dragPos:CGFloat=0.0
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragPos = scrollView.contentOffset.y
        if dragPos < -130  {
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
    
    
}


extension accountSettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountSettingsCell", for: indexPath) as! accountSettingsCell
        
        cell.nameLabel.text = tableData[indexPath.row].name
        cell.valueLabel.text = tableData[indexPath.row].value
        cell.accessoryType = tableData[indexPath.row].needIndicator ? .disclosureIndicator : .none
        
        cell.nameLabel.textColor = !tableData[indexPath.row].needIndicator ? K.Colors.balanceT : (tableData[indexPath.row].isRed ? K.Colors.negative : K.Colors.darkTable)//K.Colors.darkTable
        cell.valueLabel.textColor = !tableData[indexPath.row].needIndicator ? K.Colors.balanceT : K.Colors.darkTable
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       /* if tableData[indexPath.row].action != nil {
            if let function = tableData[indexPath.row].action as? () {
                function
                print("dddd")
            }
        }*/
        tableData[indexPath.row].action()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


class accountSettingsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}
