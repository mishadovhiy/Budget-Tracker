//
//  IndicatorView.swift
//  POSTSD_Enterprice
//
//  Created by Mikhailo Dovhyi on 20.07.2021.
//  Copyright © 2021 Victor Havinskiy. All rights reserved.
//

import UIKit

class IndicatorView: UIView {
    
    @IBOutlet weak var backgroundHelper: UIView!
    @IBOutlet weak var userDataStack: UIStackView!
    @IBOutlet weak var actionsStack: UIStackView!
    @IBOutlet private weak var additionalDoneButton: UIButton!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    //@IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    @IBOutlet private weak var aiSuperView: UIView!
    @IBOutlet private weak var ai: UIActivityIndicatorView!
    
    @IBOutlet weak var repeatePasswordTextField: UITextField!
    
    var canCloseOnSwipe = false
    var isShowing = false
    private var textFields: [UITextField] = []
    var drawed: Bool = false
    override func draw(_ rect: CGRect) {
        print("indicatorView draw")
        if drawed {
            print("")
            return
        } else {
            drawed = true
        }
        DispatchQueue.main.async {
           // self.alpha = 0

            NotificationCenter.default.addObserver( self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver( self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            self.textFields = [self.textField, self.repeatePasswordTextField]
          //  self.setAllHidden()
            for textField in self.textFields {
                textField.delegate = self
                textField.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
            }

            //self.mainViewShadow.layer.cornerRadius = 6
            //self.mainViewShadow.layer.shadowColor = UIColor.black.cgColor
            //self.mainViewShadow.layer.shadowOpacity = 0.3
            //self.mainViewShadow.layer.shadowOffset = .zero
            //self.mainViewShadow.layer.shadowRadius = 6
         //   self.closeButton.layer.zPosition = 100
            self.rightButton.layer.cornerRadius = 6
            self.leftButton.layer.cornerRadius = 6
            self.mainView.layer.cornerRadius = 6
            self.mainView.layer.shadowColor = UIColor.black.cgColor
            self.mainView.layer.shadowOpacity = 0.3
            self.mainView.layer.shadowOffset = .zero
            self.mainView.layer.shadowRadius = 6

            self.mainView.layer.shadowPath = UIBezierPath(rect: self.mainView.bounds).cgPath
           /* self.leftButton.layer.shadowPath = UIBezierPath(rect: self.leftButton.bounds).cgPath
            self.rightButton.layer.shadowPath = UIBezierPath(rect: self.rightButton.bounds).cgPath
            self.mainViewShadow.layer.shadowPath = UIBezierPath(rect: self.mainViewShadow.bounds).cgPath*/
          //  self.rightButton.layer.masksToBounds = true
          //  self.leftButton.layer.masksToBounds = true
            self.mainView.layer.masksToBounds = true
            self.normalTitleSize = self.titleLabel.font
         //   self.ai.stopAnimating()
            
        }
    }
    
    
    
    
    
    func show(showingAI: Bool = true, title: String? = "Loading", description: String? = nil, appeareAnimation: Bool = false, attention: Bool = false, completion: @escaping (Bool) -> ()) {
    //    DispatchQueue.global().async {
        
        DispatchQueue.init(label: "\(#function)", qos: .userInteractive).async {
            
        
            if !self.hideIndicatorBlockDesibled {
            print("block")
            return
        }
    /*    DispatchQueue.main.sync {
            self.setAllHidden()
        }*/
            if !self.isShowing {
                self.isShowing = true
        }
            self.canCloseOnSwipe = false
            self.viewType = .ai
    
            let hideTitle = title == nil ? true : false
            let hideDescription = (description == "" || description == nil) ? true : false
            DispatchQueue.main.sync {
                
            
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            self.frame = window.frame
            window.addSubview(self)
            self.alpha = 1
            self.backgroundView.alpha = 1
            self.backgroundHelper.alpha = 1
                if self.isHidden {
                    self.isHidden = false
                }
            
            self.titleLabel.text = title
            self.descriptionLabel.text = description
            self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                if !self.actionsStack.isHidden {
                    self.actionsStack.isHidden = true
                }
            
            

            self.ai.startAnimating()
            UIView.animate(withDuration: appeareAnimation ? 0.25 : 0) {
                if self.titleLabel.isHidden != hideTitle {
                    self.titleLabel.isHidden = hideTitle
                }
                if self.descriptionLabel.isHidden != hideDescription {
                    self.descriptionLabel.isHidden = hideDescription
                }
                if self.aiSuperView.isHidden {
                    self.aiSuperView.isHidden = false
                }
                
                //showingAI ? false : true
            } completion: { (_) in
                UIView.animate(withDuration: 0.15) {
                    
                    self.backgroundView.backgroundColor = attention ? self.accentBackgroundColor : self.normalBackgroundColor
                    self.backgroundHelper.backgroundColor = attention ? self.accentBackgroundColor : self.normalBackgroundColor
                    self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (_) in
                  //  DispatchQueue.main.async {
                       // self.aiSuperView.isHidden = false
                        self.aiSuperView.layoutIfNeeded()
                        print("jbgyuiknvghjkmnbghjk")
                        print(self.aiSuperView.isHidden)
                        print("jbgyuiknvghjkmnbghjk end")
                   // }
                    completion(true)
                   
                    
                }
            }

      //  }
    //    }
            }
        }
    }

    
  /*  func internetError() {
        canCloseOnSwipe = true
        completeWithActions(buttonsTitles: (nil, "OK"), rightButtonActon: { (_) in
            self.hideIndicator(fast: true) { (co) in
                
            }
        }, title: "No internet", description: "Try again later", error: true)
    }*/
    
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    func hideIndicator(fast: Bool = false, title: String? = nil, hideAfter: Int = 2, completion: @escaping (Bool) -> ()) {
        if !hideIndicatorBlockDesibled {
            print(hideIndicatorBlockDesibled)
            return
        }
        fastHide(completionn: completion)
       // fastHide(completion: completion)
      /*  if !fast {
        //    canCloseOnSwipe = true
            DispatchQueue.main.async {
                self.titleLabel.isHidden = false
                self.titleLabel.text = title
              //  self.titleLabel.font = .systemFont(ofSize: 21, weight: .medium)
                UIView.animate(withDuration: 0.15) {
                    self.titleLabel.isHidden = title == nil ? true : false
                    self.descriptionLabel.isHidden = true
                    self.aiSuperView.isHidden = true
                    self.backgroundView.backgroundColor = self.normalBackgroundColor
                    self.backgroundHelper.backgroundColor = self.normalBackgroundColor
                } completion: { (_) in
                    self.ai.stopAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(hideAfter)) {
                        self.fastHide(completionn: completion)
                    }
                }

            }
        } else {
            fastHide(completionn: completion)
        }*/
    }

    //@IBOutlet weak var mainViewShadow: UIView!
    
    @IBOutlet weak var tableSecondTitle: UILabel!
    struct button {
        let title: String
        var style: ButtonType
        var close: Bool = true
        let action: (Bool) -> ()
    }
    
    
    
    
    private var _viewType:ViewType = .standard
    private var viewType: ViewType {
        get {
            return _viewType
        }
        set {
            DispatchQueue.main.async {
                if !(self.imageView.superview?.isHidden ?? false) {
                    self.imageView.superview?.isHidden = true
                }
                
                switch newValue {
                case .error:
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.image = UIImage(named: "warning")
                        self.mainView.layer.shadowOpacity = 0.9
                        self.titleLabel.font = .systemFont(ofSize: 32, weight: .bold)

                        //self.mainView.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.9)
                        if self.imageView.superview?.isHidden != false {
                            self.imageView.superview?.isHidden = false
                        }
                        

                        
                        self.backgroundView.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.8)
                        self.backgroundHelper.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.8)
                    } completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                            self.backgroundHelper.backgroundColor = self.accentBackgroundColor
                            self.backgroundView.backgroundColor = self.accentBackgroundColor
                        }
                    }

                    

                case .standardError, .standard:
                    let hideImage = newValue == .standardError ? false : true
                    if newValue == .standardError {
                        self.imageView.image = UIImage(named: "warning")
                    }
                    if self.imageView.superview?.isHidden != true {
                        self.imageView.superview?.isHidden = true
                    }
                    
                    
                    self.titleLabel.font = newValue == .standardError ? self.errorFont : self.normalTitleSize //systemFont(ofSize: newValue == .standardError ? 32 : 28, weight: .bold)
                   // self.mainView.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.9)
                    
                    
                    UIView.animate(withDuration: 0.3) {
                        self.mainView.layer.shadowOpacity = 0.9
                        if self.imageView.superview?.isHidden != hideImage {
                            self.imageView.superview?.isHidden = hideImage
                        }
                        
                        self.backgroundHelper.backgroundColor = self.accentBackgroundColor
                        self.backgroundView.backgroundColor = self.accentBackgroundColor
                    }
                case .ai:
                    self.leftButton.layer.shadowOpacity = 0
                    self.mainView.layer.shadowOpacity = 0.3
                   // self.titleLabel.font = .systemFont(ofSize: 23, weight: .regular)
                    //self.mainView.backgroundColor = .black//UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.1)
                case .succsess:
                    self.leftButton.layer.shadowOpacity = 0
                    self.mainView.layer.shadowOpacity = 0.3
                   // self.titleLabel.font = .systemFont(ofSize: 27, weight: .semibold)
                    self.imageView.image = UIImage(named: "success")
                    UIView.animate(withDuration: 0.3) {
                        if self.imageView.superview?.isHidden != false {
                            self.imageView.superview?.isHidden = false
                        }
                        
                        //self.mainView.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.9)
                    } completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                            self.backgroundHelper.backgroundColor = self.accentBackgroundColor
                            self.backgroundView.backgroundColor = self.accentBackgroundColor
                        }
                    }

                    
                    //UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.1)
                    
                }


            }
            
            
        }
    }
    
    let errorFont = UIFont.systemFont(ofSize: 32, weight: .bold)
    enum ViewType {
        case error
        case succsess
        case standard
        case standardError
        case ai
    }
    
    enum ButtonType {
        case error
        case success
        case standart
    }
    
    @IBOutlet weak var tableFirstTitle: UILabel!
    
    @IBOutlet weak var tableSeparetor: UIImageView!
    func setCompletionTable(data: ((String, String), (String, String)?)? ){
        DispatchQueue.main.async {
            self.tableFirstTitle.text = data?.0.0
            self.usernameLabel.text = data?.0.1
            self.tableSecondTitle.text = data?.1?.0
            self.emailLabel.text = data?.1?.1
        }
    }
    
    private let blueColor = K.Colors.yellow
    private let lightBlueColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1)
    private func setStyle(button: UIButton, style: ButtonType) {
        DispatchQueue.main.async {
            switch style {
            case .error:
                button.backgroundColor = .red
                button.setTitleColor(.white, for: .normal)
            case .standart:
                button.backgroundColor = self.lightBlueColor
                button.setTitleColor(.black, for: .normal)
            case .success:
                button.backgroundColor = self.blueColor
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    
    @IBOutlet weak private var imageView: UIImageView!
    
    private var rightFunc: (Any?, Bool)?
    private var leftFunc: (Any?, Bool)?
    private var hideIndicatorBlockDesibled = true
    func completeWithActions(buttons: (button, button?), title: String? = "Done", descriptionText: String? = nil, descriptionTable: ((String, String), (String, String)?)? = nil, type: ViewType = .standard, showCloseButton: Bool = false) {
    

        let hideDescription = (descriptionText == nil || descriptionText == "") ? true : false
        let hideDecriptionTable = descriptionTable == nil ? true : false
        let hideTextSuperview = descriptionTable == nil ? true : false
       // setAllHidden()
        DispatchQueue.init(label: "\(#function)", qos: .userInteractive).async {
            
        
            if !self.hideIndicatorBlockDesibled {
                print(self.hideIndicatorBlockDesibled)
            let new = {
                self.completeWithActions(buttons: buttons, title: title, descriptionText: descriptionText, descriptionTable: descriptionTable, type: type, showCloseButton: showCloseButton)
            }
                self.anshowedAIS.append(new)
            return
        }
        
            self.hideIndicatorBlockDesibled = false
        
            self.setStyle(button: self.rightButton, style: buttons.1?.style ?? .standart)
            self.setStyle(button: self.leftButton, style: buttons.0.style)
            self.leftFunc?.0 = buttons.0.action
            self.leftFunc = (buttons.0.action, buttons.0.close)
            self.setCompletionTable(data: descriptionTable)
        
            self.checkIfShowing(title: title ?? "", isBlack: false) { _ in
            self.viewType = type
        DispatchQueue.main.async {
            
            if let rightButtonn = buttons.1 {
                if self.rightButton.isHidden != false {
                    self.rightButton.isHidden = false
                }
                
                self.rightFunc = (rightButtonn.action, rightButtonn.close)
            } else {
                if self.rightButton.isHidden != true {
                    self.rightButton.isHidden = true
                }
                
            }
            if self.leftButton.superview?.isHidden != false {
                self.leftButton.superview?.isHidden = false
            }
            if self.leftButton.isHidden != false {
                self.leftButton.isHidden = false
            }
            

            if type == .error {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.leftButton.setTitle(buttons.0.title, for: .normal)
            if buttons.1 != nil{
                self.rightButton.setTitle(buttons.1?.title ?? "Cancel", for: .normal)
            }
            self.titleLabel.text = title
            print("title:", title ?? "-", " deescription: ", descriptionText, #function)

            
            self.descriptionLabel.text = descriptionText
                UIView.animate(withDuration: 0.20) {
                    if self.titleLabel.isHidden != false {
                        self.titleLabel.isHidden = false
                    }
                    if self.descriptionLabel.isHidden != hideDescription {
                        self.descriptionLabel.isHidden = hideDescription
                    }
                    if self.leftButton.superview?.superview?.isHidden != false {
                        self.leftButton.superview?.superview?.isHidden = false
                    }
                    
                    
                    if !self.aiSuperView.isHidden {
                        self.aiSuperView.isHidden = true
                    }
                   
                    if hideDecriptionTable != self.userDataStack.isHidden {
                        self.userDataStack.isHidden = hideDecriptionTable
                    }
                    
                    if hideTextSuperview != self.textField.superview?.superview?.superview?.isHidden {
                        self.textField.superview?.superview?.superview?.isHidden = hideTextSuperview
                    }
                    
                    
                } completion: { (_) in
                    self.ai.stopAnimating()
                    if showCloseButton {
                      /*  UIView.animate(withDuration: 0.15) {
                            self.closeButton.isHidden = false
                        }*/
                        
                    }
                }
            }
            

        }
        }
    }

    private var vcActionOnTFHide: Any?
    private var textFieldMode: textType? = nil
    
    func showTextField(type: textType, error: (String, String)? = nil, textFieldText: String = "", title: String, description: String? = nil, dontChangeText: Bool = false, userData: ((String, String), (String, String)?)? = nil, showSecondTF: Bool = false, whenHide: @escaping (String, String?) -> ()) {
     //   setAllHidden()
        if !hideIndicatorBlockDesibled {
            print(hideIndicatorBlockDesibled)
            return
        }
        
        vcActionOnTFHide = whenHide
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            self.frame = window.frame
            window.addSubview(self)
            self.userDataStack.isHidden = true // test when need!!!
            if !showSecondTF {
                self.textField.text = ""
            }
            self.textField.superview?.superview?.superview?.isHidden = false
            self.repeatePasswordTextField.isHidden = true
            self.leftButton.superview?.superview?.isHidden = false
            self.leftButton.superview?.isHidden = true
            
            if !dontChangeText {
                self.titleLabel.text = title
                self.descriptionLabel.text = description
            }
            var showUserStack: Bool = false
            var needAdditionalButton = false
            var enableAdditionalButton = false
            self.textFieldMode = type
            
            switch type {
            case .code:
                enableAdditionalButton = false
                self.textField.isSecureTextEntry = false
                self.textField.keyboardType = .numberPad
                needAdditionalButton = true
                self.textField.attributedPlaceholder = NSAttributedString(string: "Enter code", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                showUserStack = true
                if !dontChangeText {
                    self.setCompletionTable(data: userData)
                 /*   self.usernameLabel.text = userData?.0
                    self.emailLabel.text = userData?.1*/
                }
                if description == nil || description == nil {
                    self.descriptionLabel.isHidden = true
                }
                
            case .nickname:
                self.textField.isSecureTextEntry = false
                self.textField.keyboardType = .default
                self.textField.attributedPlaceholder = NSAttributedString(string: "Nickname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            case .email:
                if let descr = description {
                    self.descriptionLabel.isHidden = false
                    self.descriptionLabel.text = descr
                }
                
                self.textField.isSecureTextEntry = false
                self.textField.keyboardType = .emailAddress
                self.textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            case .password:
                showUserStack = true
                self.textField.isSecureTextEntry = true
                self.textField.keyboardType = .default
                self.textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                self.repeatePasswordTextField.attributedPlaceholder = NSAttributedString(string: "Repeat password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
           //     self.usernameLabel.text = userData?.0
           //     self.emailLabel.text = userData?.0
                if !dontChangeText {
          //          self.usernameLabel.text = userData?.0
          //          self.emailLabel.text = userData?.1
                }
            case .amount:
                enableAdditionalButton = true
                self.textField.isSecureTextEntry = false
                self.textField.keyboardType = .numberPad
                needAdditionalButton = true
                self.textField.attributedPlaceholder = NSAttributedString(string: "Enter amount", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                showUserStack = false
                if !dontChangeText {
          //          self.usernameLabel.text = userData?.0
          //          self.emailLabel.text = userData?.1
                }
            }
            
            
            self.checkIfShowing(title: title, isBlack: false) { _ in
                print("strarrt")
                UIView.animate(withDuration: 0.25) {
                    
                    self.leftButton.isHidden = true
                    self.rightButton.isHidden = true
                    if !dontChangeText && type != .email {
                        self.descriptionLabel.isHidden = description == nil || description == nil ? true : false
                    }
                    
                    self.backgroundView.backgroundColor = self.accentBackgroundColor
                    self.backgroundHelper.backgroundColor = self.accentBackgroundColor
                    self.aiSuperView.isHidden = true
                    self.textField.isHidden = false
                    self.userDataStack.isHidden = showUserStack ? false : true

                //    self.closeButton.isHidden = false
                     self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.moveMainOnTop * (-1), 0)
                     if needAdditionalButton {
                         self.additionalDoneButton.isHidden = false
                         self.additionalDoneButton.isEnabled = enableAdditionalButton
                     }
                    if showSecondTF {
                        self.repeatePasswordTextField.isHidden = false
                    }
                } completion: { (_) in
                    self.ai.stopAnimating()
                    if !showSecondTF {
                        self.textField.becomeFirstResponder()
                    } else {
                        self.repeatePasswordTextField.becomeFirstResponder()
                    }
                    if textFieldText != "" {
                        self.textField.text = textFieldText
                    }
                    /*UIView.animate(withDuration: 0.25) {
                        self.closeButton.isHidden = false
                        self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.moveMainOnTop * (-1), 0)
                        if needAdditionalButton {
                            self.additionalDoneButton.isHidden = false
                            self.additionalDoneButton.isEnabled = enableAdditionalButton
                        }
                    } completion: { (_) in*/
                        if error != nil {
                            UIImpactFeedbackGenerator().impactOccurred()
                        }
                    //}

                }
            }
        }
    }
    
    
    private func checkIfShowing(title: String, isBlack: Bool, showed: @escaping (Bool) -> ()) {
        if !isShowing {
            print("NOT SHOWINGG")
            isShowing = true
            DispatchQueue.main.async {
                let window = UIApplication.shared.keyWindow ?? UIWindow()
                self.frame = window.frame
                window.addSubview(self)
                
                self.alpha = 1
                self.backgroundView.alpha = 1
                self.backgroundHelper.alpha = 1
                if self.isHidden != false {
                    self.isHidden = false
                }
                
                
                self.titleLabel.text = title
                //self.mainView.backgroundColor = !isBlack ? UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.9) : .black

                self.alpha = 1
                self.backgroundHelper.alpha = 1
                self.backgroundView.alpha = 1
                if self.backgroundView.isHidden != false {
                    self.backgroundView.isHidden = false
                }
                if self.backgroundHelper.isHidden != false {
                    self.backgroundHelper.isHidden = false
                }
                
                if self.titleLabel.isHidden != false {
                    self.titleLabel.isHidden = false
                }
                
            self.backgroundView.backgroundColor = .clear
                if self.mainView.isHidden != false {
                    self.mainView.isHidden = false
                }
                
                
                UIView.animate(withDuration: 0.15) {
                    self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (com) in
                    showed(true)
                  /*  UIView.animate(withDuration: 0.12) {
                        self.backgroundView.backgroundColor = self.normalBackgroundColor
                        self.backgroundHelper.backgroundColor = self.normalBackgroundColor
                    } completion: { (_) in
                        showed(true)
                    }*/

                }
            }
        } else {
            showed(true)
        }
    }
    
    private var moveMainOnTop: CGFloat = 70
    private func completeEditingTextField(closePressed: Bool, text: String, secondText: String) {
        if let function = vcActionOnTFHide as? (String, String?) -> () {
            DispatchQueue.main.async {
                
              //  self.closeButton.isHidden = true
                self.additionalDoneButton.isHidden = true
               /* if self.showingMessage {
                    self.showMessage(show: false, title: "", helpAction: nil) { (_) in
                        self.completeEditingTextField(closePressed: closePressed, text: text, secondText: secondText)
                    }
                }*/
                UIView.animate(withDuration: 0.1) {
                    self.textField.superview?.superview?.superview?.isHidden = true
                    self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (_) in
                    self.textField.endEditing(true)
                    self.repeatePasswordTextField.endEditing(true)
                    self.textFieldMode = nil
                    self.textField.isHidden = true
                    self.show(showingAI: true, appeareAnimation: true) { (_) in
                        function(text, secondText)
                    }
                    
                 /*   DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        function(text, secondText)
                    }test end editing*/
                }
            }
        }
        
    }
    

    
    
    @IBAction private func additionalDoneButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let text = self.textField.text ?? ""
            let SecText = self.repeatePasswordTextField.text ?? ""
/*            self.showMessage(show: false, title: "", helpAction: nil) { (_) in
                self.completeEditingTextField(closePressed: false, text: text, secondText: SecText)
            }*/
            

        }
    }
    
    @IBAction private func closePressed(_ sender: UIButton) {
        hideIndicator(fast: true) { (_) in
            
        }
    }
    
    @IBAction private func buttonPress(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("leftButtonPress")
            if let function = leftFunc?.0 as? (Bool) -> () {
                self.hideIndicatorBlockDesibled = true
                if leftFunc?.1 == true {
                    hideIndicator(fast: true) { (_) in
                        function(true)
                    }
                } else {
                    self.show(showingAI: true, title: nil, description: nil, appeareAnimation: true) { _ in
                        function(true)
                    }
                    
                }
                
            }
        case 1:
            print("rightButtonPress")
            if let function = rightFunc?.0 as? (Bool) -> () {
                self.hideIndicatorBlockDesibled = true
                if rightFunc?.1 == true {
                    hideIndicator(fast: true) { (_) in
                        function(true)
                    }
                } else {
                    self.show(showingAI: true, title: nil, description: nil, appeareAnimation: true) { _ in
                        function(true)
                    }
                }
            }
        default:
            break
        }
    }

    var anshowedAIS: [Any] = []
    
    func fastHide(completionn: @escaping (Bool) -> ()) {
        if !hideIndicatorBlockDesibled {
            print(hideIndicatorBlockDesibled)
            return
        }
        if !isShowing {
            completionn(false)
            return
        }
        drawed = false
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            UIView.animate(withDuration: 0.3) {
              //  self.closeButton.isHidden = true
                self.backgroundView.backgroundColor = .clear
                self.backgroundHelper.backgroundColor = .clear
            } completion: { (_) in
                UIView.animate(withDuration: 0.22) {
                    self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height + 100, 0)
                } completion: { (_) in
                    self.titleLabel.font = self.normalTitleSize
                    self.removeFromSuperview()
                    self.setAllHidden()
                    completionn(true)
                    if let function = self.anshowedAIS.first as? () -> ()  {
                        self.anshowedAIS.removeFirst()
                        function()
                    }
                }
            }
        }
    }
    
    private var normalTitleSize: UIFont = .systemFont(ofSize: 0)
    enum textType {
        case code
        case nickname
        case email
        case password
        case amount
    }
    private let accentBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.55)
    private let normalBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.19)

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "IndicatorView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc private func textfieldValueChanged(_ textField: UITextField) {

        if textFieldMode ?? nil == .code {
            DispatchQueue.main.async {
                if textField.text?.count == 4 {
                    self.additionalDoneButton.isEnabled = true

                } else {
                    self.additionalDoneButton.isEnabled = false
                    if textField.text?.count ?? 0 > 4 {
                        self.additionalDoneButton.isEnabled = true
                        textField.text?.removeLast()
                        UIImpactFeedbackGenerator().impactOccurred()
                    }
                }
            }
        }
    }
    private func setAllHidden() {
        
        canCloseOnSwipe = false
        isShowing = false
        
        DispatchQueue.main.async {
          //  self.descriptionLabel.isHidden = true
            if self.leftButton.superview?.isHidden != true {
                self.leftButton.superview?.isHidden = true
            }
            
           // self.leftButton.superview?.superview?.isHidden = false
          //  self.closeButton.isHidden = true
            if self.imageView.superview?.isHidden != true {
                self.imageView.superview?.isHidden = true
            }
            
            self.textField.text = ""
            self.repeatePasswordTextField.text = ""
            self.textField.endEditing(true)
            self.repeatePasswordTextField.endEditing(true)
        }
       /* for textfield in textFields {
            textfield.isHidden = true
        }
        canCloseOnSwipe = false
        isShowing = false
        descriptionLabel.isHidden = true
        titleLabel.isHidden = true
         a/iSuperView.isHidden = true
        closeButton.isHidden = true
        leftButton.superview?.isHidden = true
        textField.superview?.superview?.superview?.isHidden = true
        leftButton.isHidden = true
        rightButton.isHidden = true
        additionalDoneButton.isHidden = true
        self.isHidden = true
        showMessage(show: false, title: "", helpAction: nil) { (_) in
        }
        mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
        
        DispatchQueue.main.async {
            self.imageView.superview?.isHidden = true
            self.textField.text = ""
            self.repeatePasswordTextField.text = ""
            self.textField.endEditing(true)
            self.repeatePasswordTextField.endEditing(true)
        }*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches, "gyuikmnbhj")
        if canCloseOnSwipe {
            canCloseOnSwipe = false
            self.fastHide { (_) in
                
            }
        }
    }
  /*  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
    }*/
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if keyboardHeight > 1.0 {
                let selectedTextfieldd = self.mainView
                let dif = (self.backgroundView.frame.height + self.backgroundHelper.frame.height) - CGFloat(keyboardHeight) - (selectedTextfieldd?.frame.maxY ?? 0)
                print("selectedTextfieldd?.frame.maxY ?? 0", selectedTextfieldd?.frame.maxY ?? 0)
                print("dif:", dif)
                if dif < 20 {

                    
                    DispatchQueue.main.async {
                  //      let resDif
                        UIView.animate(withDuration: 0.3) {
                            //self.view.layer.frame = CGRect(x: 0, y: dif - 20, width: self.view.layer.frame.width, height: self.view.layer.frame.height)
                            //self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif - 20, 0)
                            self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif + (-100), 0)
                           // self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, dif - 20, 0)
                        }
                    }
                }
            }
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
        }
    }
    
    
    
    
    
}

extension IndicatorView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.endEditing(true)
            let one = self.textField.text ?? ""
            let two = self.repeatePasswordTextField.text ?? ""
            
            if textField.text != "" {
             /*   self.showMessage(show: false, title: "", helpAction: nil) { (_) in
                    self.completeEditingTextField(closePressed: false, text: one, secondText: two)
                }*/
                
            }
        }
        return true
    }
    
}

