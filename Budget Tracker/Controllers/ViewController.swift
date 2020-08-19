//
//  ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

var appData = AppData()
var statisticBrain = StatisticBrain()
var sumAllCategories: [String: Double] = [:]
var allSelectedTransactionsData: [TransactionsStruct] = []
var expenseLabelPressed = true
var selectedPeroud = ""
var refreshDataComlition: Bool?

class ViewController: UIViewController {
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTextLabel: UILabel!
    
    @IBOutlet weak var calculationSView: UIStackView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var addTransitionButton: UIButton!
    @IBOutlet weak var noTableDataLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    var refreshControl = UIRefreshControl()
    var tableData = appData.transactions.sorted{ $0.dateFromString > $1.dateFromString }
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appData.username = "Misha"
        updateUI()
        print("username: \(appData.username)")
        
    }
    
    func updateUI() {
        
        downloadFromDB()
        addRefreshControll()
        let showCatsSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showCats(_:)))
        showCatsSwipe.direction = .right
        DispatchQueue.main.async {
            self.view.addGestureRecognizer(showCatsSwipe)
            self.mainTableView.delegate = self
            self.mainTableView.dataSource = self
        }
        DispatchQueue.main.async {
            self.switchFromCoreData()
        }
        
        if appData.defaults.value(forKey: "firstLaunch") as? Bool ?? false {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toFirstLoad", sender: self)
                self.message.hideMessage()
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (a) in
                    self.createFirstData()
                    self.calculateLabels()
                }
            }
            appData.defaults.set(false, forKey: "firstLaunch")
        }
    }
    
    
    func filter() {
        
        DispatchQueue.main.async {
            self.filterTextLabel.text = "Filtering ..."
        }
        print("filter called")
        print("filter for: ", appData.filter.from, appData.filter.to)
        selectedPeroud = selectedPeroud != "" ? selectedPeroud : "This Month"
        allDaysBetween()
        performFiltering(from: appData.filter.from, to: appData.filter.to, all: appData.filter.showAll)
        calculateLabels()
    }
    
    func allDaysBetween() {
        
        if getYearFrom(string: appData.filter.to) == getYearFrom(string: appData.filter.from) {
            
            let lastDay = "31.\(makeTwo(n: appData.filter.getMonthFromString(s: appData.filter.getToday(appData.filter.filterObjects.currentDate)))).\(appData.filter.getYearFromString(s: appData.filter.getToday(appData.filter.filterObjects.currentDate)))"
            let firstDay = "01.\(makeTwo(n: appData.filter.getMonthFromString(s: appData.filter.getToday(appData.filter.filterObjects.currentDate)))).\(appData.filter.getYearFromString(s: appData.filter.getToday(appData.filter.filterObjects.currentDate)))"
            appData.filter.to = appData.filter.to == "" ? lastDay : appData.filter.to
            appData.filter.from = appData.filter.from == "" ? firstDay : appData.filter.from
            let to = appData.filter.to
            print("allDaysBetween: to - \(to)")
            print("allDaysBetween: from -", appData.filter.from)
            let monthT = appData.filter.getMonthFromString(s: to)
            let yearT = appData.filter.getYearFromString(s: to)
            let dayTo = appData.filter.getLastDayOf(month: monthT, year: yearT)
            selectedToDayInt = dayTo
            print(selectedToDayInt, "selectedToDayInt")
            selectedFromDayInt = appData.filter.getDayFromString(s: appData.filter.from)
            print(selectedFromDayInt, "selectedFromDayInt")
            
            let monthDifference = getMonthFrom(string: appData.filter.to) - getMonthFrom(string: appData.filter.from)
            print(monthDifference, "monthDifference")
            var amount = selectedToDayInt + (31 - selectedFromDayInt) + (monthDifference * 31)
            print(amount)
            if amount < 0 {
                amount *= -1
            }
            print("amount \(amount)")
            
            calculateDifference(amount: amount)
            
            

        } else {
            let yearDifference = (getYearFrom(string: appData.filter.to) - getYearFrom(string: appData.filter.from)) - 1
            let monthDifference = (12 - getMonthFrom(string: appData.filter.from)) + (yearDifference * 12) + getMonthFrom(string: appData.filter.to)
            var amount = selectedToDayInt + (31 - selectedFromDayInt) + (monthDifference * 31)
            if amount < 0 {
                amount *= -1
            }
            calculateDifference(amount: amount)
        }
        
        
        
    }
    func performFiltering(from: String, to: String, all: Bool) {
        
        print("performFiltering called")
        print(daysBetween, "daysBetween")
        if all == true {
            tableData = appData.transactions.sorted{ $0.dateFromString > $1.dateFromString }
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
            print("showing for all time")
            allSelectedTransactionsData = tableData
            print("end performFiltering FROM: \(from), TO: \(to), SHOW ALL: \(all)")
        } else {
            
            print("performFiltering: appending transactions data")
            print("daysBetween: \(daysBetween.count), appData.transactions: \(appData.transactions.count)")
            var arr = tableData
            arr.removeAll()
            var matches = 0
            
            
            let days = Array(daysBetween)
            let transactions = Array(appData.transactions)
            
            for number in 0..<days.count {
                for i in 0..<transactions.count {
                    if days.count > number {
                        if days[number] == transactions[i].date {
                            matches += 1
                            print("\(matches) performFiltering: arr.appended at \(i)")
                            arr.append(transactions[i])
                        }
                    }
                }
            }
            self.tableData = arr.sorted{ $0.dateFromString > $1.dateFromString }
            allSelectedTransactionsData = self.tableData
            print("end performFiltering FROM: \(from), TO: \(to), SHOW ALL: \(all)")
            print("table data reloaded")
            
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
            
        }
        
    }
    func calculateDifference(amount: Int) {
        if appData.filter.to != appData.filter.from {
            print("calculateDifference: appData.filter.from: \(appData.filter.from), appData.filter.to: \(appData.filter.to ), amount: \(amount)")
               var dayA: Int = selectedFromDayInt
               var monthA: Int = getMonthFrom(string: appData.filter.from)
               var yearA: Int = getYearFrom(string: appData.filter.from)
            daysBetween.removeAll()
               for _ in 0..<amount {
                   dayA += 1
                   if dayA == 32 {
                       dayA = 1
                       monthA += 1
                       if monthA == 13 {
                           monthA = 1
                           yearA += 1
                       }
                   }
                   let new: String = "\(makeTwo(n: dayA)).\(makeTwo(n: monthA)).\(makeTwo(n: yearA))"
                print(new, "calculateDifferencenew")
                   if new == appData.filter.to {
                    print("breake new == appData.filter.to; new: \(new), appData.filter.to: \(appData.filter.to)")
                       break
                   }
                   daysBetween.append(new)
               }
        } else {
            print("calculateDifference: appData.filter.from: \(appData.filter.from), appData.filter.to: \(appData.filter.to ), amount: \(amount)")
            daysBetween.removeAll()
            daysBetween.append(appData.filter.from)
            print(daysBetween, "calculateDifference")
        }
        
        
       }
    @objc func refresh(sender:AnyObject) {
    
        if appData.username != "" {
            
            appData.internetPresend = nil
            self.downloadFromDB()
            
        } else {
            print("appData.transactions.count:", appData.transactions.count)
            print("tableData.count:", self.tableData.count)
            self.filter()
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }

    }
    
    var unsavedTransactionsCount = 0
    var previusSelected: IndexPath? = nil
    var selectedCell: IndexPath? = nil
    
    func invalidateTimer() {
        print("invalidateTimer")
        ckeckInternetTimer.invalidate()
    }
    lazy var ckeckInternetTimer = {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (a) in
            print("timer: ")
            if appData.internetPresend == false {
                print("refresh: appData.internetPresend == false")
                self.filter()
                self.invalidateTimer()
            } else {
                print("checking internet")
                if appData.internetPresend == true {
                    self.invalidateTimer()
                }
            }
        }
        
    }()
   
    
        
//MARK: - MySQL
    
    
    //its ok
    func downloadFromDB() {
        
        ckeckInternetTimer.fire()
        if appData.username != "" {
            appData.internetPresend = nil
            print("downloadFromDB: username: \(appData.username), not nill")
            let load = LoadFromDB()
            load.Users(mainView: self) { (loadedData) in
                appData.allUsers = loadedData
                if loadedData.count == 0 {
                    appData.internetPresend = false
                }
                print("loaded")
            }
            
            load.Transactions(mainView: self) { (loadedData) in
                print("loaded \(loadedData.count) transactions from DB")
                print("Transactions:was: \(appData.transactions.count)\nNow: \(loadedData.count)")
                var dataStruct: [TransactionsStruct] = []
                for i in 0..<loadedData.count {
                    
                    let value = loadedData[i][3]
                    let category = loadedData[i][1]
                    let date = loadedData[i][2]
                    let comment = loadedData[i][4]
                    dataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                }
                appData.saveTransations(dataStruct)
                self.invalidateTimer()
                //DispatchQueue.main.async {
                    self.filter()
               // }

            }
            
            load.Categories(mainView: self) { (loadedData) in
                print("loaded \(loadedData.count) Categories from DB")
                print("Categories:was: \(appData.categoriesCoreData.count)\nNow: \(loadedData.count)")
                var dataStruct: [CategoriesStruct] = []
                for i in 0..<loadedData.count {
                    
                    let name = loadedData[i][1]
                    let purpose = loadedData[i][2]
                    dataStruct.append(CategoriesStruct(name: name, purpose: purpose))
                }
 
                appData.saveCategories(dataStruct)
            }
            
        }/* else {
            let load = LoadFromDB()
            load.Users(mainView: self) { (loadedData) in
                appData.allUsers = loadedData
                
                DispatchQueue.main.async {
                    self.filter()
                }
            }
            
        }*/
    
        
    }
    func deleteFromDB(at: Int) {
        
        let Nickname = appData.username
        if Nickname != "" {
            let Category = tableData[at].category
            let Date = tableData[at].date
            let Value = tableData[at].value
            let Comment = tableData[at].comment
            
            let toDataString = "&Nickname=\(Nickname)" + "&Category=\(Category)" + "&Date=\(Date)" + "&Value=\(Value)" + "&Comment=\(Comment)"
            let delete = DeleteFromDB()
            delete.Transactions(toDataString: toDataString, mainView: self)
            
        } else {
            print("noNickname")
        }
    }
    func checkUnsaved() {

        let delete = DeleteFromDB()
        let save = SaveToDB()
        
        print(appData.unsendedData.count, "appData.unsendedData.count")
        for i in 0..<appData.unsendedData.count {
            
            switch appData.unsendedData[i][0] {
            case "delete":
                print("delete unsendedData")
                delete.Transactions(toDataString: appData.unsendedData[i][1], mainView: self, showSucssess: true)
            case "save":
                print("save unsendedData")
                save.Transactions(toDataString: appData.unsendedData[i][1], mainView: self)
            default:
                print("default")
            }
            
        }
    }
    
    
    
//MARK: - Core Data
    
    func switchFromCoreData() {
        
        let dataCount = appData.defaults.value(forKey: "transactionsCoreDataCount") as? Int ?? 1
        print(dataCount, "core data: dataCount")
        if dataCount != 0 {
            DispatchQueue.main.async {
                self.loadItemsCoreData()
            }
            
            if appData.transactionsCoreData.count != 0 {
                var alldata = appData.transactions
                
                for i in 0..<appData.transactionsCoreData.count  {
                    let value = "\(appData.transactionsCoreData[i].value)"
                    let category = appData.transactionsCoreData[i].category ?? ""
                    let date = appData.transactionsCoreData[i].date ?? ""
                    let comment = appData.transactionsCoreData[i].comment ?? ""
                    
                    alldata.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                    
                }
                appData.saveTransations(alldata)
                print(appData.transactions, "transactions setted to defaults")
                
                DispatchQueue.main.async {
                    self.mainTableView.reloadData()
                }
                
                for i in 0..<appData.transactionsCoreData.count {
                    appData.context().delete(appData.transactionsCoreData[i])
                    do { try appData.context().save()
                    } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
                }

                appData.defaults.set(appData.transactionsCoreData.count, forKey: "transactionsCoreDataCount")
                print("after deleting core data, left: \(appData.transactionsCoreData.count)")
            } else {
                print("Transactions: core data count = \(appData.transactionsCoreData.count)")
                appData.defaults.set(appData.transactionsCoreData.count, forKey: "transactionsCoreDataCount")
            }
            
            if appData.categoriesCoreData.count != 0 {
                var allData = appData.getCategories()
                
                for i in 0..<appData.categoriesCoreData.count {
                    let name = appData.categoriesCoreData[i].name ?? ""
                    let purpose = appData.categoriesCoreData[i].purpose ?? ""
                    
                    allData.append(CategoriesStruct(name: name, purpose: purpose))
                }
                appData.saveCategories(allData)
                print(appData.getCategories(), "categories setted to defaults")
            } else {
                print("Categories: core data count = \(appData.categoriesCoreData.count)")
            }
        }
        
        
    }
    func loadItemsCoreData(_ request: NSFetchRequest<Transactions> = Transactions.fetchRequest(), predicate: NSPredicate? = nil) {
        
        print("Loading core data")
        
        do { appData.transactionsCoreData = try appData.context().fetch(request)
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}
        
        let catRequest: NSFetchRequest<Categories> = Categories.fetchRequest()
        do { appData.categoriesCoreData = try appData.context().fetch(catRequest)
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("today is", appData.filter.getToday(appData.filter.filterObjects.currentDate))
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        invalidateTimer()
        print("prepare")
    }
    

//MARK: - Calculation
    
    var sumIncomes: Double = 0.0
    var sumExpenses: Double = 0.0
    var sumPeriodBalance: Double = 0.0
    var totalBalance = 0.0
    
    func calculateLabels() {
        
        recalculation(i: self.incomeLabel, e: self.expenseLabel, data: self.tableData)
        calculateBalance(balanceLabel: self.balanceLabel)
        statisticBrain.getlocalData(from: self.tableData)
        sumAllCategories = statisticBrain.statisticData
        DispatchQueue.main.async {
            self.filterTextLabel.text = "Filter: \(selectedPeroud)"
        }
        
    }
    func recalculation(i:UILabel, e: UILabel, data: [TransactionsStruct]) {

        sumIncomes = 0.0
        sumExpenses = 0.0
        sumPeriodBalance = 0.0
        var arreyNegative: [Double] = [0.0]
        var arreyPositive: [Double] = [0.0]
        print("recalculation", data.count)
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
            DispatchQueue.main.async {
                i.text = "\(Int(self.sumIncomes))"
                e.text = "\(Int(self.sumExpenses) * -1)"
            }
            
            
        } else {
            
            DispatchQueue.main.async {
                i.text = "\(self.sumIncomes)"
                e.text = "\(self.sumExpenses * -1)"
            }
            
        }
        
        print("recalculating labels")
    }
    func calculateBalance(balanceLabel: UILabel) {
        
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
            DispatchQueue.main.async {
                balanceLabel.text = "\(Int(self.totalBalance))"
            }
            
            
        } else {
            DispatchQueue.main.async {
                balanceLabel.text = "\(self.totalBalance)"
            }
            
        }
        
        if totalBalance < 0.0 {
            DispatchQueue.main.async {
                balanceLabel.textColor = K.Colors.negative
            }
        } else {
            DispatchQueue.main.async {
                balanceLabel.textColor = K.Colors.balanceV
            }
        }
        
    }
    

//MARK: - Other
    
    
    var daysBetween = [""]
    var selectedFromDayInt = 0
    var selectedToDayInt = 0
    func makeTwo(n: Int) -> String {
        if n < 10 {
            return "0\(n)"
        } else {
            return "\(n)"
        }
    }
    func getMonthFrom(string: String) -> Int {
        
        if string != "" {
            if string.count == 10 {
                var monthS = string
                for _ in 0..<3 {
                    monthS.removeFirst()
                }
                for _ in 0..<5 {
                    monthS.removeLast()
                }
                return Int(monthS) ?? 11
            } else {
                return 11
            }
            
        } else {
            return 11
        }
    }
    func getYearFrom(string: String) -> Int {
        
        
        if string != "" {
            if string.count == 10 {
                var yearS = string
                for _ in 0..<6 {
                    yearS.removeFirst()
                }
                return Int(yearS) ?? 1996
            } else {
                return 1996
            }
            
            
        } else {
            return 1996
        }
    }
    
    @objc func showCats(_ gesture: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
    }
    func addRefreshControll() {
        
        DispatchQueue.main.async {
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            self.refreshControl.backgroundColor = UIColor.clear
            self.refreshControl.tintColor = K.Colors.pink
            self.mainTableView.addSubview(self.refreshControl)
        }

    }
    
    func deleteRow(at: Int) {
        
        deleteFromDB(at: at)
        tableData.remove(at: at)
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
        appData.saveTransations(tableData)
        calculateLabels()
    }
    func editRow(at: Int) {
        
        print("change edit")
        editingDate = tableData[at].date
        editingValue = Double(tableData[at].value) ?? 0.0
        editingCategory = tableData[at].category
        editingComment = tableData[at].comment
        performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
        deleteRow(at: at)
    }
    func scrollToNew(date: String, category: String, value: String, comment: String) {
        for i in 0..<tableData.count {
            if tableData[i].date == date {
                if tableData[i].value == value {
                    if tableData[i].category == category {
                        if tableData[i].comment == comment {
                            DispatchQueue.main.async {
                                self.mainTableView.scrollToRow(at: IndexPath(row: i, section: 1), at: .bottom, animated: true)
                            }
                            UIView.animate(withDuration: 0.6) {
                                self.mainTableView.cellForRow(at: IndexPath(row: i, section: 1))?.contentView.backgroundColor = K.Colors.separetor
                            }
                            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                                highliteDate = " "
                                UIView.animate(withDuration: 0.6) {
                                    self.mainTableView.cellForRow(at: IndexPath(row: i, section: 1))?.contentView.backgroundColor = K.Colors.background
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    var newValue: String?
    var newCategory: String?
    var newDate: String?
    var newComment: String?
    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.filter()
            
            if self.newValue != nil && self.newCategory != nil && self.newDate != nil && self.newComment != nil {
                DispatchQueue.main.async {
                    self.scrollToNew(date: self.newDate!, category: self.newCategory!, value: self.newValue!, comment: self.newComment!)
                }
            }
            self.newValue = nil
            self.newCategory = nil
            self.newDate = nil
            self.newComment = nil

            editingDate = ""
            editingCategory = ""
            editingValue = 0.0
            editingComment = ""
        }
    }
    @IBAction func homeVC(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.downloadFromDB()
        }
    }
    @IBAction func unwindToFilter(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.filter()
            print("unwindToFilter filter: \(selectedPeroud)")
        }
    }
    @IBAction func settingsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 0: expenseLabelPressed = true
        case 1: expenseLabelPressed = false
        default: expenseLabelPressed = true
        }
        performSegue(withIdentifier: K.statisticSeque, sender: self)
    }
    func createFirstData() {
        
        let transactions = [
            TransactionsStruct(value: "5000", category: "Freelance", date: "\(appData.filter.getToday(appData.filter.filterObjects.currentDate))", comment: ""),
            TransactionsStruct(value: "-350", category: "Food", date: "\(appData.filter.getToday(appData.filter.filterObjects.currentDate))", comment: "")
        ]
        let categories = [
            CategoriesStruct(name: "Food", purpose: K.expense),
            CategoriesStruct(name: "Work", purpose: K.income)
        ]
        appData.saveTransations(transactions)
        appData.saveCategories(categories)
        
        DispatchQueue.main.async {
            self.filterTextLabel.text = "Filter: This Month"
        }
        tableData = transactions
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
        
    }

}

//MARK: - extension

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 1
        case 1: return tableData.count
        case 2:
            if tableData.count < 3 {
                return 0
            } else { return 1 }
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
        guard let calculationCell = mainTableView.dequeueReusableCell(withIdentifier: K.calcCellIdent, for: IndexPath(row: 0, section: 0)) as? calcCell else {return UITableViewCell()}
            if totalBalance != 0.0 && sumExpenses != 0.0 && sumPeriodBalance != 0.0 && sumIncomes != 0.0 {
                
                calculationCell.setupCell(totalBalance, sumExpenses: sumExpenses, sumPeriodBalance: sumPeriodBalance, sumIncomes: sumIncomes)
            } else {
                
                let expenss = sumIncomes == 0.0 && sumExpenses == 0.0 ? "..." : "\(Int(self.sumExpenses))"
                let incomss = sumExpenses == 0.0 && sumIncomes == 0.0 ? "..." : "\(Int(self.sumIncomes))"
                DispatchQueue.main.async {

                    calculationCell.balanceLabel.text = self.totalBalance == 0.0 ? "..." : "\(Int(self.totalBalance))"
                    calculationCell.periodBalanceValueLabel.text = self.sumPeriodBalance == 0.0 ? "..." : "\(Int(self.sumPeriodBalance))"
                    calculationCell.expensesLabel.text = self.sumExpenses == 0.0 ? expenss : "\(Int(self.sumExpenses * -1))"
                    calculationCell.incomeLabel.text = self.sumIncomes == 0.0 ? incomss :  "\(Int(self.sumIncomes))"
                }
            }
            return calculationCell
            
        case 1:
            let data = tableData[indexPath.row]
            let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
            transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell)
            if tableData.count == 0 {
                noTableDataLabel.alpha = 0.5
            } else {
                noTableDataLabel.alpha = 0
            }
            return transactionsCell
            
        case 2:
            let highestExpenseCell = tableView.dequeueReusableCell(withIdentifier: K.plotCellIdent, for: indexPath) as! PlotCell
            highestExpenseCell.setupCell()
            return highestExpenseCell
            
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        case 1:
            if selectedCell == indexPath {
                selectedCell = nil
            } else {
                previusSelected = selectedCell
                selectedCell = indexPath
            }
            DispatchQueue.main.async {
                self.mainTableView.reloadRows(at: [indexPath, self.previusSelected ?? indexPath], with: .automatic)
            }
            
        case 2:
            expenseLabelPressed = true
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        default:
            print("1")
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 {
            let editeAction = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
                self.editRow(at: indexPath.row)
            }
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                self.deleteRow(at: indexPath.row)
                
            }
            editeAction.backgroundColor = K.Colors.yellow
            deleteAction.backgroundColor = K.Colors.negative
            return UISwipeActionsConfiguration(actions: [editeAction, deleteAction])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            calculationSView.alpha = 1
            filterView.alpha = 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            filterView.alpha = 1
            calculationSView.alpha = 0
        }
    }
    
}

