//
//  LoginViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var createOrLogLabel: UILabel!
    @IBOutlet weak var createOrLogButton: UIButton!
    @IBOutlet weak var logIn: UIStackView!
    @IBOutlet weak var createAcount: UIStackView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var createAccButton: UIButton!
    
    @IBOutlet weak var nicknameLabelCreate: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UITextField!
    
    @IBOutlet weak var nicknameLogLabel: UITextField!
    @IBOutlet weak var passwordLogLabel: UITextField!
    
    var canUseThisName: Bool = true
    enum screenType {
        case logIn
        case singIn
    }
    var selectedScreen: screenType = .singIn
    var allUsers:[[String]] = []
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if no internet
        //u cant create an account now, plese come back when you'll be connected to the internet and try again later
        
        message.initMessage()
        print("username: \(appData.username)")
        let load = LoadFromDB()
        load.Users(mainView: self) { (data) in
            print(data, "allusers")
            for i in 0..<data.count {
                self.allUsers.append([data[i][0], data[i][1], data[i][2], data[i][3]])
            }
        }
        updateUI()

    }

    var textfields: [UITextField] {
        return [nicknameLabelCreate, emailLabel, passwordLabel, confirmPasswordLabel, nicknameLogLabel, passwordLogLabel]
    }
    
    func updateUI() {
        
        toggleScreen(options: selectedScreen, animation: 0)
        for i in 0..<textfields.count {
            textfields[i].delegate = self
            textfields[i].addTarget(self, action: #selector(textfieldValueChanged), for: .editingChanged)
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
    
    @objc func textfieldValueChanged(_ textField: UITextField) {
        message.hideMessage()
        if obthervValues {
            showWrongFields()
        }
    }
    
    func toggleScreen(options: screenType, animation: TimeInterval = 0.6) {
        
        let bounds = UIScreen.main.bounds
        let height = bounds.height
        
        switch options {
        case .logIn:
            obthervValues = false
            for i in 0..<textfields.count {
                textfields[i].backgroundColor = K.Colors.background
            }
            message.hideMessage()
            UIView.animate(withDuration: animation) {
                self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, height * (-2), 0)
                self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
            createOrLogLabel.text = "Don't have an account?"
            createOrLogButton.setTitle("Create", for: .normal)
            createOrLogButton.tag = 0
            
        case .singIn:
            obthervValues = false
            for i in 0..<textfields.count {
                textfields[i].backgroundColor = K.Colors.background
            }
            message.hideMessage()
            UIView.animate(withDuration: animation) {
                self.createAcount.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                self.logIn.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, height * (2), 0)
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
        
        hideKeyboard()
        let name = nicknameLogLabel.text ?? ""
        let password = passwordLogLabel.text ?? ""
        
        if name != "" && password != "" {
            logIn(nickname: name, password: password)
        } else {
            message.showMessage(text: "All fields are required", type: .staticError, windowHeight: 50)
            obthervValues = true
            showWrongFields()
        }
        
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        
        hideKeyboard()
        let name = nicknameLabelCreate.text ?? ""
        let email = emailLabel.text ?? ""
        let password = passwordLabel.text ?? ""
        let regDate = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        
        print("createAccountPressed")
        
        if password == confirmPasswordLabel.text ?? "" {
            if name != "" && email != "" && password != "" {
                if userExists(name: name) == false  {
                    registration(nickname: name, email: email, password: password, registrationDate: regDate)
                    appData.username = name
                    appData.password = password
                    self.message.showMessage(text: "new user: \(name) has created", type: .succsess)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "homeVC", sender: self)
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
    }
    
    var obthervValues = false
    func showWrongFields() {
        
        UIView.animate(withDuration: 0.3) {
            for i in 0..<self.textfields.count {
                self.textfields[i].backgroundColor = self.textfields[i].text == "" ? K.Colors.negative : K.Colors.background
            }
        }
        
    }
    
    var wrongPasswordCount = 0
    func logIn(nickname: String, password: String) {
        
        print(allUsers)

        let DBusernameIndex = 0
        let DBemailIndex = 1
        let DBpasswordIndex = 2
        let DBRegDateIndex = 3
            
        var psswordFromDB = ""
        var emailFromDB = ""
        var registrationDateFromDB = ""
            
        
        if userExists(name: nickname) {
            for i in 0..<allUsers.count {
                if allUsers[i][DBusernameIndex] == nickname {
                    psswordFromDB = allUsers[i][DBpasswordIndex]
                    emailFromDB = allUsers[i][DBemailIndex]
                    registrationDateFromDB = allUsers[i][DBRegDateIndex]
                    print("user's password is ", psswordFromDB, "\nuser's email is - ", emailFromDB)
                    
                    if password != psswordFromDB {
                        if self.wrongPasswordCount < 3 {
                            self.wrongPasswordCount += 1
                            DispatchQueue.main.async {
                                self.message.showMessage(text: "wrong password \nYou have \(4 - self.wrongPasswordCount) attemps", type: .staticError, windowHeight: 50)
                            }
                                    
                        } else {
                            self.message.showMessage(text: "reseting password..", type: .staticError, windowHeight: 30)
                            self.recetPassword(Nickname: nickname, Email: emailFromDB, Registration_Date: registrationDateFromDB)
                            self.wrongPasswordCount = 0
                        }
                    
                    } else {
                        appData.username = nickname
                        appData.password = password
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "homeVC", sender: self)
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
        
        for i in 0..<allUsers.count {
            if allUsers[i][0] == name {
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
        performSegue(withIdentifier: "homeVC", sender: self)
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
