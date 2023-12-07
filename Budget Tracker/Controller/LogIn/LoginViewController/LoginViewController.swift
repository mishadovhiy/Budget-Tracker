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
    @IBOutlet weak var logInButton: LoadingButton!
    @IBOutlet weak var createAccButton: LoadingButton!
    
    @IBOutlet weak var nicknameLabelCreate: TextField!
    @IBOutlet weak var emailLabel: TextField!
    @IBOutlet weak var passwordLabel: TextField!
    @IBOutlet weak var confirmPasswordLabel: TextField!
    
    @IBOutlet weak var nicknameLogLabel: TextField!
    @IBOutlet weak var passwordLogLabel: TextField!
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
        if appData.username == "" {
            loadKeychainPasswords()
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
        self.additionalSafeAreaInsets.bottom = AppDelegate.shared?.banner.size ?? 0
    }
    
    func showAlert(title:String? = nil,text:String? = nil, error: Bool, goToLogin: Bool = false) {
        
        let resultTitle = title ?? (error ? "Error".localize : "Success".localize)
        endAnimating()
        DispatchQueue.main.async {
            self.ai?.showAlertWithOK(title: resultTitle, text: text, error: error) { _ in
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
        DispatchQueue(label: "api", qos: .userInitiated).async {
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
        case "toTransfareData":
            let vc = segue.destination as! CategoriesVC
            vc.screenType = .localData
            vc.transfaringCategories = transferingData
        default:
            break
        }
    }
    

    override func viewDidDismiss() {
        super.viewDidDismiss()
        removeKeyboardObthervers()
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
            var i = 0
            textfields.forEach({
                $0.delegate = self
                $0.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 6
                
                $0.setPaddings(5)
                $0.placeholder = self.placeHolder[i]
                $0.setPlaceHolderColor(K.Colors.textFieldPlaceholder)
                $0.tag = i
                self.textFieldToID.updateValue("\(i)", forKey: $0.accessibilityIdentifier ?? "")
                i += 1

            })
        }
        
    }
    
    var textFieldToID:[String:String] = [:]
    
    
    override func viewDidDisappear(_ animated: Bool) {
      //  AppDelegate.shared?.banner.appeare(force: true)
        DispatchQueue.main.async {
            self.helperNavView?.removeFromSuperview()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
     //   AppDelegate.shared?.banner.hide(ios13Hide: true)
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
    
    private func performLoginPressed() {
        
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
                        self.obthervValues = true
                        DispatchQueue.main.async {
                            self.newMessage?.show(title: "All fields are required".localize, type: .error)
                            self.ai?.fastHide()
                            self.showWrongFields()
                        }
                        
                        
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
    
    @IBAction func logInPressed(_ sender: UIButton) {
        print("LOGINPRESSED")
        transactionAdded = true
        actionButtonsEnabled = false
        
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }

        self.hideKeyboard()
        self.ai?.show(title: "Logging in".localize) { (_) in
            self.hideKeyboard()
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performLoginPressed()
            }
        }
        
        
        
    }
    

    func performLoggin(userData:[String]) {
        let nickname = userData[0]
        let password = userData[2]
        let email = userData[1]
        let isPro = userData[4]
        if let keycheinPassword = KeychainService.loadPassword(account: nickname) {
          //  if keycheinPassword != password {
                KeychainService.updatePassword(account: nickname, data: password)
           // }
        } else {
            KeychainService.savePassword(account: nickname, data: password)
        }
        let prevUserName = appData.username
        
        
        if prevUserName != nickname {
            let dat = (self.db.categories, self.db.transactions)
            userChanged()
            db.db.updateValue(prevUserName, forKey: "prevUserName")
            
            if prevUserName == "" && forceLoggedOutUser == "" {
                let db = AppDelegate.shared?.db ?? .init()
                db.localCategories = dat.0
                db.localTransactions = dat.1
                
            }
            
            if forceLoggedOutUser == "" {
                appData.fromLoginVCMessage = "Wellcome".localize + ", \(appData.username)"
            }
            
        }
        appData.username = nickname
        appData.password = password
        appData.userEmailHolder = email
        
        
        if !appData.purchasedOnThisDevice {
            appData.proVersion = isPro == "1" ? true : appData.proVersion
        }
        appData.needDownloadOnMainAppeare = true
        if fromPro || self.forceLoggedOutUser != "" {
            DispatchQueue.main.async {
                self.endAnimating()
                self.dismiss(animated: true) {
                    self.ai?.fastHide()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.endAnimating()
                self.ai?.fastHide { _ in
                    self.performSegue(withIdentifier: "homeVC", sender: self)
                }
            }

        }
    }
    
    
    func endAnimating() {
        self.logInButton.stopAnimating()
        self.createAccButton.stopAnimating()
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
                    self.showError(title: messageTitle)
                }
            }
        } else {
            self.actionButtonsEnabled = true
            DispatchQueue.main.async {
                self.showError(title: "User not found".localize)
            }
        }
        

    }

    
    func showError(title:String) {
        endAnimating()
        self.newMessage?.show(title: title, type: .error)
        self.ai?.fastHide()
    }
    
    private func performCreateAccount() {
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
    
    @IBAction func createAccountPressed(_ sender: Any) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }

        self.ai?.show(title: "Creating".localize) { (_) in
            self.hideKeyboard()

            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performCreateAccount()
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
        let usernameHolder = db.db["UsernameHolder"] as? String
        if usernameHolder != nil {
            db.db.removeValue(forKey: "UsernameHolder")
        }
        invalidateTimers()
        if fromSettings {
            DispatchQueue.main.async {
                let window = AppDelegate.shared?.window ?? UIWindow()
                self.helperNavView?.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: self.appData.resultSafeArea.0)
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
        endAnimating()
        textfields.forEach({ tf in
            if tf == self.emailLabel {
                if self.emailLabel.text != "" {
                    UIView.animate(withDuration: 0.3) {
                        tf.backgroundColor = !(self.emailLabel.text ?? "").contains("@") ? K.Colors.negative : .clear
                    }
                }
            }
            UIView.animate(withDuration: 0.3) {
                tf.backgroundColor = tf.text == "" ? K.Colors.negative : .clear
        
            }
        })
        
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
            textfields[i].backgroundColor = .clear
        }
        obthervValues = false
        
        hideKeyboard()
        if messagesFromOtherScreen != "" {
            let message = messagesFromOtherScreen
            messagesFromOtherScreen = ""
            DispatchQueue.main.async {
                self.newMessage?.show(title: message, type: .error)
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
                                    self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, (dif - 100), 0)
                                } else {
                                    if self.selectedScreen == .singIn {
                                        self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, (dif - 50), 0)
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
                    }
                }
                

            }
        }
    }

    
    @IBAction func emailUsersPressed(_ sender: UIButton) {
            let vc = SelectValueVC.configure()
        vc.delegate = self
        vc.tableData = [.init(sectionName: "", cells: enteredEmailUsers.compactMap({ apiUser in
            .init(name: apiUser, regular: .init(didSelect: {
                if let nav = self.navigationController{
                    nav.popViewController(animated: true)
                } else {
                    self.presentingViewController?.dismiss(animated: true)
                }
                self.userSelected(user: apiUser)
            }))
        }))]
        vc.titleText = "Select user".localize
        DispatchQueue.main.async {
            self.nicknameLogLabel.endEditing(true)
        }
        if let nav = self.navigationController{
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true)
        }
    }
    
    private func loadKeychainPasswords() {
        DispatchQueue(label: "db", qos: .userInitiated).async {
            if let keychain = KeychainService.loadUsers() {
                DispatchQueue.main.async {
                    self.enteredEmailUsers = keychain
                }
            }
        }
    }
}

// extentions










extension LoginViewController {
    func logout() {
        DispatchQueue(label: "local", qos: .userInitiated).async {
            if !self.appData.purchasedOnThisDevice {
                self.appData.proVersion = false
                self.appData.proTrial = false
            }
            self.appData.db.removeAll()
            self.appData.needFullReload = true
            DispatchQueue.main.async {
                self.title = "Sign In".localize
                self.passwordLabel.text = ""
                self.passwordLogLabel.text = ""
                self.nicknameLogLabel.text = ""
                self.ai?.fastHide(completionn: { _ in
                    self.loadKeychainPasswords()
                })
                //here
            }
        }
    }
    
    func dismissed() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.alpha = 1
            } 
        }
    }
}





extension LoginViewController: SelectUserVCDelegate {
    func selected(user: String) {
        userSelected(user: user)
    }
    
    func userSelected(user: String) {
        keyChainPassword(nick: user)
        nicknameLogLabel.text = user
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
        db.removeAll()
        appData.proTrial = false
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {//morepressed
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let pro = self.appData.proEnabeled
            DispatchQueue.main.async {
                let data = MoreOptionsData(vc: self)
                self.appData.presentMoreVC(currentVC: self, data: data.get(isPro: self.appData.proEnabeled), proIndex: 1)
                self.hideKeyboard()
            }
        }
    }
    
    
    
}

extension LoginViewController {
    static func configure() -> LoginViewController {
        let vc = UIStoryboard(name: "LogIn", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        return vc
        
    }
}
