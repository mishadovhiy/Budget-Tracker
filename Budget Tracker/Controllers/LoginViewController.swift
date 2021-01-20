//
//  LoginViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

//sing in pressed
//if transCount > 0 save trans to savedData and loaded transactions > 0
//performing back show message - wellcome, username /n your data has been saved to another account

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
        case logIn
        case singIn
    }
    var selectedScreen: screenType = .logIn
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let new = TransactionsStruct(value: "\(Int.random(in: 0..<100000))", category: "dfgdgsdfsgerfweewf", date: "23.11.2024", comment: "mac")
        let new1 = TransactionsStruct(value: "\(Int.random(in: 0..<90000))", category: "nil", date: "23.11.2024", comment: "mac")
        var allData = appData.transactions
        allData.append(new)
        allData.append(new1)
        appData.saveTransations(allData)
        appData.username = ""
        print("username: \(appData.username)")
        print("localTransactions:", appData.transactions.count)
        
        updateUI()
        

    }
    
    func updateUI() {
        
        message.initMessage()
        downloadFromDB()
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
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTapped))
        let hideKeyboardGestureSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboardSwipped))
           hideKeyboardGestureSwipe.direction = .down
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(hideKeyboardGesture)
            self.view.addGestureRecognizer(hideKeyboardGestureSwipe)
        }
        self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height * (-2), 0)
        self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height * (-2), 0)
        
        
    }
    
    func downloadFromDB() {
           
        appData.internetPresend = nil
        let load = LoadFromDB()
        load.Users(mainView: nil) { (loadedData) in
            appData.allUsers = loadedData
        }
        
        if appData.username != "" {
            load.Transactions(mainView: nil) { (loadedData, error)  in
                if error == "" {
                    var dataStruct: [TransactionsStruct] = []
                    for i in 0..<loadedData.count {
                        
                        let value = loadedData[i][3]
                        let category = loadedData[i][1]
                        let date = loadedData[i][2]
                        let comment = loadedData[i][4]
                        dataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                    }
                    DBTransactions = dataStruct
                } else {
                    print("error loading data")
                }
            }
            
            load.Categories(mainView: nil) { (loadedData) in
                var dataStruct: [CategoriesStruct] = []
                for i in 0..<loadedData.count {
                    let name = loadedData[i][1]
                    let purpose = loadedData[i][2]
                    dataStruct.append(CategoriesStruct(name: name, purpose: purpose))
                }
                DBCategories = dataStruct
            }
        }
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        
        downloadFromDB()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (action) in
            if appData.internetPresend != nil {
                if appData.internetPresend == false {
                    self.message.showMessage(text: "No internet", type: .staticError, windowHeight: 50)
                    action.invalidate()
                }
                if appData.internetPresend == true {
                    self.hideKeyboard()
                    let name = self.nicknameLogLabel.text ?? ""
                    let password = self.passwordLogLabel.text ?? ""
                    
                    if name != "" && password != "" {
                        self.logIn(nickname: name, password: password)
                        
                    } else {
                        self.message.showMessage(text: "All fields are required", type: .staticError, windowHeight: 50)
                        self.obthervValues = true
                        self.showWrongFields()
                    }
                    action.invalidate()
                }
            }
        }
        
    }
    
    
    
    func logIn(nickname: String, password: String) {
        
        print(appData.allUsers)

        let DBusernameIndex = 0
        let DBemailIndex = 1
        let DBpasswordIndex = 2
        let DBRegDateIndex = 3
            
        var psswordFromDB = ""
        var emailFromDB = ""
        var registrationDateFromDB = ""
            
        if userExists(name: nickname) {
            for i in 0..<appData.allUsers.count {
                if appData.allUsers[i][DBusernameIndex] == nickname {
                    psswordFromDB = appData.allUsers[i][DBpasswordIndex]
                    emailFromDB = appData.allUsers[i][DBemailIndex]
                    registrationDateFromDB = appData.allUsers[i][DBRegDateIndex]
                    print("user's password is ", psswordFromDB, "\nuser's email is - ", emailFromDB)
                    
                    if password != psswordFromDB {
                        if self.wrongPasswordCount < 3 {
                            self.wrongPasswordCount += 1
                            self.message.showMessage(text: "wrong password \nYou have \(4 - self.wrongPasswordCount) attemps", type: .staticError, windowHeight: 50)
                                    
                        } else {
                            self.message.showMessage(text: "reseting password..", type: .staticError, windowHeight: 30)
                            self.recetPassword(Nickname: nickname, Email: emailFromDB, Registration_Date: registrationDateFromDB)
                            self.wrongPasswordCount = 0
                        }
                    
                    } else {
                        appData.username = nickname
                        appData.password = password
                        performLoging(nickname: nickname, password: password)
                        
                    }
                }
            }
        } else {
            message.showMessage(text: "user not found", type: .staticError, windowHeight: 50)
        }
    }

    @IBAction func createAccountPressed(_ sender: Any) {
        
        downloadFromDB()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (action) in
            if appData.internetPresend != nil {
                if appData.internetPresend == true {
                    self.createAccoun()
                    action.invalidate()
                }
                if appData.internetPresend == false {
                    self.message.showMessage(text: "no internet", type: .error)
                    action.invalidate()
                }
            }
            
        }
        
        
    }
    
    func createAccoun() {
        hideKeyboard()
        let name = nicknameLabelCreate.text ?? ""
        let email = emailLabel.text ?? ""
        let password = passwordLabel.text ?? ""
        let regDate = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        
        print("createAccountPressed")
        
        if password == confirmPasswordLabel.text ?? "" {
            if name != "" && email != "" && password != "" {
                if userExists(name: name) == false  {
                    
                    appData.username = name
                    appData.password = password
                    performRegistration(nickname: name, email: email, password: password, registrationDate: regDate)
                    
                } else {
                    message.showMessage(text: "username '\(name)' is already taken", type: .staticError, windowHeight: 50)
                    print("username '\(name)' is already taken")
                }
            
            } else {
                obthervValues = true
                showWrongFields()
                message.showMessage(text: "all fields are required", type: .staticError, windowHeight: 50)
                print("all fields are required")
            }
        } else {
            message.showMessage(text: "passwords not much", type: .staticError, windowHeight: 50)
            print("passwords not much")
        }
    }
    
    func performRegistration(nickname: String, email: String, password: String, registrationDate: String) {
        appData.internetPresend = nil
        downloadFromDB()
        DispatchQueue.main.async {
            self.message.showMessage(text: "Checking data...", type: .succsess)
        }
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (a) in
            
            print("performLoging: timer called")
            if appData.internetPresend == true {
                a.invalidate()
                
                print("performLoging: internet true")
                
                self.registration(nickname: nickname, email: email, password: password, registrationDate: registrationDate)
                
                difference = appData.transactions
                if difference.count > 0 {
                    print("would you like to store your local data in database or delete it?")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toLocalData", sender: self)
                    }

                } else {
                    DBTransactions = []
                    DBCategories = []
                    print("go to main")
                }
                
            }
            if appData.internetPresend == false {
                appData.username = ""
                appData.password = ""
                a.invalidate()
                print("performLoging: internet false")
                DispatchQueue.main.async {
                    self.message.showMessage(text: "no internet", type: .error)
                }
            }
        }
        timers.append(timer)
    }
    
    func performLoging(nickname: String, password: String) {
        appData.internetPresend = nil
        downloadFromDB()
        DispatchQueue.main.async {
            self.message.showMessage(text: "Checking data...", type: .succsess)
        }
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (a) in
            
            print("performLoging: timer called")
            if appData.internetPresend == true {
                a.invalidate()
                print("performLoging: local: \(appData.transactions.count), DB: \(DBTransactions.count)")
                self.createDifference()
                
            }
            if appData.internetPresend == false {
                appData.username = ""
                appData.password = ""
                a.invalidate()
                print("performLoging: internet false")
                DispatchQueue.main.async {
                    self.message.showMessage(text: "no internet", type: .error)
                }
            }
        }
        timers.append(timer)
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
        
        if diff.count > 0 {
            print("would you like to store your local data in database or delete it?")
            difference = diff
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toLocalData", sender: self)
            }

        } else {
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
    
    func registration(nickname: String, email: String, password: String, registrationDate: String) {
        let save = SaveToDB()
        let toDataString = "&Nickname=\(nickname)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(registrationDate)"
    //    save.Users(toDataString: toDataString, mainView: self)
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
    
    func userExists(name: String) -> Bool {
        var userExists = false
        
        for i in 0..<appData.allUsers.count {
            if appData.allUsers[i][0] == name {
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
    
    var wrongPasswordCount = 0
    
    func recetPassword(Nickname: String, Email: String, Registration_Date: String) {
        let newPassword = "1111"
        print(newPassword)
        message.showMessage(text: "we have updated your password\nYour new password: \(newPassword)", type: .succsess, windowHeight: 50)
        
        let save = SaveToDB()
        let toDataString = "&Nickname=\(Nickname)" + "&Email=\(Email)" + "&Password=\(newPassword)" + "&Registration_Date=\(Registration_Date)"
        //save.NewPassword(toDataString: toDataString, mainView: self)
    }
    
    @objc func hideKeyboardSwipped(_ sender: UISwipeGestureRecognizer? = nil) {
        hideKeyboard()
    }
    
    @objc func hideKeyboardTapped(_ sender: UITapGestureRecognizer? = nil) {
        hideKeyboard()
    }
    
    @IBAction func withoutAccount(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "homeVC", sender: self)
        }
    }
    func hideKeyboard() {
        
        for i in 0..<textfields.count {
            textfields[i].endEditing(true)
        }
    }
    
    func toggleScreen(options: screenType, animation: TimeInterval = 0.6) {
        
        let bounds = UIScreen.main.bounds
        let height = bounds.height
        let secondAnimation = animation == 0 ? 0 : animation - 0.4
        let thirdAnimation = animation == 0 ? 0 : animation + 0.5
        selectedScreen = options

        switch options {
        case .logIn:
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
        case 0:
            toggleScreen(options: .singIn)
        case 1:
            toggleScreen(options: .logIn)
        default:
            toggleScreen(options: .logIn)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if selectedScreen == .singIn {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.createAcount.frame.minY * (-1) + 40, 0)
                }
            }
            
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.logIn.frame.minY * (-1) + 40, 0)
                }
            }
        }
        
        for i in 0..<self.titleLabels.count {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.6) {
                    self.titleLabels[i].textColor = K.Colors.balanceT
                }
            }
        }
    }
       
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if selectedScreen == .singIn {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                }
            }
            
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                }
            }
            
        }
        
        for i in 0..<titleLabels.count {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.6) {
                    self.titleLabels[i].textColor = K.Colors.category
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
