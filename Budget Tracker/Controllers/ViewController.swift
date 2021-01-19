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

/* animation
 transactionVC:
 - when add pressed - vc.frame = add button frame and to init frame
 orange background, (pluss icon maybe)
 - when editing - vc.frame = cell frame
 white background, labels positions - cell.labels positions
 
 when quiting, done sucs - vc.frame = oval and going down
 */

/*
 if unsended data - show view (view pressed - perform vc)
 show from up to down
 */

class ViewController: UIViewController, TransitionVCProtocol {
    func addNewTransaction(value: String, category: String, date: String, comment: String) {
        let new = TransactionsStruct(value: value, category: category, date: date, comment: comment)
        let save = SaveToDB()
        save.Transactions(transactionStruct: new, mainView: self, completion: { (error) in
            if error {
                var allunsended = appData.unsavedTransactions
                allunsended.append(new)
                appData.unsavedTransactions = allunsended
                self.filter()
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Error saving data", type: .error)
                }
                print("error saving new data - save to unsended")
                
            } else {
                self.filter()
                print("new dana has sended")
            }
            self.editingIndexPath = nil
        })
    }
    
    func quiteTransactionVC() {
        print("mk bvgyhkmhjk")
    }
    
    
    
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
    var tableData = appData.transactions.sorted{ $0.dateFromString < $1.dateFromString }
   // var newTableData: [tableStuct] = []
    var _TableData: [tableStuct] = []
    var newTableData: [tableStuct] {
        get {
            return _TableData
        }
        set {
            _TableData = newValue
            print("self.tableData.count:", self.tableData.count)
            DispatchQueue.main.async {
                
                self.mainTableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                self.mainTableView.isScrollEnabled = self.tableData.count == 0 ? false : true
                
                if self.tableData.count == 0 {
                    self.mainTableView.backgroundColor = K.Colors.background
                    self.noTableDataLabel.alpha = 0.5
                    self.noTableDataLabel.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } else {
                    self.mainTableView.backgroundColor = .clear
                    self.noTableDataLabel.alpha = 0
                    self.noTableDataLabel.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height, 0)
                }
                
                if self.forseSendUnsendedData {
                    if appData.unsavedTransactions.count > 0 {
                        print("table data reloaded, unse count:", appData.unsavedTransactions.count)
                        self.sendUnsaved()
                    }
                }
                
            }
        }
    }
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()

    var forseSendUnsendedData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //transaDelegate = self
        print("username: \(appData.username)")
        /*var res: [TransactionsStruct] = []
        for i in 0..<20{
            let new = TransactionsStruct(value: "\(i + 1)", category: "1", date: "22.01.2021", comment: "i")
            res.append(new)
        }
        unsendedTransactions = res*/
        
        updateUI()
        /*DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.sendUnsaved()
        }*/
        
        print(appData.unsavedTransactions.count, "unsended")
        
    }
    
    var viewLoadedvar = false
    override func viewDidLayoutSubviews() {
        filterView.layer.masksToBounds = true
        filterView.layer.cornerRadius = 6
        if !viewLoadedvar {
            whiteBackgroundFrame = whiteBackground.frame
        }
    }
    
    @IBOutlet weak var secondAddTransButton: UIButton!
    var refreshSubview = UIView.init(frame: .zero)
    func updateUI() {
        self.mainTableView.backgroundColor = K.Colors.background
        downloadFromDB()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        DispatchQueue.main.async {
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            let superWidth = self.view.frame.width
            let buttonWidth = self.secondAddTransButton.frame
            
            self.refreshSubview.frame = CGRect(x: superWidth / 2 - (buttonWidth.width / 2), y: 0, width: buttonWidth.width, height: buttonWidth.height)
            print(self.refreshSubview.frame, "ijhyghujijnhj")
            self.refreshSubview.addSubview(self.secondAddTransButton)
            self.refreshSubview.backgroundColor = K.Colors.background
            self.refreshSubview.alpha = 0
            self.refreshControl.addSubview(self.refreshSubview)
            self.mainTableView.addSubview(self.refreshControl)
            self.noTableDataLabel.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height, 0)
            self.noTableDataLabel.alpha = 0
        }
        switchFromCoreData()
        if appData.defaults.value(forKey: "firstLaunch") as? Bool ?? true {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toFirstLoad", sender: self)
            }
            
        }
    }
    
    
    struct tableStuct {
        let date: String
        var transactions: [TransactionsStruct]
    }
    func createTransactionsFor(date: String, filteredData: [TransactionsStruct]) -> [TransactionsStruct] {
        var result: [TransactionsStruct] = []
        let arr = Array(filteredData.sorted{ $0.dateFromString < $1.dateFromString })
        for i in 0..<arr.count {
            if date == arr[i].date {
                print("createTransactionsFor appended", arr[i])
                result.append(arr[i])
            }
        }
        return result
    }
    
    func filter() {
        
        DispatchQueue.main.async {
            self.filterTextLabel.text = "Filtering ..."
        }
        print("filter called")
        print("filter for: ", appData.filter.from, appData.filter.to)
        selectedPeroud = selectedPeroud != "" ? selectedPeroud : "This Month"
        allDaysBetween()
        let allFilteredData = performFiltering(from: appData.filter.from, to: appData.filter.to, all: appData.filter.showAll).sorted{ $0.dateFromString < $1.dateFromString }
        print("filterrrr: all filtered: ", allFilteredData)
        
        newTableData = createTableData(filteredData: allFilteredData)
        calculateLabels()
        /*let tableTrans = Array(allFilteredData) + Array(unsendedTransactions)
        let allTrans = Array(appData.transactions) + Array(unsendedTransactions)
        //recalculation(i: self.incomeLabel, e: self.expenseLabel, periudData: tableTrans, allData: allTrans)
       // calculateBalance(balanceLabel: self.balanceLabel, transactions: allTrans)
        statisticBrain.getlocalData(from: tableTrans)
        sumAllCategories = statisticBrain.statisticData
        DispatchQueue.main.async {
            self.filterTextLabel.text = "Filter: \(selectedPeroud)"
        }
        calculateLabels()*/
       // calculateLabels()

    }
    
    var _Calculations = (0, 0, 0, 0)
    func calculate(filteredData: [TransactionsStruct]) -> (Int, Int, Int, Int) {
        var result = (0, 0, 0, 0)
        let allTrans = Array(appData.transactions)
        for i in 0..<allTrans.count {
            if Double(allTrans[i].value) ?? 0.0 > 0 {
            }
        }
        _Calculations = result
        return result
    }
    
    func createTableData(filteredData: [TransactionsStruct]) -> [tableStuct] {
        var result: [tableStuct] = []
        var currentDate = ""
        for i in 0..<filteredData.count {
            currentDate = filteredData[i].date
            if i > 0 {
                if filteredData[i-1].date != currentDate {
                    let new = tableStuct(date: currentDate, transactions: createTransactionsFor(date: filteredData[i].date, filteredData: filteredData))
                    result.insert(new, at: 0)
                }
            } else {
                let new = tableStuct(date: currentDate, transactions: createTransactionsFor(date: filteredData[i].date, filteredData: filteredData))
                result.insert(new, at: 0)
            }
        }
        return result
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
    
    func performFiltering(from: String, to: String, all: Bool) -> [TransactionsStruct] {
        
        print("performFiltering called")
        if all == true {
            tableData = appData.transactions.sorted{ $0.dateFromString < $1.dateFromString }
            /*mmmDispatchQueue.main.async {
                self.mainTableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }*/
            print("showing for all time")
            allSelectedTransactionsData = tableData

            print(allSelectedTransactionsData, "allSelectedTransactionsDataallSelectedTransactionsData")
            print("end performFiltering FROM: \(from), TO: \(to), SHOW ALL: \(all)")
            return allSelectedTransactionsData

        } else {
            
            print("performFiltering: appending transactions data")
            print("daysBetween count: \(daysBetween.count), appData.transactions: \(appData.transactions.count)")
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
            self.tableData = arr.sorted{ $0.dateFromString < $1.dateFromString }
            
            allSelectedTransactionsData = self.tableData
            print(allSelectedTransactionsData, "allSelectedTransactionsDataallSelectedTransactionsData")
            print("end performFiltering FROM: \(from), TO: \(to), SHOW ALL: \(all)")
            print("table data reloaded")
            
            /*DispatchQueue.main.async {
                self.mainTableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }*/
            return arr.sorted{ $0.dateFromString < $1.dateFromString }
            
        }
        
    }
    
    
    func sendUnsaved() {

        var transactions = appData.unsavedTransactions
        let save = SaveToDB()
        if let transaction = transactions.first {
            save.Transactions(transactionStruct: transaction, mainView: self) { (error) in
                if error {
                    self.filter()
                    print("sendUnsaved: ERROR")
                    self.forseSendUnsendedData = false
                } else {
                    transactions.removeFirst()
                    appData.unsavedTransactions = transactions
                    var alldata = appData.transactions
                    alldata.append(transaction)
                    appData.saveTransations(alldata)
                    self.filter()
                    print("sendUnsaved: unsended count:", appData.unsavedTransactions)
                }
            }
        }
        
    }
    
    
    var allData: [[TransactionsStruct]] = []
    
    
    func calculateDifference(amount: Int) {
        allData = []
        if appData.filter.to != appData.filter.from {
            print("calculateDifference: appData.filter.from: \(appData.filter.from), appData.filter.to: \(appData.filter.to ), amount: \(amount)")
            var dayA: Int = selectedFromDayInt
            var monthA: Int = getMonthFrom(string: appData.filter.from)
            var yearA: Int = getYearFrom(string: appData.filter.from)

            daysBetween = [appData.filter.from]
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
                if new == appData.filter.to {
                print("breake new == appData.filter.to; new: \(new), appData.filter.to: \(appData.filter.to)")
                    break
                }
                daysBetween.append(new)
            }
            print("daysBetween", daysBetween)
        } else {
            print("calculateDifference: appData.filter.from: \(appData.filter.from), appData.filter.to: \(appData.filter.to ), amount: \(amount)")
            daysBetween.removeAll()
            daysBetween.append(appData.filter.from)
            print(daysBetween, "calculateDifference")
        }
        
    }
    

    @objc func refresh(sender:AnyObject) {
        //add transaction
        //scrolltop (other, similier function) - to ask if user whants to refresh db
        forseSendUnsendedData = true
        if refreshData {
            if appData.username != "" {
                self.downloadFromDB()
            } else {
                self.filter()
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToEditVC", sender: self)
            }
            
        }
        

    }
    
    var unsavedTransactionsCount = 0
    var previusSelected: IndexPath? = nil
    var selectedCell: IndexPath? = nil

    
    
    
//MARK: - MySQL
    
    func downloadFromDB() {
        
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
            
            load.Transactions(mainView: self) { (loadedData, error) in
                if error == "" {
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
                    self.filter()
                } else {
                    print("error loading data")
                }

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
            //sendUnsendedToDB()
            
        } else {
            filter()
        }

    }
    
    func deleteFromDB(at: IndexPath) {
        
        let Nickname = appData.username
        if Nickname != "" {
            let Category = newTableData[at.section].transactions[at.row].category
            let Date = newTableData[at.section].transactions[at.row].date
            let Value = newTableData[at.section].transactions[at.row].value
            let Comment = newTableData[at.section].transactions[at.row].comment
            
            let toDataString = "&Nickname=\(Nickname)" + "&Category=\(Category)" + "&Date=\(Date)" + "&Value=\(Value)" + "&Comment=\(Comment)"
            let delete = DeleteFromDB()
            delete.Transactions(toDataString: toDataString, mainView: self)
            
        } else {
            print("noNickname")
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
    

    
//MARK: - Calculation
    
    var sumIncomes: Double = 0.0
    var sumExpenses: Double = 0.0
    var sumPeriodBalance: Double = 0.0
    var totalBalance = 0.0
    
    func calculateLabels() {
        let tableTrans = Array(tableData) + Array(appData.unsavedTransactions)
        let allTrans = Array(appData.transactions)
        recalculation(i: self.incomeLabel, e: self.expenseLabel, periudData: tableTrans)
        var totalExpenses = 0.0
        var totalIncomes = 0.0
        for i in 0..<allTrans.count {
            let value = Double(allTrans[i].value) ?? 0.0
            if value > 0.0 {
                totalIncomes = totalIncomes + value
            } else {
                totalExpenses = totalExpenses + value
            }
        }
        totalBalance = totalIncomes + totalExpenses
        if totalBalance < Double(Int.max) {
            DispatchQueue.main.async {
                self.balanceLabel.text = "\(Int(self.totalBalance))"
            }
        } else {
            DispatchQueue.main.async {
                self.balanceLabel.text = "\(self.totalBalance)"
            }
        }
        if totalBalance < 0.0 {
            DispatchQueue.main.async {
                self.balanceLabel.textColor = K.Colors.negative
            }
        } else {
            DispatchQueue.main.async {
                self.balanceLabel.textColor = K.Colors.balanceV
            }
        }
        statisticBrain.getlocalData(from: tableTrans)
        sumAllCategories = statisticBrain.statisticData
        DispatchQueue.main.async {
            self.filterTextLabel.text = "Filter: \(selectedPeroud)"
        }
    }
    
    func recalculation(i:UILabel, e: UILabel, periudData: [TransactionsStruct]) {
        sumIncomes = 0.0
        sumExpenses = 0.0
        sumPeriodBalance = 0.0
        var arreyNegative: [Double] = [0.0]
        var arreyPositive: [Double] = [0.0]
        print("recalculation", periudData.count)
        for i in 0..<periudData.count {
            sumPeriodBalance = sumPeriodBalance + (Double(periudData[i].value) ?? 0.0)
            
            if (Double(periudData[i].value) ?? 0.0) > 0 {
                arreyPositive.append((Double(periudData[i].value) ?? 0.0))
                sumIncomes = sumIncomes + (Double(periudData[i].value) ?? 0.0)
                
            } else {
                arreyNegative.append((Double(periudData[i].value) ?? 0.0))
                sumExpenses = sumExpenses + (Double(periudData[i].value) ?? 0.0)
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
    func deleteRow(at: IndexPath) {
        deleteFromDB(at: at)
        //tableData.remove(at: at)
        newTableData[at.section].transactions.remove(at: at.row)
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
        
        
        var new: [TransactionsStruct] = []
        
        for i in 0..<newTableData.count {
            for n in 0..<newTableData[i].transactions.count {
                new.append(TransactionsStruct(value: newTableData[i].transactions[n].value, category: newTableData[i].transactions[n].category, date: newTableData[i].date, comment: newTableData[i].transactions[n].comment))
            }
        }
        
        appData.saveTransations(new)
        
        calculateLabels()
    }

    func editRow(at: IndexPath) {
        print("change edit")
        
        editingIndexPath = at
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
        }
        
        deleteRow(at: at)
    }
    var editingIndexPath: IndexPath?
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")

        switch segue.identifier {
        case "toFiterVC":
            print("toFiterVC")
            UIView.animate(withDuration: 0.2) {
                self.filterView.backgroundColor = K.Colors.separetor
            }
            let vc = segue.destination as? FilterTVC
            vc?.frame = CGRect(x: filterView.frame.origin.x, y: filterView.frame.origin.y + filterView.frame.height + 5, width: (filterView.frame.width + 50) / 2, height: 200)
            
        case K.goToEditVCSeq:
            let vc = segue.destination as! TransitionVC
            vc.delegate = self
            if let i = editingIndexPath {
                print("prepare:", i)
                vc.editingDate = newTableData[i.section].date
                vc.editingValue = Double(newTableData[i.section].transactions[i.row].value) ?? 0.0
                vc.editingCategory = newTableData[i.section].transactions[i.row].category
                vc.editingComment = newTableData[i.section].transactions[i.row].comment
            }
            
        default: return // print("default")
        }
 
    }

    @IBAction func homeVC(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.downloadFromDB()
            if appData.fromLoginVCMessage != "" {
                self.message.showMessage(text: appData.fromLoginVCMessage, type: .succsess)
            }
        }
    }
    @IBAction func unwindToFilter(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.filter()
            print("unwindToFilter filter: \(selectedPeroud)")
        }
    }
    @IBAction func settingsPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toSettings", sender: self)
        }
    }
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 0: expenseLabelPressed = true
        case 1: expenseLabelPressed = false
        default: expenseLabelPressed = true
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.statisticSeque, sender: self)
        }
    }
    
    @IBOutlet weak var whiteBackground: UIView!
    var  whiteBackgroundFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var refreshData = false
    //here
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //move white space if != initframe
     //   if self.whiteBackground.frame != self.whiteBackgroundFrame {
            DispatchQueue.main.async {
                self.whiteBackground.frame = self.whiteBackgroundFrame
            }
     //   }
        
    }

    var lastWhiteBackheight = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let finger = scrollView.panGestureRecognizer.location(in: self.view)
        refreshData = finger.x > self.view.frame.width / 2 ? false : true
        self.refreshControl.tintColor = self.refreshData ? K.Colors.pink : .clear
        
        let max:CGFloat = 100
        let offsetY = scrollView.contentOffset.y * (-1)
        let alpha = offsetY / max
        UIView.animate(withDuration: 0.3) {
            self.refreshSubview.alpha = self.refreshData ? 0 : alpha
        }
        
        
        
        if scrollView.contentOffset.y < 0.0 {
            let y = self.whiteBackgroundFrame.minY + (scrollView.contentOffset.y * (-1))
            print(y, "jvfghjkmbgujkmng")
//            DispatchQueue.main.async { //badacc
                self.whiteBackground.frame = CGRect(x: 0, y: y, width: self.whiteBackgroundFrame.width, height: self.whiteBackgroundFrame.height)
//            }
            if scrollView.contentOffset.y <= addTransitionButton.frame.maxY * (-1) {
                print("too far")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                
            }
        } else {
            if scrollView.contentSize.height - 200 <= scrollView.contentOffset.y {
                scrollView.contentOffset.y = scrollView.contentSize.height - 200
            }
        }
        

    }

}

//MARK: - extension

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 1
      //  case 1: return unsendedTransactions.count
        case 1..<(1 + newTableData.count):
            let n = newTableData[section - 1].transactions.count
            print(newTableData.count, "newTableData.count")
            print(n, "numberOfRowsInSection")
            return n
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + newTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
       // guard let calculationCell = mainTableView.dequeueReusableCell(withIdentifier: K.calcCellIdent, for: IndexPath(row: 0, section: 0)) as? calcCell else {return UITableViewCell()}
            let calculationCell = mainTableView.dequeueReusableCell(withIdentifier: K.calcCellIdent, for: indexPath) as! calcCell
            //DispatchQueue.main.async {
                //calculationCell.setupCell(self.totalBalance, sumExpenses: self.sumExpenses, sumPeriodBalance: self.sumPeriodBalance, sumIncomes: self.sumIncomes)
          //  }
            calculationCell.balanceLabel.textColor = totalBalance < 0.0 ? K.Colors.negative : K.Colors.balanceV
            if totalBalance == sumPeriodBalance {
               // DispatchQueue.main.async {
                    calculationCell.periodStack.isHidden = true
                    calculationCell.periodStack.alpha = 0
               // }
                
            } else {
               // DispatchQueue.main.async {
                    calculationCell.periodStack.isHidden = false
                    calculationCell.periodStack.alpha = 1
               // }
            }
            let unsendedCount = appData.defaults.value(forKey: "unsavedTransactions") as? [[String]] ?? []
            if unsendedCount.count > 0 {
                //DispatchQueue.main.async {
                calculationCell.unsesndedTransactionsLabel.superview?.superview?.isHidden = false
                    calculationCell.unsesndedTransactionsLabel.text = "\(unsendedCount.count)"
               // }
            } else {
            //    DispatchQueue.main.async {
                    calculationCell.unsesndedTransactionsLabel.superview?.superview?.isHidden = true
             //   }
            }
            
            if totalBalance < Double(Int.max), sumExpenses < Double(Int.max), sumIncomes < Double(Int.max), sumPeriodBalance < Double(Int.max) {
                
                calculationCell.balanceLabel.text = "\(Int(totalBalance))"
                calculationCell.periodBalanceValueLabel.text = "\(Int(sumPeriodBalance))"
                calculationCell.expensesLabel.text = "\(Int(sumExpenses * -1))"
                calculationCell.incomeLabel.text = "\(Int(sumIncomes))"
                
            } else {
                
                calculationCell.balanceLabel.text = "\(totalBalance)"
                calculationCell.periodBalanceValueLabel.text = "\(sumPeriodBalance)"
                calculationCell.expensesLabel.text = "\(sumExpenses * -1)"
                calculationCell.incomeLabel.text = "\(sumIncomes)"
                
            }
            calculationCell.savedTransactionsLabel.text = "1"
            
            return calculationCell
            
        case 1..<(1 + newTableData.count):
            let data = newTableData[indexPath.section - 1].transactions[indexPath.row]
            let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent) as! mainVCcell
            transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell, indexPath: indexPath)
            //transactionsCell.contentView.backgroundColor = UIColor.white
            return transactionsCell
            
        default: return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        case 1..<(1 + newTableData.count):
            if selectedCell == indexPath {
                selectedCell = nil
            } else {
                previusSelected = selectedCell
                selectedCell = indexPath
            }
            DispatchQueue.main.async {
                self.mainTableView.reloadRows(at: [indexPath, self.previusSelected ?? indexPath], with: .automatic)
            }
        default:
            print("1")
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        switch indexPath.section {
        case 1..<(1 + newTableData.count):
            let editeAction = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
                self.editRow(at: IndexPath(row: indexPath.row, section: indexPath.section - 1))
            }
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                self.deleteRow(at: IndexPath(row: indexPath.row, section: indexPath.section - 1))
            }
            editeAction.backgroundColor = K.Colors.yellow
            deleteAction.backgroundColor = K.Colors.negative
            return UISwipeActionsConfiguration(actions: [editeAction, deleteAction])
        default:
            return UISwipeActionsConfiguration(actions: [])
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section > 0 {
            return newTableData[section - 1].date
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section > 0 {
            let tableFrame = self.mainTableView.layer.frame
            
            let main = UIView(frame: CGRect(x: 0, y: 0, width: tableFrame.width, height: 2))
            main.backgroundColor = section == 1 ? K.Colors.background : UIColor.clear
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableFrame.width, height: 40))
            view.backgroundColor = UIColor.white
            view.layer.masksToBounds = true
            view.layer.cornerRadius = section == 1 ? 15 : 0

            let dateLabel = UILabel(frame: CGRect(x: 20, y: 0, width: tableFrame.width - 40, height: view.frame.height))
            dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
            dateLabel.textColor = K.Colors.category
            dateLabel.text = newTableData[section - 1].date
            dateLabel.textAlignment = .center
            main.addSubview(view)
            view.addSubview(dateLabel)
            return main
            
        } else {
            return nil
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            calculationSView.alpha = 1
            filterView.alpha = 0
            self.mainTableView.layer.masksToBounds = true
            self.mainTableView.layer.cornerRadius = 15
            self.mainTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            filterView.alpha = 1
            calculationSView.alpha = 0
            self.mainTableView.layer.cornerRadius = 0
        }
    }
}

/*extension ViewController: TransitionVCProtocol {
    func addNewTransaction(value: String, category: String, date: String, comment: String) {
        print("khujnhjgvhkjlkmnjbh")
    }
    
    func quiteTransactionVC() {
        print("quit")
    }
    
    
}*/
