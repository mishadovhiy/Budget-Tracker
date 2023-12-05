//
//  AmountToPayCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class AmountToPayCell: UITableViewCell {
    @IBOutlet weak var totalNameLabel: Label!
    @IBOutlet weak var amountTitleLabel: Label!
    @IBOutlet weak var restTitleLabel: Label!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var editingStack: UIStackView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var restAmountLabel: UILabel!
    @IBOutlet weak var amountToPayLabel: UILabel!
    @IBOutlet weak var amountToPayTextField: NumbersTF!
    @IBOutlet weak var changeButton: UIButton!
    
    private var changeFunc:(() -> ())?
    private var deleteFunc:(() -> ())?
    override func removeFromSuperview() {
        super.removeFromSuperview()
        changeFunc = nil
        deleteFunc = nil
    }
    func set(_ selectedCategory:NewCategories?,
             changeAmountState:(Bool, Bool),
             catTotal:Double,
             isEditing:Bool,
             changePressed:@escaping ()->(),
             removePressed:@escaping ()->()) {
        
        let amToPay = Int((selectedCategory?.amountToPay ?? selectedCategory?.monthLimit) ?? 0)
        let progress = amToPay == 0 ? 0 : (catTotal * -1) / ((selectedCategory?.amountToPay ?? selectedCategory?.monthLimit) ?? 0)
        amountTitleLabel.text = selectedCategory?.purpose == .debt ? "Amount to pay:" : "Monthly spending limit:"
        totalNameLabel.text = selectedCategory?.purpose == .debt ? "Total payed:" : "This month total spent:"
        restTitleLabel.text = selectedCategory?.purpose == .debt ? "Rest:" : (amToPay <= Int(catTotal) ? "Overspent:" : "Rest:")
        print(progress)
        print(amToPay, " amToPayamToPayamToPay")
        self.deleteFunc = removePressed
        self.editingStack.alpha = changeAmountState.1 ? 1 : 0
        self.changeFunc = changePressed
        self.isEdit = isEditing
        let tEx = Int(catTotal)
        self.totalLabel.text = "\(tEx * (-1))"
        self.restAmountLabel.text = "\(amToPay + tEx)"
        self.amountToPayLabel.text = "\(amToPay)"
        self.progressBar.progress = Float(progress)
        self.progressBar.progressTintColor = AppData.colorNamed(selectedCategory?.color)
        self.progressBar.isHidden = amToPay == 0
        amountToPayLabel.text = "\(amToPay)"
        amountToPayTextField.addTarget(self, action: #selector(tfChanged(_:)), for: .editingChanged)
        amountToPayTextField.isHidden = !isEditing
        amountToPayLabel.isHidden = isEditing
        //   editingStack.isHidden = !changeAmountState.0
        self.tfValue = "\(amToPay)"
    }
    
    @objc private func tfChanged(_ sender:UITextField) {
        let text = sender.text ?? ""
        if text.isAllNumbers {
            self.tfValue = text
        } else {
            sender.text = self.tfValue
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let amPress = HistoryVC.shared?.calendarAmountPressed.1 ?? false
        print(amPress, "amPressamPressamPressamPress")
        if amPress {
            if !isEdit {
                if let touch = touches.first {
                    DispatchQueue.main.async {
                        if touch.view != self.changeButton || touch.view != self.deleteButton {
                            UIView.animate(withDuration: 0.3) {
                                self.editingStack.alpha = 0
                            } completion: { 
                                if !$0 {
                                    return
                                }
                                HistoryVC.shared?.calendarAmountPressed = (false, false)
                                HistoryVC.shared?.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
            
        } else {
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 0.12) {
                    self.editingStack.alpha = 1
                } completion: { 
                    if !$0 {
                        return
                    }
                    HistoryVC.shared?.calendarAmountPressed.1 = true
                    HistoryVC.shared?.tableView.reloadData()
                }
                
            }
            
        }
    }
    
    var _isEdit = false
    var isEdit:Bool {
        get {
            return _isEdit
        }
        set {
            _isEdit = newValue
            print(newValue, "newValuenewValuenewValuenewValuenewValuenewValuenewValue")
            let deleteIcon = newValue ? "xmark.circle" : "trash"
            let changeIcon = newValue ? "paperplane.fill" : "pencil"
            
            DispatchQueue.main.async {
                if newValue {
                    if self.amountToPayTextField.isHidden != false {
                        self.amountToPayTextField.isHidden = false
                    }
                    if self.amountToPayLabel.isHidden != true {
                        self.amountToPayLabel.isHidden = true
                    }
                }
                
                self.deleteButton.setImage(AppData.iconSystemNamed(deleteIcon), for: .normal)
                self.changeButton.setImage(AppData.iconSystemNamed(changeIcon), for: .normal)
                
            }
        }
    }
    
    func setAmountEditing(_ editing:Bool) {
        DispatchQueue.main.async {
            if self.editingStack.alpha != (editing ? 1 : 0) {
                self.editingStack.alpha = editing ? 1 : 0
            }
            
            if self.amountToPayLabel.isHidden != editing ? true : false {
                self.amountToPayLabel.isHidden = editing ? true : false
            }
            if self.amountToPayTextField.isHidden != editing ? false : true {
                self.amountToPayTextField.isHidden = editing ? false : true
            }
        }
    }
    
    private func showEdit(_ value:Bool, hideStack:Bool , completionn: @escaping (Bool) -> ()) {
        let hideLabel = value ? true : false
        let hideTF = value ? false : true
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                if self.editingStack.alpha != (hideStack ? 0 : 1) {
                    self.editingStack.alpha = hideStack ? 0 : 1
                }
                
                if self.amountToPayLabel.isHidden != hideLabel {
                    self.amountToPayLabel.isHidden = hideLabel
                }
                if self.amountToPayTextField.isHidden != hideTF {
                    self.amountToPayTextField.isHidden = hideTF
                }
            } completion: { 
                if !$0 {
                    return
                }
                completionn(true)
            }
        }
    }
    
    
    @IBAction func changePressed(_ sender: UIButton) {
        if isEdit {
            //  DispatchQueue.main.async {
            HistoryVC.shared?.ai?.show(title: "Sending".localize, completion: { _ in
                self.isEdit = false
                self.showEdit(false, hideStack: true) { _ in
                    let text = self.amountToPayTextField.text ?? ""
                    HistoryVC.shared?.sendAmountToPay(text)
                }
            })
            //   }
        } else {
            self.isEdit = true
            showEdit(true, hideStack: false) { _ in
                
                DispatchQueue.main.async {
                    self.amountToPayTextField.becomeFirstResponder()
                }
                if !self.isEdit {
                    if let funcc = self.changeFunc {
                        funcc()
                    }
                }
            }
            
        }
        
    }
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func deletePressed(_ sender: UIButton) {
        
        let new = !isEdit
        if !isEdit {
            if let funcc = deleteFunc {
                //    DispatchQueue.main.async {
                HistoryVC.shared?.ai?.show(title: "Deleting".localize, completion: { _ in
                    self.showEdit(new, hideStack: true) { _ in
                        funcc()
                        
                    }
                })
                //    }
            }
            
        } else {
            self.isEdit = false
            self.showEdit(false, hideStack: true) { _ in
                
                HistoryVC.shared?.calendarAmountPressed = (false,false)
                HistoryVC.shared?.amountToPayEditing = false
                DispatchQueue.main.async {
                    self.amountToPayTextField.endEditing(true)
                }
            }
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        deleteButton.layer.cornerRadius = deleteButton.layer.frame.width / 2
        changeButton.layer.cornerRadius = changeButton.layer.frame.width / 2
        
        amountToPayTextField.delegate = self
    }
    
    
    var tfValue:String = ""
    
}

extension AmountToPayCell:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.endEditing(true)
            let text = textField.text ?? ""
            if text.isAllNumbers {
                self.tfValue = text
                HistoryVC.shared?.sendAmountToPay(text)
            } else {
                textField.text = self.tfValue
            }
            
        }
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        HistoryVC.shared?.amountToPayEditing = true
        isEdit = true
        showEdit(true, hideStack: false) { _ in
            
        }
        
    }
}
