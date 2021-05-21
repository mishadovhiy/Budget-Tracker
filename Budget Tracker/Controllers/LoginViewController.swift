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
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    var messagesFromOtherScreen = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helperNavView.backgroundColor = K.Colors.background
        print("username: \(appData.username)")
        print("localTransactions:", appData.getTransactions.count)
        updateUI()

      //  logoutButton.alpha = appData.username != "" ? 1 : 0

        DispatchQueue.main.async {
            self.title = appData.username == "" ? "Sing In" : appData.username
        }
        
       /* Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (_) in
            self.loadingIndicator.show()
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (_) in
                self.loadingIndicator.showTextField(type: .password, title: "ff", userData: ("d", "g"), showSecondTF: true) { (firstText, secondText) in
                    print(firstText, "scheduledTimer")
                    print(secondText, "scheduledTimer")
                    self.loadingIndicator.show()
                }
            }
        }*/
    }
    
    var waitingType:waitingFor?
    
    func saveNewPasswordDB() {
        
    }
    
    var currectAnsware = ""
    var foundUsername: String?
    
    
    func sendRestorationCode(toChange: restoreCodeAction) {

        let username = foundUsername != nil ? foundUsername! : appData.username
        if username != "" {
            self.currectAnsware = ""
            DispatchQueue.main.async {
                self.loadingIndicator.show()
            }
            
    
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
                        
                        let save = SaveToDB()
                        save.sendCode(toDataString: "emailTo=\(emailToSend)&Nickname=\(username)&resetCode=\(code)") { (codeError) in
                            if codeError {
                                DispatchQueue.main.async {
                                    self.loadingIndicator.internetError()
                                }
                            } else {
                                self.currectAnsware = code
                                self.waitingType = .code
                                self.loadingIndicator.showTextField(type: .code, title: "Resoration code", description: "We have sent 4-digit resoration code on your email", userData: (username, emailToSend)) { (code, not) in
                                    self.checkRestoreCode(value: code, userData: (username, emailToSend), ifCorrect: toChange)
                                }
                                
                            }
                        }
                    }
                }
            }
            
            
        } else {

            loadingIndicator.showTextField(type: .nickname, title: "Enter your username", description: "You will receive 4-digits code on email asigned to this username") { (enteredUsername, _) in
                self.seekingUser(enteredUsername: enteredUsername)
            }
        }
    }
    
    func seekingUser(enteredUsername: String, wasError: Bool = false) {
        
        
        loadingIndicator.showTextField(type: .nickname, title: "Enter your username", description: "You will receive 4-digits code on email asigned to this username") { (enteredUsername, _) in
            self.loadingIndicator.show(appeareAnimation: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
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
                            self.sendRestorationCode(toChange: .changePassword)
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
            self.loadingIndicator.showMessage(show: true, title: "Username not found", helpAction: nil)
        }
    }
    
    
    func dbChangePassword(userData: (String, String)) {
        self.loadingIndicator.showTextField(type: .password, title: "Create your new password", userData: userData) { (password, notUsing) in
            
            self.loadingIndicator.showTextField(type: .password, title: "Repeat password", userData: userData, showSecondTF: true) { (newPassword, passwordRepeat) in
                
                self.checkNewPassword(one: password, two: passwordRepeat ?? "", userData: userData)
            }
        }
    }
    
    
    func dbChangeEmail(userData: (String, String)) {
        self.loadingIndicator.showTextField(type: .email, title: "Enter you new email", userData: userData) { (newEmail, _) in
            
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
                                    
                                }
                            }
                        }
                    }
                }
            }
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
                DispatchQueue.main.async {
                    self.dbChangeEmail(userData: userData)
                }
            }
            
        } else {
            DispatchQueue.main.async {
                self.loadingIndicator.showMessage(show: true, title: "Wrong code!", description: "You have entered: \(value)", helpAction: nil)
                self.loadingIndicator.showTextField(type: .code, title: "Repeate code", dontChangeText: true) { (code, notUsing) in
                    
                    self.checkRestoreCode(value: code, userData: userData, ifCorrect: ifCorrect)
                }
            }
        }
    }
    
    
    
    func checkNewPassword(one: String, two: String, userData: (String, String)) {
        print("checkNewPassword:", "one:", one, "  ", "two:", two)
        if one == two {
            //send new password
            DispatchQueue.main.async {
                self.loadingIndicator.show(appeareAnimation: true)
                self.cangePasswordDB(username: userData.0, newPassword: two)
            }
        } else {
            self.loadingIndicator.showMessage(show: true, title: "Psswords not much", helpAction: nil)
            self.loadingIndicator.showTextField(type: .password, title: "Repeat password", userData: userData, showSecondTF: true) { (newPassword, passwordRepeat) in
                
                self.checkNewPassword(one: newPassword, two: passwordRepeat ?? "", userData: userData)
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
                            KeychainService.savePassword(service: "BudgetTrackerApp", account: userData[0], data: newPassword)
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
    

    @IBAction func moreButtonPressed(_ sender: UIButton) {
        foundUsername = nil
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            
            
            let forgotPassword = UIAlertAction(title: "Forgot password", style: .default, handler: { (_) in
                
                self.sendRestorationCode(toChange: .changePassword)
            })
            
            
            
            let changePassword = UIAlertAction(title: "Change password", style: .default) { (ac) in
                //ask old password
                //if dont know- send code on nickname and change password
                let username = appData.username
                if username != "" {
                    DispatchQueue.main.async {
                        self.loadingIndicator.show()
                    }
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
                            
                            DispatchQueue.main.async {
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
            
            
            let changeEmail = UIAlertAction(title: "Change email", style: .default) { (ac) in
                //send code on old email
                //change email if true
                self.sendRestorationCode(toChange: .changeEmail)
            }
            
            
            let logout = UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
                transactionAdded = true
                appData.username = ""
                appData.password = ""
                self.nicknameLogLabel.text = ""
                self.passwordLogLabel.text = ""
                self.title = "Sing In"
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
        }
        
    }
    
    func checkOldPassword(_ password: String, dbPassword: String, email: String){
        if password != dbPassword {
            self.loadingIndicator.showTextField(type: .password, title: "Enter your old password", userData: (appData.username, email)) { (enteredPassword, _) in
                self.checkOldPassword(enteredPassword, dbPassword: dbPassword, email: email)
            }
            DispatchQueue.main.async {
                self.loadingIndicator.showMessage(show: true, title: "Wrong password", helpAction: nil)
            }
            
        } else {
            self.loadingIndicator.showTextField(type: .password, title: "Create your new password", userData: (appData.username, email)) { (password, _) in
                
                self.loadingIndicator.showTextField(type: .password, title: "Repeat password", userData: (appData.username, email), showSecondTF: true) { (newPassword, passwordRepeat) in
                    print("")
                    self.checkNewPassword(one: password, two: passwordRepeat ?? "", userData: (appData.username, email))
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        default:
            break
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
            self.helperNavView.removeFromSuperview()
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
        
        transactionAdded = true
        actionButtonsEnabled = false
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        self.loadingIndicator.show(title: "Logging in")
        hideKeyboard()
        load.Users { (loadedData, Error) in
            if !Error {
                DispatchQueue.main.async {
                    let name = self.nicknameLogLabel.text ?? ""
                    let password = self.passwordLogLabel.text ?? ""
                    if name != "" && password != "" {
                        self.logIn(nickname: name, password: password, loadedData: loadedData)
                    } else {
                        self.actionButtonsEnabled = true
                        DispatchQueue.main.async {
                            self.loadingIndicator.hideIndicator(fast: true) { (_) in
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
                DispatchQueue.main.async {
                    self.loadingIndicator.internetError()
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
                            
                            self.loadingIndicator.hideIndicator(fast: true) { (_) in
                                self.message.showMessage(text: "Wrong password!", type: .error)
                            }
                            
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
                            let trans = wasTrans + appData.getTransactions
                            appData.saveTransations(trans, key: K.Keys.localTrancations)
                            let wascats = appData.getCategories(key: K.Keys.localCategories)
                            let cats = wascats + appData.getCategories()
                            var catResult: [CategoriesStruct] = []
                            for i in 0..<cats.count {
                                catResult.append(CategoriesStruct(name: cats[i].name, purpose: cats[i].purpose, count: cats[i].count))

                            }
                            let wasDebts = appData.getDebts() + appData.getDebts(key: K.Keys.localDebts)
                            appData.saveDebts(wasDebts, key: K.Keys.localDebts)
                            appData.saveCategories(catResult, key: K.Keys.localCategories)
                            appData.fromLoginVCMessage = trans.count > 0 ? "Wellcome, \(appData.username), \nYour Data has been saved localy" : "Wellcome, \(appData.username)"
                        }
                        needFullReload = true
                        if fromPro {
                            DispatchQueue.main.async {
                                self.loadingIndicator.hideIndicator(fast: false, title: "Login success") { (_) in
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.loadingIndicator.hideIndicator(fast: false, title: "Login success") { (_) in
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
                    
                    self.loadingIndicator.hideIndicator(fast: true) { (_) in
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
        DispatchQueue.main.async {
            self.loadingIndicator.show(showingAI: true, title: "Creating an account")
        }
        hideKeyboard()
        load.Users { (loadedData, Error) in
            if !Error {
                self.createAccoun(loadedData: loadedData)
            } else {
                self.actionButtonsEnabled = true
                DispatchQueue.main.async {
                    self.loadingIndicator.internetError()
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
                            DispatchQueue.main.async {

                                self.loadingIndicator.completeWithActions(buttonsTitles: (nil, "Try again"), rightButtonActon: { (_) in
                                    self.loadingIndicator.hideIndicator(fast: true) { (co) in
                                        self.emailLabel.becomeFirstResponder()
                                    }
                                }, title: "Enter valid email address", description: "With correct email address you could restore your password in the future", error: true)
                                
                                
                            }
                        } else {
                            let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate)"
                            save.Users(toDataString: toDataString) { (error) in
                                if error {
                                    print("error")
                                    DispatchQueue.main.async {
                                        self.loadingIndicator.internetError()
                                    }
                                } else {
                                    
                                    UserDefaults.standard.setValue(appData.username, forKey: "prevUserName")
                                    KeychainService.savePassword(service: "BudgetTrackerApp", account: name, data: password)
                                    appData.username = name
                                    appData.password = password
                                    let wasTransactions = appData.getTransactions + appData.getLocalTransactions
                                    appData.saveTransations(wasTransactions, key: K.Keys.localTrancations)
                                    let wasCats = appData.getCategories() + appData.getCategories(key: K.Keys.localCategories)
                                    var catResult: [CategoriesStruct] = []
                                    for i in 0..<wasCats.count {
                                        catResult.append(CategoriesStruct(name: wasCats[i].name, purpose: wasCats[i].purpose, count: wasCats[i].count))

                                    }
                                    appData.saveCategories(catResult, key: K.Keys.localCategories)
                                    let wasDebts = appData.getDebts() + appData.getDebts(key: K.Keys.localDebts)
                                    appData.saveDebts(wasDebts, key: K.Keys.localDebts)
                                    appData.fromLoginVCMessage = wasTransactions.count > 0 ? "Wellcome, \(appData.username), \nYour Data has been saved localy" : "Wellcome, \(appData.username)"
                                    needFullReload = true
                                    if self.fromPro {
                                        DispatchQueue.main.async {
                                            self.loadingIndicator.hideIndicator(fast: false, title: "Account created successfully") { (_) in
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {

                                            self.loadingIndicator.hideIndicator(fast: false, title: "Account created successfully") { (_) in
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

                            self.loadingIndicator.hideIndicator(fast: true) { (_) in
                                self.message.showMessage(text: "Username '\(name)' is already taken", type: .error, windowHeight: 65)
                                
                            }
                        }
                    }
                
                } else {
                    self.actionButtonsEnabled = true
                    self.obthervValues = true
                    self.showWrongFields()

                    DispatchQueue.main.async {
                        self.loadingIndicator.hideIndicator(fast: true) { (_) in
                            self.message.showMessage(text: "All fields are required", type: .error)
                        }
                    }
                    print("all fields are required")
                }
            } else {
                self.actionButtonsEnabled = true
                DispatchQueue.main.async {

                    self.loadingIndicator.hideIndicator(fast: true) { (_) in
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
                self.helperNavView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: safeArTopHeight)
                window.addSubview(self.helperNavView)
                self.message.hideMessage(duration: 0)
            }
        }
    }
    let helperNavView = UIView()
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
                            self.textfields[i].backgroundColor = !(self.emailLabel.text ?? "").contains("@") ? K.Colors.negative : K.Colors.loginColor
                        }
                    }
                }
                UIView.animate(withDuration: 0.3) {
                    self.textfields[i].backgroundColor = self.textfields[i].text == "" ? K.Colors.negative : K.Colors.loginColor
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
            textfields[i].backgroundColor = K.Colors.loginColor
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
    
    enum waitingFor {
        case newPassword
        case nickname
        case code
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
                            self.message.showMessage(text: "Password loaded from Keychain", type: .succsess, windowHeight: 65)
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




