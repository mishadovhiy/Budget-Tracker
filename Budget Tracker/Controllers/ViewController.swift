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
    var tableData = appData.transactions.sorted{ $0.dateFromString < $1.dateFromString }
    var _TableData: [tableStuct] = []
    var newTableData: [tableStuct] {
        get {
            return _TableData
        }
        set {
            _TableData = newValue
            let lastDownloadDate = UserDefaults.standard.value(forKey: "LastLoadDataDate") as? Date ?? Date()
            let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: lastDownloadDate)
            let lastLaunxText = "Updated: \(component.year ?? 0).\(self.makeTwo(n: component.month ?? 0)).\(self.makeTwo(n: component.day ?? 0)), \(self.makeTwo(n: component.hour ?? 0)):\(self.makeTwo(n: component.minute ?? 0)):\(self.makeTwo(n: component.second ?? 0))"
            DispatchQueue.main.async {
                self.calculationSView.alpha = 0
                UIView.animate(withDuration: 0.8) {
                    self.calculationSView.alpha = 1
                }
                self.tableActionActivityIndicator.removeFromSuperview()
                self.dataCountLabel.text = "Transactions: \(self.tableData.count)\(appData.username != "" ? "\n\(lastLaunxText)" : "")"
                self.filterTextLabel.text = "Filter: \(selectedPeroud)"
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
                    self.sendUnsaved()
                }
                
            }
        }
    }
    
    var tableDHolder: [tableStuct] = []
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()

    let tableCorners: CGFloat = 22
    var forseSendUnsendedData = true
    var forseShowAddButton = false
    var addTransFrame = CGRect.zero
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        addTransitionButton.layer.cornerRadius = tableCorners
        prepareFilterOptions()
    }
    
    func updateUI() {
        addTransitionButton.translatesAutoresizingMaskIntoConstraints = true
        self.mainTableView.backgroundColor = K.Colors.background
        downloadFromDB()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        DispatchQueue.main.async {
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
        switchFromCoreData()
        if appData.defaults.value(forKey: "firstLaunch") as? Bool ?? true {
            appData.createFirstData {
                self.filter()
                UserDefaults.standard.setValue(false, forKey: "firstLaunch")
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Wellcome to Budget Tracker\nWe have created demo data for you", type: .succsess, windowHeight: 80, bottomAppearence: self.view.frame.width < 500 ? true : false)
                }
            }
        }

    }
    
    var filterAndCalcFrameHolder = (CGRect.zero, CGRect.zero)
    var viewLoadedvar = false
    override func viewDidLayoutSubviews() {
        if !viewLoadedvar {
            whiteBackgroundFrame = whiteBackground.frame
        }
    }
    
    var refreshSubview = UIView.init(frame: .zero)
    
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
            return arr.sorted{ $0.dateFromString < $1.dateFromString }
            
        }
        
    }
    
    var didloadCalled = false
    var sendSavedData = false
    var sendindSavedData = false
    func sendUnsaved() {//here
        
        let dataCount = appData.unsendedData.count
        if forseSendUnsendedData {
            if dataCount > 0 {
                let save = SaveToDB()
                if let first = appData.unsendedData.first {
                    print("SensUnsended:", first)
                    if let transaction = first["transaction"] {
                        print("SENDTRANS")
                        save.Transactions(toDataString: transaction) { (error) in
                            if error {
                                self.forseSendUnsendedData = false
                                self.sendingUnsendedData = false
                                self.filter()
                            } else {
                                appData.unsendedData.removeFirst()
                                DispatchQueue.main.async {
                                    self.mainTableView.reloadData()
                                    if self.refreshControl.isRefreshing {
                                        self.refreshControl.endRefreshing()
                                    }
                                }
                                if !self.didloadCalled {
                                    self.didloadCalled = true
                                    self.filter()
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
                                    self.sendingUnsendedData = false
                                    self.filter()
                                } else {
                                    appData.unsendedData.removeFirst()
                                    DispatchQueue.main.async {
                                        self.mainTableView.reloadData()
                                        if self.refreshControl.isRefreshing {
                                            self.refreshControl.endRefreshing()
                                        }
                                    }
                                    if !self.didloadCalled {
                                        self.didloadCalled = true
                                        self.filter()
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
                                        self.sendingUnsendedData = false
                                        self.filter()
                                    } else {
                                        appData.unsendedData.removeFirst()
                                        DispatchQueue.main.async {
                                            self.mainTableView.reloadData()
                                            if self.refreshControl.isRefreshing {
                                                self.refreshControl.endRefreshing()
                                            }
                                        }
                                        if !self.didloadCalled {
                                            self.didloadCalled = true
                                            self.filter()
                                        }
                                        self.sendUnsaved()
                                    }
                                }
                            } else {
                                if let deleteTransaction = first["deleteCategory"] {
                                    delete.Categories(toDataString: deleteTransaction) { (error) in
                                        print("delete cateeeee", error)
                                        if error {
                                            self.forseSendUnsendedData = false
                                            self.sendingUnsendedData = false
                                            self.filter()
                                        } else {
                                            appData.unsendedData.removeFirst()
                                            DispatchQueue.main.async {
                                                self.mainTableView.reloadData()
                                                if self.refreshControl.isRefreshing {
                                                    self.refreshControl.endRefreshing()
                                                }
                                            }
                                            if !self.didloadCalled {
                                                self.didloadCalled = true
                                                self.filter()
                                            }
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
                if sendSavedData == true {
                    sendindSavedData = true
                    let save = SaveToDB()
                    var newCategories = appData.getCategories(key: "savedCategories")
                    print("sendUnsaved unsaved cats", newCategories.count)
                    if let categoryy = newCategories.first {
                        let toDataStringg = "&Nickname=\(appData.username)" + "&Title=\(categoryy.name)" + "&Purpose=\(categoryy.purpose)"
                        save.Categories(toDataString: toDataStringg) { (error) in
                            if error {
                                self.filter()
                                self.sendSavedData = false
                                self.forseSendUnsendedData = false
                                self.sendindSavedData = false
                                print("Error saving category")
                            } else {
                                print("cat: unsended sended")
                                var allCats = appData.getCategories()
                                allCats.append(categoryy)
                                appData.saveCategories(allCats)
                                newCategories.removeFirst()
                                appData.saveCategories(newCategories, key: "savedCategories")
                                self.filter()
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
                                    self.sendindSavedData = false
                                    self.filter()
                                    self.forseSendUnsendedData = false
                                    self.sendSavedData = false
                                    print("Error saving category")
                                } else {
                                    trans.removeFirst()
                                    appData.saveTransations(trans, key: "savedTransactions")
                                    var alldata = appData.transactions
                                    alldata.append(tran)
                                    appData.saveTransations(alldata)
                                    self.filter()
                                }
                            }
                        } else {
                            sendSavedData = false
                            sendindSavedData = false
                            DispatchQueue.main.async {
                                self.message.showMessage(text: "Data has been sended successfully", type: .succsess, windowHeight: 65)
                            }
                        }
                    }
                } else {
                    self.sendindSavedData = false
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

            print("downloadFromDB: username: \(appData.username), not nill")
            if appData.unsendedData.count > 0 {
                self.sendingUnsendedData = true
                self.sendUnsaved()
            } else {
                self.sendingUnsendedData = false
                DispatchQueue.main.async {
                    self.filterTextLabel.text = "Downloading ..."
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
                            if error == "" {
                                print("loaded \(loadedData.count) Categories from DB")
                                var dataStructt: [CategoriesStruct] = []
                                for i in 0..<loadedDataa.count {
                                    
                                    let name = loadedDataa[i][1]
                                    let purpose = loadedDataa[i][2]
                                    dataStructt.append(CategoriesStruct(name: name, purpose: purpose))
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
                            self.message.showMessage(text: error, type: .internetError)//internetError
                        }
                        
                    }

                }
                
            }
            
        } else {
            filter()
        }

    }
    //here
    func deleteFromDB(at: IndexPath) {
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
                        print("FOUND")
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
                    new.append(TransactionsStruct(value: data[i].transactions[n].value, category: data[i].transactions[n].category, date: data[i].date, comment: data[i].transactions[n].comment))
                }
            }
            appData.saveTransations(new)
            self.filter()
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
    func editRow(at: IndexPath) {//here
        print("change edit")
        
        editingTransaction = newTableData[at.section].transactions[at.row]
        let delete = DeleteFromDB()
        if let trans = editingTransaction {
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
                            self.performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
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
    
    var filteredData:[String: [String]] = [:]
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

        switch segue.identifier {
        case "toFiterVC":
            prevSelectedPer = selectedPeroud
            print("toFiterVC")
            let vc = segue.destination as? FilterTVC
            vc?.months = filteredData["months"] ?? []
            vc?.years = filteredData["years"] ?? []
            DispatchQueue.main.async {
                let filterFrame = self.filterView.frame
                let superFilter = self.filterView.superview?.frame ?? .zero
                let vcFrame = CGRect(x: filterFrame.minX + superFilter.minX, y: filterFrame.minY + superFilter.minY, width: filterFrame.width, height: filterFrame.width)
                vc?.frame = vcFrame
                self.filterHelperView.frame = CGRect(x: filterFrame.minX + superFilter.minX, y: filterFrame.minY + superFilter.minY, width: vcFrame.width, height: vcFrame.height)
                self.filterHelperView.alpha = 0
                
                UIView.animate(withDuration: 0.2) {
                    self.filterHelperView.alpha = 1
                }
            }
            
        case K.goToEditVCSeq:
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
            vc.delegate = self
            
        case "toSettings":
            let vc = segue.destination as! SettingsViewController
            vc.delegate = self
          //  UIView.animate(withDuration: 0.4) {
               // self.calculationSView.alpha = 0
          //m  }
        default: return
        }
 
    }

    
    //quite seques
    @IBAction func homeVC(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            print("HomeVC called")
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
    
    
    //from filter //quitFilterTVC
    @IBAction func unwindToFilter(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                self.filterHelperView.alpha = 0
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
        UIView.animate(withDuration: 0.3) {
            self.refreshSubview.alpha = self.refreshData ? 0 : alpha
        }
        
        let lastCellVisible = self.newTableData.count > 8 ? true : false
        
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
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toUnsendedVC", sender: self)
        }
    }
    @objc func unsavedPtransPressed(_ sender: UITapGestureRecognizer) {
        if !forseSendUnsendedData {
            DispatchQueue.main.async {
                self.message.showMessage(text: "Your data is sending", type: .succsess)
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toUnsendedVC", sender: self)
            }
        }
    }

    
    @objc func addTransButtonPressed(_ sender: UIButton) {
        print("addtrans")
        self.performSegue(withIdentifier: "goToEditVC", sender: self)
    }
    
    var unsendedValue = 0
    var sendingUnsendedData = false
    
    let tableActionActivityIndicator = UIActivityIndicatorView.init(style: .gray)
    
    @objc func incomePressed(_ sender: UITapGestureRecognizer) {
        expenseLabelPressed = false
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.statisticSeque, sender: self)
        }
    }
    @objc func expensesPressed(_ sender: UITapGestureRecognizer) {
        expenseLabelPressed = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.statisticSeque, sender: self)
        }
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
            let calculationCell = tableView.dequeueReusableCell(withIdentifier: K.calcCellIdent, for: indexPath) as! calcCell
            
            let sendedCount = (appData.defaults.value(forKey: "savedTransactions") as? [[String]] ?? []) + (appData.defaults.value(forKey: "savedCategories") as? [[String]] ?? [])
            
            calculationCell.savedTransactionsLabel.text = "\(sendedCount.count)"
            let newUnsendedCount = appData.unsendedData.count
            calculationCell.unsesndedTransactionsLabel.text = "\(newUnsendedCount)"

            let ai = UIActivityIndicatorView.init(style: .gray)
            if sendingUnsendedData {
                ai.startAnimating()
                let labelFrame = calculationCell.unsesndedTransactionsLabel.layer.frame
                ai.frame = CGRect(x: labelFrame.minX + 10, y: 12, width: 10, height: 10)
                calculationCell.unsesndedTransactionsLabel.superview?.addSubview(ai)
            } else {
                ai.removeFromSuperview()
            }
            let aiSavedData = UIActivityIndicatorView.init(style: .gray)
            if sendindSavedData {
                print("sending saved data")
                aiSavedData.startAnimating()
                let savedLabelFrame = calculationCell.savedTransactionsLabel.layer.frame
                aiSavedData.frame = CGRect(x: savedLabelFrame.minX - 7, y: 12, width: 10, height: 10)
                calculationCell.savedTransactionsLabel.superview?.addSubview(aiSavedData)
            print(aiSavedData.frame, "aiSavedData.frame")
            } else {
                aiSavedData.removeFromSuperview()
                print("not sanding saved data")
            }
            
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
                if selectedCell == indexPath {
                    selectedCell = nil
                } else {
                    previusSelected = selectedCell
                    selectedCell = indexPath
                }
                DispatchQueue.main.async {
                    self.mainTableView.reloadRows(at: [indexPath, self.previusSelected ?? indexPath], with: .middle)
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
            view.backgroundColor = UIColor(named: "darkTableColor")
            view.layer.masksToBounds = true
            view.layer.cornerRadius = section == 1 ? tableCorners : 0
            //self.mainTableView.layer.cornerRadius = 15
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            let dateLabel = UILabel(frame: CGRect(x: 20, y: 0, width: tableFrame.width - 40, height: view.frame.height))
            dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
            dateLabel.textColor = UIColor.white
            dateLabel.text = newTableData[section - 1].date
            dateLabel.textAlignment = .left
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
            view.addSubview(dateLabel)
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
        ///
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
                    if self.editingTransaction != nil {
                        self.editingTransaction = nil
                    }
                    var trans = appData.transactions
                    trans.append(new)
                    appData.saveTransations(trans)
                    self.filter()
                }
            } else {
                var trans = appData.transactions
                trans.append(new)
                appData.saveTransations(trans)
                self.filter()
            }
        }
    }
    
    func quiteTransactionVC() {
        print("mainvc:quit")
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    
}


extension ViewController: UnsendedDataVCProtocol {
    func deletePressed() {
        appData.saveTransations([], key: "savedTransactions")
        appData.saveCategories([], key: "savedCategories")
        self.filter()
    }
    
    func sendPressed() {
        sendSavedData = true
        self.filter()
    }
    
}

extension ViewController: SettingsViewControllerProtocol {
    func closeSettings(sendSavedData: Bool) {
        self.animateCellWillAppear = false
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.animateCellWillAppear = true
        }
        if sendSavedData {
            self.sendSavedData = true
            filter()
        } else {
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
        }
    }
    
    
}
