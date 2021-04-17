//
//  LoginViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("username: \(appData.username)")
        print("localTransactions:", appData.transactions.count)
        updateUI()

        logoutButton.alpha = appData.username != "" ? 1 : 0

    }
    @IBAction func logoutPressed(_ sender: UIButton) {
        appData.username = ""
        appData.password = ""
        DispatchQueue.main.async {
            self.nicknameLogLabel.text = ""
            self.passwordLogLabel.text = ""
            self.performSegue(withIdentifier: "homeVC", sender: self)
            
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
        DispatchQueue.main.async {
            self.nicknameLogLabel.text = appData.username
            self.passwordLogLabel.text = appData.password
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(hideKeyboardGestureSwipe)
        }
        self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height * (-2), 0)
        self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height * (-2), 0)
        
        
    }

    
    let ai = UIActivityIndicatorView.init(style: .gray)
    
    
    func showActivityIndicator(at button: UIButton) {
        DispatchQueue.main.async {
            self.ai.frame = CGRect(x: 5, y: 5, width: 15, height: 15)
            button.addSubview(self.ai)
            self.ai.startAnimating()
        }
    }
    
    let load = LoadFromDB()
    @IBAction func logInPressed(_ sender: UIButton) {
        showActivityIndicator(at: sender)
        hideKeyboard()
        load.Users { (loadedData, Error) in
            if !Error {
                DispatchQueue.main.async {
                    let name = self.nicknameLogLabel.text ?? ""
                    let password = self.passwordLogLabel.text ?? ""
                    if name != "" && password != "" {
                        self.logIn(nickname: name, password: password, loadedData: loadedData)
                    } else {
                        DispatchQueue.main.async {
                            self.ai.removeFromSuperview()
                            self.message.showMessage(text: "All fields are required", type: .error, autoHide: false)
                        }
                        self.obthervValues = true
                        self.showWrongFields()
                    }
                }
            } else {
                print("error!!!")
                DispatchQueue.main.async {
                    self.ai.removeFromSuperview()
                    self.message.showMessage(text: "Internet Error!", type: .error, autoHide: false)
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
                        DispatchQueue.main.async {
                            self.ai.removeFromSuperview()
                            self.message.showMessage(text: "Wrong password", type: .error, autoHide: false)
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
                        
                        appData.username = nickname
                        appData.password = password
                        if prevUserName != nickname {
                            UserDefaults.standard.setValue(prevUserName, forKey: "prevUserName")
                            let wasTrans = appData.savedTransactions
                            let trans = wasTrans + appData.transactions
                            appData.saveTransations(trans, key: "savedTransactions")
                            let wascats = appData.getCategories(key: "savedCategories")
                            let cats = wascats + appData.getCategories()
                            var catResult: [CategoriesStruct] = []
                            for i in 0..<cats.count {
                                catResult.append(CategoriesStruct(name: cats[i].name, purpose: cats[i].purpose, count: cats[i].count, debt: cats[i].debt))

                            }
                            appData.saveCategories(catResult, key: "savedCategories")
                            appData.fromLoginVCMessage = trans.count > 0 ? "Wellcome, \(appData.username), \nYour Data has been saved localy" : "Wellcome, \(appData.username)"
                        }
                        if fromPro {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "homeVC", sender: self)
                            }
                        }
                        
                    }
                    return
                }
            }
        } else {
            DispatchQueue.main.async {
                self.ai.removeFromSuperview()
                self.message.showMessage(text: "User not found", type: .error, autoHide: false)
            }
        }
    }

    
    @IBAction func createAccountPressed(_ sender: Any) {
        showActivityIndicator(at: sender as! UIButton)
        hideKeyboard()
        load.Users { (loadedData, Error) in
            if !Error {
                self.createAccoun(loadedData: loadedData)
            } else {
                DispatchQueue.main.async {
                    self.ai.removeFromSuperview()
                    self.message.showMessage(text: "Internet Error!", type: .error, autoHide: false)
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
                        
                        if !email.contains("@") || !email.contains(".") {
                            self.ai.removeFromSuperview()
                            self.obthervValues = true
                            self.showWrongFields()
                            self.message.showMessage(text: "Enter valid email address", type: .error, autoHide: false)
                        } else {
                            let save = SaveToDB()
                            let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate)"
                            save.Users(toDataString: toDataString) { (error) in
                                if error {
                                    print("error")
                                    self.ai.removeFromSuperview()
                                    self.message.showMessage(text: "Internet Error!", type: .error, autoHide: false)
                                } else {
                                    UserDefaults.standard.setValue(appData.username, forKey: "prevUserName")
                                    KeychainService.savePassword(service: "BudgetTrackerApp", account: name, data: password)
                                    appData.username = name
                                    appData.password = password
                                    let wasTransactions = appData.transactions + appData.savedTransactions
                                    appData.saveTransations(wasTransactions, key: "savedTransactions")
                                    let wasCats = appData.getCategories() + appData.getCategories(key: "savedCategories")
                                    var catResult: [CategoriesStruct] = []
                                    for i in 0..<wasCats.count {
                                        catResult.append(CategoriesStruct(name: wasCats[i].name, purpose: wasCats[i].purpose, count: wasCats[i].count, debt: wasCats[i].debt))

                                    }
                                    appData.saveCategories(catResult, key: "savedCategories")
                                    appData.fromLoginVCMessage = wasTransactions.count > 0 ? "Wellcome, \(appData.username), \nYour Data has been saved localy" : "Wellcome, \(appData.username)"
                                    if self.fromPro {
                                        DispatchQueue.main.async {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "homeVC", sender: self)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.ai.removeFromSuperview()
                        self.message.showMessage(text: "Username '\(name)' is already taken", type: .error, windowHeight: 65, autoHide: false)
                        print("username '\(name)' is already taken")
                    }
                
                } else {
                    self.ai.removeFromSuperview()
                    self.obthervValues = true
                    self.showWrongFields()
                    self.message.showMessage(text: "All fields are required", type: .error, autoHide: false)
                    print("all fields are required")
                }
            } else {
                self.ai.removeFromSuperview()
                self.message.showMessage(text: "Passwords not match", type: .error, autoHide: false)
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
    
    var usernameHolder = ""
    override func viewWillDisappear(_ animated: Bool) {
        invalidateTimers()
        DispatchQueue.main.async {
            self.message.hideMessage(duration: 0)
        }
    }
    
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
                self.message.showMessage(text: message, type: .succsess, windowHeight: 65)
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
                        //here
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.3) {
                                self.view.layer.frame = CGRect(x: 0, y: dif - 20, width: self.view.layer.frame.width, height: self.view.layer.frame.height)
                            }
                        }
                    }
                }
            }
        }
    }
       
    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.layer.frame.minY != 0 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.view.layer.frame = CGRect(x: 0, y: 0, width: self.view.layer.frame.width, height: self.view.layer.frame.height)
                }
            }
        }
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
                    textField.endEditing(true)
                }
            }
            
        case emailLabel:
            if !(self.emailLabel.text ?? "").contains("@") || !(self.emailLabel.text ?? "").contains(".") {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Enter valid email address", type: .error, autoHide: false)
                    textField.endEditing(true)
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
                    textField.endEditing(true)
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
                            textField.endEditing(true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: "Repeat password", type: .error, autoHide: false)
                        textField.endEditing(true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Repeat password", type: .error, autoHide: false)
                    textField.endEditing(true)
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
                        textField.endEditing(true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Enter username", type: .error, autoHide: false)
                    textField.endEditing(true)
                }
            }
            
            
        case passwordLogLabel:
            if textField.text != "" {
                logInPressed(logInButton)
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Enter password!", type: .error, autoHide: false)
                    textField.endEditing(true)
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

//var difference: [TransactionsStruct] = []

/*var DBTransactions:[TransactionsStruct] {
// creating and using only in login - local vc
    get {
        let dick = appData.defaults.value(forKey: "DBTransactions") as? [[String]] ?? []
        var data: [TransactionsStruct] = []
        for i in 0..<dick.count {
            data.append(TransactionsStruct(value: dick[i][1], category: dick[i][2], date: dick[i][3], comment: dick[i][4]))
        }
        print("DBTransactions: called, count: \(data.count)")
        return data
    }
    
    set(dataStruct){
        var dick: [[String]] = []
        let datastr = Array(dataStruct)
        let nickname = appData.username
        
        for i in 0..<datastr.count {
            let nickname = nickname
            let value = datastr[i].value
            let category = datastr[i].category
            let date = datastr[i].date
            let comment = datastr[i].comment
            dick.append([nickname, value, category, date, comment])
        }

        
        print("DBTransactions: saved \(dick.count)")
        appData.defaults.set(dick, forKey: "DBTransactions")
    }
}*/
/*var DBCategories:[CategoriesStruct] {
    get {
        let dick = appData.defaults.value(forKey: "DBCategories") as? [[String]] ?? []
        var data: [CategoriesStruct] = []
        for i in 0..<dick.count {
            data.append(CategoriesStruct(name: dick[i][1], purpose: dick[i][2], count: 0, debt: dick[i][3]))
        }
        print("DBCategories: returned \(data.count)")
        return data
    }
    
    set(dataStruct){
        var dick: [[String]] = []
        
        for i in 0..<dataStruct.count {
            let nickname = appData.username
            let name = dataStruct[i].name
            let purpose = dataStruct[i].purpose
            dick.append([nickname, name, purpose])
        }
        print("DBCategories: saved \(dataStruct)")
        appData.defaults.set(dick, forKey: "DBCategories")
    }
}*/
