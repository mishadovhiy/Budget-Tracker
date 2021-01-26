//
//  TransactionVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

protocol TransitionVCProtocol {
    func addNewTransaction(value: String, category: String, date: String, comment: String)
    func quiteTransactionVC()
}

class TransitionVC: UIViewController {
    @IBOutlet weak var dateTextField: CustomTextField!
    @IBOutlet weak var categoryTextField: CustomTextField!
    @IBOutlet weak var purposeSwitcher: UISegmentedControl!
    @IBOutlet weak var showValueButton: UIButton!
    @IBOutlet weak var numbarPadView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var minusPlusLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentCountLabel: UILabel!
    var pressedValue = "0"
    var expenseArr = [""]
    var incomeArr = [""]
    
    var delegate:TransitionVCProtocol?;
    
    var editingDateHolder = ""
    var editingCategoryHolder = ""
    var editingValueHolder = 0.0
    var editingCommentHolder = ""
    
    var editingDate = ""
    var editingCategory = ""
    var editingValue = 0.0
    var editingComment = ""
    
    var pressedValueArrey: [String] =  []
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        purposeSwitcher.selectedSegmentIndex = 0
        purposeSwitched(purposeSwitcher)
        getEditingdata()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.quiteTransactionVC()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toCalendar":
            print("toCalendar")
            let vc = segue.destination as! CalendarVC
            vc.delegate = self
            if let date = dateTextField.text {
                vc.selectedFrom = date
            }
            
        case "toCategories":
            print("toCalendar")
            let vc = segue.destination as! CategoriesVC
            vc.delegate = self
        default:
            print("segue default")
        }
    }
    
    func updateUI() {
        
        appendPurposes()
        delegates(fields: [categoryTextField, dateTextField, commentTextField])
        appData.objects.datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            appData.objects.datePicker.preferredDatePickerStyle = .wheels
        }
        dateTextField.inputView = UIView(frame: .zero)//appData.objects.datePicker
        appData.objects.datePicker.addTarget(self, action: #selector(datePickerChangedValue(sender:)), for: .valueChanged)
        dateTextField.isUserInteractionEnabled = false
        dateTextField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(datePressed)))
        
        dateTextField.placeholder = UserDefaults.standard.value(forKey: "lastSelectedDate") as? String ?? appData.stringDate(appData.objects.datePicker)
        pressedValue = "0"
        valueLabel.text = pressedValue
        commentTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        commentTextField.addTarget(self, action: #selector(commentCount), for: .editingChanged)
        categoryTextField.isUserInteractionEnabled = false
        categoryTextField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryPressed)))
        
    }
    
    @objc func datePressed(_ sender: UITapGestureRecognizer) {
        print("datePressed")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toCalendar", sender: self)
        }
    }
    
    @objc func categoryPressed(_ sender: UITapGestureRecognizer) {
        print("toCategories")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toCategories", sender: self)
        }
    }
    
    
    func delegates(fields: [UITextField]) {
        
        for i in 0..<fields.count {
            fields[i].delegate = self
        }
    }
    
    @objc func commentCount() {
        
        commentCountLabel.text = "\(30 - (commentTextField.text?.count ?? 0))"
        if commentTextField.text?.count == 30 {
            commentCountLabel.textColor = K.Colors.negative
            UIImpactFeedbackGenerator().impactOccurred()
        } else {
            commentCountLabel.textColor = K.Colors.balanceT
        }
        if commentTextField.text?.count == 0 {
            UIView.animate(withDuration: 0.2) {
                self.commentCountLabel.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.commentCountLabel.alpha = 1
            }
        }
    }
    
    func getEditingdata() {
        
        if editingDate != "" {
            if editingValue > 0.0 {
                editingValueAmount(segment: 1, multiply: 1)
            } else {
                editingValueAmount(segment: 0, multiply: -1)
            }
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
            }
            minusPlusLabel.alpha = 1
            categoryTextField.text = editingCategory
            dateTextField.text = editingDate
            commentTextField.text = editingComment
            editingCategoryHolder = editingCategory
            editingDateHolder = editingDate
            editingValueHolder = editingValue
            editingCommentHolder = editingComment
            if (commentTextField.text?.count ?? 0) > 0 {
                commentCountLabel.text = "\(30 - (commentTextField.text?.count ?? 0))"
                UIView.animate(withDuration: 0.2) {
                    self.commentCountLabel.alpha = 1
                }
            }
        } else {
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = false
            }
        }
        
    }
    
    func editingValueAmount(segment: Int, multiply: Int) {
        
        self.purposeSwitcher.selectedSegmentIndex = segment
        self.purposeSwitched(self.purposeSwitcher)
        valueLabel.text = "\(Int(editingValue) * multiply)"
        pressedValue = "\(Int(editingValue) * multiply)"
    }
    
    func appendPurposes() {
        
        expenseArr.removeAll()
        incomeArr.removeAll()
        let categories = appData.getCategories()
        for i in 0..<categories.count {
            if categories[i].purpose == K.expense {
                expenseArr.append(categories[i].name)
            } else {
                incomeArr.append(categories[i].name)
            }}
        if expenseArr.count == 0 {
            expenseArr.append(K.Text.unknExpense)
        }
        if incomeArr.count == 0 {
            incomeArr.append(K.Text.unknIncome)
        }
    }
    
    func addNew(value: String, category: String, date: String, comment: String) {

        UIImpactFeedbackGenerator().impactOccurred()
        print("addNew called", date)
        if appData.username != "" {
            self.dismiss(animated: true) {
                self.delegate?.addNewTransaction(value: value, category: category, date: date, comment: comment)
            }
        } else {
            self.dismiss(animated: true) {
                self.delegate?.addNewTransaction(value: value, category: category, date: date, comment: comment)
            }
        }
        

    }
    
    @objc func valueLabelColor() {
        
        valueLabel.textColor = K.Colors.balanceV
        minusPlusLabel.textColor = K.Colors.balanceV
    }
    
    //delete
    @objc func datePickerChangedValue(sender: UIDatePicker) {
        
        dateTextField.text = appData.stringDate(sender)
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        
        if valueLabel.text != "0" {
            
            let value = purposeSwitcher.selectedSegmentIndex == 0 ? "\((Double(valueLabel.text ?? "") ?? 0.0) * (-1))" : valueLabel.text ?? ""
            //let category = purposeSwitcher.selectedSegmentIndex == 0 ? expenseArr[appData.selectedExpense] : incomeArr[appData.selectedIncome]
            DispatchQueue.main.async {
                let category = self.categoryTextField.text ?? ""
                let date = self.dateTextField.text ?? self.dateTextField.placeholder!
                let comment = self.commentTextField.text ?? ""
                print(date, "datedatedatedatedatedate")
                self.addNew(value: value, category: category, date: date == "" ? self.dateTextField.placeholder ?? appData.stringDate(appData.objects.datePicker) : date, comment: comment)
            }
            
        } else {
            errorSaving()
        }
    }
    
    func errorSaving() {
        
        var wasHidden = false
        let bounds = valueLabel.bounds
        if minusPlusLabel.alpha == 0 {
            wasHidden = true
            minusPlusLabel.alpha = 0
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.valueLabel.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + 10, height: bounds.size.height)
        }) { (success:Bool) in
            if success {
                UIView.animate(withDuration: 0.5, animations: {
                    self.valueLabel.bounds = bounds
                })
                if wasHidden == false {
                    self.minusPlusLabel.alpha = 1
                }}
        }
        UIImpactFeedbackGenerator().impactOccurred()
        valueLabel.textColor = K.Colors.negative
        minusPlusLabel.textColor = K.Colors.negative
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(valueLabelColor), userInfo: nil, repeats: false)
        
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        if editingDate != "" {

            let value = "\(editingValueHolder)"
            let category = editingCategoryHolder
            let date = editingDateHolder
            let comment = editingCommentHolder
            addNew(value: value, category: category, date: date, comment: comment)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func purposeSwitched(_ sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex
        switch index {
            
        case 0:
            minusPlusLabel.text = "-"
            //categoryTextField.inputView = appData.objects.expensesPicker
            categoryTextField.text = "\(expenseArr[appData.selectedExpense])"
            showPadPressed(showValueButton)
            
        case 1:
            minusPlusLabel.text = "+"
            //categoryTextField.inputView = appData.objects.incomePicker
            categoryTextField.text = "\(incomeArr[appData.selectedIncome])"
            showPadPressed(showValueButton)
            
        default:
           // categoryTextField.inputView = appData.objects.expensesPicker
            categoryTextField.placeholder = expenseArr[appData.selectedExpense]
        }
    }
    
    @IBAction func showPadPressed(_ sender: UIButton) {
        
        categoryTextField.endEditing(true)
       // dateTextField.endEditing(true)
        commentTextField.endEditing(true)
        UIView.animate(withDuration: 0.2) {
            self.numbarPadView.alpha = 1
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        if pressedValue == "0" {
            pressedValue = ""
        }
        if pressedValue.count != 7 {
            AudioServicesPlaySystemSound(1104)
            pressedValue = pressedValue + (sender.currentTitle ?? "")
            if pressedValue != "0" {
                minusPlusLabel.alpha = 1
            }
        } else {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        DispatchQueue.main.async {
            self.valueLabel.text = self.pressedValue
        }
        
        
    }
    
    @IBAction func erasePressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            AudioServicesPlaySystemSound(1155)
            if pressedValue.count > 0 {
                pressedValue.removeLast()
                valueLabel.text = pressedValue
            }
            if pressedValue.count == 0 {
                pressedValue.removeAll()
                valueLabel.text? = "0"
                minusPlusLabel.alpha = 0
            }
        }
        if sender.tag == 2 {
            AudioServicesPlaySystemSound(1156)
            pressedValue.removeAll()
            valueLabel.text? = "0"
            minusPlusLabel.alpha = 0
        }
    }
    var lastSelectedDate = ""
}


//MARK: - TableView



//MARK: - TextField

extension TransitionVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.numbarPadView.alpha = 0
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 30
    }
    
    
    
}


//MARK: - Custom Text Field

class CustomTextField: UITextField {
    
    var enableLongPressActions = false
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return enableLongPressActions
    }
    
}

extension TransitionVC: CalendarVCProtocol {
    func dateSelected(date: String) {
        dateTextField.text = date
        UserDefaults.standard.setValue(date, forKey: "lastSelectedDate")
    }
    
    
}

extension TransitionVC: CategoriesVCProtocol {
    func categorySelected(category: String, purpose: Int) {
        purposeSwitcher.selectedSegmentIndex = purpose
        purposeSwitched(purposeSwitcher)
        categoryTextField.text = category
        UserDefaults.standard.setValue(category, forKey: "lastSelectedCategory")
    }
    
    
}
