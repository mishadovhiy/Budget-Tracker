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
    
    var transactionsCoreData = [Transactions]()
    var categoriesCoreData = [Categories]()
    
    func context() -> NSManagedObjectContext {
        
        if #available(iOS 13.0, *) {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            return context
        } else {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer2.viewContext
        }
        
    }
    
    let defaults = UserDefaults.standard
    
    var unshowedErrors = ""
    var newValue = [""]
    
    var internetPresend: Bool?
    
    var username: String {
        get{
            return defaults.value(forKey: "username") as? String ?? ""
        }
        set(value){
            print("new username setted - \(value)")
            defaults.set(value, forKey: "username")
        }
    }
    var canShowInternetError: Bool {
        get{
            let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
            let last = defaults.value(forKey: "lastTimeShowedInternetError") as? String ?? "true"
            
            if last == "true" {
                return true
            } else {
                if today == last {
                    return false
                } else {
                    return true
                }
            }
            
        }
        set(value){
            defaults.set(value, forKey: "lastTimeShowedInternetError")
        }
    }
    var password: String {
        get{
            return defaults.value(forKey: "password") as? String ?? ""
        }
        set(value){
            print("new password setted - \(value)")
            defaults.set(value, forKey: "password")
        }
    }
    
    var unshowedError: String {
        get{
            return defaults.value(forKey: "unshowedError") as? String ?? ""
        }
        set(value){
            print("error saved - \(value)")
            defaults.set(value, forKey: "unshowedError")
        }
    }

    var unsendedData:[[String: String]] {
        //0 - type (delete transaction)
        //1 - toDataString
        get {
            return defaults.value(forKey: "unsendedData") as? [[String: String]] ?? []
        }
        set(value){
            defaults.set(value, forKey: "unsendedData")
        }
    }
    
    var unsavedTransactionsAppended = false
    var unsavedCategoriesAppended = false
    var fromLoginVCMessage = ""
    
    func makeTwo(int: Int) -> String {
        return int <= 9 ? "0\(int)" : "\(int)"
    }
    
    //savedTransactions
    //unsavedTransactions
    func saveTransations(_ data: [TransactionsStruct], key: String = "transactionsData") {
        var dict: [[String]] = []
        for i in 0..<data.count {
            let nickname = username
            let value = data[i].value
            let category = data[i].category
            let date = data[i].date
            let comment = data[i].comment
            
            dict.append([nickname, value, category, date, comment])
        }
        print("transactions saved to user defaults, count: \(dict.count)")
        defaults.set(dict, forKey: key)
    }

    var transactions: [TransactionsStruct] {
        get{
            let localData = defaults.value(forKey: "transactionsData") as? [[String]] ?? []
            var results: [TransactionsStruct] = []
            for i in 0..<localData.count {
                let value = localData[i][1]
                let category = localData[i][2]
                let date = localData[i][3]
                let comment = localData[i][4]
                results.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
            }
            return results
        }
    }
    
    var savedTransactions: [TransactionsStruct] {
        get{
            let localData = defaults.value(forKey: "savedTransactions") as? [[String]] ?? []
            var results: [TransactionsStruct] = []
            for i in 0..<localData.count {
                let value = localData[i][1]
                let category = localData[i][2]
                let date = localData[i][3]
                let comment = localData[i][4]
                results.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
            }
            return results
        }
    }
    
    var unsavedTransactions: [TransactionsStruct] {
        get{
            var results: [TransactionsStruct] = []
            let localData = defaults.value(forKey: "unsavedTransactions") as? [[String]] ?? []
            
            for i in 0..<localData.count {
                let value = localData[i][1]
                let category = localData[i][2]
                let date = localData[i][3]
                let comment = localData[i][4]
                results.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
            }
            
            return results
        }
        set(value) {
            
            var results: [[String]] = []
            for i in 0..<value.count {
                results.append([username, value[i].value, value[i].category, value[i].date, value[i].comment])
            }
            
            defaults.set(results, forKey: "unsavedTransactions")
        }
    }

    //"savedCategories" -- from prev acc
    //"unsavedCategories" -- when no internet
    func saveCategories(_ data: [CategoriesStruct], key: String = "categoriesData") {
        var dict: [[String]] = []
        for i in 0..<data.count {
            let nickname = username
            let name = data[i].name
            let purpose = data[i].purpose
            
            dict.append([nickname, name, purpose])
        }
        print("categories saved to user defaults, count: \(dict.count), \(dict)")
        defaults.set(dict, forKey: key)
    }
    
    //"savedCategories" -- from prev acc
    //"unsavedCategories" -- when no internet
    func getCategories(key: String = "categoriesData") -> [CategoriesStruct] {
        let localData = defaults.value(forKey: key) as? [[String]] ?? []
        var results: [CategoriesStruct] = []
        for i in 0..<localData.count {
            let name = localData[i][1]
            let purpose = localData[i][2]
            results.append(CategoriesStruct(name: name, purpose: purpose))
        }
        return results
    }
    
    func createFirstData(_ tableview: UITableView) {
        let transactions = [
            TransactionsStruct(value: "5000", category: "Freelance", date: "\(filter.getToday(appData.filter.filterObjects.currentDate))", comment: ""),
            TransactionsStruct(value: "-350", category: "Food", date: "\(filter.getToday(appData.filter.filterObjects.currentDate))", comment: "")
        ]
        let categories = [
            CategoriesStruct(name: "Food", purpose: K.expense),
            CategoriesStruct(name: "Work", purpose: K.income)
        ]
        saveTransations(transactions)
        saveCategories(categories)
        
        DispatchQueue.main.async {
            tableview.reloadData()
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
        
        /*func dimNewCell(_ transactionsCell: mainVCcell, index: Int, tableView: UITableView) {

            DispatchQueue.main.async {
                tableView.scrollToRow(at: IndexPath(row: index, section: 1), at: .bottom, animated: true)
            }
            UIView.animate(withDuration: 0.6) {
                transactionsCell.contentView.backgroundColor = K.Colors.separetor
            }
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                UIView.animate(withDuration: 0.6) {
                    transactionsCell.contentView.backgroundColor = K.Colors.background
                }
            }
        }*/

        func showNoDataLabel(_ label: UILabel, tableData: [TransactionsStruct]) {
            
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
        
        mutating func recalculation(i:UILabel, e: UILabel, data: [TransactionsStruct]) {

            sumIncomes = 0.0
            sumExpenses = 0.0
            sumPeriodBalance = 0.0
            var arreyNegative: [Double] = [0.0]
            var arreyPositive: [Double] = [0.0]
            
            for i in 0..<data.count {
                sumPeriodBalance = sumPeriodBalance + (Double(data[i].value) ?? 0.0)
                
                if (Double(data[i].value) ?? 0.0) > 0 {
                    arreyPositive.append((Double(data[i].value) ?? 0.0))
                    sumIncomes = sumIncomes + (Double(data[i].value) ?? 0.0)
                    
                } else {
                    arreyNegative.append((Double(data[i].value) ?? 0.0))
                    sumExpenses = sumExpenses + (Double(data[i].value) ?? 0.0)
                }}
            
            if sumPeriodBalance < Double(Int.max), sumIncomes < Double(Int.max), sumExpenses < Double(Int.max) {
                i.text = "\(Int(sumIncomes))"
                e.text = "\(Int(sumExpenses) * -1)"
                
            } else {
                i.text = "\(sumIncomes)"
                e.text = "\(sumExpenses * -1)"
            }
            
            print("recalculating labels")
        }
        
        var totalBalance = 0.0
        
        mutating func calculateBalance(balanceLabel: UILabel) {
            
            var totalExpenses = 0.0
            var totalIncomes = 0.0
            let transactions = appData.transactions
            
            for i in 0..<transactions.count {

                let value = Double(transactions[i].value) ?? 0.0
                if value > 0.0 {
                    totalIncomes = totalIncomes + value
                } else {
                    totalExpenses = totalExpenses + value
                }
            }
            
            totalBalance = totalIncomes + totalExpenses
            
            if totalBalance < Double(Int.max) {
                balanceLabel.text = "\(Int(self.totalBalance))"
                
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
        
        var showAll = false
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
        
        
        
        func getToday(_ sender: UIDatePicker, dateformatter: String = "dd.MM.yyyy") -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateformatter
            var date: Date? = nil
            DispatchQueue.main.async {
                date = sender.date
            }
            let results = dateFormatter.string(from: date ?? Date())
            return results
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
    
    
    func createFirstData(completion: @escaping () -> ()) {
        
        
        let transactions = [
            TransactionsStruct(value: "5000", category: "Freelance", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.MM.yyyy"))", comment: ""),
            TransactionsStruct(value: "10000", category: "Work", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.01.yyyy"))", comment: ""),
            TransactionsStruct(value: "-100", category: "Food", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.MM.yyyy"))", comment: ""),
            TransactionsStruct(value: "-400", category: "Food", date: "\(filter.getToday(filter.filterObjects.currentDate))", comment: ""),
            TransactionsStruct(value: "-1000", category: "Bills", date: "\(filter.getToday(filter.filterObjects.currentDate))", comment: ""),
        ]
        let categories = [
            CategoriesStruct(name: "Food", purpose: K.expense),
            CategoriesStruct(name: "Taxi", purpose: K.expense),
            CategoriesStruct(name: "Public Transport", purpose: K.expense),
            CategoriesStruct(name: "Bills", purpose: K.expense),
            CategoriesStruct(name: "Work", purpose: K.income),
            CategoriesStruct(name: "Freelance", purpose: K.income)
        ]
        saveTransations(transactions)
        saveCategories(categories)
        completion()
    }
    

    
}

//MARK: - sort Item Extension


extension TransactionsStruct {
    
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,]
        return formatter
    }()

    var dateFromString: Date {
        let dateString = date.components(separatedBy: ".").reversed().joined(separator: ".")
        if TransactionsStruct.isoFormatter.date(from: dateString) == nil {
            return Date.init(timeIntervalSince1970: 1)
        } else {
            return TransactionsStruct.isoFormatter.date(from: dateString)!
        }
    }
    
}

struct TransactionsStruct {
    let value: String
    let category: String
    let date: String
    let comment: String
}


struct CategoriesStruct {
    let name: String
    let purpose: String
}

