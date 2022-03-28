//
//  IndicatorView.swift
//  POSTSD_Enterprice
//
//  Created by Mikhailo Dovhyi on 20.07.2021.
//  Copyright © 2021 Victor Havinskiy. All rights reserved.
//

import UIKit

class IndicatorView: UIView {
    private let accentBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.60)
    private let normalBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.19)
    
    @IBOutlet private weak var backgroundHelper: UIView!
    @IBOutlet private weak var userDataStack: UIStackView!
    @IBOutlet private weak var actionsStack: UIStackView!
    @IBOutlet private weak var additionalDoneButton: UIButton!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    //@IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    @IBOutlet private weak var aiSuperView: UIView!
    @IBOutlet private weak var ai: UIActivityIndicatorView!
    

    var canCloseOnSwipe = false
    var isShowing = false

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
            self.normalTitleSize = self.titleLabel.font
        }
    }

    
    func show(showingAI: Bool = true, title: String? = "Loading".localize, description: String? = nil, appeareAnimation: Bool = false, attention: Bool = false, completion: @escaping (Bool) -> ()) {
        DispatchQueue.init(label: "\(#function)", qos: .userInteractive).async {
            if !self.hideIndicatorBlockDesibled {
            print("block")
            return
        }
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
                
            } completion: { (_) in
                UIView.animate(withDuration: 0.15) {
                    
                    self.backgroundView.backgroundColor = attention ? self.accentBackgroundColor : self.normalBackgroundColor
                    self.backgroundHelper.backgroundColor = attention ? self.accentBackgroundColor : self.normalBackgroundColor
                    self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (_) in
                        self.aiSuperView.layoutIfNeeded()
                        print(self.aiSuperView.isHidden)

                    completion(true)
                }
            }

            }
        }
    }

    
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    func hideIndicator(fast: Bool = false, title: String? = nil, hideAfter: Int = 2, completion: @escaping (Bool) -> ()) {
        if !hideIndicatorBlockDesibled {
            print(hideIndicatorBlockDesibled)
            return
        }
        fastHide(completionn: completion)
    }

    
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
                case .error, .internetError:
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.image = UIImage(named: "warning")
                        self.titleLabel.font = .systemFont(ofSize: 32, weight: .bold)

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
                    
                    
                    self.titleLabel.font = newValue == .standardError ? self.errorFont : self.normalTitleSize
                    UIView.animate(withDuration: 0.3) {
                        if self.imageView.superview?.isHidden != hideImage {
                            self.imageView.superview?.isHidden = hideImage
                        }
                        
                        self.backgroundHelper.backgroundColor = self.accentBackgroundColor
                        self.backgroundView.backgroundColor = self.accentBackgroundColor
                    }
                case .ai:
break
                case .succsess:
                    self.imageView.image = UIImage(named: "success")
                    UIView.animate(withDuration: 0.3) {
                        if self.imageView.superview?.isHidden != false {
                            self.imageView.superview?.isHidden = false
                        }
                        
                    } completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                            self.backgroundHelper.backgroundColor = self.accentBackgroundColor
                            self.backgroundView.backgroundColor = self.accentBackgroundColor
                        }
                    }
                }
            }
        }
    }
    
    private let errorFont = UIFont.systemFont(ofSize: 32, weight: .bold)
    enum ViewType {
        case error
        case internetError
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
    
    @IBOutlet private weak var tableFirstTitle: UILabel!
    
    @IBOutlet private weak var tableSeparetor: UIImageView!
    private func setCompletionTable(data: ((String, String), (String, String)?)? ){
        DispatchQueue.main.async {
            self.tableFirstTitle.text = data?.0.0
            self.usernameLabel.text = data?.0.1
            self.tableSecondTitle.text = data?.1?.0
            self.emailLabel.text = data?.1?.1
        }
    }

    private func setStyle(button: UIButton, style: ButtonType) {
        DispatchQueue.main.async {
            switch style {
            case .error:
                button.backgroundColor = K.Colors.negative
            case .standart:
                button.backgroundColor = K.Colors.primaryBacground
            case .success:
                button.backgroundColor = K.Colors.link
            }
        }
    }
    
    
    @IBOutlet weak private var imageView: UIImageView!
    
    private var rightFunc: (Any?, Bool)?
    private var leftFunc: (Any?, Bool)?
    private var hideIndicatorBlockDesibled = true
    func completeWithActions(buttons: (button, button?), title: String? = "Done".localize, descriptionText: String? = nil, descriptionTable: ((String, String), (String, String)?)? = nil, type: ViewType = .standard, showCloseButton: Bool = false) {
        if !hideIndicatorBlockDesibled {
        let new = {
            self.completeWithActions(buttons: buttons, title: title, descriptionText: descriptionText, descriptionTable: descriptionTable, type: type, showCloseButton: showCloseButton)
        }
            self.anshowedAIS.append(new)
        return
    }

        let hideDescription = type == .internetError ? false : ((descriptionText == nil || descriptionText == "") ? true : false)
        let hideDecriptionTable = descriptionTable == nil ? true : false
        DispatchQueue.init(label: "\(#function)", qos: .userInteractive).async {
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
                self.rightButton.setTitle(buttons.1?.title ?? "Cancel".localize, for: .normal)
            }
            self.titleLabel.text = type == .internetError ? Text.Error.InternetTitle: title
            self.descriptionLabel.text = type == .internetError ? Text.Error.internetDescription : descriptionText
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
                } completion: { (_) in
                }
            }
            

        }
        }
    }

    private var vcActionOnTFHide: Any?

    
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

                }
            }
        } else {
            showed(true)
        }
    }
    
    private var moveMainOnTop: CGFloat = 70


    
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
        if !isShowing {
            completionn(false)
            return
        }
        if !hideIndicatorBlockDesibled {
            return
        }
        drawed = false
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            UIView.animate(withDuration: 0.10) {
              //  self.closeButton.isHidden = true
                self.backgroundView.backgroundColor = .clear
                self.backgroundHelper.backgroundColor = .clear
            } completion: { (_) in
                UIView.animate(withDuration: 0.25) {
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
    

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "IndicatorView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    private func setAllHidden() {
        
        canCloseOnSwipe = false
        isShowing = false
        
        DispatchQueue.main.async {

            if self.leftButton.superview?.isHidden != true {
                self.leftButton.superview?.isHidden = true
            }

            if self.imageView.superview?.isHidden != true {
                self.imageView.superview?.isHidden = true
            }

        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canCloseOnSwipe {
            canCloseOnSwipe = false
            self.fastHide { (_) in
                
            }
        }
    }

}



