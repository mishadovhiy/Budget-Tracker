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

class ViewController: UIViewController {
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTextLabel: UILabel!
    @IBOutlet weak var dataTaskCountLabel: UILabel!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var calculationSView: UIStackView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var addTransitionButton: UIButton!
    @IBOutlet weak var noTableDataLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    var refreshControl = UIRefreshControl()
    var tableData:[TransactionsStruct] = []
    var _TableData: [tableStuct] = []
    var newTableData: [tableStuct] {
        get {
            return _TableData
        }
        set {
            _TableData = newValue
            var datacountText = ""
            if appData.username != "" {
                let lastDownloadDate = UserDefaults.standard.value(forKey: "LastLoadDataDate") as? Date ?? Date()
                let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: lastDownloadDate)
                let date = "\(appData.returnMonth(component.month ?? 0)) \(self.makeTwo(n: component.day ?? 0)), \(component.year ?? 0)"
                //let undendeddCount = self.undendedCount == 0 ? "" : "Data pending to resend: \(self.undendedCount)"
                let lastLaunxText = "Updated: \(date) at: \(self.makeTwo(n: component.hour ?? 0)):\(self.makeTwo(n: component.minute ?? 0)):\(self.makeTwo(n: component.second ?? 0))"
                datacountText = "Data count: \(self.tableData.count)\("\n\(lastLaunxText)")"
            }
            dataTaskCount = nil
            selectedCell = nil
            
            DispatchQueue.main.async {
                self.filterText = "Filter: \(selectedPeroud)"
                self.calculationSView.alpha = 0
                UIView.animate(withDuration: 0.8) {
                    self.calculationSView.alpha = 1
                }
                self.tableActionActivityIndicator.removeFromSuperview()
                self.dataCountLabel.text = "\(datacountText)"
                self.mainTableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                self.mainTableView.isScrollEnabled = self.tableData.count == 0 ? false : true
                
                if self.tableData.count == 0 {
                    self.mainTableView.separatorColor = K.Colors.separetor
                    self.forseShowAddButton = true
                    let supFrame = self.view.frame
                    self.addTransitionButton.backgroundColor = .clear
                    UIView.animate(withDuration: 0.6) {
                        self.addTransitionButton.frame = CGRect(x: supFrame.width / 2 - (self.addTransFrame.width / 2 + self.addTransitionButton.contentEdgeInsets.right / 2), y: supFrame.height - self.addTransFrame.height - self.view.safeAreaInsets.bottom , width: self.addTransFrame.width, height: self.addTransFrame.height)
                    }
                    self.addTransitionButton.isHidden = false
                    self.mainTableView.backgroundColor = K.Colors.background
                    self.noTableDataLabel.alpha = 0.5
                    self.noTableDataLabel.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } else {
                    self.mainTableView.separatorColor = UIColor(named: "darkSeparetor")
                    self.addTransitionButton.backgroundColor = UIColor(named: "darkTableColor")
                    self.forseShowAddButton = false
                    if self.addTransitionButton.frame != self.addTransFrame {
                        self.addTransitionButton.frame = self.addTransFrame
                    }
                    self.mainTableView.backgroundColor = .clear
                    self.noTableDataLabel.alpha = 0
                    self.noTableDataLabel.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height, 0)
                }
                
                if self.sendSavedData {
                    if appData.username != "" {
                        self.sendUnsaved()
                    }
                }
                print(self.newTransaction, "self.newTransactionself.newTransactionself.newTransaction")
                if let new = self.newTransaction {
                    self.mainTableView.backgroundColor = UIColor(named: "darkTableColor")
                    self.newTransaction = nil
                    for i in 0..<newValue.count {
                        let date = "\(self.makeTwo(n: newValue[i].date.day ?? 0)).\(self.makeTwo(n: newValue[i].date.month ?? 0)).\(newValue[i].date.year ?? 0)"
                        print("date:", date )
                        if new.date == "\(date)" {
                            for t in 0..<newValue[i].transactions.count {
                                if new.category == newValue[i].transactions[t].category && new.comment == newValue[i].transactions[t].comment && new.value == newValue[i].transactions[t].value
                                {
                                    let cell = IndexPath(row: t, section: i+1)
                                    self.highliteCell = cell
                                    self.mainTableView.scrollToRow(at: cell, at: .middle, animated: true)
                                }
                            }
                        }
                    }
                }

                if self.openFiler {
                    self.openFiler = false
                    Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
                        self.performSegue(withIdentifier: "toFiterVC", sender: self)
                    }
                } else {
                    if let _ = filterAndGoToStatistic {
                        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
                            self.performSegue(withIdentifier: "toStatisticVC", sender: self)
                        }
                    }
                }
                
                
                
            }
        }
    }
    
    var newTransaction: TransactionsStruct?
    var highliteCell: IndexPath?
    var tableDHolder: [tableStuct] = []
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()

    let tableCorners: CGFloat = 15
    var forseSendUnsendedData = true
    var forseShowAddButton = false
    var addTransFrame = CGRect.zero
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        //UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func updateUI() {
        addTransitionButton.translatesAutoresizingMaskIntoConstraints = true
        self.mainTableView.backgroundColor = K.Colors.background
        downloadFromDB()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        DispatchQueue.main.async {
            self.addTransitionButton.layer.cornerRadius = self.tableCorners
            self.addTransitionButton.isHidden = true
            self.addTransitionButton.alpha = 1
            let tableFrame = self.mainTableView.frame
            let TransFrame = self.addTransitionButton.frame
            
            self.addTransFrame = CGRect(x: tableFrame.width - TransFrame.width, y: tableFrame.minY, width: TransFrame.width, height: TransFrame.height)
            print(self.addTransFrame, "self.addTransitionButton.frame", tableFrame.minY)
            self.view.addSubview(self.filterHelperView)
            self.filterHelperView.layer.shadowColor = UIColor.black.cgColor
            self.filterHelperView.layer.shadowOpacity = 0.3
            self.filterHelperView.layer.shadowOffset = .zero
            self.filterHelperView.layer.shadowRadius = 10
            self.filterHelperView.layer.cornerRadius = 9
            self.filterHelperView.backgroundColor = K.Colors.pink
            self.filterView.superview?.layer.masksToBounds = true
            self.filterView.superview?.translatesAutoresizingMaskIntoConstraints = true
            self.filterView.translatesAutoresizingMaskIntoConstraints = true
            self.calculationSView.translatesAutoresizingMaskIntoConstraints = true
            self.filterAndCalcFrameHolder.0 = self.filterView.frame
            self.filterAndCalcFrameHolder.1 = self.calculationSView.frame
            
            let superframe = self.calculationSView.superview?.frame ?? .zero
            let calcFrame = self.calculationSView.frame
            self.calculationSView.frame = CGRect(x: -superframe.height, y: calcFrame.minY, width: calcFrame.width, height: calcFrame.height)
            
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            let superWidth = self.view.frame.width
            self.refreshSubview.frame = CGRect(x: superWidth / 2 - 10, y: 5, width: 20, height: 20)
            print(self.refreshSubview.frame, "ijhyghujijnhj")
            let image = UIImage(named: "plusIcon")
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            button.setImage(image, for: .normal)
            self.refreshSubview.addSubview(button)
            self.refreshSubview.backgroundColor = K.Colors.background
            self.refreshSubview.alpha = 0
            self.refreshControl.addSubview(self.refreshSubview)
            self.mainTableView.addSubview(self.refreshControl)
            self.noTableDataLabel.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.height, 0)
            self.noTableDataLabel.alpha = 0
            
        }

        if appData.defaults.value(forKey: "firstLaunch") as? Bool ?? true {
            appData.createFirstData {
                self.prepareFilterOptions()
                self.filter()
                UserDefaults.standard.setValue(false, forKey: "firstLaunch")
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Wellcome to Budget Tracker\nWe have created demo data for you", type: .succsess, windowHeight: 80, bottomAppearence: self.view.frame.width < 500 ? true : false)
                }
            }
        }

    }
    
    func downloadFromDB() {
        lastSelectedDate = nil
        if appData.username != "" {
            let unsend = appData.unsendedData
            undendedCount = unsend.count
            print("downloadFromDB: username: \(appData.username), not nill")
            if unsend.count > 0 {
                if appData.username != "" {
                    self.sendUnsaved()
                }
            } else {
                DispatchQueue.main.async {
                    self.filterText = "Downloading"
                }
                let load = LoadFromDB()
                load.Transactions{(loadedData, error) in
                    if error == "" {
                        print("loaded \(loadedData.count) transactions from DB")
                        var dataStruct: [TransactionsStruct] = []
                        for i in 0..<loadedData.count {
                            let value = loadedData[i][3]
                            let category = loadedData[i][1]
                            let date = loadedData[i][2]
                            let comment = loadedData[i][4]
                            dataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                        }
                        appData.saveTransations(dataStruct)
                        self.prepareFilterOptions()
                        load.Categories{(loadedDataa, error) in
                            print(loadedDataa)
                            if error == "" {
                                print("loaded \(loadedDataa) Categories from DB")
                                var dataStructt: [CategoriesStruct] = []
                                for i in 0..<loadedDataa.count {
                                    let name = loadedDataa[i][1]
                                    let purpose = loadedDataa[i][2]
                                    let isDebt = loadedDataa[i][3] == "0" ? false : true
                                    dataStructt.append(CategoriesStruct(name: name, purpose: purpose, count: 0, debt: isDebt))
                                }
                                UserDefaults.standard.setValue(Date(), forKey: "LastLoadDataDate")
                                appData.saveCategories(dataStructt)
                                self.filter()
                                
                            } else {
                                self.filter()
                                DispatchQueue.main.async {
                                    self.message.showMessage(text: error, type: .internetError)
                                }
                            }
                        }
                    } else {
                        print("error loading data1")
                        self.filter()
                        self.prepareFilterOptions()
                        DispatchQueue.main.async {
                            self.message.showMessage(text: error, type: .internetError)
                        }
                        
                    }

                }
                
            }
            
        } else {
            DispatchQueue.main.async {
                self.filterText = "Filtering"
            }
            prepareFilterOptions()
            filter()
        }

    }
    var undendedCount = 0
    var filterAndCalcFrameHolder = (CGRect.zero, CGRect.zero)
    var viewLoadedvar = false
    override func viewDidLayoutSubviews() {
        if !viewLoadedvar {
            whiteBackgroundFrame = whiteBackground.frame
        }
    }
    
    var refreshSubview = UIView.init(frame: .zero)
    struct tableStuct {
        let date: DateComponents
        let amount: Int
        var transactions: [TransactionsStruct]
    }
    func createTransactionsFor(date: String, filteredData: [TransactionsStruct]) -> ([TransactionsStruct], Int) {
        var result: [TransactionsStruct] = []
        var amount = 0.0
        let arr = Array(filteredData.sorted{ $0.dateFromString < $1.dateFromString })
        for i in 0..<arr.count {
            if date == arr[i].date {
                amount = amount + (Double(arr[i].value) ?? 0.0)
                result.append(arr[i])
            }
        }

        return (result, Int(amount))
    }
    
    func filter() {
        dataTaskCount = (0,0)
        animateCellWillAppear = true
        DispatchQueue.main.async {
            self.filterText = "Filtering"
        }
        selectedPeroud = selectedPeroud != "" ? selectedPeroud : "This Month"
        if !appData.filter.showAll {
            allDaysBetween()
        }
        let allFilteredData = performFiltering(from: appData.filter.from, to: appData.filter.to, all: appData.filter.showAll).sorted{ $0.dateFromString < $1.dateFromString }
        calculateLabels()
        newTableData = createTableData(filteredData: allFilteredData)

    }
    
    var _Calculations = (0, 0, 0, 0)
    func calculate(filteredData: [TransactionsStruct]) -> (Int, Int, Int, Int) {
        let result = (0, 0, 0, 0)
        let allTrans = Array(appData.transactions)
        for i in 0..<allTrans.count {
            if Double(allTrans[i].value) ?? 0.0 > 0 {
            }
        }
        _Calculations = result
        return result
    }
    
    var dataTaskCount: (Int, Int)? {
        get { return nil }
        set {
            if let new = newValue {
                let statusText = new.0 > 0 ? "\(new.0)/\(new.1)" : ""
                DispatchQueue.main.async {
                    self.dataTaskCountLabel.text = statusText
                }
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.6) {
                        self.dataTaskCountLabel.alpha = 0
                    } completion: { (_) in
                        self.dataTaskCountLabel.text = ""
                        self.dataTaskCountLabel.alpha = 1
                    }
                }
            }
        }
    }
    
    func stringToDateComponent(s: String) -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: s)
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? Date())
        
    }
    
    func createTableData(filteredData: [TransactionsStruct]) -> [tableStuct] {
        var result: [tableStuct] = []
        var currentDate = ""
        let otherSections = 1
        //dataTaskCount?.1 = filteredData.count
        for i in 0..<filteredData.count {
            DispatchQueue.main.async {
                self.dataTaskCount = (i+1, filteredData.count)
            }
            currentDate = filteredData[i].date
            if i > 0 {
                if filteredData[i-otherSections].date != currentDate {
                    let cteatedTransaction = createTransactionsFor(date: filteredData[i].date, filteredData: filteredData)
                    let new = tableStuct(date: stringToDateComponent(s: currentDate), amount: cteatedTransaction.1, transactions: cteatedTransaction.0.sorted { Double($0.value) ?? 0.0 < Double($1.value) ?? 0.0 })
                    result.insert(new, at: 0)
                }
            } else {
                let cteatedTransaction = createTransactionsFor(date: filteredData[i].date, filteredData: filteredData)
                let new = tableStuct(date: stringToDateComponent(s: currentDate), amount: cteatedTransaction.1, transactions: cteatedTransaction.0.sorted { Double($0.value) ?? 0.0 < Double($1.value) ?? 0.0 })
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
            let monthT = appData.filter.getMonthFromString(s: to)
            let yearT = appData.filter.getYearFromString(s: to)
            let dayTo = appData.filter.getLastDayOf(month: monthT, year: yearT)
            selectedToDayInt = dayTo
            selectedFromDayInt = appData.filter.getDayFromString(s: appData.filter.from)
            
            let monthDifference = getMonthFrom(string: appData.filter.to) - getMonthFrom(string: appData.filter.from)
            var amount = selectedToDayInt + (31 - selectedFromDayInt) + (monthDifference * 31)
            print(amount)
            if amount < 0 {
                amount *= -1
            }
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
            tableData = appData.transactions
            allSelectedTransactionsData = tableData
            return allSelectedTransactionsData

        } else {
            print("performFiltering: appending transactions data")
            print("daysBetween count: \(daysBetween.count), appData.transactions: \(appData.transactions.count)")
            var arr = tableData
            arr.removeAll()
            var matches = 0
            let days = Array(daysBetween)
            let transactions = UserDefaults.standard.value(forKey: "transactionsData") as? [[String]] ?? []
            for number in 0..<days.count {
                for i in 0..<transactions.count {
                    if days.count > number {
                        if days[number] == transactions[i][3] {
                            matches += 1
                            arr.append(TransactionsStruct(value: transactions[i][1], category: transactions[i][2], date: transactions[i][3], comment: transactions[i][4]))
                        }
                    }
                }
            }
            self.tableData = arr
            allSelectedTransactionsData = arr
            return arr
            
        }
        
    }
    
    
    var _filterText: String = "Filter"
    var filterText: String{
        get {
            return _filterText
        }
        set {
            _filterText = newValue
            var dots = ""
            DispatchQueue.main.async {
                self.filterTextLabel.text = newValue
            }
            for i in 0..<self.timers.count {
                self.timers[i].invalidate()
            }
            if newValue != "Filter: \(selectedPeroud)" {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
                    if self._filterText == "Filter: \(selectedPeroud)" {
                        timer.invalidate()
                        DispatchQueue.main.async {
                            self.filterTextLabel.text = "Filter: \(selectedPeroud)"
                        }
                        for i in 0..<self.timers.count {
                            self.timers[i].invalidate()
                        }
                        return
                    }
                    switch dots {
                    case "":
                        dots = "."
                    case ".":
                        dots = ".."
                    case "..":
                        dots = "..."
                    case "...":
                        dots = ""
                    default:
                        dots = ""
                    }

                    DispatchQueue.main.async {
                        self.filterTextLabel.text = self._filterText + dots
                    }
                }
                timers.append(timer)
            }
        }
    }
    var timers: [Timer] = []
    
    
   // var didloadCalled = false
    var sendSavedData = false
    func sendUnsaved() {
        let dataCount = appData.unsendedData.count
        print(dataCount, "dataCountdataCountdataCountdataCountdataCountdataCount")
        if forseSendUnsendedData {
            if dataCount > 0 {
                self.animateCellWillAppear = false
                let save = SaveToDB()
                if let first = appData.unsendedData.first {
                    if self._filterText != "Sending" {
                        DispatchQueue.main.async {
                            self.filterText = "Sending"
                        }
                    }
                    print("SensUnsended:", first)
                    if let transaction = first["transaction"] {
                        print("SENDTRANS")
                        save.Transactions(toDataString: transaction) { (error) in
                            if error {
                                self.forseSendUnsendedData = false
                                self.filter()
                                DispatchQueue.main.async {
                                    self.message.showMessage(text: "Internet Error!", type: .internetError)
                                }
                            } else {
                                appData.unsendedData.removeFirst()
                                DispatchQueue.main.async {
                                    self.mainTableView.reloadData()
                                    if self.refreshControl.isRefreshing {
                                        self.refreshControl.endRefreshing()
                                    }
                                }
                                self.sendUnsaved()
                            }
                        }
                    } else {
                        if let category = first["category"] {
                            print("SENDCATS")
                            save.Categories(toDataString: category) { (error) in
                                if error {
                                    self.forseSendUnsendedData = false
                                    self.filter()
                                    DispatchQueue.main.async {
                                        self.message.showMessage(text: "Internet Error!", type: .internetError)
                                    }
                                } else {
                                    appData.unsendedData.removeFirst()
                                    DispatchQueue.main.async {
                                        self.mainTableView.reloadData()
                                        if self.refreshControl.isRefreshing {
                                            self.refreshControl.endRefreshing()
                                        }
                                    }

                                    self.sendUnsaved()
                                }
                            }
                        } else {
                            let delete = DeleteFromDB()
                            if let deleteTransaction = first["deleteTransaction"] {
                                delete.Transactions(toDataString: deleteTransaction) { (error) in
                                    print("deleteTransaction cateeeee", error)
                                    if error {
                                        self.forseSendUnsendedData = false
                                        self.filter()
                                        DispatchQueue.main.async {
                                            self.message.showMessage(text: "Internet Error!", type: .internetError)
                                        }
                                    } else {
                                        appData.unsendedData.removeFirst()
                                        DispatchQueue.main.async {
                                            self.mainTableView.reloadData()
                                            if self.refreshControl.isRefreshing {
                                                self.refreshControl.endRefreshing()
                                            }
                                        }
                                        /*if !self.didloadCalled {
                                            self.didloadCalled = true
                                            self.filter()
                                        }*/
                                        self.sendUnsaved()
                                    }
                                }
                            } else {
                                if let deleteTransaction = first["deleteCategory"] {
                                    delete.Categories(toDataString: deleteTransaction) { (error) in
                                        print("delete cateeeee", error)
                                        if error {
                                            self.forseSendUnsendedData = false
                                            self.filter()
                                            DispatchQueue.main.async {
                                                self.message.showMessage(text: "Internet Error!", type: .internetError)
                                            }
                                        } else {
                                            appData.unsendedData.removeFirst()

                                            DispatchQueue.main.async {
                                                self.mainTableView.reloadData()
                                                if self.refreshControl.isRefreshing {
                                                    self.refreshControl.endRefreshing()
                                                }
                                            }
                                            /*if !self.didloadCalled {
                                                self.didloadCalled = true
                                                self.filter()
                                            }*/
                                            self.sendUnsaved()
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                }
            }
            if dataCount == 0 {
                //filter()
                if sendSavedData == true {
                    if self._filterText != "Sending" {
                        DispatchQueue.main.async {
                            self.filterText = "Sending"
                        }
                    }
                    
                    self.animateCellWillAppear = false
                    let save = SaveToDB()
                    var newCategories = appData.getCategories(key: "savedCategories")
                    print("sendUnsaved unsaved cats", newCategories.count)
                    if let categoryy = newCategories.first {
                        let toDataStringg = "&Nickname=\(appData.username)" + "&Title=\(categoryy.name)" + "&Purpose=\(categoryy.purpose)" + "&ExpectingPayment=\(categoryy.debt ? "1" : "0")"
                        save.Categories(toDataString: toDataStringg) { (error) in
                            if error {
                                self.filter()
                                self.sendSavedData = false
                                self.forseSendUnsendedData = false
                                DispatchQueue.main.async {
                                    self.message.showMessage(text: "Internet Error!", type: .internetError)
                                }
                                print("Error saving category")
                            } else {
                                print("cat: unsended sended")
                                var allCats = appData.getCategories()
                                allCats.append(categoryy)
                                appData.saveCategories(allCats)
                                newCategories.removeFirst()
                                appData.saveCategories(newCategories, key: "savedCategories")
                                DispatchQueue.main.async {
                                    self.mainTableView.reloadData()
                                }
                                self.sendUnsaved()
                            }
                        }
                    }
                    
                    if newCategories.count == 0 {
                        var trans = appData.savedTransactions
                        print("saved trans count:", trans.count)
                        if let tran = trans.first {
                            let toDataString = "&Nickname=\(appData.username)" + "&Category=\(tran.category)" + "&Date=\(tran.date)" + "&Value=\(tran.value)" + "&Comment=\(tran.comment)"
                            save.Transactions(toDataString: toDataString) { (error) in
                                if error {
                                    self.filter()
                                    self.forseSendUnsendedData = false
                                    self.sendSavedData = false
                                    DispatchQueue.main.async {
                                        self.message.showMessage(text: "Internet Error!", type: .internetError)
                                    }
                                    print("Error saving category")
                                } else {
                                    trans.removeFirst()
                                    appData.saveTransations(trans, key: "savedTransactions")
                                    var alldata = appData.transactions
                                    alldata.append(tran)
                                    appData.saveTransations(alldata)
                                    DispatchQueue.main.async {
                                        self.mainTableView.reloadData()
                                    }
                                    self.sendUnsaved()
                                }
                            }
                        } else {
                            sendSavedData = false
                            forseSendUnsendedData = false
                            self.downloadFromDB()
                            DispatchQueue.main.async {
                                self.message.showMessage(text: "Data has been sended successfully", type: .succsess, windowHeight: 65, bottomAppearence: true)
                            }
                        }
                    }
                } else {
                    self.filter()
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
                daysBetween.append(new) // was bellow break: last day in month wasnt displeying
                if new == appData.filter.to {
                print("breake new == appData.filter.to; new: \(new), appData.filter.to: \(appData.filter.to)")
                    break
                }
                
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
        if appData.username != "" {
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
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToEditVC", sender: self)
            }
        }
        
        

    }
    
    var unsavedTransactionsCount = 0
   // var previusSelected: IndexPath? = nil
    var selectedCell: IndexPath? = nil

    
    
    
//MARK: - MySQL
    

    func deleteFromDB(at: IndexPath) {
        selectedCell = nil
        let Nickname = appData.username
        if Nickname != "" {
            let Category = newTableData[at.section].transactions[at.row].category
            let Date = newTableData[at.section].transactions[at.row].date
            let Value = newTableData[at.section].transactions[at.row].value
            let Comment = newTableData[at.section].transactions[at.row].comment
            
            let toDataString = "&Nickname=\(Nickname)" + "&Category=\(Category)" + "&Date=\(Date)" + "&Value=\(Value)" + "&Comment=\(Comment)"
            let delete = DeleteFromDB()
            delete.Transactions(toDataString: toDataString, completion: { (error) in
                if error {
                    appData.unsendedData.append(["deleteTransaction": toDataString])
                }
                
                var arr = Array(appData.transactions)
                for i in 0..<arr.count{
                    if arr[i].category == Category && arr[i].date == Date && arr[i].value == Value && arr[i].comment == Comment{
                        arr.remove(at: i)
                        appData.saveTransations(arr)
                        self.filter()
                        return
                    }
                }

            })
            
        } else {
            print("noNickname")
            //tableData.remove(at: at)
            //newTableData[at.section].transactions.remove(at: at.row)
            var data = newTableData
            data[at.section].transactions.remove(at: at.row)
            //appData.saveTransations(data)
            var new: [TransactionsStruct] = []
            for i in 0..<data.count {
                for n in 0..<data[i].transactions.count {
                    let date = "(\(self.makeTwo(n: data[i].date.day ?? 0)).\(self.makeTwo(n: data[i].date.month ?? 0)).\(data[i].date.year ?? 0))"
                    new.append(TransactionsStruct(value: data[i].transactions[n].value, category: data[i].transactions[n].category, date: date, comment: data[i].transactions[n].comment))
                }
            }
            appData.saveTransations(new)
            self.filter()
        }
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
        let tableTrans = Array(tableData)
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

    var editingRow: Int?
    func editRow(at: IndexPath) {
        print("change edit")
        selectedCell = nil
        editingTransaction = newTableData[at.section].transactions[at.row]
        if appData.username != "" {
            if let trans = editingTransaction {
                let delete = DeleteFromDB()
                let toDataString = "&Nickname=\(appData.username)" + "&Category=\(trans.category)" + "&Date=\(trans.date)" + "&Value=\(trans.value)" + "&Comment=\(trans.comment)"
                delete.Transactions(toDataString: toDataString) { (error) in
                    if error {
                        appData.unsendedData.append(["deleteTransaction":toDataString])
                    }
                    var arr = Array(appData.transactions)
                    for i in 0..<arr.count{
                        if arr[i].category == trans.category && arr[i].date == trans.date && arr[i].value == trans.value && arr[i].comment == trans.comment{
                            arr.remove(at: i)
                            self.editingRow = i
                            appData.saveTransations(arr)
                            DispatchQueue.main.async {
                                self.tableActionActivityIndicator.removeFromSuperview()
                                self.performSegue(withIdentifier: "goToEditVC", sender: self)
                            }
                            return
                        }
                    }
                }
            }
        } else {
            if let trans = editingTransaction {
                var arr = Array(appData.transactions)
                for i in 0..<arr.count{
                    if arr[i].category == trans.category && arr[i].date == trans.date && arr[i].value == trans.value && arr[i].comment == trans.comment{
                        arr.remove(at: i)
                        self.editingRow = i
                        appData.saveTransations(arr)
                        DispatchQueue.main.async {
                            self.tableActionActivityIndicator.removeFromSuperview()
                            self.performSegue(withIdentifier: "goToEditVC", sender: self)
                        }
                        return
                    }
                }
            }
        }
        
        
    }
    var goToEdit = false
    var editingTransaction: TransactionsStruct?
    
    var prevSelectedPer = selectedPeroud
    
    var filteredData:[String: [String]] {
        get {
            return UserDefaults.standard.value(forKey: "filterOptions") as? [String: [String]] ?? [:]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "filterOptions")
        }
    }
    func prepareFilterOptions() {
        let arr = Array(appData.transactions.sorted{ $0.dateFromString > $1.dateFromString })
        var months:[String] = []
        var years:[String] = []
        for i in 0..<arr.count {
            if !months.contains(removeDayFromString(arr[i].date)) {
                months.append(removeDayFromString(arr[i].date))
            }
            
            if !years.contains(removeDayMonthFromString(arr[i].date)) {
                years.append(removeDayMonthFromString(arr[i].date))
            }
        }
        filteredData = [
            "months":months,
            "years":years
        ]
    }
    
    func removeDayFromString(_ s: String) -> String {
        var m = s
        for _ in 0..<3 {
            m.removeFirst()
        }
        return m
    }
    
    func removeDayMonthFromString(_ s: String) -> String {
        var m = s
        for _ in 0..<6 {
            m.removeFirst()
        }
        return m
    }
    
    var filterHelperView = UIView(frame: .zero)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        selectedCell = nil
        switch segue.identifier {
        case "toFiterVC":
            self.mainTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            prevSelectedPer = selectedPeroud
            print("toFiterVC")
            let vc = segue.destination as? FilterTVC
            vc?.months = filteredData["months"] ?? []
            vc?.years = filteredData["years"] ?? []
            DispatchQueue.main.async {
                let filterFrame = self.filterView.frame//self.filterAndCalcFrameHolder.0
                let superFilter = self.filterView.superview?.frame ?? .zero
                let vcFrame = CGRect(x: filterFrame.minX + superFilter.minX, y: filterFrame.minY + superFilter.minY, width: filterFrame.width, height: filterFrame.width)
                vc?.frame = vcFrame
                self.filterHelperView.frame = CGRect(x: filterFrame.minX + superFilter.minX, y: filterFrame.minY + superFilter.minY, width: vcFrame.width, height: vcFrame.height)
                self.filterHelperView.alpha = 0
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
                    UIView.animate(withDuration: 0.6) {
                        self.filterHelperView.alpha = 1
                    }
                }
            }
            
        case "goToEditVC":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! TransitionVC
            vc.delegate = self
            if let transaction = editingTransaction {
                vc.editingDate = transaction.date
                vc.editingValue = Double(transaction.value) ?? 0.0
                vc.editingCategory = transaction.category
                vc.editingComment = transaction.comment
            }
        case "toUnsendedVC":
            let vc = segue.destination as! UnsendedDataVC
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
            vc.delegate = self
            
        case "toSettings":
            let vc = segue.destination as! SettingsViewController
            vc.delegate = self
        
        case "toStatisticVC":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! StatisticVC
            vc.dataFromMain = tableData
        default: return
        }
 
    }

    
    override func viewDidAppear(_ animated: Bool) {
        print("appeare main vc")
    }
    
    //quite seques
    @IBAction func homeVC(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            print("HomeVC called")
            transactionAdded = false
            DispatchQueue.main.async {
                self.dataCountLabel.text = ""
            }
            self.downloadFromDB()
            if appData.fromLoginVCMessage != "" {
                print("appData.fromLoginVCMessage", appData.fromLoginVCMessage)
                DispatchQueue.main.async {
                    self.message.showMessage(text: appData.fromLoginVCMessage, type: .succsess, windowHeight: 65, bottomAppearence: true)
                    appData.fromLoginVCMessage = ""
                }
            }
        }
    }
    //homeVCWithSegue
    
    
    //from filter //quitFilterTVC // K.quitFilterTVC
    @IBAction func unwindToFilter(segue: UIStoryboardSegue) {
        print("FROM FILTER")
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                self.filterHelperView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.filterTextLabel.alpha = 1
                }
            }
            if self.prevSelectedPer != selectedPeroud {
                self.filter()
                print("unwindToFilter filter: \(selectedPeroud)")
            }
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //move white space if != initframe
     //   if self.whiteBackground.frame != self.whiteBackgroundFrame {
           /* DispatchQueue.main.async {
                self.whiteBackground.frame = self.whiteBackgroundFrame
            }*/
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
        if appData.username != "" {
            UIView.animate(withDuration: 0.3) {
                self.refreshSubview.alpha = self.refreshData ? 0 : alpha
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.refreshControl.tintColor = .clear
                self.refreshSubview.alpha = alpha
            }
        }
        
        
        let lastCellVisible = self.newTableData.count > 8 ? true : false
        if scrollView.contentOffset.y > 5.0 {
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        }
        
        
        if !lastCellVisible {
            if scrollView.contentOffset.y < 0.0 {
                /*let y = self.whiteBackgroundFrame.minY + (scrollView.contentOffset.y * (-1))
                print(y, "jvfghjkmbgujkmng")
                self.whiteBackground.frame = CGRect(x: 0, y: y, width: self.whiteBackgroundFrame.width, height: self.whiteBackgroundFrame.height)
                if scrollView.contentOffset.y <= calculationSView.frame.maxY * (-1) {
                    print("too far")
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                    
                }*/
            } else {
                let safeArea = self.whiteBackground.frame.minY - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom
                print(safeArea, "lknbvghjklmnbhvg")
                
                if scrollView.contentSize.height - 210 <= scrollView.contentOffset.y {
                    scrollView.contentOffset.y = scrollView.contentSize.height - 210
                }
            }
        }
    }
    

    @objc func savedTransPressed(_ sender: UITapGestureRecognizer) {
        if !sendSavedData {
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toUnsendedVC", sender: self)
            }
        }
    }


    
    @objc func addTransButtonPressed(_ sender: UIButton) {
        print("addtrans")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToEditVC", sender: self)
        }
    }
    
    let tableActionActivityIndicator = UIActivityIndicatorView.init(style: .gray)
    
    @objc func incomePressed(_ sender: UITapGestureRecognizer) {
        expenseLabelPressed = false
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toStatisticVC", sender: self)
        }
    }
    @objc func expensesPressed(_ sender: UITapGestureRecognizer) {
        expenseLabelPressed = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toStatisticVC", sender: self)
        }
    }
    
    var openFiler = false
    @IBAction func filterPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.filterTextLabel.alpha = 0.2
            }
        }
        if self._filterText == "Filter: \(selectedPeroud)" {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toFiterVC", sender: self)
            }
        } else {
            DispatchQueue.main.async {
                self.openFiler = true
                UIImpactFeedbackGenerator().impactOccurred()
                UIView.animate(withDuration: 0.23) {
                    self.filterTextLabel.alpha = 1
                }
            }
        }
    }
    
    func returnMonth(_ month: Int) -> String {
        let monthes = [
            1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun",
            7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"
        ]
        return monthes[month] ?? "Jan"
    }
    
    var animateCellWillAppear = true
}

//MARK: - extension

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 1
        case 1..<(1 + newTableData.count):
            let n = newTableData[section - 1].transactions.count
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
            let calculationCell = tableView.dequeueReusableCell(withIdentifier: K.calcCellIdent, for: indexPath) as! calcCell
            
            let sendedCount = (appData.defaults.value(forKey: "savedTransactions") as? [[String]] ?? []) + (appData.defaults.value(forKey: "savedCategories") as? [[String]] ?? [])

            //prevUserName
            calculationCell.prevAcountDataLabel.text = "Data from \(UserDefaults.standard.value(forKey: "prevUserName") as? String ?? "previous account"):"
            calculationCell.savedTransactionsLabel.text = "\(sendedCount.count)"
            let newUnsendedCount = appData.unsendedData.count
            calculationCell.unsesndedTransactionsLabel.text = "\(newUnsendedCount)"
            
            
            calculationCell.savedTransactionsLabel.superview?.superview?.superview?.superview?.isHidden = (sendedCount.count + newUnsendedCount) == 0 ? true : false
            calculationCell.unsesndedTransactionsLabel.superview?.superview?.isHidden = newUnsendedCount > 0 ? false : true
            calculationCell.savedTransactionsLabel.superview?.superview?.isHidden = sendedCount.count > 0  ? false : true
            
            calculationCell.setup(calculations: (totalBalance, sumExpenses, sumIncomes, sumPeriodBalance))
            calculationCell.incomeLabel.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(incomePressed(_:))))
            calculationCell.expensesLabel.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expensesPressed(_:))))
            
            calculationCell.savedTransactionsLabel.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(savedTransPressed(_:))))
            
            
            
            if UserDefaults.standard.value(forKey: "StatisticVCFirstLaunch") as? Bool ?? false == false {
                Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { (timer) in
                    if calculationCell.expensesLabel.layer.shadowColor != UIColor.black.cgColor {
                        print("StatisticVCFirstLaunch shadowcalled")
                        calculationCell.expensesLabel.layer.shadowColor = UIColor.black.cgColor
                        calculationCell.expensesLabel.layer.shadowOpacity = 0.4
                        calculationCell.expensesLabel.layer.shadowOffset = .zero
                    }
                    UIView.animate(withDuration: 0.4) {
                        calculationCell.expensesLabel.layer.shadowOpacity = calculationCell.expensesLabel.layer.shadowOpacity == 0.0 ? 0.4 : 0.0
                    }

                    if UserDefaults.standard.value(forKey: "StatisticVCFirstLaunch") as? Bool ?? false == true {
                        calculationCell.expensesLabel.layer.shadowOpacity = 0.0
                        timer.invalidate()
                    }
                    
                }
            }
            
            
            return calculationCell
            
        case 1..<(1 + newTableData.count):
            let data = newTableData[indexPath.section - 1].transactions[indexPath.row]
            let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent) as! mainVCcell
            transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell, indexPath: indexPath)
            return transactionsCell
            
        default: return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            print("1")
        case 1..<(1 + newTableData.count):
            if newTableData[indexPath.section-1].transactions[indexPath.row].comment != "" {
                let previusSelected = selectedCell
                if selectedCell == indexPath {
                    selectedCell = nil
                } else {
                    selectedCell = indexPath
                }
                DispatchQueue.main.async {
                    self.mainTableView.reloadRows(at: previusSelected != nil ? [indexPath, previusSelected ?? indexPath] : [indexPath], with: .middle)
                }
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
                self.tableActionActivityIndicator.startAnimating()
                self.tableActionActivityIndicator.frame = CGRect(x: view.frame.width / 2 - 5, y: 0, width: 10, height: view.frame.height)
                view.addSubview(self.tableActionActivityIndicator)
                self.deleteFromDB(at: IndexPath(row: indexPath.row, section: indexPath.section - 1))
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
            return "\(newTableData[section - 1].date)"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section > 0 {
            let tableFrame = self.mainTableView.layer.frame
            let main = UIView(frame: CGRect(x: 0, y: 0, width: tableFrame.width, height: 2))
            main.backgroundColor = section == 1 ? K.Colors.background : UIColor.clear
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableFrame.width, height: 52))
            view.backgroundColor = UIColor(named: "darkTableColor")//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = section == 1 ? tableCorners : 0
            //self.mainTableView.layer.cornerRadius = 15
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            main.addSubview(view)
            if section == 1 {
                let button = UIButton(frame: CGRect(x: view.frame.width - 60, y: 0, width: 60, height: 60))
                button.addTarget(self, action: #selector(addTransButtonPressed(_:)), for: .touchDown)
                button.setImage(UIImage(named: "plusIcon"), for: .normal)
                button.contentVerticalAlignment = .top
                button.contentHorizontalAlignment = .right
                button.contentEdgeInsets = .init(top: 7, left: 0, bottom: 0, right: 7)
                view.addSubview(button)
            }
            
            let stackHelper = UIView(frame: CGRect(x: 15, y: 10, width: 200, height: view.frame.height - 5))
            let amountStack = UIStackView()
            amountStack.spacing = 2
            amountStack.alignment = .fill//.firstBaseline
            amountStack.distribution = .equalSpacing
            amountStack.axis = .horizontal
            stackHelper.addSubview(amountStack)
            amountStack.translatesAutoresizingMaskIntoConstraints = false
            let dateLabel = UILabel()//UILabel(frame: CGRect(x: 10, y: 0, width: tableFrame.width - 40, height: view.frame.height))
            dateLabel.font = .systemFont(ofSize: 28, weight: .bold)
            dateLabel.textColor = UIColor(red: 241/255, green: 129/255, blue: 58/255, alpha: 1)
            dateLabel.text = "\(makeTwo(n: newTableData[section - 1].date.day ?? 0))"
            let monthLabel = UILabel()
            monthLabel.font = .systemFont(ofSize: 10, weight: .regular)
            monthLabel.textColor = K.Colors.balanceT
            monthLabel.text = "\(returnMonth(newTableData[section - 1].date.month ?? 0)),\n\(newTableData[section - 1].date.year ?? 0)"
            monthLabel.numberOfLines = 0
            let amountStackLabels: [UILabel] = [dateLabel, monthLabel]
            for label in amountStackLabels {
                label.translatesAutoresizingMaskIntoConstraints = false
                label.adjustsFontSizeToFitWidth = true
                amountStack.addArrangedSubview(label)
            }
            let amountview = UIView()
            let amountLabel = UILabel()
            amountLabel.font = .systemFont(ofSize: 10, weight: .semibold)
            amountLabel.textColor = UIColor(named: "darkTableColor") ?? .black//K.Colors.balanceV//UIColor(named: "darkTableColor") ?? .black
            amountLabel.backgroundColor = K.Colors.balanceV
            amountLabel.layer.masksToBounds = true
            amountLabel.layer.cornerRadius = 2
            amountLabel.text = " \(newTableData[section - 1].amount > 0 ? "+" : "")\(newTableData[section - 1].amount) "

            amountview.addSubview(amountLabel)
            amountLabel.translatesAutoresizingMaskIntoConstraints = false
            let constraints: [NSLayoutConstraint] = [
                amountLabel.leftAnchor.constraint(equalTo: amountview.leftAnchor, constant: 0),
                amountLabel.rightAnchor.constraint(equalTo: amountview.rightAnchor, constant: 0),
                amountLabel.centerYAnchor.constraint(equalTo: amountview.centerYAnchor, constant: 0),
            ]
            NSLayoutConstraint.activate(constraints)
            amountStack.addArrangedSubview(amountview)
            view.addSubview(stackHelper)
            return main
            
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 50
        } else {
            return 0
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                if self.newTableData.count > 0 {
                    self.mainTableView.backgroundColor = UIColor(named: "darkTableColor") ?? .black
                }
                self.mainTableView.layer.masksToBounds = true
                self.mainTableView.layer.cornerRadius = self.tableCorners
                self.mainTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.addTransitionButton.isHidden = false
                UIView.animate(withDuration: self.animateCellWillAppear ? 0.2 : 0) {
                    let superframe = self.filterView.superview?.frame ?? .zero
                    let selfFrame = self.filterView.frame
                    self.filterView.frame = CGRect(x: selfFrame.minX, y: -superframe.height, width: selfFrame.width, height: selfFrame.height)
                    self.calculationSView.frame = self.filterAndCalcFrameHolder.1
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == highliteCell {
            highliteCell = nil
            DispatchQueue.main.async {
                let initSize = cell.frame
                

                UIView.animate(withDuration: 0.23) {
                    //cell.frame = CGRect(x: initSize.minX + 10, y: initSize.minY + 5, width: initSize.width - 20, height: initSize.height - 10)
                    cell.backgroundColor = UIColor(red: 225/255, green: 114/255, blue: 44/255, alpha: 1)
                } completion: { (_) in
                    UIView.animate(withDuration: 0.36) {
                        cell.backgroundColor = UIColor(named: "darkTableColor")
                    } completion: { (_) in
                        UIView.animate(withDuration: 0.1) {
                            self.mainTableView.backgroundColor = .clear
                        }
                    }
                }

                
                
            }
        }
        
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                if self.newTableData.count > 0 {
                    self.mainTableView.backgroundColor = .clear
                }
                self.mainTableView.layer.cornerRadius = 0
                self.addTransitionButton.isHidden = !self.forseShowAddButton ? true : false
                UIView.animate(withDuration: self.animateCellWillAppear ? 0.3 : 0) {
                    let superframe = self.calculationSView.superview?.frame ?? .zero
                    let selfFrame = self.calculationSView.frame
                    self.calculationSView.frame = CGRect(x: selfFrame.minX, y: -superframe.height, width: selfFrame.width, height: selfFrame.height)
                    self.filterView.frame = self.filterAndCalcFrameHolder.0
                }
            }
        }
    }
}

extension ViewController: TransitionVCProtocol {
    func addNewTransaction(value: String, category: String, date: String, comment: String) {
        let new = TransactionsStruct(value: value, category: category, date: date, comment: comment)
        self.newTransaction = new
        editingTransaction = nil
        self.animateCellWillAppear = false
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.animateCellWillAppear = true
        }

        if value != "" && category != "" && date != "" {
            if appData.username != "" {
                let toDataString = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                let save = SaveToDB()
                save.Transactions(toDataString: toDataString) { (error) in
                    if error {
                        let neew: String = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                        appData.unsendedData.append(["transaction": neew])
                    }
                    
                    var trans = appData.transactions
                    trans.append(new)
                    appData.saveTransations(trans)
                    if !error {
                        self.forseSendUnsendedData = true
                        self.sendUnsaved()
                    }
                    self.filter()
                }
            } else {
                var trans = appData.transactions
                trans.append(new)
                appData.saveTransations(trans)
                self.filter()
            }
        } else {
            print("reloaddd")
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func quiteTransactionVC(){
        print("quite trans")
    }
    
    
}


extension ViewController: UnsendedDataVCProtocol {
    func quiteUnsendedData(deletePressed: Bool, sendPressed: Bool) {
        if !deletePressed && !sendPressed {
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
        } else {
            if deletePressed {
                appData.saveTransations([], key: "savedTransactions")
                appData.saveCategories([], key: "savedCategories")
                DispatchQueue.main.async {
                    self.mainTableView.reloadData()
                }
            } else {
                if sendPressed {
                    sendSavedData = true
                    forseSendUnsendedData = true
                    if appData.username != "" {
                        self.sendUnsaved()
                    }
                }
            }
        }
    }
    
}

extension ViewController: SettingsViewControllerProtocol {
    func closeSettings(sendSavedData: Bool, needFiltering: Bool) {
        self.animateCellWillAppear = false
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.animateCellWillAppear = true
        }
        if sendSavedData {
            self.sendSavedData = true
            forseSendUnsendedData = true
            if appData.username != "" {
                self.sendUnsaved()
            }
        } else {
            if needFiltering {
                print("ViewController needFiltering")
                self.filter()
            } else {
                DispatchQueue.main.async {
                    self.mainTableView.reloadData()
                }
            }
            
        }
    }
    
    
}
