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


class LoginViewController: UIViewController {

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
        
    }
    
    var waitingType:waitingFor?
    
    var currectAnsware = ""
    
    func fortgotPaswordPressed() {
        let username = appData.username
        if username != "" {
            self.currectAnsware = ""
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
                self.ai.showIndicator()
            }
            
    
            DispatchQueue.init(label: "getEmail").async {
                
                let load = LoadFromDB()
                load.Users { (loadedData, error) in
                    if error {
                        DispatchQueue.main.async {
                            self.ai.fastHideIndicator { (_) in
                                self.message.showMessage(text: "No Internet!", type: .internetError)
                            }
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
                                    self.ai.fastHideIndicator { (_) in
                                        self.message.showMessage(text: "No Internet!", type: .internetError)
                                    }
                                }
                            } else {
                                self.currectAnsware = code
                                self.waitingType = .code
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "toEnterVC", sender: self)
                                }
                                
                            }
                        }
                    }
                }
            }
            
            
        } else {
            //wait for nickname
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
                self.ai.fastHideIndicator { (_) in
                    self.message.showMessage(text: "No Internet!", type: .internetError)
                }
            }
        } else {
            if result == "" {
                DispatchQueue.main.async {
                    self.ai.fastHideIndicator { (_) in
                        self.message.showMessage(text: "Username not found!", type: .internetError)
                    }
                }
            }
            
        }
        return result
        
        
    }
    
    //here
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            
            
            let forgotPassword = UIAlertAction(title: "Forgot password", style: .default, handler: { (_) in
                
                self.fortgotPaswordPressed()
            })
            
            
            
            let changePassword = UIAlertAction(title: "Change password", style: .default) { (ac) in
                
            }
            
            
            let changeEmail = UIAlertAction(title: "Change email", style: .default) { (ac) in
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toEnterVC":
            let vc = segue.destination as! enterValueVC
            vc.delegate = self
            switch waitingType {
            case .code:
                print("")
            default:
                break
            }
        default:
            break
        }
    }
    

    
    @IBAction func logoutPressed(_ sender: UIButton) {
        
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
        DispatchQueue.main.async {
            self.nicknameLogLabel.text = appData.username
            self.passwordLogLabel.text = appData.password
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
            self.ai = LoadingIndicator(superView: self.view)
            self.ai.showIndicator()
        }
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
                            self.ai.fastHideIndicator { (_) in
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
                    self.ai.completeWithDone(title: "Internet error", error: true) { (_) in
                        
                    }
                }
            }
        }
        
        
    }
    
    
    lazy var ai : LoadingIndicator = {
        return LoadingIndicator(superView: self.view)
    }()

    
    
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

                            self.ai.completeWithDone(title: "Wrong password", error: true) { (_) in
                                self.passwordLogLabel.becomeFirstResponder()
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
                                self.ai.hideIndicator(completionText: "success", hideAfter: 1.0) { (_) in
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.ai.hideIndicator(completionText: "success", hideAfter: 1.0) { (_) in
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
                    self.ai.completeWithDone(title: "User not found", error: true) { (_) in
                        
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
            self.ai.showIndicator(text: "Wait")
        }
        hideKeyboard()
        load.Users { (loadedData, Error) in
            if !Error {
                self.createAccoun(loadedData: loadedData)
            } else {
                self.actionButtonsEnabled = true
                DispatchQueue.main.async {
                    self.ai.completeWithDone(title: "Internet error", error: true) { (_) in
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
                                self.ai.completeWithDone(title: "Enter valid email address", error: true) { (_) in
                                }
                            }
                        } else {
                            let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate)"
                            save.Users(toDataString: toDataString) { (error) in
                                if error {
                                    print("error")
                                    DispatchQueue.main.async {
                                        self.ai.completeWithDone(title: "Internet error", error: true) { (_) in
                                        }
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
                                            self.ai.hideIndicator(completionText: "success", hideAfter: 1.0) { (_) in
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                            
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.ai.hideIndicator(completionText: "success", hideAfter: 1.0) { (_) in
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
                            self.ai.completeWithDone(title: "Username '\(name)' is already taken", error: true) { (_) in
                            }
                        }
                        print("username '\(name)' is already taken")
                    }
                
                } else {
                    self.actionButtonsEnabled = true
                    self.obthervValues = true
                    self.showWrongFields()

                    DispatchQueue.main.async {
                        self.ai.completeWithDone(title: "All fields are required", error: true) { (_) in
                        }
                    }
                    print("all fields are required")
                }
            } else {
                self.actionButtonsEnabled = true
                DispatchQueue.main.async {
                    self.ai.completeWithDone(title: "Passwords not match", error: true) { (_) in
                    }
                }
                print("passwords not much")
            }
        }
    }

      
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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



extension LoginViewController: enterValueVCProtocol {
    func hideScreen(close: Bool, value: String) {
        
        if !close {
            DispatchQueue.init(label: "getWaitingValue").async {
                var errorText = ""
                switch self.waitingType {
                case .code:
                    if value == self.currectAnsware {
                        //ask email
                        self.currectAnsware = ""
                        self.waitingType = .newPassword
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toEnterVC", sender: self)
                        }
                    } else {
                        errorText = "Wrong code!"
                    }
                case .newPassword:
                    print("new password")
                    //delete user with old password
                    //add user with new password
                //load users = save all user data as loaded
                //delete user where - loadedUserData
                //saveUser with new userData
                // if error not nil - show password has changed on all your devices - else - show message succsess password changed on this device and will be changed on other devices when you laung app when you connected to the internet
                    
                case .nickname:
                    errorText = "Nickname not found"
                default:
                    errorText = "Values didn't much"
                }
                if value != self.currectAnsware {
                    DispatchQueue.main.async {
                        self.ai.completeWithDone(title: errorText, error: true) { (_) in
                        }
                    }
                }
                
            }
            
        } else {
            DispatchQueue.main.async {
                self.ai.fastHideIndicator { (_) in
                    
                }
            }
        }

    }
    
    
}
