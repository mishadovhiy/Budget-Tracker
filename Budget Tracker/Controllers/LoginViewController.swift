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
        case logIn
        case singIn
    }
    var selectedScreen: screenType = .singIn
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadFromDB()
        print("username: \(appData.username)")
        updateUI()
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    func downloadFromDB() {
           
           appData.internetPresend = nil
           let load = LoadFromDB()
           load.Users(mainView: self) { (loadedData) in
               appData.allUsers = loadedData
           }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if keyboardHeight > 1.0 {
                
                if selectedScreen == .singIn {
                    UIView.animate(withDuration: 0.6) {
                        self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.createAcount.frame.minY * (-1) + 20, 0)
                    }
                } else {
                    UIView.animate(withDuration: 0.6) {
                        self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.logIn.frame.minY * (-1) + 20, 0)
                    }
                }
                UIView.animate(withDuration: 0.3) {
                    self.closeButton.alpha = 0
                }
                for i in 0..<titleLabels.count {
                    UIView.animate(withDuration: 0.2) {
                        self.titleLabels[i].textColor = K.Colors.balanceT
                    }
                }
                
            }
        }
        
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if selectedScreen == .singIn {
            UIView.animate(withDuration: 0.6) {
                self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
        } else {
            UIView.animate(withDuration: 0.6) {
                self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
        }
        UIView.animate(withDuration: 0.6) {
            self.closeButton.alpha = 1
        }
        for i in 0..<titleLabels.count {
            UIView.animate(withDuration: 0.2) {
                self.titleLabels[i].textColor = K.Colors.category
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
    
    func updateUI() {
        
        toggleScreen(options: selectedScreen, animation: 0)
        for i in 0..<textfields.count {
            textfields[i].delegate = self
            textfields[i].addTarget(self, action: #selector(textfieldValueChanged), for: .editingChanged)
            textfields[i].layer.masksToBounds = true
            textfields[i].layer.cornerRadius = 6
            textfields[i].setRightPaddingPoints(5)
            textfields[i].setLeftPaddingPoints(5)
        }
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(hideKeyboardGesture)
        let hideKeyboardGestureSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboardSwipped))
           hideKeyboardGestureSwipe.direction = .down
        view.addGestureRecognizer(hideKeyboardGestureSwipe)
        
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
            obthervValues = false
            for i in 0..<textfields.count {
                textfields[i].backgroundColor = K.Colors.loginColor
            }
            message.hideMessage()
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
            createOrLogLabel.text = "Don't have an account?"
            createOrLogButton.setTitle("Create", for: .normal)
            createOrLogButton.tag = 0
            
        case .singIn:
            obthervValues = false
            for i in 0..<textfields.count {
                textfields[i].backgroundColor = K.Colors.loginColor
            }
            message.hideMessage()
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
            createOrLogLabel.text = "Already have an account?"
            createOrLogButton.setTitle("Log in", for: .normal)
            createOrLogButton.tag = 1
        }
        
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
    
    @IBAction func logInPressed(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            self.downloadFromDB()
        }
        if appData.internetPresend != false {
            hideKeyboard()
            let name = nicknameLogLabel.text ?? ""
            let password = passwordLogLabel.text ?? ""
            
            if name != "" && password != "" {
                self.message.showMessage(text: "Checking data...", type: .succsess)
                logIn(nickname: name, password: password)
                
            } else {
                message.showMessage(text: "All fields are required", type: .staticError, windowHeight: 50)
                obthervValues = true
                showWrongFields()
            }
            
        }
        
        
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.downloadFromDB()
        }
     //   if appData.internetPresend != false {
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
                        self.message.showMessage(text: "Checking data...\nfor: \(name), \(name)", type: .succsess, windowHeight: 30)
                        appData.username = name
                        if appData.internetPresend != nil {
                            if (appData.internetPresend ?? false) {
                                appData.password = password
                                self.message.showMessage(text: "wellcome, \(name)", type: .succsess, windowHeight: 30)
                                
                                if appData.transactions.count > 0 {
                                    print(appData.transactions.count, "appData.transactions.count")
                                } else {
                                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (a) in
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "homeVC", sender: self)
                                        }
                                    }
                                }
                                
                                
                            } else {
                                appData.username = ""
                            }
                        }
                        
                        print("new user: \(name) has created")
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
            
      //  }
        
        
    }
    
    var obthervValues = false
    func showWrongFields() {
        
        UIView.animate(withDuration: 0.3) {
            for i in 0..<self.textfields.count {
                self.textfields[i].backgroundColor = self.textfields[i].text == "" ? K.Colors.negative : K.Colors.loginColor
            }
        }
        
    }
    
    var wrongPasswordCount = 0
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
                        self.message.showMessage(text: "Checking data...\nfor: \(nickname), \(nickname)", type: .succsess, windowHeight: 30)
                        appData.username = nickname
                        if appData.internetPresend != nil {
                            if (appData.internetPresend ?? false) {
                                appData.password = password
                                self.message.showMessage(text: "wellcome, \(nickname)", type: .succsess, windowHeight: 30)
                                if appData.transactions.count > 0 {
                                    print(appData.transactions.count, "appData.transactions.count")
                                } else {
                                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (a) in
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "homeVC", sender: self)
                                        }
                                    }
                                }
                            } else {
                                appData.username = ""
                            }
                        }
                        
                    }
                }
            }
        } else {
            message.showMessage(text: "user not found", type: .staticError, windowHeight: 50)
        }
    }
    
    func recetPassword(Nickname: String, Email: String, Registration_Date: String) {
        let newPassword = "1111"
        print(newPassword)
        message.showMessage(text: "we have updated your password\nYour new password: \(newPassword)", type: .succsess, windowHeight: 50)
        
        let save = SaveToDB()
        let toDataString = "&Nickname=\(Nickname)" + "&Email=\(Email)" + "&Password=\(newPassword)" + "&Registration_Date=\(Registration_Date)"
        save.NewPassword(toDataString: toDataString, mainView: self)
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
    
    func registration(nickname: String, email: String, password: String, registrationDate: String) {
        let save = SaveToDB()
        let toDataString = "&Nickname=\(nickname)" + "&Email=\(email)" + "&Password=\(password)" + "&Registration_Date=\(registrationDate)"
        save.Users(toDataString: toDataString, mainView: self)
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

}


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
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
