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

var highliteDate = " "
var editingDate = ""
var editingCategory = ""
var editingValue = 0.0
var editingComment = ""

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
    
    var editingDateHolder = ""
    var editingCategoryHolder = ""
    var editingValueHolder = 0.0
    var editingCommentHolder = ""
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        reloadAllfromDB()
    }
    
    func reloadAllfromDB() {
        
        if appData.username != "" {
            appData.internetPresend = nil
      //      let _ = AppData.DB(username: appData.username, mainView: self)
            print(appData.internetPresend ?? "appData.internetPresend is nil", "internetPresend")
            while appData.internetPresend != nil {
                 if appData.internetPresend == false {
                     DispatchQueue.main.async {
                         self.message.showMessage(text: "No internet, but you stiil can use app", type: .internetError, windowHeight: 50)
                        print("reloadAllfromDB main vc : no internet")
                     }
                     break
                 }
                 
             }

        }
        
    }
    
    
    func updateUI() {
        
        appendPurposes()
        delegates(fields: [categoryTextField, dateTextField, commentTextField], pickes: [appData.objects.expensesPicker, appData.objects.incomePicker])
        appData.objects.datePicker.datePickerMode = .date
        dateTextField.inputView = appData.objects.datePicker
        appData.objects.datePicker.addTarget(self, action: #selector(datePickerChangedValue(sender:)), for: .valueChanged)
        dateTextField.text = "\(appData.stringDate(appData.objects.datePicker))"
        pressedValue = "0"
        valueLabel.text = pressedValue
        commentTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        commentTextField.addTarget(self, action: #selector(commentCount), for: .editingChanged)
        
    }
    
    func delegates(fields: [UITextField], pickes: [UIPickerView]) {
        
        for i in 0..<fields.count {
            fields[i].delegate = self
        }
        for i in 0..<pickes.count {
            pickes[i].delegate = self
            pickes[i].dataSource = self
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

        highliteDate = date
        appData.newValue = [value, category, date, comment]
        //toDo
        //for i in 0..<alldata.count
        //if value == alldata[i].value ...etc
        //let selected = i
        //return
        
        //on main - scroll to selected, higlite selected
        //indeed dim label
        UIImpactFeedbackGenerator().impactOccurred()
        
        if appData.username != "" {
            if !(appData.internetPresend ?? false) {
                var unsavedData = appData.unsavedTransactions
                unsavedData.insert(TransactionsStruct(value: value, category: category, date: date, comment: comment), at: 0)
            } else {
                var allData = appData.transactions
                allData.insert(TransactionsStruct(value: value, category: category, date: date, comment: comment), at: 0)
                print(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                appData.saveTransations(allData)
                let toDataString = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                
                let save = SaveToDB()
                save.Transactions(toDataString: toDataString, mainView: self)
            
            }
        } else {
            var allData = appData.transactions
            allData.insert(TransactionsStruct(value: value, category: category, date: date, comment: comment), at: 0)
            print(TransactionsStruct(value: value, category: category, date: date, comment: comment))
            appData.saveTransations(allData)
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.quitVC, sender: self)
        }

    }
    
    @objc func valueLabelColor() {
        
        valueLabel.textColor = K.Colors.balanceV
        minusPlusLabel.textColor = K.Colors.balanceV
    }
    
    @objc func datePickerChangedValue(sender: UIDatePicker) {
        
        dateTextField.text = appData.stringDate(sender)
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        
        if valueLabel.text != "0" {
            
            let value = purposeSwitcher.selectedSegmentIndex == 0 ? "\((Double(valueLabel.text ?? "") ?? 0.0) * (-1))" : valueLabel.text ?? ""
            let category = purposeSwitcher.selectedSegmentIndex == 0 ? expenseArr[appData.selectedExpense] : incomeArr[appData.selectedIncome]
            let date = dateTextField.text ?? ""
            let comment = commentTextField.text ?? ""
            addNew(value: value, category: category, date: date, comment: comment)
            
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
            categoryTextField.inputView = appData.objects.expensesPicker
            categoryTextField.text = "\(expenseArr[appData.selectedExpense])"
            showPadPressed(showValueButton)
            
        case 1:
            minusPlusLabel.text = "+"
            categoryTextField.inputView = appData.objects.incomePicker
            categoryTextField.text = "\(incomeArr[appData.selectedIncome])"
            showPadPressed(showValueButton)
            
        default:
            categoryTextField.inputView = appData.objects.expensesPicker
            categoryTextField.placeholder = expenseArr[appData.selectedExpense]
        }
    }
    
    @IBAction func showPadPressed(_ sender: UIButton) {
        
        categoryTextField.endEditing(true)
        dateTextField.endEditing(true)
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
    
}


//MARK: - TableView

extension TransitionVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == appData.objects.expensesPicker {
            return expenseArr.count
        } else {
            return incomeArr.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == appData.objects.expensesPicker {
            return expenseArr[row]
        } else {
            return incomeArr[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == appData.objects.expensesPicker {
            categoryTextField.text = expenseArr[row]
            appData.selectedExpense = row
        } else {
            categoryTextField.text = incomeArr[row]
            appData.selectedIncome = row
        }
    }
    
}


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
