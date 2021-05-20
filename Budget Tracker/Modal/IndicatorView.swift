//
//  IndicatorView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class IndicatorView: UIView {

    @IBOutlet weak var userDataStack: UIStackView!
    @IBOutlet weak var actionsStack: UIStackView!
    @IBOutlet private weak var additionalDoneButton: UIButton!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var ai: UIActivityIndicatorView!
    
    @IBOutlet weak var repeatePasswordTextField: UITextField!
    @IBOutlet private weak var messageView: UIView!
    @IBOutlet private weak var messageTitle: UILabel!
    @IBOutlet private weak var messageDescription: UILabel!
    @IBOutlet private weak var messageHelpButton: UIButton!
    
    var canCloseOnSwipe = false
    var isShowing = false
    private var textFields: [UITextField] = []
    
    override func draw(_ rect: CGRect) {
        print("indicatorView draw")
        DispatchQueue.main.async {
            self.textFields = [self.textField, self.repeatePasswordTextField]
            self.setAllHidden()
            for textField in self.textFields {
                textField.delegate = self
                textField.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
            }
            self.closeButton.layer.zPosition = 100
            self.rightButton.layer.cornerRadius = 6
            self.leftButton.layer.cornerRadius = 6
            self.mainView.layer.cornerRadius = 6
            self.messageView.layer.cornerRadius = 6
            self.mainView.layer.shadowColor = UIColor.black.cgColor
            self.mainView.layer.shadowOpacity = 0.15
            self.mainView.layer.shadowOffset = .zero
            self.mainView.layer.shadowRadius = 6
            self.messageView.layer.shadowColor = UIColor.black.cgColor
            self.messageView.layer.shadowOpacity = 0.15
            self.messageView.layer.shadowOffset = .zero
            self.messageView.layer.shadowRadius = 6
            self.messageView.layer.shadowPath = UIBezierPath(rect: self.messageView.bounds).cgPath
            self.mainView.layer.shadowPath = UIBezierPath(rect: self.mainView.bounds).cgPath
            self.rightButton.layer.masksToBounds = true
            self.leftButton.layer.masksToBounds = true
            self.mainView.layer.masksToBounds = true
            self.normalTitleSize = self.titleLabel.font
            self.ai.stopAnimating()
            
        }
    }
    

    func show(showingAI: Bool = true, title: String? = "Processing", description: String? = nil, appeareAnimation: Bool = false, attention: Bool = false) {
        
        if !isShowing {
            isShowing = true
        }
        canCloseOnSwipe = false
        DispatchQueue.main.async {
            if !showingAI {
                self.ai.stopAnimating()
            } else {
                self.ai.startAnimating()
            }
            self.isHidden = false
            self.titleLabel.text = title
            self.descriptionLabel.text = description
            self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            self.actionsStack.isHidden = true
            UIView.animate(withDuration: appeareAnimation ? 0.25 : 0.0) {
                self.titleLabel.isHidden = title == nil ? true : false
                self.descriptionLabel.isHidden = description == nil ? true : false
                self.ai.isHidden = showingAI ? false : true
            } completion: { (_) in
                UIView.animate(withDuration: 0.15) {
                    self.backgroundView.backgroundColor = attention ? self.accentBackgroundColor : self.normalBackgroundColor
                    self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (_) in
                    /*if showingAI {
                        if self.ai.frame.minY < 0 {
                            self.ai.isHidden = false
                        }
                    }*/
                    
                    
                }
            }

        }
    }
    
    
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    func hideIndicator(fast: Bool = false, title: String? = nil, hideAfter: Int = 2, completion: @escaping (Bool) -> ()) {
        if !fast {
            DispatchQueue.main.async {
                self.titleLabel.text = title
                self.titleLabel.font = .systemFont(ofSize: 21, weight: .medium)
                UIView.animate(withDuration: 0.15) {
                    self.titleLabel.isHidden = title == nil ? true : fast
                    self.descriptionLabel.isHidden = true
                    self.ai.isHidden = true
                    self.backgroundView.backgroundColor = self.normalBackgroundColor
                } completion: { (_) in
                    self.ai.stopAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        self.fastHide(completion: completion)
                    }
                }

            }
        } else {
            fastHide(completion: completion)
        }
    }

    private var rightFunc: Any?
    private var leftFunc: Any?
    func completeWithActions(buttonsTitles: (String?, String?)? = nil, leftButtonActon: ((Bool) -> ())? = nil, rightButtonActon: ((Bool) -> ())? = nil, title: String? = "Done", description: String? = nil, error: Bool = false) {

        rightFunc = rightButtonActon
        leftFunc = leftButtonActon
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
            self.leftButton.superview?.superview?.isHidden = false
            self.leftButton.superview?.isHidden = false
            self.leftButton.isHidden = true
            self.rightButton.isHidden = true
            self.leftButton.setTitle(buttonsTitles?.0, for: .normal)
            self.rightButton.setTitle(buttonsTitles?.1, for: .normal)
            self.titleLabel.text = title
            self.descriptionLabel.text = description
            self.checkIfShowing { (_) in
                UIView.animate(withDuration: 0.25) {
                    self.descriptionLabel.isHidden = description == nil ? true : false
                    self.backgroundView.backgroundColor = self.accentBackgroundColor
                    self.ai.isHidden = true
                    self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (_) in
                    self.ai.stopAnimating()
                    UIView.animate(withDuration: 0.20) {
                        self.rightButton.isHidden = rightButtonActon == nil ? true : false
                        self.leftButton.isHidden = buttonsTitles?.0 ?? "" == "" ? true : false
                    } completion: { (_) in
                        
                    }
                }
            }
            

        }
    }

    private var vcActionOnTFHide: Any?
    private var textFieldMode: textType? = nil
    
    func showTextField(type: textType, title: String, description: String? = nil, dontChangeText: Bool = false, userData: (String, String)? = nil, showSecondTF: Bool = false, whenHide: @escaping (String, String?) -> ()) {
        
        vcActionOnTFHide = whenHide
        DispatchQueue.main.async {
            if !showSecondTF {
                self.textField.text = ""
            }
            self.leftButton.superview?.superview?.isHidden = false
            self.textField.superview?.superview?.isHidden = false
            self.repeatePasswordTextField.isHidden = true
            if !dontChangeText {
                self.titleLabel.text = title
                self.descriptionLabel.text = description
            }
            var showUserStack: Bool = false
            var needAdditionalButton = false
            self.textFieldMode = type
            switch type {
            case .code:
                self.textField.isSecureTextEntry = false
                self.textField.keyboardType = .numberPad
                needAdditionalButton = true
                self.textField.attributedPlaceholder = NSAttributedString(string: "Enter code", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
                showUserStack = true
                if !dontChangeText {
                    self.usernameLabel.text = userData?.0
                    self.emailLabel.text = userData?.1
                }
            case .nickname:
                self.textField.isSecureTextEntry = false
                self.textField.keyboardType = .default
                self.textField.attributedPlaceholder = NSAttributedString(string: "Nickname", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
            case .email:
                self.textField.isSecureTextEntry = false
                self.textField.keyboardType = .emailAddress
                self.textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
            case .password:
                showUserStack = true
                self.textField.isSecureTextEntry = true
                self.textField.keyboardType = .default
                self.textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
                self.repeatePasswordTextField.attributedPlaceholder = NSAttributedString(string: "Repeat password", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
                self.usernameLabel.text = userData?.0
                self.emailLabel.text = userData?.0
                if !dontChangeText {
                    self.usernameLabel.text = userData?.0
                    self.emailLabel.text = userData?.1
                }
            }
            
            self.checkIfShowing { (sh) in
                print("strarrt")
                UIView.animate(withDuration: 0.25) {
                    if !dontChangeText {
                        self.descriptionLabel.isHidden = description == nil ? true : false
                    }
                    self.backgroundView.backgroundColor = self.accentBackgroundColor
                    self.ai.isHidden = true
                    self.textField.isHidden = false
                    if showUserStack {
                        self.userDataStack.isHidden = false
                    }
                    if showSecondTF {
                        self.repeatePasswordTextField.isHidden = false
                    }
                } completion: { (_) in
                    self.ai.stopAnimating()
                    UIImpactFeedbackGenerator().impactOccurred()
                    if !showSecondTF {
                        self.textField.becomeFirstResponder()
                    } else {
                        self.repeatePasswordTextField.becomeFirstResponder()
                    }
                    UIView.animate(withDuration: 0.25) {
                        self.closeButton.isHidden = false
                        self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.moveMainOnTop * (-1), 0)
                        if needAdditionalButton {
                            self.additionalDoneButton.isHidden = false
                            self.additionalDoneButton.isEnabled = false
                        }
                    } completion: { (_) in
                        
                    }

                }
            }
        }
    }
    
    
    private func checkIfShowing(showed: @escaping (Bool) -> ()) {
        if !isShowing {
            print("NOT SHOWINGG")
            isShowing = true
            DispatchQueue.main.async {
                self.isHidden = false
                self.titleLabel.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.backgroundView.backgroundColor = self.normalBackgroundColor
                } completion: { (com) in
                    UIView.animate(withDuration: 0.25) {
                        self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                    } completion: { (_) in
                        showed(true)
                    }
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
                self.showMessage(show: false, title: "", helpAction: nil)
                self.closeButton.isHidden = true
                self.additionalDoneButton.isHidden = true
                UIView.animate(withDuration: 0.3) {
                    self.textField.isHidden = true
                    self.textField.superview?.superview?.isHidden = true
                    self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (_) in
                    self.textField.endEditing(true)
                    self.repeatePasswordTextField.endEditing(true)
                    self.textFieldMode = nil

                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        function(text, secondText)
                    }
                }
            }
        }
        
    }
    
    
    var showingMessage = false
    func showMessage(show: Bool, title: String, description: String? = nil, helpAction: Any?) {
        showingMessage = show
        DispatchQueue.main.async {
            if show {
                print("showMessageshowMessageshowMessageshowMessage")
                self.messageTitle.text =  title
                self.messageDescription.text = description
                self.messageDescription.isHidden = description == nil ? true : false
                self.messageView.isHidden = false
            }
            let position = show ? 0 : self.messageView.layer.frame.height + (self.mainView.layer.frame.height / 2)
            UIView.animate(withDuration: 0.3) {
                self.messageView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, position + (self.moveMainOnTop * (-1)) , 0)
            } completion: { (_) in
                
                UIView.animate(withDuration: 0.25) {
                    self.messageHelpButton.isHidden = show ? (helpAction == nil ? true : false) : true
                } completion: { (_) in
                    if !show {
                        self.messageView.isHidden = true
                    }
                }
            }
        }
    }
    
    
    
    @IBAction private func additionalDoneButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let text = self.textField.text ?? ""
            let SecText = self.repeatePasswordTextField.text ?? ""
            self.completeEditingTextField(closePressed: false, text: text, secondText: SecText)

        }
    }
    
    @IBAction private func closePressed(_ sender: UIButton) {
        hideIndicator(fast: true) { (_) in
            DispatchQueue.main.async {
                self.textField.endEditing(true)
                self.repeatePasswordTextField.endEditing(true)
            }
        }
    }
    
    @IBAction private func buttonPress(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("leftButtonPress")
            if let function = rightFunc as? (Bool) -> () {
                hideIndicator(fast: true) { (_) in
                    function(true)
                }
            }
        case 1:
            print("rightButtonPress")
            if let function = rightFunc as? (Bool) -> () {
                hideIndicator(fast: true) { (_) in
                    function(true)
                }
            }
        default:
            break
        }
    }

    private func fastHide(completion: @escaping (Bool) -> ()) {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            UIView.animate(withDuration: 0.15) {
                self.backgroundView.backgroundColor = .clear
            } completion: { (_) in
                UIView.animate(withDuration: 0.22) {
                    self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height + 100, 0)
                } completion: { (_) in

                    self.setAllHidden()
                    completion(true)
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
    }
    private let accentBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.55)
    private let normalBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.19)

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ActivityIndicatorView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc private func textfieldValueChanged(_ textField: UITextField) {
        //if code//here
        if textFieldMode ?? nil == .code {
            DispatchQueue.main.async {
                if textField.text?.count == 4 {
                    self.additionalDoneButton.isEnabled = true
                    if self.showingMessage {
                        self.showMessage(show: false, title: "", helpAction: nil)
                    }
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
        for textfield in textFields {
            textfield.isHidden = true
        }
        isShowing = false
        canCloseOnSwipe = false
        descriptionLabel.isHidden = true
        titleLabel.isHidden = true
        ai.isHidden = true
        closeButton.isHidden = true
        leftButton.superview?.isHidden = true
        textField.superview?.superview?.isHidden = true
        leftButton.isHidden = true
        rightButton.isHidden = true
        additionalDoneButton.isHidden = true
        self.isHidden = true
        showMessage(show: false, title: "", helpAction: nil)
        mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
    }
}

extension IndicatorView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            let one = self.textField.text ?? ""
            let two = self.repeatePasswordTextField.text ?? ""
            if textField.text != "" {
                self.completeEditingTextField(closePressed: false, text: one, secondText: two)
            }
        }
        return true
    }
    
}
