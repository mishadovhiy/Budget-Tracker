//
//  LoginViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
var needFullReload = false

//on login or create an account if account not in a list - append to "loggedInUsers"

//forgot password - if show (if from settings and if nick == "")
//change password - if nick != ""
//log out - if nick != ""


class LoginViewController: SuperViewController {

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
    enum screenType {
        case createAccount
        case singIn
    }
    var selectedScreen: screenType = .createAccount
    var fromPro = false
    
   
    
    var messagesFromOtherScreen = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoriesDebtsCount = (0,0)

        updateUI()

        DispatchQueue.main.async {
            self.title = appData.username == "" ? "Sing In" : appData.username
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
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

        
        let repeateActionn = {
            
            let fromPrev = EnterValueVC.shared?.enteringValue ?? ""
            
            let repeatPasAction = {
                
                let new = EnterValueVC.shared?.enteringValue ?? ""
                if fromPrev != new {
                    self.showAlert(title: "Passwords not much!", text: nil, error: true)
                    EnterValueVC.shared?.clearAll(animated: true)
                } else {
                    self.cangePasswordDB(username: appData.username, newPassword: new)
                }
            }
            EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change password", title: "Repeate password", placeHolder: "Password", nextAction: repeatPasAction, screenType: .password))
        }
        EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change password", title: "Create your new password", placeHolder: "Password", nextAction: repeateActionn, screenType: .password))
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
                                    //pop to login nav
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
            let newEmail = EnterValueVC.shared?.enteringValue ?? ""
            if !(newEmail).contains("@") || !(newEmail).contains(".") {
                self.showAlert(title: "Enter valid email", error: true)
            } else {
                self.ai.show(title: nil) { _ in
                    self.performChanageEmail(userData: userData, newEmail: newEmail)
                }
            }
            
        }
        
        EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change email", title: "Enter your new email", placeHolder: "Email", nextAction: emailAction, screenType: .email))
        
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
                                        if EnterValueVC.shared?.enteringValue.count ?? 0 == 4 {
                                            self.ai.show(title: nil) { _ in
                                                
                                                self.checkRestoreCode(value: EnterValueVC.shared?.enteringValue ?? "", userData: (username, emailToSend), ifCorrect: toChange)
                                            }
                                        } else {
                                            self.showAlert(title: "Wrong code!", text: "Enter 4 digits\n we have send you", error: true)
                                        }
                                        
                                    }
                                    
                                    self.enterValueVCScreenData = EnterValueVCScreenData(taskName: taskNameTitle, title: "Restoration code", subTitle: "We have sent 4-digit resoration code on your email", placeHolder: "Code", nextAction: nextAction, screenType: .code, descriptionTable: userData)
                                    
                                    
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
                        let enteredUsername = EnterValueVC.shared?.enteringValue ?? ""
                        
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
            
            enterValueVCScreenData = EnterValueVCScreenData(taskName: "Forgot password", title: "Enter your username", subTitle: "You will receive restoration code", placeHolder: "Username", nextAction: nextAction, screenType: .password)
            
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
            print(newValue?.title ?? "-")
            _enterValueVCScreenData = newValue
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toEnterValueVC", sender: self)
            }
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
    
    func checkChangeOldPassword(_ password: String, dbPassword: String, email: String){
        
        if password != dbPassword {
            showAlert(text: "Wrong password!", error: true)
        } else {
            let repeateActionn = {
                let fromPrev = EnterValueVC.shared?.enteringValue ?? ""
                let repeatPasAction = {
                    let new = EnterValueVC.shared?.enteringValue ?? ""
                    if fromPrev != new {
                        self.showAlert(title: "Passwords not much!", text: nil, error: true)
                        EnterValueVC.shared?.clearAll(animated: true)
                    } else {
                        self.cangePasswordDB(username: appData.username, newPassword: new)
                    }
                }
                EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change password", title: "Repeate password", placeHolder: "Password", nextAction: repeatPasAction, screenType: .password))
            }
            EnterValueVC.shared?.showSelfVC(data: EnterValueVCScreenData(taskName: "Change password", title: "Create your new password", placeHolder: "Password", nextAction: repeateActionn, screenType: .password))
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
                            let new = EnterValueVC.shared?.enteringValue ?? ""
                            self.checkChangeOldPassword(new, dbPassword: userData[2], email: userData[1])
                        }
                        
                        let userrData:((String, String)?, (String, String)?)? = (("Email:", userData[1]),("Nickname:",userData[0]))
                        
                        self.enterValueVCScreenData = EnterValueVCScreenData(taskName: "Change password", title: "Enter your old password", subTitle: nil, placeHolder: "Old password", nextAction: nextAction, screenType: .password, descriptionTable: userrData)
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

                            let firstButton = IndicatorView.button(title: "Cancel", style: .success, close: true) { _ in
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
    
    
    
    @IBOutlet weak var moreButton: UIButton!
    var aai:UIActivityIndicatorView?
    @IBAction func moreButtonPressed(_ sender: UIButton) {//morepressed
        let appData = AppData()
        //get screen data
        let addAmountToPay = {
            print("func")
        }

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
                    let newValue = EnterValueVC.shared?.enteringValue ?? ""
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
                
                self.enterValueVCScreenData = EnterValueVCScreenData(taskName: "Forgot password", title: "Enter your username", placeHolder: "Username", nextAction: nextAction, screenType: .password)
            }
            
           /* DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toEnterValueVC", sender: self)
            }*/
        }
        let changePassword = {
            self.changePasswordTapped()
        }
        
        
        let loggedUserData = [
           // MoreVC.ScreenData(name: "Username", description: "", action: nil),
           // MoreVC.ScreenData(name: "Web purchase", description: "", action: nil),
           // MoreVC.ScreenData(name: "Device purchase", description: "", action: nil),
            MoreVC.ScreenData(name: "Change Email", description: "", action: changeEmailAction),
            MoreVC.ScreenData(name: "Change password", description: "", action: changePassword),
            MoreVC.ScreenData(name: "Forgot password", description: "", action: forgotPassword),
            MoreVC.ScreenData(name: "Log out", description: "", distructive: true, action: logoutAction),
        ]
        
        let notUserLogged = [
            //MoreVC.ScreenData(name: "Device purchase", description: appData.purchasedOnThisDevice ? "Yes":"No", action: nil),
            MoreVC.ScreenData(name: "Forgot password", description: "", action: forgotPassword),
        ]
        
        appData.presentMoreVC(currentVC: self, data: appData.username == "" ? notUserLogged : loggedUserData, dismissOnAction: true)

    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toAccountSettings":
            break
            let vc = segue.destination as! accountSettingsVC
            vc.tableTopMargin = self.view.frame.minY
            vc.delegate = self
        case "toEnterValueVC":
            let vc = segue.destination as! EnterValueVC
            if let screenData = enterValueVCScreenData {
                vc.screenData = screenData
                
            }
        default:
            break
        }
    }
    

    func showAlert(title:String? = nil,text:String? = nil, error: Bool) {
        
        let resultTitle = title == nil ? (error ? "Error" : "Succsess!") : title!
        
        let okButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in
        }
        
        DispatchQueue.main.async {
            EnterValueVC.shared?.valueTextField.endEditing(true)
            self.ai.completeWithActions(buttons: (okButton, nil), title: resultTitle, descriptionText: text, type: error ? .error : .standard)
        }

    }
    
    
    func updateUI() {
        toggleScreen(options: .createAccount, animation: 0.0)
        for i in 0..<textfields.count {
            self.textfields[i].delegate = self
            self.textfields[i].addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
            self.textfields[i].layer.masksToBounds = true
            self.textfields[i].layer.cornerRadius = 6
            
            textfields[i].setRightPaddingPoints(5)
            textfields[i].setLeftPaddingPoints(5)
        }
        
        let hideKeyboardGestureSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboardSwipped))
        hideKeyboardGestureSwipe.direction = .down
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let usernameHolder = UserDefaults.standard.value(forKey: "UsernameHolder") as? String
        DispatchQueue.main.async {
            self.nicknameLogLabel.text = usernameHolder != nil ? usernameHolder! :  appData.username
            self.passwordLogLabel.text = appData.username == "" ? "" : appData.password
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(hideKeyboardGestureSwipe)
        }
        self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height * (-2), 0)
        self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height * (-2), 0)
        
        
    }


    
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
    
    let load = LoadFromDB()
    @IBAction func logInPressed(_ sender: UIButton) {
        print("LOGINPRESSED")
        transactionAdded = true
        actionButtonsEnabled = false
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }

        self.ai.show(title: "Logging in") { (_) in
            self.hideKeyboard()
            self.load.Users { (loadedData, Error) in
                if !Error {
                    DispatchQueue.main.async {
                        let name = self.nicknameLogLabel.text ?? ""
                        let password = self.passwordLogLabel.text ?? ""
                        if name != "" && password != "" {
                            self.logIn(nickname: name, password: password, loadedData: loadedData)
                        } else {
                            self.actionButtonsEnabled = true
                            DispatchQueue.main.async {
                                self.ai.hideIndicator(fast: true) { (_) in
                                    self.message.showMessage(text: "All fields are required", type: .error, autoHide: false)
                                }
                                
                            }
                            self.obthervValues = true
                            self.showWrongFields()
                        }
                    }
                } else {
                    print("error!!!")
                    self.actionButtonsEnabled = true
                    self.showAlert(title: "No internet", text: nil, error: true)
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
                    psswordFromDB = loadedData[i][DBpasswordIndex]
                    
                    if password != psswordFromDB {
                        print("wrong password", psswordFromDB)
                        self.actionButtonsEnabled = true
                        DispatchQueue.main.async {
                            
                           // self.ai.hideIndicator(fast: true) { (_) in
                            //    self.message.showMessage(text: "Wrong password!", type: .error)
                                self.showAlert(text: "Wrong password!", error: true)
                           // }
                            
                        }
                    } else {
                        if let keycheinPassword = KeychainService.loadPassword(service: "BudgetTrackerApp", account: nickname) {
                            if keycheinPassword != password {
                                KeychainService.updatePassword(service: "BudgetTrackerApp", account: nickname, data: password)
                            }
                        } else {
                            KeychainService.savePassword(service: "BudgetTrackerApp", account: nickname, data: password)
                        }
                        let prevUserName = appData.username
                        self.actionButtonsEnabled = true
                        appData.username = nickname
                        appData.password = password
                        if prevUserName != nickname {

                            UserDefaults.standard.setValue(prevUserName, forKey: "prevUserName")
                            let wasTrans = appData.getLocalTransactions
                            let trans: [TransactionsStruct] = prevUserName == "" ? [] : wasTrans + appData.getTransactions

                            let wascats = appData.getCategories(key: K.Keys.localCategories)
                            let cats = wascats + appData.getCategories()
                            var catResult: [CategoriesStruct] = prevUserName == "" ? [] : cats
                            for i in 0..<cats.count {
                                catResult.append(CategoriesStruct(name: cats[i].name, purpose: cats[i].purpose, count: cats[i].count))

                            }
                            let wasDebts = prevUserName == "" ? [] : appData.getDebts() + appData.getDebts(key: K.Keys.localDebts)
                            
                            if prevUserName == "" {
                                appData.saveDebts(wasDebts, key: K.Keys.localDebts)
                                appData.saveCategories(catResult, key: K.Keys.localCategories)
                                appData.saveTransations(trans, key: K.Keys.localTrancations)
                            }
                            

                            appData.fromLoginVCMessage = (trans.count + wasDebts.count + catResult.count) > 0 ? "Wellcome, \(appData.username), \nYour Data has been saved localy" : "Wellcome, \(appData.username)"
                        }
                        needFullReload = true
                        lastSelectedDate = nil
                        _debtsHolder.removeAll()
                        _categoriesHolder.removeAll()
                        UserDefaults.standard.setValue(nil, forKey: "lastSelectedCategory")
                        if !appData.purchasedOnThisDevice {
                            appData.proVersion = loadedData[i][4] == "1" ? true : appData.proVersion
                        }
                        if fromPro {
                            DispatchQueue.main.async {
                                self.ai.fastHide { _ in
                                    self.dismiss(animated: true, completion: nil)
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
                    
                    self.ai.hideIndicator(fast: true) { (_) in
                        self.message.showMessage(text: "User not found", type: .error)
                        
                    }
                }

            }
        }
    }

    
    @IBAction func createAccountPressed(_ sender: Any) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        transactionAdded = true
        self.actionButtonsEnabled = true

        self.ai.show(title: "Creating an account") { (_) in
            self.hideKeyboard()
            self.load.Users { (loadedData, Error) in
                if !Error {
                    self.createAccoun(loadedData: loadedData)
                } else {
                    self.actionButtonsEnabled = true
                    self.showAlert(title: "No internet", text: nil, error: true)
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
                if name != "" && email != "" && password != "" {
                    if self.userExists(name: name, loadedData: loadedData) == false  {
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
                      /*      DispatchQueue.main.async {

                                self.loadingIndicator.completeWithActions(buttonsTitles: (nil, "Try again"), rightButtonActon: { (_) in
                                    self.loadingIndicator.hideIndicator(fast: true) { (co) in
                                        self.emailLabel.becomeFirstResponder()
                                    }
                                }, title: "Enter valid email address", description: "With correct email address you could restore your password in the future", error: true)
                                
                                
                            }*/
                        } else {
                            let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate)"
                            save.Users(toDataString: toDataString) { (error) in
                                if error {
                                    print("error")
                                    self.showAlert(title: "No internet", text: nil, error: true)
                                } else {
                                    let prevUsere = appData.username
                                    UserDefaults.standard.setValue(prevUsere, forKey: "prevUserName")
                                    KeychainService.savePassword(service: "BudgetTrackerApp", account: name, data: password)
                                    appData.username = name
                                    appData.password = password
                                    let wasTransactions: [TransactionsStruct] = prevUsere == "" ? [] : appData.getTransactions + appData.getLocalTransactions
                                    
                                    let wasCats = appData.getCategories() + appData.getCategories(key: K.Keys.localCategories)
                                    var catResult: [CategoriesStruct] = prevUsere == "" ? [] : wasCats
                                    for i in 0..<wasCats.count {
                                        catResult.append(CategoriesStruct(name: wasCats[i].name, purpose: wasCats[i].purpose, count: wasCats[i].count))

                                    }

                                    
                                    let wasDebts = prevUsere == "" ? [] : appData.getDebts() + appData.getDebts(key: K.Keys.localDebts)

                                    if prevUsere == "" {
                                        appData.saveTransations(wasTransactions, key: K.Keys.localTrancations)
                                        appData.saveDebts(wasDebts, key: K.Keys.localDebts)
                                        appData.saveCategories(catResult, key: K.Keys.localCategories)
                                    }
                                    
                                    appData.fromLoginVCMessage = wasTransactions.count + catResult.count + wasDebts.count > 0 ? "Wellcome, \(appData.username), \nYour Data has been saved localy" : "Wellcome, \(appData.username)"
                                    needFullReload = true
                                    lastSelectedDate = nil
                                    _debtsHolder.removeAll()
                                    _categoriesHolder.removeAll()
                                    UserDefaults.standard.setValue(nil, forKey: "lastSelectedCategory")
                                    if self.fromPro {
                                        DispatchQueue.main.async {
                                            self.ai.fastHide { _ in
                                                self.dismiss(animated: true, completion: nil)
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
                        self.actionButtonsEnabled = true
                        DispatchQueue.main.async {

                            self.ai.hideIndicator(fast: true) { (_) in
                                self.message.showMessage(text: "Username '\(name)' is already taken", type: .error, windowHeight: 65)
                                
                            }
                        }
                    }
                
                } else {
                    self.actionButtonsEnabled = true
                    self.obthervValues = true
                    self.showWrongFields()

                    DispatchQueue.main.async {
                        self.ai.hideIndicator(fast: true) { (_) in
                            self.message.showMessage(text: "All fields are required", type: .error)
                        }
                    }
                    print("all fields are required")
                }
            } else {
                self.actionButtonsEnabled = true
                DispatchQueue.main.async {

                    self.ai.hideIndicator(fast: true) { (_) in
                        self.message.showMessage(text: "Passwords not match", type: .error)
                    }
                }
                print("passwords not much")
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
                self.helperNavView?.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: safeArTopHeight)
                window.addSubview(self.helperNavView ?? UIView())
                self.message.hideMessage(duration: 0)
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
    
    func toggleScreen(options: screenType, animation: TimeInterval = 0.6) {
        
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
                self.message.showMessage(text: message, type: .succsess, windowHeight: 80)
            }
        } else {
            message.hideMessage()
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
                if let index = selectedTextfield {
                    let selectedTextfieldd = textfields[index]
                    let dif = self.view.frame.height - CGFloat(keyboardHeight) - (selectedTextfieldd.superview?.frame.maxY ?? 0)
                    if dif < 20 {

                        
                        DispatchQueue.main.async {
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
                }
            }
        }
    }
       
    @objc func keyboardWillHide(_ notification: Notification) {
    //    if self.view.layer.frame.minY != 0 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    //self.view.layer.frame = CGRect(x: 0, y: 0 + (self.navigationController?.navigationBar.frame.height ?? 0), width: self.view.layer.frame.width, height: self.view.layer.frame.height + (self.navigationController?.navigationBar.frame.height ?? 0))

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
       
    @objc func textfieldValueChanged(_ textField: UITextField) {
           message.hideMessage()
           if obthervValues {
               showWrongFields()
           }
    }

    var selectedTextfield: Int?
    var textfields: [UITextField] {
        return [nicknameLabelCreate, emailLabel, passwordLabel, confirmPasswordLabel, nicknameLogLabel, passwordLogLabel]
    }
    
    

}

// extentions

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nicknameLabelCreate:
            if textField.text != "" {
                DispatchQueue.main.async {
                    self.emailLabel.becomeFirstResponder()
                }
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Create username", type: .error, autoHide: false)
                 //   textField.endEditing(true)
                }
            }
            
        case emailLabel:
            if !(self.emailLabel.text ?? "").contains("@") || !(self.emailLabel.text ?? "").contains(".") {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Enter valid email address", type: .error, autoHide: false)
                   // textField.endEditing(true)
                }
            } else {
                DispatchQueue.main.async {
                    self.passwordLabel.becomeFirstResponder()
                }
            }
        case passwordLabel:
            if textField.text != "" {
                DispatchQueue.main.async {
                    self.confirmPasswordLabel.becomeFirstResponder()
                }
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Create password", type: .error, autoHide: false)
                  //  textField.endEditing(true)
                }
            }
        case confirmPasswordLabel:
            if let text = textField.text {
                if text != "" {
                    if text == passwordLabel.text {
                        self.createAccountPressed(createAccButton!)
                    } else {
                        DispatchQueue.main.async {
                            self.message.showMessage(text: "Passwords not match", type: .error, autoHide: false)
                           // textField.endEditing(true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: "Repeat password", type: .error, autoHide: false)
                      //  textField.endEditing(true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Repeat password", type: .error, autoHide: false)
                   // textField.endEditing(true)
                }
            }
            
        case nicknameLogLabel:
            if let nick = textField.text {
                if nick != "" {
                    if let keychainPassword = KeychainService.loadPassword(service: "BudgetTrackerApp", account: nick) {
                        DispatchQueue.main.async {
                            self.passwordLogLabel.isSecureTextEntry = false
                            self.passwordLogLabel.text = keychainPassword
                            self.nicknameLogLabel.endEditing(true)
                         //   self.message.showMessage(text: "Password loaded from Keychain", type: .succsess, windowHeight: 65)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.passwordLogLabel.becomeFirstResponder()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: "Enter username", type: .error, autoHide: false)
                      //  textField.endEditing(true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Enter username", type: .error, autoHide: false)
                        //     textField.endEditing(true)
                }
            }
            
            
        case passwordLogLabel:
            if textField.text != "" {
                logInPressed(logInButton)
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Enter password!", type: .error, autoHide: false)
                    //textField.endEditing(true)
                }
            }
        default:
            textField.endEditing(true)
        }

        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nicknameLabelCreate: selectedTextfield = 0
        case emailLabel: selectedTextfield = 1
        case passwordLabel: selectedTextfield = 2
        case confirmPasswordLabel: selectedTextfield = 3
            
        case nicknameLogLabel: selectedTextfield = 4
        case passwordLogLabel: selectedTextfield = 5
        default:
            textField.endEditing(true)
        }
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




extension LoginViewController: accountSettingsVCDelegate {
    func logout() {
        lastSelectedDate = nil
        _debtsHolder.removeAll()
        _categoriesHolder.removeAll()
        UserDefaults.standard.setValue(nil, forKey: "lastSelectedCategory")
        
        DispatchQueue.main.async {
            self.title = "Sing in"
            self.passwordLabel.text = ""
            self.passwordLogLabel.text = ""
            self.nicknameLogLabel.text = ""
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
