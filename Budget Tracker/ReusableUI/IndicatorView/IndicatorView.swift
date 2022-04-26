//
//  BaseViewController.swift
//  ScoopChat
//
//  Created by Mikhailo Dovhyi on 20.07.2021.
//

import UIKit

class IndicatorView: UIView {
    let accentBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.60)
    let normalBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.19)
    
    private let mainViewLightColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 0.65)
    private let mainViewDarkColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 0.85)
    
    @IBOutlet private weak var actionsStack: UIStackView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    @IBOutlet private weak var aiSuperView: UIView!
    @IBOutlet private weak var ai: UIActivityIndicatorView!
    @IBOutlet private weak var buttonsSeparetorImage: UIImageView!
    @IBOutlet weak private var imageView: UIImageView!
    
    private var canCloseOnSwipe = false
    var isShowing = false

    private var anshowedAIS: [Any] = []
    private var rightFunc: (Any?, Bool)?
    private var leftFunc: (Any?, Bool)?
    var hideIndicatorBlockDesibled = true
    private var normalTitleSize: UIFont = .systemFont(ofSize: 0)
    private let errorFont = UIFont.systemFont(ofSize: 32, weight: .bold)
    
    override func draw(_ rect: CGRect) {
        self.normalTitleSize = self.titleLabel.font
    }

    
    func show(title: String? = "Loading".localize, description: String? = nil, appeareAnimation: Bool = false, completion: @escaping (Bool) -> ()) {
        DispatchQueue.init(label: "\(#function)", qos: .userInteractive).async {
            if !self.hideIndicatorBlockDesibled {
            print("block")
            return
        }
        if !self.isShowing {
            self.isShowing = true
        }
        self.canCloseOnSwipe = false
        let hideTitle = title == nil ? true : false
        let hideDescription = (description == "" || description == nil) ? true : false
        self.setBacground(higlight: false, ai: true)
            DispatchQueue.main.sync {
                let window = AppDelegate.shared?.window ?? UIWindow()
                //keyWindow ?? UIWindow()
            self.frame = window.frame
            window.addSubview(self)
            if self.imageView.superview?.isHidden != true {
                self.imageView.superview?.isHidden = true
            }
            self.alpha = 1
            self.backgroundView.alpha = 1
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
                UIView.animate(withDuration: appeareAnimation ? 0.25 : 0.1) {
                self.mainView.backgroundColor = self.mainViewLightColor
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
                    self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (_) in
                        self.aiSuperView.layoutIfNeeded()
                    completion(true)
                }
            }

            }
        }
    }

    
    func showAlert(buttons: (button, button?), title: String? = "Done".localize, description: String? = nil, type: ViewType = .standard, image:Image? = nil) {
        if !hideIndicatorBlockDesibled {
            let new = {
                self.showAlert(buttons: buttons, title: title, description:description, type: type)
            }
            self.anshowedAIS.append(new)
            return
        }
        let hideDescription = type == .internetError ? false : ((description == nil || description == "") ? true : false)
        let hideButtonSeparetor = buttons.1 == nil ? true : false
        DispatchQueue.init(label: "showAlert", qos: .userInteractive).async {
            self.hideIndicatorBlockDesibled = false
            self.leftFunc = (buttons.0.action, buttons.0.close)
            self.checkIfShowing(title: title ?? "", isBlack: false) { _ in
                let needHiglight = type == .error || type == .internetError
                self.setBacground(higlight: needHiglight, ai: false)
                self.buttonStyle(self.leftButton, type: buttons.0)
                if let right = buttons.1 {
                    self.rightFunc = (right.action, right.close)
                    self.buttonStyle(self.rightButton, type: right)
                }
        DispatchQueue.main.async {
            if buttons.1 == nil {
                if self.rightButton.isHidden != true {
                    self.rightButton.isHidden = true
                }
            }
            if self.buttonsSeparetorImage.isHidden != hideButtonSeparetor {
                self.buttonsSeparetorImage.isHidden = hideButtonSeparetor
            }

            if type == .error {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            self.titleLabel.text = type == .internetError ? "Internet error".localize : title
            self.descriptionLabel.text = type == .internetError ? "Try again later".localize : description
            let mailImage = self.getAlertImage(image: image, type: type)
                UIView.animate(withDuration: 0.20) {
                    self.mainView.backgroundColor = self.mainViewDarkColor
                    
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
                    if let image = mailImage {
                        self.imageView.image = image
                        self.imageView.superview?.isHidden = false
                    } else {
                        if self.imageView.superview?.isHidden != true {
                            self.imageView.superview?.isHidden = true
                        }
                    }
                }
            }
                
            }
        }
    }


    

    

    private func checkIfShowing(title: String, isBlack: Bool, showed: @escaping (Bool) -> ()) {
        if !isShowing {
            print("NOT SHOWINGG")
            isShowing = true
            DispatchQueue.main.async {
                let window = AppDelegate.shared?.window ?? UIWindow()
                self.frame = window.frame
                window.addSubview(self)
                self.alpha = 1
                self.backgroundView.alpha = 1
                if self.isHidden != false {
                    self.isHidden = false
                }
                self.titleLabel.text = title
                self.alpha = 1
                self.backgroundView.alpha = 1
                if self.backgroundView.isHidden != false {
                    self.backgroundView.isHidden = false
                }
                
                if self.titleLabel.isHidden != false {
                    self.titleLabel.isHidden = false
                }
                
            self.backgroundView.backgroundColor = .clear
                if self.mainView.isHidden != false {
                    self.mainView.isHidden = false
                }
                UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .allowAnimatedContent) {
                    self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { _ in
                    window.endEditing(true)
                    self.bannerBackgroundWas = AppDelegate.shared?.banner.clearBackground ?? true
                    AppDelegate.shared?.banner.setBackground(clear: true)
                    showed(true)
                }

            }
        } else {
            showed(true)
        }
    }
    

    
    @IBAction private func closePressed(_ sender: UIButton) {
        fastHide()
    }
    
    @IBAction private func buttonPress(_ sender: UIButton) {
        hideIndicatorBlockDesibled = true
        switch sender.tag {
        case 0:
            print("leftButtonPress")
            if let function = leftFunc?.0 as? (Bool) -> () {
                if leftFunc?.1 == true {
                    fastHide { _ in
                        function(true)
                    }
                } else {
                    self.show(appeareAnimation:true) { _ in
                        function(true)
                    }
                }
            } else {
                fastHide()
            }
        case 1:
            print("rightButtonPress")
            if let function = rightFunc?.0 as? (Bool) -> () {
                if rightFunc?.1 == true {
                    fastHide { (_) in
                        function(true)
                    }
                } else {
                    self.show(appeareAnimation:true) { _ in
                        function(true)
                    }
                }
            } else {
                fastHide()
            }
        default:
            break
        }
    }

    func fastHide() {
        fastHide { _ in
            
        }
    }
    
    func fastHide(completionn: @escaping (Bool) -> ()) {
        if !isShowing {
            completionn(false)
            return
        }
        if !hideIndicatorBlockDesibled {
            return
        }
        DispatchQueue.main.async {
            let window = AppDelegate.shared?.window ?? UIWindow()
            UIView.animate(withDuration: 0.10) {
                self.backgroundView.backgroundColor = .clear
            } completion: { (_) in
                UIView.animate(withDuration: 0.25) {
                    if self.actionsStack.isHidden != true {
                        self.actionsStack.isHidden = true
                    }
                    self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height + 100, 0)
                } completion: { (_) in
                    if let b = self.bannerBackgroundWas {
                        self.bannerBackgroundWas = nil
                        AppDelegate.shared?.banner.setBackground(clear: b)
                    }
                    
                    self.titleLabel.font = self.normalTitleSize
                    self.removeFromSuperview()
                    self.setAllHidden()
                    completionn(true)
                    self.checkUnshowed()
                }
            }
        }
    }
    private var bannerBackgroundWas:Bool?
    
    func checkUnshowed() {
        if let function = anshowedAIS.first as? () -> ()  {
            anshowedAIS.removeFirst()
            function()
        }
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canCloseOnSwipe {//if touches != view
            canCloseOnSwipe = false
            self.fastHide()
        }
    }
    

    private func setAllHidden() {//mainthread
        canCloseOnSwipe = false
        isShowing = false
        if leftButton.superview?.isHidden != true {
            leftButton.superview?.isHidden = true
        }
        if imageView.superview?.isHidden != true {
            imageView.superview?.isHidden = true
        }
    }

}




