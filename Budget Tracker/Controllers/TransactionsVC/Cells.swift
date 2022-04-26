//
//  Cells.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 26.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension AmountToPayCell:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.endEditing(true)
            let text = textField.text ?? ""
            HistoryVC.shared?.sendAmountToPay(text)
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
class AmountToPayCell: UITableViewCell {
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var editingStack: UIStackView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var restAmountLabel: UILabel!
    @IBOutlet weak var amountToPayLabel: UILabel!
    
    @IBOutlet weak var amountToPayTextField: NumbersTF!
    //@IBOutlet weak var amountToPayTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    
    
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
                            } completion: { _ in
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
                } completion: { _ in
                    HistoryVC.shared?.calendarAmountPressed.1 = true
                    HistoryVC.shared?.tableView.reloadData()
                }

            }
            
        }
    }
    
    var changeFunc:(() -> ())?
    var deleteFunc:(() -> ())?
    
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
            } completion: { _ in
                completionn(true)
            }
        }
    }

    
    @IBAction func changePressed(_ sender: UIButton) {
        if isEdit {
          //  DispatchQueue.main.async {
            HistoryVC.shared?.ai.show(title: "Sending".localize, completion: { _ in
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
                HistoryVC.shared?.ai.show(title: "Deleting".localize, completion: { _ in
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
    
    
    
    
}

class DebtDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var AlertDateStack: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var noAlertIndicator: UILabel!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var alertDateLabel: UILabel!
    @IBOutlet weak var alertMonthLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var expiredDaysCount: UILabel!
    @IBOutlet weak var expiredStack: UIStackView!
    
    var cellPressed = false
    var _expired = false
    var expired:Bool {
        get {
            return _expired
        }
        set {
            _expired = newValue
            DispatchQueue.main.async {
                self.changeButton.superview?.isHidden = newValue ? false : (self.cellPressed ? false : true)
            }
        }
    }

    private let ai = AppDelegate.shared?.ai ?? IndicatorView.instanceFromNib() as! IndicatorView
    
    var removeAction:(() -> ())?
    @IBAction func changeDatePressed(_ sender: Any) {//remove
     //   DispatchQueue.main.async {
          //  self.ai.show() { _ in
                if let funcc = self.removeAction {
                    funcc()
                }
           // }
     //   }
        

    }
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        changeButton.layer.cornerRadius = changeButton.layer.frame.width / 2
        doneButton.layer.cornerRadius = doneButton.layer.frame.width / 2
        
    }
    
    var changeAction:(() -> ())?
    @IBAction func doneDatePressed(_ sender: Any) {//change
        self.ai.show { _ in
            if let funcc = self.changeAction {
                funcc()
            }
        }
    }
    

}
