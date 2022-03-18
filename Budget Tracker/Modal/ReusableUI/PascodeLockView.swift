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
    
    
    public func present(passcodeEntered:(()->())? = nil) {
        enteredAction = passcodeEntered
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
            AppDelegate.shared?.delegate?.resighnActive()
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

            }
        }
    }
    private var presenting = false
    
    var passwordNotEntered = true
    func passcodeLock() {
        passwordNotEntered = true
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
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
                AppDelegate.shared?.newMessage.show(title: "Wrong code!", type: .error)
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
