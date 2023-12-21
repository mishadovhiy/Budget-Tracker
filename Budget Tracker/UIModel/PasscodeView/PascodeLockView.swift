//
//  PascodeLockView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 10.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation
import LocalAuthentication

class PascodeLockView: UIView, UITextFieldDelegate {

    //for app delegate only
    let backgroundCol = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.98)
    let lightBackground = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.85)
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var primaryStack: UIStackView!
    @IBOutlet private weak var topStack: UIStackView!
    
    @IBOutlet private weak var appIcon: UIImageView!
    @IBOutlet private weak var numbersStack: UIView!
    @IBOutlet private weak var primaryTitleLabel: UILabel!
    
    private var enteredAction:(()->())?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if passwordNotEntered && (enteredValue ?? "" == "") {
            passcodeLock(passcodeEntered: enteredAction)
        }
    }
    private var moved:Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if !moved {
            moved = true
            self.textField.delegate = self
            let _ = self.addBluer(insertAt: 0)
            topStack.isUserInteractionEnabled = true
            topStack.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: #selector(repeateAuthorizationPressed(_:))))
        }
        self.layer.zPosition = 1000
    }
    
    @objc func repeateAuthorizationPressed(_ sender:UITapGestureRecognizer) {
        if #available(iOS 13.0.0, *) {
            self.presentSystemAuthorization()
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func present(presentCompletion:((Bool)->())? = nil) {

        enteredValue = ""
        if presenting {
            return
        }
        presenting = true
        DispatchQueue.main.async {
            AppDelegate.shared?.properties?.ai.hideIndicatorBlockDesibled = false
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            self.frame = window.frame
            self.primaryStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height + 100, 0)
            window.addSubview(self)
            self.backgroundColor = .clear
            self.appIcon.alpha = 1
            UIView.animate(withDuration: 0.5) {
                
                if self.appIcon.isHidden != false {
                    self.appIcon.isHidden = false
                }
                if self.numbersStack.isHidden != true {
                    self.numbersStack.isHidden = true
                }
                self.backgroundColor = self.lightBackground
                self.primaryStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            } completion: { 
                if !$0 {
                    return
                }
                if let presentCompletion = presentCompletion {
                    presentCompletion(true)
                }
                
            }
        }
    }
    
    @available(iOS 13.0.0, *)
    private func presentSystemAuthorization() {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to App") { authorithed, error in
            print(authorithed, " gterfwed")
            print(error, " gterfwedq")
            if authorithed {
                self.passwordNotEntered = false
                self.hide()
            }
        }
    }
    
     var presenting = false
    var passwordNotEntered = true
    func passcodeLock(passcodeEntered:(()->())? = nil) {
        enteredAction = passcodeEntered
        passwordNotEntered = true
        if !presenting {
            present(presentCompletion:  { _ in
                self.performPresentingLock()
            })
            if passcodeEntered == nil {
                if #available(iOS 13.0.0, *) {
                    self.presentSystemAuthorization()
                }
            }
            
        } else {
            performPresentingLock()
            if passcodeEntered == nil {
                if #available(iOS 13.0.0, *) {
                    self.presentSystemAuthorization()
                }
            }
        }
    }
    private func performPresentingLock() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.appIcon.alpha = 0
                self.backgroundColor = self.backgroundCol
                if self.numbersStack.isHidden != false {
                    self.numbersStack.isHidden = false
                }
                if self.appIcon.isHidden != true {
                    self.appIcon.isHidden = true
                }

            } completion: { 
                if !$0 {
                    return
                }
                let window = UIApplication.shared.keyWindow ?? UIWindow()
                window.endEditing(true)
                self.becomeFirstResponder()
                window.bringSubviewToFront(self)
                var found = false
                for i in 0..<window.subviews.count {
                    if window.subviews[i] == self {
                        found = true
                    }
                }
                if !found {
                    self.frame = window.frame
                    self.primaryStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                    window.addSubview(self)
                }
            }
        }
    }
    
    
    
    func hide() {
   //     passwordNotEntered = false
        if passwordNotEntered {
            return
        }
        presenting = false
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = .clear
                self.primaryStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height + 100, 0)

                if self.numbersStack.isHidden != true {
                    self.numbersStack.isHidden = true
                }
                
            } completion: { 
                if !$0 {
                    return
                }
                if let action = self.enteredAction {
                    self.enteredAction = nil
                    action()
                }
                self.removeFromSuperview()
                AppDelegate.shared?.properties?.ai.hideIndicatorBlockDesibled = true
                AppDelegate.shared?.properties?.ai.checkUnshowed()
            }

        }
    }

    private var _enteredValue:String?
    private var enteredValue:String? {
        get { return _enteredValue }
        set {
            _enteredValue = newValue
            if newValue?.count ?? 0 == 4 {
                checkPasscode(newValue ?? "")
            }
            DispatchQueue.main.async {
                self.textField.text = newValue
            }
        }
    }
    
    private func checkPasscode(_ newValue:String) {
        if newValue == UserSettings.Security.password {
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(1101)
            }
            passwordNotEntered = false
            hide()
        } else {
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(1102)
                AppDelegate.shared?.properties?.newMessage.show(title: "Wrong code!".localize, type: .error)
                self.enteredValue = ""
            }
        }
    }
    
    
    
    
    @IBAction private func numberPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            
            if let numString = sender.title(for: .normal) {
                if let _ = Int(numString) {
                    AudioServicesPlaySystemSound(1104)
                    self.enteredValue = (self.enteredValue ?? "") + numString
                }
                
                
            }
        }
    }
    
    
    @IBOutlet private weak var removeLastButton: UIButton!
    @IBAction private func removeLastPressed(_ sender: UIButton) {
        if self.enteredValue ?? "" != "" {
            AudioServicesPlaySystemSound(1155)
            self.enteredValue?.removeLast()
        }
    }
    

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PascodeLockView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
