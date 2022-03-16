//
//  EnterValueVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 22.09.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

var count = 0
class EnterValueVC:UIViewController, UITextFieldDelegate {
    
    var screenData:EnterValueVCScreenData?

    @IBOutlet weak private var codeLabel: UILabel!
    @IBOutlet weak private var mainStack: UIStackView!
    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var userTableStack: UIStackView!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.ai?.fastHide { _ in
            self.valueTextField.becomeFirstResponder()
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EnterValueVC.shared = self
        valueTextField.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
        valueTextField.delegate = self
        updateScreen()
        
        
    }

    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        valueTextField.setRightPaddingPoints(5)
        valueTextField.setLeftPaddingPoints(5)
        valueTextField.attributedPlaceholder = NSAttributedString(string: self.screenData?.placeHolder ?? "Enter value", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.textFieldPlaceholder])
        valueTextField.layer.cornerRadius = 6
    }
    
    private func updateScreen() {
        let hideTF = self.screenData?.screenType == .code ? true : false
        let hideCode = !hideTF
        DispatchQueue.main.async {
            
            self.title = self.screenData?.taskName
            self.mainTitleLabel.text = self.screenData?.title
            self.descriptionLabel.text = self.screenData?.subTitle
            self.userTableStack.isHidden = self.screenData?.descriptionTable == nil ? true : false
            self.emailLabel.text = self.screenData?.descriptionTable?.0?.1
            self.userNameLabel.text = self.screenData?.descriptionTable?.1?.1
      /*      if self.valueTextField.isHidden != hideTF {
                self.valueTextField.isHidden = hideTF
            }*/
            
       /*     if self.codeLabel.isHidden != hideCode {
                self.codeLabel.isHidden = hideCode
            }*/

            if !hideCode {
                self.numberView.delegate = self
                self.numberView.frame = CGRect(x: 0, y: 0, width: 320, height: 400)
                self.valueTextField.inputView = self.numberView
                self.numberView.limit = 4
                /*self.numberView.delegate = self
                let size = self.numberView.viewSize
              //  let centerPosition =
                self.numberView.frame = CGRect(x: (self.view.frame.width / 2) - (size.width / 2), y: self.view.frame.height - size.height, width: size.width, height: size.height)
               
                self.view.addSubview(self.numberView)
                
                self.kayboardAppeared(self.numberView.frame.height)*/
                
            }
            

            
        }
    }
    lazy var numberView: NumbersView = {
        let newView = NumbersView.instanceFromNib() as! NumbersView
        return newView
    }()
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    }
    
    func kayboardAppeared(_ keyboardHeight:CGFloat) {
        DispatchQueue.main.async {
            let selectedTextfieldd = self.mainStack
            let dif = self.view.frame.height - CGFloat(keyboardHeight) - (selectedTextfieldd?.superview?.frame.maxY ?? 0)
            if dif < 20 {

                
             //   DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        self.mainStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, ((dif / 2) - 20) / 2, 0)
                    }
               // }
            }
        }
    }
    
    
    @objc func textfieldValueChanged(_ sender:UITextField) {
        DispatchQueue.main.async {
            self.enteringValue = sender.text ?? ""
            
            
        }
    }
    
    @IBAction private func mainValueChanged(_ sender: UITextField) {
        DispatchQueue.main.async {
            self.enteringValue = sender.text ?? ""
        }

    }
    

    
    
    static var shared:EnterValueVC?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let function = screenData?.nextAction as? () -> () {
            function()
        }
        return true
    }
    
    @IBAction private func nextPressed(_ sender: UIButton) {
        if let function = screenData?.nextAction as? () -> () {
            function()
        }
    }

    public func clearAll(animated: Bool = false) {
        enteringValue = ""
    }
    
    public func closeVC(closeMessage: String) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    let ai = AppDelegate.shared?.ai
    public func showSelfVC(data: EnterValueVCScreenData) {
        DispatchQueue.main.async {
            var vcs = self.navigationController?.viewControllers ?? []
            vcs.removeLast()
            let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
            let vccc = storyboard.instantiateViewController(withIdentifier: "EnterValueVC") as! EnterValueVC
            vccc.screenData = data
            vcs.append(vccc)
            self.navigationController?.setViewControllers(vcs, animated: true)
          //  self.navigationController?.pushViewController(vccc, animated: true)
           // let test = UINavigationController(rootViewController: <#T##UIViewController#>)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        
    }
    
    enum screenType {
        case code
        case email
        case password
    }
    
    var _enteringValue:String = ""
    var enteringValue: String {
        get {
            return _enteringValue
        }
        set {
            _enteringValue = newValue
            DispatchQueue.main.async {
                self.valueTextField.text = newValue
                if self.screenData?.screenType == .code {
                    if self.valueTextField.text?.count ?? 0 >= 4 {
                        self.valueTextField.endEditing(true)
                        if let function = self.screenData?.nextAction as? () -> () {
                            function()
                        }
                    }
                }
            }
        }
    }
    
}


extension EnterValueVC {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if keyboardHeight > 1.0 {
                kayboardAppeared(keyboardHeight)
            }
        }
    }
       
    @objc func keyboardWillHide(_ notification: Notification) {

            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.mainStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                }
            }
    }
}



extension EnterValueVC:NumbersViewProtocol{
    func valuePressed(n: Int?, remove: NumbersView.SymbolType?) {
        if let num = n {
            let enter = enteringValue + "\(num)"
            if enter.count <= 4 {
                enteringValue += "\(num)"
            }
            
        }
        if let sumbol = remove {
            switch sumbol {
            case .removeLast:
                if enteringValue.count > 0 {
                    enteringValue.removeLast()
                }
            case .removeAll:
                enteringValue = ""
            }
        }
    }
    
    
}


struct EnterValueVCScreenData {
    let taskName: String
    let title: String
    var subTitle: String? = nil
    let placeHolder:String
    let nextAction:Any
    let screenType: EnterValueVC.screenType
    var descriptionTable: ((String,String)?,(String,String)?)? = nil
}



