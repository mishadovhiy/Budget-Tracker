//
//  AppData.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit



class AppData {
    
    static var linkColor: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "SelectedTintColor")
            let color = colorNamed(newValue)
            DispatchQueue.main.async {
                let window = UIApplication.shared.keyWindow ?? UIWindow()
                window.tintColor = color
            }
        }
        get {
            return UserDefaults.standard.value(forKey: "SelectedTintColor") as? String ?? "Yellow"
        }
    }
    
    let defaults = UserDefaults.standard
    var safeArea: (CGFloat, CGFloat) = (0.0, 0.0)//0-bt  1-top
    var unshowedErrors = ""
    
    var deptsData: [CategoriesStruct] = []

    let lastSelected = LastSelected()
    
    var proVersion: Bool {
        get{
            let result = !purchasedOnThisDevice ? (defaults.value(forKey: "proVersion") as? Bool ?? false) : purchasedOnThisDevice
            print(result, "resultresultresultresultresult")
            return result
        }
        set(value){
            defaults.set(value, forKey: "proVersion")
        }
    }
    
    var purchasedOnThisDevice: Bool {
        get{
            return defaults.value(forKey: "purchasedOnThisDevice") as? Bool ?? false
        }
        set(value){
            defaults.set(value, forKey: "purchasedOnThisDevice")
        }
    }
    
    var trialDate: String {
        get{
            return defaults.value(forKey: "trialDate") as? String ?? ""
        }
        set(value){
            defaults.set(value, forKey: "trialDate")
        }
    }
    
    var proTrial: Bool {
        get{
            return defaults.value(forKey: "proTrial") as? Bool ?? false
        }
        set(value){
            defaults.set(value, forKey: "proTrial")
        }
    }
    
    
    var deliveredNotificationIDs: [String] {
        get {
            let result = UserDefaults.standard.value(forKey: "deliveredNotificationIDs") as? [String]
            print(result ?? ["-"], "deliveredNotificationIDs")
            return result ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "deliveredNotificationIDs")
            AppDelegate.shared.center.getDeliveredNotifications { notifications in
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = notifications.count + newValue.count
                }
            }
        }
    }

    
    
    func emailFromLoadedDataPurch(_ data:[[String]]) -> String? {
        //get user email
        //loadedData.append([name, email, password, registrationDate, pro, trialDate])
        if !appData.purchasedOnThisDevice {
            let currnt = appData.username
            var emailOptional:String?
            for i in 0..<data.count {
                if data[i][0] == currnt {
                    emailOptional = data[i][1]
                }
            }
            if let email = emailOptional {
                var dbPurch = false
                for i in 0..<data.count {
                    if !dbPurch {
                        if data[i][1] == email {
                            if data[i][4] == "1" {
                                dbPurch = true
                                break
                            }
                        }
                    }
                }
                appData.proVersion = dbPurch
                print("dbPurch:", dbPurch)
                return email
            }
            
        }
        return nil
    }
    
    
    var username: String {
        get{
            return defaults.value(forKey: "username") as? String ?? ""
        }
        set(value){
            print("new username setted - \(value)")
            defaults.set(value, forKey: "username")
        }
    }
    
    var selectedUsernames: [String] {//сохранять и пароль и имейл и все что приходит
        get{
            let users = defaults.value(forKey: "selectedUsernames") as? [String] ?? ([defaults.value(forKey: "username") as? String ?? ""])
            return users// + ["mishadovhiy2"]
        }
        set(value){
            print("new usernames setted - \(value)")
            defaults.set(value, forKey: "selectedUsernames")
        }
    }
    
    var loggedUsers: [String] {
        get{
            let users = defaults.value(forKey: "selectedUsernames") as? [String] ?? ([defaults.value(forKey: "username") as? String ?? ""])
            return users + ["mishadovhiy2"]
        }
        set(value){
            print("new usernames setted - \(value)")
            defaults.set(value, forKey: "selectedUsernames")
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
    
    var userEmailHolder: String {
        get{
            return defaults.value(forKey: "userEmailHolder") as? String ?? ""
        }
        set(value){
            print("new password setted - \(value)")
            defaults.set(value, forKey: "userEmailHolder")
        }
    }
    
    var devMode:Bool {
        return userEmailHolder.contains("dovhiy.com")
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

    var unsendedData:[[String: [String:Any]]] {
        //0 - type (delete transaction)
        //1 - toDataString
        get {
            return defaults.value(forKey: "unsendedData") as? [[String: [String:Any]]] ?? []
        }
        set(value){
            defaults.set(value, forKey: "unsendedData")
        }
    }

    var fromLoginVCMessage = ""
    
    func makeTwo(int: Int) -> String {
        return int <= 9 ? "0\(int)" : "\(int)"
    }
    
    //savedTransactions
    //unsavedTransactions 
    func saveTransations(_ data: [TransactionsStruct], key: String = "transactionsData") {//delete
        var dict: [[String]] = []
        for i in 0..<data.count {
            let nickname = username
            let value = data[i].value
            let category = data[i].categoryID
            let date = data[i].date
            let comment = data[i].comment
            
            dict.append([nickname, value, category, date, comment])
        }
        print("transactions saved to user defaults, count: \(dict.count)")
        UserDefaults.standard.set(dict, forKey: key)
    }
    
    var debts: [DebtsStruct] {
        get {
            let localData = Array(defaults.value(forKey: "allDebts") as? [[String]] ?? [])
            var results: [DebtsStruct] = []
            for i in 0..<localData.count {
                let name = localData[i][1]
                let amountToPay = localData[i][2]
                let dueDate = localData[i][3]
                results.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
            }
            return results
        }
        set {
            var dict: [[String]] = []
            for i in 0..<newValue.count {
                let nickname = username
                let name = newValue[i].name
                let amountToPay = newValue[i].amountToPay
                let dueDate = "\(newValue[i].dueDate)"
                dict.append([nickname, name, amountToPay, dueDate])
            }
            print("debts saved to user defaults, count: \(dict.count), \(dict)")
            defaults.set(dict, forKey: "allDebts")
        }
    }
    //"savedDebts" -- from prev acc
    //"unsavedDebts" -- when no internet
    func saveDebts(_ data: [DebtsStruct], key: String = "allDebts") {
        var dict: [[String]] = []
        for i in 0..<data.count {
            let nickname = username
            let name = data[i].name
            let amountToPay = data[i].amountToPay
            let dueDate = "\(data[i].dueDate)"
            dict.append([nickname, name, amountToPay, dueDate])
        }
        print("debts saved to user defaults, count: \(dict.count), \(dict), key:", key)
        defaults.set(dict, forKey: key)
    }
    func getDebts(key: String = "allDebts") -> [DebtsStruct] {
        let localData = Array(defaults.value(forKey: key) as? [[String]] ?? [])
        var results: [DebtsStruct] = []
        for i in 0..<localData.count {
            let name = localData[i][1]
            let amountToPay = localData[i][2]
            let dueDate = localData[i][3]
            results.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
        }
        return results
    }
    

    var getTransactions: [TransactionsStruct] {//
        get{
            let localData = Array(defaults.value(forKey: "transactionsData") as? [[String]] ?? [])
            var results: [TransactionsStruct] = []
            for i in 0..<localData.count {
                let value = localData[i][1]
                let category = localData[i][2]
                let date = localData[i][3]
                let comment = localData[i][4]
                results.append(TransactionsStruct(value: value, categoryID: category, date: date, comment: comment))
            }
            return results
        }
    }
    
    var getLocalTransactions: [TransactionsStruct] {
        get{
            let localData = defaults.value(forKey: K.Keys.localTrancations) as? [[String]] ?? []
            var results: [TransactionsStruct] = []
            for i in 0..<localData.count {
                let value = localData[i][1]
                let category = localData[i][2]
                let date = localData[i][3]
                let comment = localData[i][4]
                results.append(TransactionsStruct(value: value, categoryID: category, date: date, comment: comment))
            }
            return results
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
        print("categories saved to user defaults, count: \(dict.count), \(dict), key:", key)
        defaults.set(dict, forKey: key)
    }
    
    //"savedCategories" -- from prev acc
    //"unsavedCategories" -- when no internet
    func getCategories(key: String = "categoriesData") -> [CategoriesStruct] {//
        let localData = defaults.value(forKey: key) as? [[String]] ?? []
        var results: [CategoriesStruct] = []
       // let trans = Array(transactions)
        let trans = UserDefaults.standard.value(forKey: "transactionsData") as? [[String]] ?? []
        for i in 0..<localData.count {
            let name = localData[i][1]
            let purpose = localData[i][2]
            var count = 0
            for t in 0..<trans.count {
                if trans[t][2] == name {
                    count += 1
                }
            }
            results.append(CategoriesStruct(name: name, purpose: purpose, count: count))
        }
        return results
    }
    
    var selectedExpense = 0
    var selectedIncome = 0
    

    let categoryColors = [
        "BlueColor", "BlueColor2", "BlueColor3", "GreenColor", "GreenColor-2", "yellowColor2", "OrangeColor", "OrangeColor-1", "pinkColor2", "PinkColor", "PinkColor-1", "RedColor", "yellowColor"
    ]
    
    let screenColors = [
        "BlueColor", "BlueColor2", "BlueColor3", "GreenColor", "GreenColor-2", "yellowColor2", "OrangeColor", "OrangeColor-1", "pinkColor2", "PinkColor", "PinkColor-1", "RedColor", "yellowColor"
    ]
    
    var randomColorName: String {
        let data = categoryColors
        return data[Int.random(in: 0..<data.count)]
    }
    
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
            let transactions = appData.getTransactions
            
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
        var purposeField = UITextField()
        var selectedPurpose = 0
        
    }
    
    
    func createFirstData(completion: @escaping () -> ()) {
        
       /* let transactions = [
            TransactionsStruct(value: "5000", categoryID: "Freelance", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.MM.yyyy"))", comment: ""),
            TransactionsStruct(value: "10000", categoryID: "Work", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.01.yyyy"))", comment: ""),
            TransactionsStruct(value: "-100", categoryID: "Food", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.MM.yyyy"))", comment: ""),
            TransactionsStruct(value: "-400", categoryID: "Food", date: "\(filter.getToday(filter.filterObjects.currentDate))", comment: ""),
            TransactionsStruct(value: "-1000", categoryID: "Bills", date: "\(filter.getToday(filter.filterObjects.currentDate))", comment: ""),
        ]
        let categories = [
            CategoriesStruct(name: "Food", purpose: K.expense, count: 0),
            CategoriesStruct(name: "Taxi", purpose: K.expense, count: 0),
            CategoriesStruct(name: "Public Transport", purpose: K.expense, count: 0),
            CategoriesStruct(name: "Bills", purpose: K.expense, count: 0),
            CategoriesStruct(name: "Work", purpose: K.income, count: 0),
            CategoriesStruct(name: "Freelance", purpose: K.income, count: 0)
        ]
        saveTransations(transactions)
        saveCategories(categories)*/
        completion()
    }
    
    func returnMonth(_ month: Int) -> String {
        let monthes = [
            1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun",
            7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"
        ]
        return monthes[month] ?? "Jan"
    }
    func presentBuyProVC(currentVC: UIViewController, selectedProduct:Int) {
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        let vccc = storyboard.instantiateViewController(withIdentifier: "BuyProVC") as! BuyProVC
        vccc.modalPresentationStyle = .formSheet
        vccc.navigationController?.setNavigationBarHidden(true, animated: false)
        vccc.selectedProduct = selectedProduct
        currentVC.present(vccc, animated: true)
    }
    
    
    func presentMoreVC(currentVC: UIViewController, data: [MoreVC.ScreenData], proIndex: Int = 0) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vccc = storyboard.instantiateViewController(withIdentifier: "MoreVC") as! MoreVC
            vccc.modalPresentationStyle = .overFullScreen //.overCurrentContext - cant swipe close
            vccc.tableData = data
            vccc.navigationController?.setNavigationBarHidden(true, animated: false)
            let cellHeight = 50
            let contentHeight = (data.count) * cellHeight
            let safeAt = appData.safeArea.1
            let safebt = appData.safeArea.0
            
            //let tableInButtom = (currentVC.view.frame.height - (safeAt + safebt + 150)) - CGFloat(contentHeight)
            
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            let screenHeight = window.frame.height//currentVC.view.frame.height
            print(safeAt, "safebtsafebt")
            let additionalMargin:CGFloat = safeAt > 0 ? 45 : 40
            let tableInButtom = (screenHeight - (safeAt + safebt + additionalMargin)) - (CGFloat(contentHeight))
            //2
            print(tableInButtom, "sectionHeight")
            print(currentVC.view.frame.height, "ScreenHeight")
          //  firstCellHeight = CGFloat(contentHeight) > self.view.frame.height / 2 ? self.view.frame.height / 2 : tableInButtom
            if CGFloat(contentHeight) > currentVC.view.frame.height / 2 {
                vccc.firstCellHeight = currentVC.view.frame.height / 2
            } else {
                vccc.firstCellHeight = tableInButtom
            }
            vccc.selectedProIndex = proIndex
            vccc.cellHeightCust = CGFloat.init(cellHeight)
            currentVC.present(vccc, animated: true)
        }
        
    }

    

    
    
}


extension UIViewController {
    func shadow(for view:UIView, opasity: Float = 0.4, radius:CGFloat? = 9, color: UIColor = K.Colors.secondaryBackground) {
        DispatchQueue.main.async {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = opasity
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 12
            if let radius = radius {
                view.layer.cornerRadius = radius
            }
            
            view.backgroundColor = color
        }
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
    var categoryID: String
    var date: String
    let comment: String
    
    var category:NewCategories {
        let db = DataBase()
        return db.category(categoryID) ?? NewCategories(id: -1, name: "Unknown", icon: "", color: "", purpose: .expense)
    }
    
}


struct CategoriesStruct {
    let name: String
    let purpose: String
    let count: Int
}


enum CategoryPurpose {
    case expense
    case income
    case debt
}
func purposeToString(_ pupose:CategoryPurpose) -> String {
    switch pupose {
    case .debt:
        return "debt"
    case .income:
        return K.income
    case .expense:
        return K.expense
    }
}
func stringToPurpose(_ string: String) -> CategoryPurpose {
    switch string {
    case K.income:
        return .income
    case K.expense:
        return .expense
    case "Debt":
        return .debt
    default:
        return .debt
    }
}

struct DebtsStruct {
    let name: String
    var amountToPay: String
    var dueDate: String
}



class NavigationController : UINavigationController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("navTouches")
    }
    
   /* override func viewWillDisappear(_ animated: Bool) {
        
    }*/
}


func stringToDateComponent(s: String, dateFormat:String="dd.MM.yyyy") -> DateComponents {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    let date = dateFormatter.date(from: s)
    return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? Date())
}
func stringToCompIso(s: String, dateFormat:String="dd.MM.yyyy") -> DateComponents {
    if let date = s.iso8601withFractionalSeconds {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    } else {
        return stringToDateComponent(s: s, dateFormat: dateFormat)
    }
}

func dateCompToIso(isoComp: DateComponents) -> String? {
    if let date = Calendar.current.date(from: isoComp){ //isoComp.date {
        return date.iso8601withFractionalSeconds
    }
    return nil
}


func iconNamed(_ name: String?) -> UIImage {
    print("iconNamed:", name ?? "-")
    let def = "photo.fill"
    let namee = name ?? def
    let resultName = namee != "" ? namee : def
    if #available(iOS 13.0, *) {
        return UIImage(named: resultName) ?? UIImage(named: def)!
    } else {
        return UIImage(named: "warning")!
    }
    
}

func colorNamed(_ name: String?) -> UIColor {
    print("colorNamed:", name ?? "-")
    let defaultCo = K.Colors.link ?? .red
    if name ?? "" != "" {
        return UIColor(named: name ?? "") ?? defaultCo
    } else {
        return defaultCo
    }
}




