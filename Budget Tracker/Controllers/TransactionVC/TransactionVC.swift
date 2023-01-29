//
//  TransactionVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation

///bug:
//when quiting vc its refreshing on mainVC

var lastSelectedDate:String?

protocol TransitionVCProtocol {
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime:DateComponents?, repeated:Bool?)
    func editTransaction(_ transaction:TransactionsStruct, was:TransactionsStruct,reminderTime: DateComponents?, repeated: Bool?, idx:Int?)
    func quiteTransactionVC(reload:Bool)
    func deletePressed()
}

class TransitionVC: SuperViewController {
    var reminder_Repeated:Bool?
    var reminder_Time:DateComponents?
    @IBOutlet weak var removeLastButton: UIButton!
    @IBOutlet weak var removeAllButton: UIButton!
    @IBAction func trashPressed(_ sender: UIButton) {
        donePressed = true
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                DispatchQueue.init(label: "reload").async {
                    self.delegate?.deletePressed()
                }
                
            }
        }
        
    }
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dateTextField: CustomTextField!
    @IBOutlet weak var categoryTextField: CustomTextField!
    @IBOutlet weak var purposeSwitcher: UISegmentedControl!
    @IBOutlet weak var showValueButton: UIButton!
    @IBOutlet weak var numbarPadView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var minusPlusLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentCountLabel: UILabel!
    var paymentReminderAdding = false
    var pressedValue = "0"

    var selectedPurpose: Int?
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

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        purposeSwitcher.selectedSegmentIndex = 0
        purposeSwitched(purposeSwitcher)
        getEditingdata()

        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toCalendar":
            let vc = segue.destination as! CalendarVC
            vc.delegate = self
      //      vc.darkAppearence = true
            vc.selectedFrom = displeyingTransaction.date == "" ? self.defaultDate : displeyingTransaction.date

            if paymentReminderAdding {
                vc.datePickerDate = reminder_Time?.toIsoString() ?? ""
                vc.selectingDate = false
                vc.needPressDone = true
                vc.canSelectOnlyOne = true
            }

        case "toCategories":
            let vc = segue.destination as! CategoriesVC
            vc.delegate = self
        //    vc.darkAppearence = true
            vc.hideTitle = true

        default:
            print("segue default")
        }
    }
    
    lazy var defaultDate:String = {
        return appData.filter.from
    }()
    @IBOutlet weak var doneButton: UIButton!
    var dateChanged = false
    var sbvsloded = false
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !sbvsloded {
            dateTextField.inputView = UIView(frame: .zero)
            dateTextField.isUserInteractionEnabled = false
            dateTextField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(datePressed)))
            commentTextField.addTarget(self, action: #selector(commentCount), for: .editingChanged)
            categoryTextField.isUserInteractionEnabled = false
            categoryTextField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryPressed)))

            self.dateTextField.placeholder = defaultDate
            if editingDate == "" {
                displeyingTransaction.date = defaultDate
            }
            self.dateTextField.setPlaceHolderColor(K.Colors.textFieldPlaceholder)
            self.commentTextField.placeholder = "Short comment".localize
            self.commentTextField.setPlaceHolderColor(K.Colors.textFieldPlaceholder)
            if #available(iOS 13.4, *) {
                appData.objects.datePicker.preferredDatePickerStyle = .wheels
            }
            
        }
    }
    
    
    func updateUI() {
        if paymentReminderAdding {
            self.repeatedView.isHidden = false
            self.repeateSwitch.isOn = (reminder_Repeated ?? false)
        }

        delegates(fields: [categoryTextField, dateTextField, commentTextField])
        appData.objects.datePicker.datePickerMode = .date
        pressedValue = "0"

        DispatchQueue.main.async {
            self.valueLabel.text = self.pressedValue
            
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
        
        DispatchQueue.main.async {
            self.commentCountLabel.text = "\(30 - (self.commentTextField.text?.count ?? 0))"
            if self.commentTextField.text?.count == 30 {
                self.commentCountLabel.textColor = K.Colors.negative
                UIImpactFeedbackGenerator().impactOccurred()
            } else {
                self.commentCountLabel.textColor = K.Colors.balanceT
            }
            if self.commentTextField.text?.count == 0 {
                UIView.animate(withDuration: 0.2) {
                    self.commentCountLabel.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.commentCountLabel.alpha = 1
                }
            }
        }
    }
    
    let db = DataBase()
    func getEditingdata() {
        var lastExpense: NewCategories {
            let all = Array(db.categories)
            for i in 0..<all.count {
                if all[i].purpose == .expense {
                    return all[i]
                }
            }
            return NewCategories(id: -1, name: "Uncategorized", icon: "", color: "", purpose: .expense)
        }
        selectedCategory = db.category(editingCategory) ?? lastExpense
        if editingCategory != "" {
            
            print(selectedPurpose, "selectedPurpose")
            purposeSwitcher.selectedSegmentIndex = selectedPurpose != nil ? selectedPurpose! : 0
            purposeSwitched(purposeSwitcher)
            DispatchQueue.main.async {
                self.categoryTextField.text = self.selectedCategory?.name ?? "-"//self.editingCategory
            }
            
        }
        if editingDate != "" {
            //here
            self.dateChanged = true
            displeyingTransaction.date = editingDate
            if editingValue > 0.0 {
                editingValueAmount(segment: 1, multiply: 1)
            } else {
                editingValueAmount(segment: 0, multiply: -1)
            }
          /*  if #available(iOS 13.0, *) {//desable close
                self.isModalInPresentation = true
            }*/
            minusPlusLabel.alpha = 1
            let db = DataBase()
            let category = db.category(self.editingCategory)
            selectedCategory = category
            DispatchQueue.main.async {
                self.categoryTextField.text = category?.name ?? "-"
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
                if !self.paymentReminderAdding {
                    self.trashButton.isHidden = false
                }
            }
        } else {
            displeyingTransaction.date = defaultDate
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
    

    
    @IBOutlet weak var repeatedView: UIView!
    
    @IBAction func repeatedSwitched(_ sender: UISwitch) {
        DispatchQueue.main.async {
            self.reminder_Repeated = sender.isOn
        }
    }
    var idxHolder:Int?
    var donePressed = false
    func checkDate(date:String, completion:(Bool)->()) {
        if idxHolder != nil {
            if let time = self.reminder_Time {
                var day =  date.stringToCompIso()
                day.hour = time.hour
                day.minute = time.minute
                day.second = time.second
                if !day.expired {
                    completion(true)
                } else {
                    DispatchQueue.main.async {
                        self.newMessage.show(title:"Day can't be older than today".localize, type: .error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.newMessage.show(title:"Set reminder date".localize, type: .error)
                }
            }
        } else {
            completion(true)
        }
        
    }
    func addNew(value: String, category: String, date: String, comment: String) {
        donePressed = true
        print("addNew called", value)
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
            self.checkDate(date: date) { _ in
                self.dismiss(animated: true) {
                    DispatchQueue.init(label: "download").async {
                    if self.editingDate != "" {
                        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
                        let was = TransactionsStruct(value: "\(Int(self.editingValue))", categoryID: self.editingCategory, date: self.editingDate, comment: self.editingComment)
                        self.delegate?.editTransaction(new, was: was, reminderTime: self.reminder_Time, repeated: self.reminder_Repeated, idx: self.idxHolder)
                    } else {
                        self.delegate?.addNewTransaction(value: value, category: category, date: date, comment: comment, reminderTime: self.reminder_Time, repeated: self.reminder_Repeated)
                    }
                    }
                }
            }
            
        }
    }
    
    @objc func valueLabelColor() {
        valueLabel.textColor = K.Colors.category
        minusPlusLabel.textColor = K.Colors.category
    }
    

    var displeyingTransaction = TransactionsStruct(value: "0", categoryID: "", date: "", comment: "")
    
    @IBOutlet weak var repeateSwitch: UISwitch!
    @IBAction func donePressed(_ sender: UIButton) {
     //   selectedCategory
        let newDate = self.displeyingTransaction.date == "" ? defaultDate : self.displeyingTransaction.date
        
        if let category = selectedCategory {
            DispatchQueue.main.async {
                if self.valueLabel.text != "0" {
                    let selectedSeg = self.purposeSwitcher.selectedSegmentIndex
                    let intValue = (Double(self.valueLabel.text ?? "") ?? 0.0) * (-1)
                    let value = selectedSeg == 0 ? "\(Int(intValue))" : self.valueLabel.text ?? ""
                    let comment = self.commentTextField.text ?? ""
                    self.addNew(value: value, category: "\(category.id)", date: newDate, comment: comment)
                } else {
                    self.errorSaving()
                }
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

        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                DispatchQueue.init(label: "reload").async {
                    if self.editingDate != "" {
                        self.delegate?.quiteTransactionVC(reload: true)
                    }
                }
                
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

     //   purposeSwitcher.tintColor = K.Colors.category
    }
    @IBAction func purposeSwitched(_ sender: UISegmentedControl) {
        var placeHolder = ""
        if !fromDebts {
            DispatchQueue.main.async {
                self.categoryTextField.text = ""
            }
            let lastSelectedID = appData.lastSelected.gett(valueType: sender.selectedSegmentIndex == 0 ? .expense : .income)
            if let cat = db.category(lastSelectedID ?? "") {
                selectedCategory = cat
                placeHolder = cat.name
            } else {
                let defCat = db.categories.first ?? NewCategories(id: -1, name: "Unknown".localize, icon: "", color: "", purpose: sender.selectedSegmentIndex == 0 ? .expense : .income)
                selectedCategory = defCat
                placeHolder = defCat.name
            }
        }
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            DispatchQueue.main.async {
                self.minusPlusLabel.text = "-"
            }

            showPadPressed(showValueButton)
            
        case 1:
            DispatchQueue.main.async {
                self.minusPlusLabel.text = "+"
            }

            showPadPressed(showValueButton)
            
        default:
            placeHolder = ""
        }
        
        DispatchQueue.main.async {
            self.categoryTextField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor: K.Colors.textFieldPlaceholder])
        }
    }
    //here
    @IBAction func showPadPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.categoryTextField.endEditing(true)
            self.commentTextField.endEditing(true)
            UIView.animate(withDuration: 0.2) {
                self.numbarPadView.alpha = 1
            }
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
    var selectedCategory: NewCategories?
    var fromDebts = false
    
    var calendarSelectedTime:DateComponents?
    
    
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        DispatchQueue.main.async {
            self.showPadPressed(self.showValueButton)
        }
    }
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
    func dateSelected(date: String, time: DateComponents?) {
        reminder_Time = time
        calendarSelectedTime = time
        dateChanged = true
        let compDate = date.stringToCompIso()
        let newDate = compDate.toShortString() ?? date
        DispatchQueue.main.async {
            self.dateTextField.text = newDate
        }
        lastSelectedDate = newDate
        displeyingTransaction.date = newDate
    }
    
    
}

extension TransitionVC: CategoriesVCProtocol {
    
    func categorySelected(category: NewCategories?, fromDebts: Bool, amount: Int) {
        if let category = category {
            print("categorySelectedtransactionsvc", category)
            self.fromDebts = fromDebts
            if !fromDebts {
                purposeSwitcher.selectedSegmentIndex = category.purpose == .expense ? 0 : 1
                purposeSwitched(purposeSwitcher)
                switch category.purpose {
                case .expense:
                    appData.lastSelected.sett(value: "\(category.id)", valueType: .expense)
                case .income:
                    appData.lastSelected.sett(value: "\(category.id)", valueType: .income)
                case .debt:
                    appData.lastSelected.sett(value: "\(category.id)", valueType: .debt)

                }
            } else {
                appData.lastSelected.sett(value: "\(category.id)", valueType: .debt)
                selectedCategory = category
                DispatchQueue.main.async {
                    
                    if self.pressedValue == "" || self.pressedValue == "0" {
                    }
                   // self.valueLabel.text = "\(amount < 0 ? amount * (-1) : amount)"
                 //   self.minusPlusLabel.alpha = 1
                   // self.purposeSwitcher.selectedSegmentIndex = amount * (-1) < 0 ? 0 : 1
                  //  self.purposeSwitched(self.purposeSwitcher)
                    
                    let selectedSeg = self.purposeSwitcher.selectedSegmentIndex
                    let value = selectedSeg == 0 ? "\(Double(self.valueLabel.text ?? "") ?? 0.0)" : self.valueLabel.text ?? ""
                    print(amount, "resultresultresultresult")
                    print(selectedSeg)
                    print(value, "selectedSegselectedSegselectedSeg")
                    
                }
            }
            selectedCategory = category
            DispatchQueue.main.async {
                self.categoryTextField.text = category.name
            }
        }
        
    }
    
    
}
