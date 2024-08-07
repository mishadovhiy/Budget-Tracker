//
//  EnterValueVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 22.09.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class EnterValueVC:SuperViewController, UITextFieldDelegate {
    
    var screenData:EnterValueVCScreenData?

    @IBOutlet weak var valueTextField: BaseTextField!
    @IBOutlet weak var nextButton: Button!
    
    @IBOutlet weak private var codeLabel: UILabel!
    @IBOutlet weak private var mainStack: UIStackView!
    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    
    @IBOutlet weak private var userTableStack: UIStackView!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak var userNameTitleLabel: UILabel!
    @IBOutlet weak private var userNameLabel: UILabel!

    var nextButtonTitle:String = "Next"
    var selectionStackData:[SelectionStackView.SelectionData]?
    weak var selectionStackView:SelectionStackView?
    var dismissedAction:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueTextField.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
        valueTextField.returnKeyType = .done
        valueTextField.keyboardType = .default
        valueTextField.delegate = self
        valueTextField.shouldReturn = {
            let _ = self.textFieldShouldReturn(self.valueTextField)
        }
        updateScreen()
        loadUI()
        nextButton.setTitle(nextButtonTitle, for: .normal)
    }

    var appeared = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.ai?.hide { 
            if !self.appeared {
                self.appeared = true
                self.valueTextField.becomeFirstResponder()

            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissedAction?()
        removeKeyboardObthervers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        valueTextField.setPaddings(5)
        valueTextField.setPaddings(5)
        valueTextField.setPlaceHolderColor(K.Colors.balanceV ?? .white)
        valueTextField.layer.cornerRadius = 6
        
        
    }
    
    
    lazy var numberView: NumbersView = {
        let newView = NumbersView.instanceFromNib() as! NumbersView
        return newView
    }()

    
    var textFieldValue:String?
    
    static func presentScreen(in nav:UINavigationController, with data: EnterValueVCScreenData, defaultValue:String? = nil) {

        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EnterValueVC") as! EnterValueVC
            vc.textFieldValue = defaultValue
            vc.screenData = data
            vc.minValue = data.screenType == .code ? 4 : 1
            nav.pushViewController(vc, animated: true)
        }

    }
    

    
    var minValue:Int = 1
    
    
    
    private func updateScreen() {
        print(#function, "\ndata: ", self.screenData)
        DispatchQueue.main.async {
            
            self.title = self.screenData?.taskName
            self.mainTitleLabel.text = self.screenData?.title
            self.descriptionLabel.text = self.screenData?.subTitle
            self.userTableStack.isHidden = self.screenData?.descriptionTable == nil ? true : false
            
            self.emailLabel.superview?.isHidden = self.screenData?.descriptionTable?.0 == nil
            self.userNameLabel.superview?.isHidden = self.screenData?.descriptionTable?.1 == nil
            
            self.emailTitleLabel.text = self.screenData?.descriptionTable?.0?.0 ?? ""
            
            self.emailLabel.text = self.screenData?.descriptionTable?.0?.1
            
            self.userNameLabel.text = self.screenData?.descriptionTable?.1?.1
            self.userNameTitleLabel.text = self.screenData?.descriptionTable?.1?.0
            
            self.valueTextField.text = self.textFieldValue
            self.valueTextField.placeholder = self.screenData?.placeHolder ?? self.textFieldValue
            self.enteringValue = self.textFieldValue ?? ""
            let hideTF = self.screenData?.screenType == .code ? true : false
            if hideTF {
                self.numberView.delegate = self
                self.numberView.frame = CGRect(x: 0, y: 0, width: 320, height: 400)
                self.valueTextField.inputView = self.numberView
                self.numberView.limit = 4

            }
        
            
        }
    }
    
    

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    }
    
    func kayboardAppeared(_ keyboardHeight:CGFloat) {
        DispatchQueue.main.async {
            let selectedTextfieldd = self.mainStack
            let dif = self.view.frame.height - CGFloat(keyboardHeight) - (selectedTextfieldd?.superview?.frame.maxY ?? 0)
            if dif < 20 {
                UIView.animate(withDuration: 0.3) {
                   // self.mainStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, ((dif / 2) - 20) / 2, 0)
                    UIApplication.shared.sceneKeyWindow?.layer.move(.top, value: ((dif / 2) - 20))
                }
            }
        }
    }
    
    
    
    
    @objc func textfieldValueChanged(_ sender:UITextField) {
        print(sender.text ?? "", " tgerfwd")
        DispatchQueue.main.async {
            self.enteringValue = sender.text ?? ""
            
            
        }
    }
    
//    @IBAction private func mainValueChanged(_ sender: UITextField) {
//        DispatchQueue.main.async {
//            self.enteringValue = sender.text ?? ""
//        }
//
//    }
    

    func loadUI() {
        if let selectionStackData = selectionStackData, selectionStackView == nil {
            selectionStackView = .create(self.view, data: selectionStackData, position: .init(x: 10, y: self.additionalSafeAreaInsets.top + self.view.safeAreaInsets.top + (self.navigationController?.navigationBar.frame.height ?? 0)))
        }
    }
    
    override func firstAppeared() {
        super.firstAppeared()
        
    }
    
    
    private func next() {
        print(#function, enteringValue)
        let errorAction = {
            AppDelegate.properties?.newMessage.show(title:"Error editing".localize, type: .error)
        }
        
        if let function = screenData?.nextAction {
            if validateValue() {
                function(self.enteringValue)
                DispatchQueue.main.async {
                    self.valueTextField.endEditing(true)
                }
            } else {
                errorAction()
            }
        }
    }
    
    private func validateValue() -> Bool {
        print(enteringValue.count, " fgvhbunjkmjygtfyrtguhijo")
        if enteringValue.count >= minValue {
            switch screenData?.screenType {
            case .email:
                return !enteringValue.contains("@") ? false : true
            case .code:
                return Int(enteringValue) == nil ? false : true
            default:
                return true
            }
        } else {
            return false
        }
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        next()
        return true
    }
    
    @IBAction private func nextPressed(_ sender: UIButton) {
        next()
    }

    
    
    public func clearAll(animated: Bool = false) {
        enteringValue = ""
    }
    
    public func closeVC(closeMessage: String = "") {
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: {
                
            })
        }
    }

    var willAppeareCalled = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !willAppeareCalled {
            willAppeareCalled = true
            
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    enum screenType {
        case code
        case email
        case password
        case string
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
                    if newValue.count == 4 {
                        self.next()
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
                   // self.mainStack.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                    UIApplication.shared.sceneKeyWindow?.layer.move(.top, value: 0)

                }
            }
    }
}



extension EnterValueVC:NumbersViewProtocol {
    func valuePressed(n: Int?, remove: NumbersView.SymbolType?) {
        if let num = n {
            let enter = enteringValue + "\(num)"
            if enter.count <= 4 {
                enteringValue += "\(num)"
            } else {
                enteringValue = enteringValue
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






extension EnterValueVC {
    struct EnterValueVCScreenData {
        let taskName: String
        let title: String
        var subTitle: String? = nil
        let placeHolder:String
        let nextAction:(String) -> ()
        let screenType: EnterValueVC.screenType
        var descriptionTable: ((String,String)?,(String,String)?)? = nil
    }
}

extension EnterValueVC {
    static func configure() -> EnterValueVC {
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EnterValueVC") as! EnterValueVC
        return vc
    }
}
