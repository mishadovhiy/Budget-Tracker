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


class LoginViewController: SuperViewController, UNUserNotificationCenterDelegate {

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
        center.delegate = self
      //  srlf.helperNavView.backgroundColor = K.Colors.background
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    @IBOutlet weak var moreButton: UIButton!
    var aai:UIActivityIndicatorView?
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        //foundUsername = nil
        DispatchQueue.main.async {
          //  self.loadingIndicator.show { _ in
            self.aai = UIActivityIndicatorView(frame: CGRect(x: self.moreButton.frame.width - self.moreButton.frame.height, y: 0, width: self.moreButton.frame.height, height: self.moreButton.frame.height))
            self.moreButton.addSubview(self.aai ?? UIView(frame: .zero))
            self.aai?.startAnimating()
            
            self.performSegue(withIdentifier: "toAccountSettings", sender: self)
          //  }
            
            /*let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            
            
            let forgotPassword = UIAlertAction(title: "Forgot password", style: .default, handler: { (_) in
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
                            self.loadingIndicator.completeWithActions(buttonsTitles: ("Cancel", "Send"), leftButtonActon: { (_) in
                                self.loadingIndicator.fastHide { (_) in
                                    
                                }
                            }, rightButtonActon: { (_) in
                                
                                self.sendRestorationCode(toChange: .changePassword)
                                
                            }, title: "Send code", description: "to change email we will have to send you a restoration code on email: \(emailToSend)", error: false)
                        }
                    }
                    
                }
                
            })
            
            
            
            let changePassword = UIAlertAction(title: "Change password", style: .default) { (ac) in
                //ask old password
                //if dont know- send code on nickname and change password
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
                
                
            }
            
            
            let changeEmail = UIAlertAction(title: "Change email", style: .default) { (ac) in
                //send code on old email
                //change email if true
                
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
                            self.loadingIndicator.completeWithActions(buttonsTitles: ("Cancel", "Send"), leftButtonActon: { (_) in
                                self.loadingIndicator.fastHide { (_) in
                                    
                                }
                            }, rightButtonActon: { (_) in
                                self.sendRestorationCode(toChange: .changeEmail)
                            }, title: "Send code", description: "to change email we will have to send you a restoration code on email: \(emailToSend)", error: false)
                        }
                    }
                    
                }
                
                
                
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
            self.present(alert, animated: true)*/
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toAccountSettings":
            
            let vc = segue.destination as! accountSettingsVC
            vc.tableTopMargin = self.view.frame.minY
            vc.delegate = self
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

        self.loadingIndicator.show(title: "Logging in") { (_) in
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
                                self.loadingIndicator.fastHide { _ in
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.loadingIndicator.fastHide { _ in
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

        self.loadingIndicator.show(title: "Creating an account") { (_) in
            self.hideKeyboard()
            self.load.Users { (loadedData, Error) in
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
                                            self.loadingIndicator.fastHide { _ in
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            
                                            self.loadingIndicator.fastHide { _ in
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
