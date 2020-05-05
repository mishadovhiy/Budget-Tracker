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

        func cornerRadius(buttons: [UIButton]) {
            
            for i in 0..<buttons.count {
                buttons[i].layer.cornerRadius = 6
            }

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
                    }
                }
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
        
        func getLastDayOf(month: Int, year: Int) -> Int {
            
            let dateComponents = DateComponents(year: year, month: month)
            let calendar = Calendar.current
            let date = calendar.date(from: dateComponents)!

            let range = calendar.range(of: .day, in: .month, for: date)!
            return range.count
        
        }
        
        func getLastDayOf(fullDate: String) -> Int {
            
            if fullDate != "" {
                let month = getMonthFromString(s: fullDate)
                let year = getMonthFromString(s: fullDate)
                
                let dateComponents = DateComponents(year: year, month: month)
                let calendar = Calendar.current
                let date = calendar.date(from: dateComponents)!

                let range = calendar.range(of: .day, in: .month, for: date)!
                return range.count
            } else {
                return 28
            }
        
        }
        
        
        
        func getToday(_ sender: UIDatePicker) -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            return dateFormatter.string(from: sender.date)
        }
        
        func makeTwo(n: Int) -> String {
            if n < 10 {
                return "0\(n)"
            } else {
                return "\(n)"
            }
        }
        
        func getDayFromString(s: String) -> Int {
            
            if s != "" {
                var day = s
                for _ in 0..<8 {
                    day.removeLast()
                }
                return Int(day) ?? 23
            } else {
                return 11
            }
            
        }
        
        
        func getMonthFromString(s: String) -> Int {
            
            if s != "" {
                var month = s
                for _ in 0..<3 {
                    month.removeFirst()
                }
                for _ in 0..<5 {
                    month.removeLast()
                }
                return Int(month) ?? 11
            } else {
                return 11
            }
        }
        
        func getYearFromString(s: String) -> Int {
            
            if s != "" {
                var year = s
                for _ in 0..<6 {
                    year.removeFirst()
                }
                return Int(year) ?? 1996
                
            } else {
                return 1996
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
