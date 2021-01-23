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
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("username: \(appData.username)")
        print("localTransactions:", appData.transactions.count)
        
        updateUI()

    }
    
    func updateUI() {
        
        message.initMessage()

        selectedScreen = appData.username != "" ? .createAccount : .singIn
        toggleScreen(options: selectedScreen)
        for i in 0..<textfields.count {
            DispatchQueue.main.async {
                self.textfields[i].delegate = self
                self.textfields[i].addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
                self.textfields[i].layer.masksToBounds = true
                self.textfields[i].layer.cornerRadius = 6
            }
            
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
    
    
    let load = LoadFromDB()
    @IBAction func logInPressed(_ sender: UIButton) {
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
                            self.message.showMessage(text: "All fields are required", type: .staticError, windowHeight: 50)
                        }
                        self.obthervValues = true
                        self.showWrongFields()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Error!", type: .error)
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
                        print("wrong password")
                        DispatchQueue.main.async {
                            self.message.showMessage(text: "wrong password", type: .staticError, windowHeight: 50)
                        }
                    } else {
                        appData.username = nickname
                        appData.password = password
                        //save to unsaved indeed unsavedTransactions
                        appData.saveTransations(appData.transactions, key: "savedTransactions")
                        appData.fromLoginVCMessage = "Wellcome, \(appData.username)\n"
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "homeVC", sender: self)
                        }
                        print("to home")
                    }
                    return
                }
            }
        } else {
            DispatchQueue.main.async {
                self.message.showMessage(text: "user not found", type: .staticError, windowHeight: 50)
            }
        }
    }

    
    @IBAction func createAccountPressed(_ sender: Any) {
        hideKeyboard()
        load.Users { (loadedData, Error) in
            if !Error {
                self.createAccoun(loadedData: loadedData)
            } else {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Error!", type: .error)
                }
            }
        }
    }
    
    //test acc creating
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
                        let save = SaveToDB()
                        let toDataString = "&Nickname=\(name)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(regDate)"
                        save.Users(toDataString: toDataString) { (error) in
                            if error {
                                print("error")
                                self.message.showMessage(text: "Error!", type: .error)
                            } else {
                                appData.username = name
                                appData.password = password
                                let wasTransactions = appData.transactions
                                appData.unsavedTransactions = wasTransactions
                                appData.saveCategories(appData.getCategories(), key: "savedCategories")
                                appData.saveCategories([])
                                appData.fromLoginVCMessage = "Wellcome, \(appData.username)\n\(wasTransactions.count > 0 ? "\ndata has been saved localy" : "")"
                                print("to home")
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "homeVC", sender: self)
                                }
                                
                            }
                        }
                        
                    } else {
                        self.message.showMessage(text: "username '\(name)' is already taken", type: .staticError, windowHeight: 50)
                        print("username '\(name)' is already taken")
                    }
                
                } else {
                    self.obthervValues = true
                    self.showWrongFields()
                    self.message.showMessage(text: "all fields are required", type: .staticError, windowHeight: 50)
                    print("all fields are required")
                }
            } else {
                self.message.showMessage(text: "passwords not much", type: .staticError, windowHeight: 50)
                print("passwords not much")
            }
        }
    }

    func createDifference() {
        let localData = Array(appData.transactions)
        print("createDifference: local \(localData.count)")
        print("createDifference: db \(DBTransactionsLazy.count)")
        difference = []

        var diff = Array(difference)
        for i in 0..<localData.count {
            if !contains(localData[i]) {
                diff.append(localData[i])
                print("difference appended \(i)")
            }
        }
        
        print("createDifference: \(difference.count)")
        print("difference: \(difference)")
        print("localData: \(localData.count)")
        print("DBTransactions: \(DBTransactions.count)")
        appData.saveTransations(DBTransactions, key: "savedTransactions")
        
        if diff.count > 0 {
            print("would you like to store your local data in database or delete it?")
            difference = diff
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toLocalData", sender: self)
            }

        } else {
            appData.saveTransations(DBTransactions, key: "savedTransactions")
            DBTransactions = []
            DBCategories = []
            print("go to main")
            appData.fromLoginVCMessage = "Wellcome, \(appData.username)\n"
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "homeVC", sender: self)
            }
        }
        
    }
    lazy var DBTransactionsLazy = DBTransactions
    func contains(_ value: TransactionsStruct) -> Bool {
        var found: Bool?
        let dbData = Array(DBTransactions)
        
        for i in 0..<dbData.count {
            if value.comment == dbData[i].comment &&
                value.category == dbData[i].category &&
                value.date == dbData[i].date &&
                value.value == dbData[i].value {
                
                found = true
                return true
            }
        }
        
        if found == nil {
            return false
        } else {
            return found!
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
    
    override func viewWillDisappear(_ animated: Bool) {
        invalidateTimers()
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
                UIView.animate(withDuration: 0.3) {
                    self.textfields[i].backgroundColor = self.textfields[i].text == "" ? K.Colors.negative : K.Colors.loginColor
                }
            }
        }
        
    }
    
    
    @objc func hideKeyboardSwipped(_ sender: UISwipeGestureRecognizer? = nil) {
        hideKeyboard()
    }
    
    @IBAction func withoutAccount(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "homeVC", sender: self)
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
        message.hideMessage()
        hideKeyboard()
        
    }

    @IBAction func toggleScreen(_ sender: UIButton) {
        switch sender.tag {
        case 0: toggleScreen(options: .singIn)
        case 1: toggleScreen(options: .createAccount)
        default:
            toggleScreen(options: .createAccount)
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
            emailLabel.becomeFirstResponder()
        case emailLabel:
            passwordLabel.becomeFirstResponder()
        case passwordLabel:
            confirmPasswordLabel.becomeFirstResponder()
        case confirmPasswordLabel:
            createAccountPressed(createAccButton!)
            
        case nicknameLogLabel:
            passwordLogLabel.becomeFirstResponder()
        case passwordLogLabel:
            logInPressed(logInButton)
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

var difference: [TransactionsStruct] = []

var DBTransactions:[TransactionsStruct] {
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
}
var DBCategories:[CategoriesStruct] {
// creating and using only in login - local vc
    get {
        
        let dick = appData.defaults.value(forKey: "DBCategories") as? [[String]] ?? []
        var data: [CategoriesStruct] = []
        for i in 0..<dick.count {
            data.append(CategoriesStruct(name: dick[i][1], purpose: dick[i][2]))
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
}
