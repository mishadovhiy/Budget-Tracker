//
//  IndicatorView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class IndicatorView: UIView {

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
    var canCloseOnSwipe = false
    var isShowing = false
    
    override func draw(_ rect: CGRect) {
        print("indicatorView draw")
        DispatchQueue.main.async {
            self.setAllHidden()
            self.textField.delegate = self
            self.closeButton.layer.zPosition = 100
            self.rightButton.layer.cornerRadius = 6
            self.leftButton.layer.cornerRadius = 6
            self.mainView.layer.cornerRadius = 6
            self.mainView.layer.shadowColor = UIColor.black.cgColor
            self.mainView.layer.shadowOpacity = 0.15
            self.mainView.layer.shadowOffset = .zero
            self.mainView.layer.shadowRadius = 6
            self.rightButton.layer.masksToBounds = true
            self.leftButton.layer.masksToBounds = true
            self.mainView.layer.masksToBounds = true
            self.normalTitleSize = self.titleLabel.font
            self.ai.stopAnimating()
        }
    }
    
    private func setAllHidden() {
        isShowing = false
        canCloseOnSwipe = false
        descriptionLabel.isHidden = true
        titleLabel.isHidden = true
        ai.isHidden = true
        closeButton.isHidden = true
        leftButton.superview?.isHidden = true
        textField.isHidden = true
        textField.superview?.isHidden = true
        leftButton.isHidden = true
        rightButton.isHidden = true
        additionalDoneButton.isHidden = true
        self.isHidden = true
    }
    
    func show(showingAI: Bool = true, title: String? = "Processing", description: String? = nil, appeareAnimation: Bool = false, attention: Bool = false) {
        
        if !isShowing {
            isShowing = true
        }
        canCloseOnSwipe = false
        
        
        DispatchQueue.main.async {
            self.isHidden = false
            self.titleLabel.text = title
            self.descriptionLabel.text = description
            self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            self.leftButton.superview?.superview?.isHidden = true
            UIView.animate(withDuration: appeareAnimation ? 0.25 : 0.0) {
                self.titleLabel.isHidden = title == nil ? true : false
                self.descriptionLabel.isHidden = description == nil ? true : false
                self.ai.isHidden = showingAI ? false : true
                
            } completion: { (_) in
                if !showingAI {
                    self.ai.stopAnimating()
                } else {
                    self.ai.startAnimating()
                }
                UIView.animate(withDuration: 0.15) {
                    self.backgroundView.backgroundColor = attention ? self.accentBackgroundColor : self.normalBackgroundColor
                } completion: { (_) in
                    
                }
            }

        }
    }
    
    func hideIndicator(fast: Bool = false, title: String? = nil, hideAfter: TimeInterval = 2.0, completion: @escaping (Bool) -> ()) {
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
                    Timer.scheduledTimer(withTimeInterval: hideAfter, repeats: false) { (_) in
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
                } completion: { (_) in
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
    
    func showTextField(type: textType, title: String, description: String? = nil, whenHide: @escaping (String) -> ()) {
        vcActionOnTFHide = whenHide
        DispatchQueue.main.async {
            self.textField.text = ""
            
            self.leftButton.superview?.superview?.isHidden = false
            self.textField.superview?.isHidden = false
            self.titleLabel.text = title
            self.descriptionLabel.text = description

            switch type {
            case .code:
                self.textField.keyboardType = .numberPad
                self.additionalDoneButton.isHidden = false
                self.textField.attributedPlaceholder = NSAttributedString(string: "Code", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
            case .nickname:
                self.textField.keyboardType = .default
                self.textField.attributedPlaceholder = NSAttributedString(string: "Nickname", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
            case .email:
                self.textField.keyboardType = .emailAddress
                self.textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
            case .password:
                self.textField.keyboardType = .default
                self.textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
            }
            
            self.checkIfShowing { (sh) in
                print("strarrt")
                UIImpactFeedbackGenerator().impactOccurred()
                UIView.animate(withDuration: 0.25) {
                    self.closeButton.isHidden = false
                    self.descriptionLabel.isHidden = description == nil ? true : false
                    self.backgroundView.backgroundColor = self.accentBackgroundColor
                    self.ai.isHidden = true
                } completion: { (_) in
                    UIView.animate(withDuration: 0.20) {
                        self.textField.isHidden = false
                    } completion: { (_) in
                        self.textField.becomeFirstResponder()
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
    
    private func completeEditingTextField(closePressed: Bool, text: String) {
        if let function = vcActionOnTFHide as? (String) -> () {
            DispatchQueue.main.async {
                self.closeButton.isHidden = true
                self.additionalDoneButton.isHidden = true
                UIView.animate(withDuration: 0.3) {
                    self.textField.isHidden = true
                    self.textField.superview?.isHidden = true
                } completion: { (_) in
                    self.textField.endEditing(true)
                    Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { (_) in
                        function(text)
                    }
                }
            }
            
        }
        
    }
    
    @IBAction private func additionalDoneButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let text = self.textField.text ?? ""
            self.completeEditingTextField(closePressed: false, text: text)

        }
    }
    
    @IBAction private func closePressed(_ sender: UIButton) {
        hideIndicator(fast: true) { (_) in
            DispatchQueue.main.async {
                self.textField.endEditing(true)
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

}

extension IndicatorView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, textField.text != "" {
            completeEditingTextField(closePressed: false, text: text)
        } else {
            completeEditingTextField(closePressed: true, text: "")
        }
        return true
    }
    
}
