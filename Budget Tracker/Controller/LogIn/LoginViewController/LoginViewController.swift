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
    
    @IBOutlet weak var nicknameLabelCreate: BaseTextField!
    @IBOutlet weak var emailLabel: BaseTextField!
    @IBOutlet weak var passwordLabel: BaseTextField!
    @IBOutlet weak var confirmPasswordLabel: BaseTextField!
    
    @IBOutlet weak var nicknameLogLabel: BaseTextField!
    @IBOutlet weak var passwordLogLabel: BaseTextField!
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
        self.title = db.username == "" ? "Sign In".localize : db.username
        if db.username == "" {
            loadKeychainPasswords()
        }
    }
    
    var userEmail = ""
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let nik = db.username
        if nik != "" {
            let api = LoadFromDB()
            api.loadUsers { users, error in
                for i in 0..<(users?.count ?? 0) {
                    if users?[i][0] == nik {
                        self.userEmail = users?[i][1] ?? ""
                        return
                    }
                }
            }
        }
        self.additionalSafeAreaInsets.bottom = AppDelegate.properties?.banner.size ?? 0
    }
    
    func showAlert(title:String? = nil,text:String? = nil, error: Bool, goToLogin: Bool = false) {
        
        let resultTitle = title ?? (error ? "Error".localize : "Success".localize)
        endAnimating()
        DispatchQueue.main.async {
            self.ai?.showAlertWithOK(title: resultTitle, description: text, viewType: error ? .error : .standard, okPressed: {
                if goToLogin {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
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
        
        let nickname =  self.forceLoggedOutUser != "" ? self.forceLoggedOutUser :  db.username
        let password = db.username == "" ? "" : db.password
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
        //  AppDelegate.properties?.banner.appeare(force: true)
        DispatchQueue.main.async {
            self.helperNavView?.removeFromSuperview()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        //   AppDelegate.properties?.banner.hide(ios13Hide: true)
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
        
        LoadFromDB.shared.login(username: textFieldValuesDict["log.user"], password: textFieldValuesDict["log.password"], forceLoggedOutUser: forceLoggedOutUser, fromPro: fromPro) { type in
            switch type {
            case .userChanged:
                break
            case .users(let list):
                break
            case .enteredEmailUsers(let newUsers):
                self.enteredEmailUsers = newUsers
                if !newUsers.isEmpty {
                    DispatchQueue.main.async {
                        
                        SelectValueVC.presentScreen(in: self, with: [], structData: [
                            .init(sectionName: "Select User", cells: newUsers.compactMap({ apiUser in
                                    .init(name: apiUser, regular: .init(didSelect: {
                                        self.navigationController?.popViewController(animated: true)
                                        self.userSelected(user: apiUser)
                                    }))
                            }))
                        ], title: "User List")
                    }
                }
            case .hideAiDismiss(let goHome):
                DispatchQueue.main.async {
                    self.endAnimating()
                    if !goHome {
                        self.dismiss(animated: true) {
                            self.ai?.hide()
                        }
                    } else {
                        self.ai?.hide {
                            self.performSegue(withIdentifier: "homeVC", sender: self)
                        }
                    }
                    
                }
            case .result(let error, let scs):
                if error != nil || !(scs ?? false) {
                    self.actionButtonsEnabled = true
                    self.obthervValues = true
                    DispatchQueue.main.async {
                        self.newMessage?.show(title: (error ?? "Error login").localize, type: .error)
                        self.ai?.hide()
                        self.showWrongFields()
                    }
                } else {
                    
                }
            }
            print(type, " performLoginPressedperformLoginPressed")
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
        self.ai?.showLoading(title: "Logging in".localize) {
            self.hideKeyboard()
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performLoginPressed()
            }
        }
        
        
        
    }
    
    
    
    
    func endAnimating() {
        self.logInButton.stopAnimating()
        self.createAccButton.stopAnimating()
    }
    
    
    
    
    func showError(title:String) {
        endAnimating()
        self.newMessage?.show(title: title, type: .error)
        self.ai?.hide()
    }
    
    private func performCreateAccount() {
        LoadFromDB.shared.Users { (loadedData, Error) in
            if !Error {
                self.createAccoun(loadedData: loadedData)
            } else {
                self.actionButtonsEnabled = true
                DispatchQueue.main.async {
                    self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true, goToLogin: true)
                }
            }
        }
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        self.ai?.showLoading(title: "Creating".localize) {
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
                let window = UIApplication.shared.sceneKeyWindow ?? UIWindow()
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
        let maxCount = db.proVersion ? 15 : 3
        for i in 0..<loadedData.count {
            if loadedData[i][1] == email {
                count += 1
            }
        }
        
        return maxCount > count ? nil : (!db.proVersion ? .canUpdate : .totalError)
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









extension LoginViewController {
    func logout() {
        DispatchQueue(label: "local", qos: .userInitiated).async {
            if !(self.properties?.db.purchasedOnThisDevice ?? false) {
                self.properties?.db.proVersion = false
                self.properties?.db.proTrial = false
            }
            self.properties?.db.removeAll()
            self.properties?.appData.needFullReload = true
            DispatchQueue.main.async {
                self.title = "Sign In".localize
                self.passwordLabel.text = ""
                self.passwordLogLabel.text = ""
                self.nicknameLogLabel.text = ""
                self.ai?.hide() {
                    self.loadKeychainPasswords()
                }
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
        self.db.transactionDate = nil
        DispatchQueue.main.async {
            AppDelegate.properties?.center.removeAllPendingNotificationRequests()
            AppDelegate.properties?.center.removeAllDeliveredNotifications()
        }
        AppDelegate.properties?.notificationManager.deliveredNotificationIDs = []
        db.removeAll()
        db.proTrial = false
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {//morepressed
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let pro = self.properties?.db.proEnabeled
            DispatchQueue.main.async {
                let data = MoreOptionsData(vc: self)
                MoreVC.presentMoreVC(currentVC: self, data: data.get(isPro: self.properties?.db.proEnabeled ?? false), proIndex: 1)
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
