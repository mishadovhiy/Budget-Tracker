//
//  PascodeLockView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 10.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation

class PascodeLockView: UIView, UITextFieldDelegate {

    //for app delegate only
    let backgroundCol = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 0.98)
    let lightBackground = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 0.85)
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var primaryStack: UIStackView!
    @IBOutlet private weak var topStack: UIStackView!
    
    @IBOutlet private weak var appIcon: UIImageView!
    @IBOutlet private weak var numbersStack: UIView!
    @IBOutlet private weak var primaryTitleLabel: UILabel!
    
    private var enteredAction:(()->())?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.textField.delegate = self
        
    }
    
    
    public func present(presentCompletion:((Bool)->())? = nil) {

        enteredValue = ""
        if presenting {
            return
        }
        presenting = true
        DispatchQueue.main.async {
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
            } completion: { _ in
                if let presentCompletion = presentCompletion {
                    presentCompletion(true)
                }
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
        } else {
            performPresentingLock()
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

            } completion: { _ in
                
            }
        }
    }
    
    
    
    func hide() {
        passwordNotEntered = false
        presenting = false
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = .clear
                self.primaryStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height + 100, 0)

                if self.numbersStack.isHidden != true {
                    self.numbersStack.isHidden = true
                }
                
            } completion: { _ in
                if let action = self.enteredAction {
                    action()
                }
                self.removeFromSuperview()
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
            hide()
        } else {
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(1102)
                AppDelegate.shared.newMessage.show(title: "Wrong code!".localize, type: .error)
                self.enteredValue = ""
            }
        }
    }
    
    
    func numberPressed(_ number:String) {
        if let _ = Int(number) {
            self.enteredValue = (self.enteredValue ?? "") + number
        }
    }
    
    @IBAction private func numberPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            if let numString = sender.title(for: .normal) {
                AudioServicesPlaySystemSound(1104)
                self.numberPressed(numString)
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
