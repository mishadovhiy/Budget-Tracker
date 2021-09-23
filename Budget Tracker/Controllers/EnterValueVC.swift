//
//  EnterValueVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 22.09.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

var count = 0
class EnterValueVC:UIViewController {
    
    var screenData:EnterValueVCScreenData?
    
    @IBOutlet weak private var mainStack: UIStackView!
    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var userTableStack: UIStackView!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak private var valueTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTextField.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
        valueTextField.delegate = self
        EnterValueVC.shared = self
        updateScreen()
    }
    
    
    private func updateScreen() {
        DispatchQueue.main.async {
            self.title = self.screenData?.taskName
            self.mainTitleLabel.text = self.screenData?.title
            self.descriptionLabel.text = self.screenData?.subTitle
            self.userTableStack.isHidden = self.screenData?.descriptionTable == nil ? true : false
            self.emailLabel.text = self.screenData?.descriptionTable?.0?.1
            self.userNameLabel.text = self.screenData?.descriptionTable?.1?.1
            self.valueTextField.placeholder = self.screenData?.placeHolder
            self.ai?.fastHide { _ in
                
            }
        }
    }
    
    @objc func textfieldValueChanged(_ sender:UITextField) {
        DispatchQueue.main.async {
            self.textFieldText = sender.text ?? ""
        }
    }
    
    @IBAction private func mainValueChanged(_ sender: UITextField) {
        DispatchQueue.main.async {
            self.textFieldText = sender.text ?? ""
        }
    }
    
    
    var textFieldText = ""
    
    
    
    static var shared:EnterValueVC?
    
    @IBAction private func nextPressed(_ sender: UIButton) {
        if let function = screenData?.nextAction as? () -> () {
            function()
        } else {
            print("error")
        }
    }

    public func clearAll(animated: Bool = false) {
        valueTextField.text = ""
    }
    
    public func closeVC(closeMessage: String) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    let ai = AppDelegate.shared?.ai
    public func showSelfVC(data: EnterValueVCScreenData) {
        DispatchQueue.main.async {
           // var vcs = self.navigationController?.viewControllers ?? []
           // vcs.removeLast()
            let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
            let vccc = storyboard.instantiateViewController(withIdentifier: "EnterValueVC") as! EnterValueVC
            vccc.screenData = data
          //  vcs.append(vccc)
          //  self.navigationController?.setViewControllers(vcs, animated: true)
            self.navigationController?.pushViewController(vccc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
}


struct EnterValueVCScreenData {
    let taskName: String
    let title: String
    var subTitle: String? = nil
    let placeHolder:String
    let nextAction:Any
    var descriptionTable: ((String,String)?,(String,String)?)? = nil
}


extension EnterValueVC:UITextFieldDelegate {
    
}
