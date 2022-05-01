//
//  LoginViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
var needFullReload = false





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
            self.title = appData.username == "" ? "Sign In".localize : appData.username
        }
        
        
    }
    
    var userEmail = ""
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
    
    func showAlert(title:String? = nil,text:String? = nil, error: Bool, goToLogin: Bool = false) {
        
        let resultTitle = title == nil ? (error ? "Error".localize : "Success".localize) : title!
        
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
                    self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
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
            vc.titleText = "Select user".localize
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
    

    
    
    
    func updateUI() {
        toggleScreen(options: .createAccount, animation: 0.0)
        
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

        self.ai.show(title: "Logging in".localize) { (_) in
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
                                self.newMessage.show(title: "All fields are required".localize, type: .error)
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
                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                    }
                }
            }
        }
        
        
        
    }
    

    
    
    func logIn(nickname: String, password: String, loadedData: [[String]]) {
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
                            self.newMessage.show(title: messageTitle, type: .error)
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
                        appData.userEmailHolder = loadedData[i][DBEmailIndex]
                        if prevUserName != nickname {
                            userChanged()
                            UserDefaults.standard.setValue(prevUserName, forKey: "prevUserName")

                            if prevUserName == "" && forceLoggedOutUser == "" {
                                let db = DataBase()
                                db.localCategories = db.categories
                                db.localTransactions = db.transactions
                                
                            }
                            
                            if forceLoggedOutUser == "" {
                                appData.fromLoginVCMessage = "Wellcome".localize + ", \(appData.username)"
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
                    self.newMessage.show(title: "User not found".localize, type: .error)
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


        self.ai.show(title: "Creating".localize) { (_) in
            self.hideKeyboard()
            LoadFromDB.shared.Users { (loadedData, Error) in
                if !Error {
                    self.createAccoun(loadedData: loadedData)
                } else {
                    self.actionButtonsEnabled = true
                    DispatchQueue.main.async {
                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
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
                            
                            
                            let firstButton = IndicatorView.button(title: "Try again".localize, style: .standart, close: true) { _ in
                                self.emailLabel.becomeFirstResponder()
                            }
                            DispatchQueue.main.async {
                                self.ai.completeWithActions(buttons: (firstButton, nil), title: "Enter valid email address".localize, descriptionText: "With correct email address you could restore your password in the future".localize, type: .error)
                            }

                        } else {
                           // let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate)"
                            SaveToDB.shared.Users(toDataString: toDataString) { (error) in
                                if error {
                                    DispatchQueue.main.async {
                                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, goToLogin: true)
                                    }
                                } else {
                                    let prevUsere = appData.username
                                    UserDefaults.standard.setValue(prevUsere, forKey: "prevUserName")
                                    KeychainService.savePassword(service: "BudgetTrackerApp", account: name, data: password)
                                    appData.username = name
                                    appData.password = password
                                    appData.userEmailHolder = email
                                    if prevUsere == "" && self.forceLoggedOutUser == "" {
                                        let db = DataBase()
                                        db.localTransactions = db.transactions
                                        db.localCategories = db.categories
                                    }
                                    if self.forceLoggedOutUser == "" {
                                        appData.fromLoginVCMessage = "Wellcome".localize + ", \(appData.username)"
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
                                self.newMessage.show(title: "You have reached the maximum amount of usernames".localize, type: .error)
                            } else {
                                appData.presentBuyProVC(currentVC: self, selectedProduct: 2)
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                    self.newMessage.show(title: "You have reached the maximum amount of usernames".localize, description: "Update to Pro".localize + " " + "to create new username".localize, type: .standart)
                                }
                            }
                            
                        } else {
                            self.actionButtonsEnabled = true
                            DispatchQueue.main.async {
                                self.newMessage.show(title: "Username".localize + " '\(name)' " + "already exists".localize, type: .error)
                            }
                        }
                        
                    }
                
                } else {
                    self.actionButtonsEnabled = true
                    self.obthervValues = true
                    self.showWrongFields()

                  //  DispatchQueue.main.async {
                    self.newMessage.show(title: "All fields are required".localize, type: .error)
                        self.ai.hideIndicator(fast: true) { (_) in
                            
                        }
                 //   }
                  
                }
            } else {
                self.actionButtonsEnabled = true
         //       DispatchQueue.main.async {
                self.newMessage.show(title: "Passwords not match".localize, type: .error)
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
                self.createOrLogLabel.text = "Don't have an account".localize + "?"
                self.createOrLogButton.setTitle("Create".localize, for: .normal)
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
                self.createOrLogLabel.text = "Already have an account".localize + "?"
                self.createOrLogButton.setTitle("Log in".localize, for: .normal)
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
        return ["Create username".localize, "Enter your email".localize, "Create password".localize, "Confirm password".localize, "Username or email".localize, "Password".localize]
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
            self.title = "Sign In".localize
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



extension LoginViewController {
    func userChanged() {
        actionButtonsEnabled = true
        needFullReload = true
        lastSelectedDate = nil
        AppDelegate.shared!.center.removeAllPendingNotificationRequests()
        AppDelegate.shared!.center.removeAllDeliveredNotifications()
        appData.deliveredNotificationIDs = []
        UserDefaults.standard.setValue(nil, forKey: "lastSelected")
        UserDefaults.standard.setValue(true, forKey: "checkTrialDate")
        UserDefaults.standard.setValue(false, forKey: "trialPressed")
        UserDefaults.standard.setValue(nil, forKey: "trialToExpireDays")
        appData.proTrial = false
        _categoriesHolder.removeAll()
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {//morepressed
        let data = MoreOptionsData(vc: self)
        appData.presentMoreVC(currentVC: self, data: data.get(), proIndex: 1)
        hideKeyboard()
    }
    
    
    
}
