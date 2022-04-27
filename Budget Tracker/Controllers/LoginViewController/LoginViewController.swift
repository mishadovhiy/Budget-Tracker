//
//  LoginViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class LoginViewController: SuperViewController {

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
        self.title = appData.username == "" ? "Sign In".localize : appData.username
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
        
        let resultTitle = title ?? (error ? "Error".localize : "Success".localize)
        
        DispatchQueue.main.async {
            self.ai.showAlertWithOK(title: resultTitle, text: text, error: error) { _ in
                if goToLogin {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
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
            let vc = segue.destination as! SelectValueVC
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

        let nickname =  self.forceLoggedOutUser != "" ? self.forceLoggedOutUser :  appData.username
        let password = appData.username == "" ? "" : appData.password
        DispatchQueue.main.async {
            self.nicknameLogLabel.text = nickname
            self.passwordLogLabel.text = password
            self.textFieldValuesDict.updateValue(nickname, forKey: "log.user")
            self.textFieldValuesDict.updateValue(password, forKey: "log.password")
            
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
        AppDelegate.shared?.banner.appeare(force: true)
        DispatchQueue.main.async {
            self.helperNavView?.removeFromSuperview()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        AppDelegate.shared?.banner.hide(ios13Hide: true)
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
                    let values = self.textFieldValuesDict
                    if let name = values["log.user"],
                       let password = values["log.password"] {
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
                                self.ai.fastHide()
                                
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
    

    func performLoggin(userData:[String]) {

        let nickname = userData[0]
        let password = userData[2]
        let email = userData[1]
        let isPro = userData[4]
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
        appData.userEmailHolder = email
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
            appData.proVersion = isPro == "1" ? true : appData.proVersion
        }
        if fromPro || self.forceLoggedOutUser != "" {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.ai.fastHide()
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
    
    
    
    func logIn(nickname: String, password: String, loadedData: [[String]]) {

        let checkPassword = LoadFromDB.checkPassword(from: loadedData, nickname: nickname, password: password)
        
        if let userExists = checkPassword.1 {
            let wrongPassword = checkPassword.0
            if !wrongPassword {
                performLoggin(userData: userExists)
            } else {
                self.actionButtonsEnabled = true
                let messageTitle = "Wrong".localize + " " + "password".localize
                DispatchQueue.main.async {
                    self.newMessage.show(title: messageTitle, type: .error)
                    self.ai.fastHide()
                }
            }
        } else {
            self.actionButtonsEnabled = true
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.newMessage.show(title: "User not found".localize, type: .error)
                    self.ai.fastHide()
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
                let window = AppDelegate.shared?.window ?? UIWindow()
                self.helperNavView?.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: appData.resultSafeArea.0)
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
                DispatchQueue.main.async {
                    let selectedTextfieldd = self.selectedScreen == .createAccount ? self.logIn : self.createAcount
                    let dif = self.view.frame.height - CGFloat(keyboardHeight) - ((selectedTextfieldd?.frame.maxY ?? 0) + 5)
                    if dif < 20 {
                            UIView.animate(withDuration: 0.3) {
                                if self.selectedScreen == .createAccount {
                                    self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif - 50, 0)
                                } else {
                                    if self.selectedScreen == .singIn {
                                        self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif - 50, 0)
                                    }
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










extension LoginViewController {
    func logout() {//logged out when log out when logout
        if !appData.purchasedOnThisDevice {
            appData.proVersion = false
            appData.proTrial = false
        }
        appData.username = ""
        appData.password = ""
        lastSelectedDate = nil
        AppData.categoriesHolder = nil
        UserDefaults.standard.setValue(nil, forKey: "lastSelected")

        DispatchQueue.main.async {
            self.title = "Sign In".localize
            self.passwordLabel.text = ""
            self.passwordLogLabel.text = ""
            self.nicknameLogLabel.text = ""
            self.ai.fastHide()
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
        textFieldValuesDict.updateValue(user, forKey: "log.user")
    }
    
    
}



extension LoginViewController {
    func userChanged() {
        actionButtonsEnabled = true
        appData.needFullReload = true
        lastSelectedDate = nil
        DispatchQueue.main.async {
            AppDelegate.shared?.center.removeAllPendingNotificationRequests()
            AppDelegate.shared?.center.removeAllDeliveredNotifications()
        }
        AppDelegate.shared?.notificationManager.deliveredNotificationIDs = []
        UserDefaults.standard.setValue(nil, forKey: "lastSelected")
        UserDefaults.standard.setValue(true, forKey: "checkTrialDate")
        UserDefaults.standard.setValue(false, forKey: "trialPressed")
        UserDefaults.standard.setValue(nil, forKey: "trialToExpireDays")
        appData.proTrial = false
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {//morepressed
        let data = MoreOptionsData(vc: self)
        appData.presentMoreVC(currentVC: self, data: data.get(), proIndex: 1)
        hideKeyboard()
    }
    
    
    
}