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

var lastSelectedDate:String?

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
        super.viewWillDisappear(true)
        print(donePressed, "donePressed")
        if !donePressed {
            self.delegate?.addNewTransaction(value: "", category: "", date: "", comment: "")
        }
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
            vc.darkAppearence = true
            if let date = dateTextField.text {
                vc.selectedFrom = date
            }
            
        case "toCategories":
            print("toCalendar")
            let vc = segue.destination as! CategoriesVC
            vc.delegate = self
            vc.darkAppearence = true
            vc.hideTitle = true
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
        dateTextField.isUserInteractionEnabled = false
        dateTextField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(datePressed)))

        pressedValue = "0"
        commentTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        commentTextField.addTarget(self, action: #selector(commentCount), for: .editingChanged)
        categoryTextField.isUserInteractionEnabled = false
        categoryTextField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryPressed)))
        DispatchQueue.main.async {
            self.valueLabel.text = self.pressedValue
            self.dateTextField.attributedPlaceholder = NSAttributedString(string: lastSelectedDate ?? appData.stringDate(appData.objects.datePicker), attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
            self.commentTextField.attributedPlaceholder = NSAttributedString(string: "Short comment", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
            self.purposeSwitcher.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white], for: .normal)
            self.purposeSwitcher.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "darkTableColor") ?? .black], for: .selected)
        }
    
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
        if editingCategory != "" {
            DispatchQueue.main.async {
                self.categoryTextField.text = self.editingCategory
            }
        }
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
            DispatchQueue.main.async {
                self.categoryTextField.text = self.editingCategory
                self.dateTextField.text = self.editingDate
                self.commentTextField.text = self.editingComment
            }
            editingCategoryHolder = editingCategory
            editingDateHolder = editingDate
            editingValueHolder = editingValue
            editingCommentHolder = editingComment
            DispatchQueue.main.async {
                if (self.commentTextField.text?.count ?? 0) > 0 {
                    self.commentCountLabel.text = "\(30 - (self.commentTextField.text?.count ?? 0))"
                    UIView.animate(withDuration: 0.2) {
                        self.commentCountLabel.alpha = 1
                    }
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
        DispatchQueue.main.async {
            self.valueLabel.text = "\(Int(self.editingValue) * multiply)"
        }
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
    
    
    var donePressed = false
    func addNew(value: String, category: String, date: String, comment: String) {
        donePressed = true
        UIImpactFeedbackGenerator().impactOccurred()
        print("addNew called", value)
        self.dismiss(animated: true) {
            self.delegate?.addNewTransaction(value: value, category: category, date: date, comment: comment)
        }
    }
    
    @objc func valueLabelColor() {
        valueLabel.textColor = K.Colors.category
        minusPlusLabel.textColor = K.Colors.category
    }
    

    
    @IBAction func donePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            if self.valueLabel.text != "0" {
                let selectedSeg = self.purposeSwitcher.selectedSegmentIndex
                let value = selectedSeg == 0 ? "\((Double(self.valueLabel.text ?? "") ?? 0.0) * (-1))" : self.valueLabel.text ?? ""
                let category = self.categoryTextField.text ?? self.categoryTextField.placeholder!
                let date = self.dateTextField.text ?? self.dateTextField.placeholder!
                let comment = self.commentTextField.text ?? ""
                self.addNew(value: value, category: category == "" ? self.categoryTextField.placeholder ?? (selectedSeg == 0 ? self.expenseArr[appData.selectedExpense] : self.incomeArr[appData.selectedIncome]) : category, date: date == "" ? self.dateTextField.placeholder ?? appData.stringDate(appData.objects.datePicker) : date, comment: comment)
            } else {
                self.errorSaving()
            }
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
        var placeHolder = ""
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            DispatchQueue.main.async {
                self.minusPlusLabel.text = "-"
            }
            if !fromDebts {
                DispatchQueue.main.async {
                    self.categoryTextField.text = ""
                }
                if let cat = UserDefaults.standard.value(forKey: "lastSelectedCategory") as? String {
                    categoryTextField.placeholder = cat
                    let allCats = Array(expenseArr)
                    var found = false
                    for i in 0..<allCats.count {
                        if allCats[i] == cat {
                            found = true
                        }
                    }
                    placeHolder = found == true ? cat : "\(expenseArr[appData.selectedExpense])"
                } else {
                    placeHolder = "\(expenseArr[appData.selectedExpense])"
                }
            }
            showPadPressed(showValueButton)
            
        case 1:
            DispatchQueue.main.async {
                self.minusPlusLabel.text = "+"
            }
            if !fromDebts {
                DispatchQueue.main.async {
                    self.categoryTextField.text = ""
                }
                placeHolder = "\(incomeArr[appData.selectedIncome])"
            }
            showPadPressed(showValueButton)
            
        default:
            placeHolder = expenseArr[appData.selectedExpense]
        }
        
        DispatchQueue.main.async {
            self.categoryTextField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white])
        }
    }
    
    @IBAction func showPadPressed(_ sender: UIButton) {
        categoryTextField.endEditing(true)
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
                DispatchQueue.main.async {
                    self.valueLabel.text = self.pressedValue
                }
            }
            if pressedValue.count == 0 {
                pressedValue.removeAll()
                DispatchQueue.main.async {
                    self.valueLabel.text? = "0"
                }
                minusPlusLabel.alpha = 0
            }
        }
        if sender.tag == 2 {
            AudioServicesPlaySystemSound(1156)
            pressedValue.removeAll()
            DispatchQueue.main.async {
                self.valueLabel.text = "0"
            }
            minusPlusLabel.alpha = 0
        }
    }
    

    var fromDebts = false
    
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
        DispatchQueue.main.async {
            self.dateTextField.text = date
        }
        lastSelectedDate = date
    }
    
    
}

extension TransitionVC: CategoriesVCProtocol {
    
    func categorySelected(category: String, purpose: Int, fromDebts: Bool, amount: Int) {
        print("categorySelectedtransactionsvc", category)
        self.fromDebts = fromDebts
        if !fromDebts {
            purposeSwitcher.selectedSegmentIndex = purpose
            purposeSwitched(purposeSwitcher)
            if purpose == 0 {
                UserDefaults.standard.setValue(category, forKey: "lastSelectedCategory")
            }
        } else {
            
            
            DispatchQueue.main.async {
                if self.pressedValue == "" || self.pressedValue == "0" {
                }
                self.valueLabel.text = "\(amount < 0 ? amount * (-1) : amount)"
                self.minusPlusLabel.alpha = 1
                self.purposeSwitcher.selectedSegmentIndex = amount * (-1) < 0 ? 0 : 1
                self.purposeSwitched(self.purposeSwitcher)
                
                let selectedSeg = self.purposeSwitcher.selectedSegmentIndex
                let value = selectedSeg == 0 ? "\(Double(self.valueLabel.text ?? "") ?? 0.0)" : self.valueLabel.text ?? ""
                print(amount, "resultresultresultresult")
                print(selectedSeg)
                print(value, "selectedSegselectedSegselectedSeg")
                
            }
        }
        DispatchQueue.main.async {
            self.categoryTextField.text = category
        }
    }
    
    
}
