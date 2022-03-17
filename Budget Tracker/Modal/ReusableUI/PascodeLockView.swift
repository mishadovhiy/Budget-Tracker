//
//  PascodeLockView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 10.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class PascodeLockView: UIView {

    //for app delegate only
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var primaryStack: UIStackView!
    @IBOutlet weak var topStack: UIStackView!
    
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var numbersStack: UIView!
    @IBOutlet weak var primaryTitleLabel: UILabel!
    
    var enteredAction:(()->())?
    
    public func present(passcodeEntered:(()->())? = nil) {
        enteredAction = passcodeEntered
        enteredValue = ""
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
         //   self.frame = window.frame
            self.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height + 100, 0)
            window.addSubview(self)
            UIView.animate(withDuration: 0.8) {
                self.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            } completion: { _ in
                
            }

        }
    }
    
    
    func hide() {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            UIView.animate(withDuration: 0.3) {
                self.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height + 100, 0)
            } completion: { _ in
                if let action = self.enteredAction {
                    action()
                }
                self.removeFromSuperview()
            }

        }
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    

    var _enteredValue:String?
    var enteredValue:String? {
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
    
    func checkPasscode(_ newValue:String) {
        if newValue == UserSettings.Security.password {
            hide()
        } else {
            AppDelegate.shared?.newMessage.show(title: "Wrong code!", type: .error)
            enteredValue = ""
        }
    }
    
    
    
    @IBAction private func numberPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            if let numString = sender.title(for: .normal) {
                if let _ = Int(numString) {
                    self.enteredValue = (self.enteredValue ?? "") + numString
                }
                
                
            }
        }
    }
    
    
    @IBOutlet private weak var removeLastButton: UIButton!
    @IBAction private func removeLastPressed(_ sender: UIButton) {
        if self.enteredValue ?? "" != "" {
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
