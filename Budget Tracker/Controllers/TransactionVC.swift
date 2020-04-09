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

class TransitionVC: UIViewController {

    @IBOutlet weak var dateTextField: CustomTextField!
    @IBOutlet weak var categoryTextField: CustomTextField!
    @IBOutlet weak var purposeSwitcher: UISegmentedControl!
    @IBOutlet weak var showValueButton: UIButton!
    @IBOutlet weak var numbarPadView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var minusPlusLabel: UILabel!
    var pressedValue = "0"
    var expenseArr = [""]
    var incomeArr = [""]
    
    var editingDateHolder = ""
    var editingCategoryHolder = ""
    var editingValueHolder = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        purposeSwitcher.selectedSegmentIndex = 0
        purposeSwitched(purposeSwitcher)
        getEditingdata()
    }
    
    func updateUI() {
        
        loadCategoriesData()
        appendPurposes()
        categoryTextField.delegate = self
        dateTextField.delegate = self
        appData.objects.expensesPicker.delegate = self
        appData.objects.expensesPicker.dataSource = self
        appData.objects.incomePicker.delegate = self
        appData.objects.incomePicker.dataSource = self
        appData.objects.datePicker.datePickerMode = .date
        dateTextField.inputView = appData.objects.datePicker
        appData.objects.datePicker.addTarget(self, action: #selector(datePickerChangedValue(sender:)), for: .valueChanged)
        dateTextField.text = "\(appData.stringDate(appData.objects.datePicker))"
        pressedValue = "0"
        valueLabel.text = pressedValue
    }
    
    func getEditingdata() {
        
        if editingDate != "" {
            self.isModalInPresentation = true
            minusPlusLabel.alpha = 1
            categoryTextField.text = editingCategory
            dateTextField.text = editingDate
            editingCategoryHolder = editingCategory
            editingDateHolder = editingDate
            editingValueHolder = editingValue
            if editingValue > 0.0 {
                self.purposeSwitcher.selectedSegmentIndex = 1
                self.purposeSwitched(self.purposeSwitcher)
                valueLabel.text = "\(Int(editingValue))"
                pressedValue = "\(Int(editingValue))"
            } else {
                self.purposeSwitcher.selectedSegmentIndex = 0
                self.purposeSwitched(self.purposeSwitcher)
                valueLabel.text = "\(Int(editingValue * -1))"
                pressedValue = "\(Int(editingValue) * -1)"
            }
        } else {
            self.isModalInPresentation = false
        }
    }
    
    func appendPurposes() {
        
        expenseArr.removeAll()
        incomeArr.removeAll()
        
        for i in 0..<appData.categories.count {
            if appData.categories[i].purpose == K.expense {
                expenseArr.append(appData.categories[i].name ?? K.Text.unknCat)
            } else {
                incomeArr.append(appData.categories[i].name ?? K.Text.unknCat)
            }}
        
        if expenseArr.count == 0 {
            expenseArr.append(K.Text.unknExpense)
        }
        
        if incomeArr.count == 0 {
            incomeArr.append(K.Text.unknIncome)
        }
    }
    
    func addNew() {
        
        let new = Transactions(context: appData.context)
        let n = Double(valueLabel.text!) ?? 0.0
        
        if purposeSwitcher.selectedSegmentIndex == 0 {
            new.category = expenseArr[appData.selectedExpense]
            new.value = -n
        } else {
            new.category = incomeArr[appData.selectedIncome]
            new.value = n
        }
        appData.transactions.insert(new, at: 0)
        if dateTextField.text == "" {
            dateTextField.text = "\(appData.stringDate(appData.objects.datePicker))"
        }
        new.date = dateTextField.text
        highliteDate = new.date ?? ""
        
        UIImpactFeedbackGenerator().impactOccurred()
        do { try appData.context.save()
        } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
        self.performSegue(withIdentifier: K.quitVC, sender: self)
    }
    
    func loadCategoriesData(_ request: NSFetchRequest<Categories> = Categories.fetchRequest(), predicate: NSPredicate? = nil) {
        
        do { appData.categories = try appData.context.fetch(request)
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}
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
            addNew()
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
                }
            }
        }
        UIImpactFeedbackGenerator().impactOccurred()
        valueLabel.textColor = K.Colors.negative
        minusPlusLabel.textColor = K.Colors.negative
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(valueLabelColor), userInfo: nil, repeats: false)
        
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        if editingDate != "" {
            let new = Transactions(context: appData.context)
            new.category = editingCategoryHolder
            new.value = editingValueHolder
            new.date = editingDateHolder
            appData.transactions.insert(new, at: 0)
            highliteDate = " "
            
            UIImpactFeedbackGenerator().impactOccurred()
            do { try appData.context.save()
            } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
            self.performSegue(withIdentifier: K.quitVC, sender: self)
            
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
        UIView.animate(withDuration: 0.2) {
            self.numbarPadView.alpha = 1
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        if pressedValue == "0" {
            pressedValue = ""
        }
        if pressedValue.count != 7 {
            pressedValue = pressedValue + sender.currentTitle!
            AudioServicesPlaySystemSound(1104)
            if pressedValue != "0" {
                minusPlusLabel.alpha = 1
            }
        } else {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        valueLabel.text = pressedValue
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


//MARK: - extensions
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

//textfield
extension TransitionVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.numbarPadView.alpha = 0
        }
    }
    
}

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
