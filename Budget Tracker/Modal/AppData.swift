//
//  AppData.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

class AppData {
    
    var transactions = [Transactions]()
    var categories = [Categories]()
    
    func context() -> NSManagedObjectContext {
        
        if #available(iOS 13.0, *) {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            return context
        } else {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer2.viewContext
        }
        
    }
    
    var selectedExpense = 0
    var selectedIncome = 0
    
    func stringDate(_ sender: UIDatePicker) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: sender.date)
        
    }
    
    var styles = Styles()
    struct Styles {
        
        func shadow(view: UIView) {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.2
            view.layer.shadowOffset = .zero
        }
        
        func cornerRadius(buttons: [UIButton], view: UIView) {
            
            for i in 0..<buttons.count {
                buttons[i].layer.cornerRadius = 6
            }
            
            view.layer.cornerRadius = 6
            view.layer.shadowRadius = 6

        }
        
        func dimNewCell(_ transactionsCell: mainVCcell, index: Int, tableView: UITableView) {

            if transactionsCell.bigDate.text == highliteDate {
                DispatchQueue.main.async {
                    tableView.scrollToRow(at: IndexPath(row: index, section: 1), at: .bottom, animated: true)
                }
                UIView.animate(withDuration: 0.6) {
                    transactionsCell.contentView.backgroundColor = K.Colors.separetor
                }
                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                    highliteDate = " "
                    UIView.animate(withDuration: 0.6) {
                        transactionsCell.contentView.backgroundColor = K.Colors.background
                    }}}
        }
        
        func removeBackground(buttons: [UIButton], labels: [UILabel], views: [UIView]) {
            
            for i in 0..<buttons.count {
                buttons[i].backgroundColor = K.Colors.pink
            }
            for i in 0..<labels.count {
                labels[i].alpha = 0
            }
            for i in 0..<views.count {
                views[i].alpha = 0
            }
        
        }
        
        func showNoDataLabel(_ label: UILabel, tableData: [Transactions]) {
            
            if tableData.count == 0 {
                UIView.animate(withDuration: 0.2) {
                    label.alpha = 0.5 }
            } else {
                UIView.animate(withDuration: 0.2) {
                    label.alpha = 0
                }}
        }
        
    }
    
    var calculation = Calculation()
    struct Calculation {
        var sumIncomes: Double = 0.0
        var sumExpenses: Double = 0.0
        var sumPeriodBalance: Double = 0.0
        
        mutating func recalculation(i:UILabel, e: UILabel, data: [Transactions]) {

            sumIncomes = 0.0
            sumExpenses = 0.0
            sumPeriodBalance = 0.0
            var arreyNegative: [Double] = [0.0]
            var arreyPositive: [Double] = [0.0]
            
            for i in 0..<data.count {
                sumPeriodBalance = sumPeriodBalance + data[i].value
                
                if data[i].value > 0 {
                    arreyPositive.append(data[i].value)
                    sumIncomes = sumIncomes + data[i].value
                    
                } else {
                    arreyNegative.append(data[i].value)
                    sumExpenses = sumExpenses + data[i].value
                }}
            
            if sumPeriodBalance < Double(Int.max), sumIncomes < Double(Int.max), sumExpenses < Double(Int.max) {
                i.text = "\(Int(sumIncomes))"
                e.text = "\(Int(sumExpenses) * -1)"
                
            } else {
                i.text = "\(sumIncomes)"
                e.text = "\(sumExpenses * -1)"
            }
        }
        
        var totalBalance = 0.0
        mutating func calculateBalance(balanceLabel: UILabel) {
            
            var totalExpenses = 0.0
            var totalIncomes = 0.0
            
            for i in 0..<appData.transactions.count {
                if appData.transactions[i].value > 0.0 {
                    totalIncomes = totalIncomes + appData.transactions[i].value
                } else {
                    totalExpenses = totalExpenses + appData.transactions[i].value
                }
            }
            
            totalBalance = totalIncomes + totalExpenses
            if totalBalance < Double(Int.max) {
                balanceLabel.text = "\(Int(totalBalance))"
            } else { balanceLabel.text = "\(totalBalance)" }
            
            if totalBalance < 0.0 {
                balanceLabel.textColor = K.Colors.negative
            } else {
                balanceLabel.textColor = K.Colors.balanceV
            }
            
        }
    }
    
    var objects = Objects()
    struct Objects {
        
        var amountField = UITextField()
        var expensesField = UITextField()
        var expensesPicker = UIPickerView()
        let datePicker = UIDatePicker()
        var incomePicker = UIPickerView()
        
    }
    
    var filter = Filter()
    struct Filter {
        
        var showAll = true
        var from: String = ""
        var to: String = ""
        var lastNumber = 31
        
        func getFirstDay(_ sender: UIDatePicker) -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "01.MM.yyyy"
            return dateFormatter.string(from: sender.date)
        }

        func getLastDay(_ sender: UIDatePicker) -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "\(lastNumber).MM.yyyy"
            return dateFormatter.string(from: sender.date)
        }
        
        
        mutating func setFilterDates(iphoneLabel: UILabel, ipadLabel: UILabel) {
            
            showAll = false
            if filterObjects.startDateField.text == "" {
                filterObjects.startDateField.text = "\(appData.stringDate(filterObjects.startDatePicker))"
            }
            
            if filterObjects.endDateField.text == "" {
                filterObjects.endDateField.text = "\(appData.stringDate(filterObjects.endDatePicker))"
            }
            
            from = filterObjects.startDateField.text!
            to = filterObjects.endDateField.text!
            selectedPeroud = "\(from) → \(to)"
            DispatchQueue.main.async {
                iphoneLabel.text = "Filter: \(selectedPeroud)"
                ipadLabel.text = "Transactions for: \(selectedPeroud)"
            }
            
        }
        
        
        
        
        
        var filterObjects = FilterObjects()
        struct FilterObjects {
            
            let currentDate = UIDatePicker()
            var startDatePicker = UIDatePicker()
            var endDatePicker = UIDatePicker()
            var startDateField = UITextField()
            var endDateField = UITextField()
            
        }
    }
    
    var categoryVC = CategoryVCBrain()
    struct CategoryVCBrain {
        
        let allPurposes = [K.expense, K.income]
        var categoryTextField = UITextField()
        var purposPicker = UIPickerView()
        var purposeField = UITextField()
        var selectedPurpose = 0
        
    }
    
}

//MARK: - sort Item Extension

extension Transactions {
    
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,]
        return formatter
    }()

    var dateFromString: Date {
        let dateString = date!.components(separatedBy: ".").reversed().joined(separator: ".")
        return Transactions.isoFormatter.date(from: dateString)!
    }
}
