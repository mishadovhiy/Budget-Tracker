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

class ViewController: SuperViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var addTransactionWhenEmptyButton: UIButton!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var unsendedDataLabel: UILabel!
    @IBOutlet weak var dataFromTitleLabel: UILabel!
    @IBOutlet weak var dataFromValueLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTextLabel: UILabel!
    @IBOutlet weak var dataTaskCountLabel: UILabel!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var calculationSView: UIStackView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var addTransitionButton: UIButton!
    //@IBOutlet weak var noTableDataLabel: UILabel!
    
    @IBOutlet weak var darkBackgroundUnderTable: UIView!
    @IBOutlet var ecpensesLabels: [UILabel]!
    @IBOutlet var incomeLabels: [UILabel]!

    @IBOutlet var balanceLabels: [UILabel]!
    @IBOutlet var perioudBalanceLabels: [UILabel]!
    
    @IBOutlet weak var bigCalcView: UIView!
    
    
    var correctFrameBackground:CGRect = .zero
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
            let tableDataDataCount = self.tableData.count
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.darkBackgroundUnderTable.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
                }
                if self.refreshControl.isRefreshing {
                 //   self.refreshControl.backgroundColor = .clear
                    self.refreshControl.endRefreshing()
                }
                
                self.mainTableView.reloadData()
                
                self.mainTableView.alpha = tableDataDataCount == 0 ? 0 : 1
                
                self.calculateLabels(noData: tableDataDataCount == 0 ? true : false)
                if tableDataDataCount == 0 {
                    self.toggleNoData(show: true, text: (UserDefaults.standard.value(forKey: "transactionsData") as? [[String]])?.count ?? 0 == 0 ? "Add your first transaction" : "No transactions\nfor selected period")
                } else {
                    self.toggleNoData(show: false, addButtonHidden: true)
                }
                self.filterText = "Filter: \(selectedPeroud)"
                self.calculationSView.alpha = 0
                UIView.animate(withDuration: 0.8) {
                    self.calculationSView.alpha = 1
                }
                self.tableActionActivityIndicator.removeFromSuperview()//?
               // self.dataCountLabel.text = "\(datacountText)"
                

                
                
                if self.sendSavedData {
                    if appData.username != "" {
                        self.sendUnsaved()
                    }
                }
                print(self.newTransaction, "self.newTransactionself.newTransactionself.newTransaction")
                if let new = self.newTransaction {
             //       self.mainTableView.backgroundColor = UIColor(named: "darkTableColor")
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
                    //here
                    self.compliteScrolling()
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
                //self.refreshControl.backgroundColor = K.Colors.background
               /* if self.justLoaded {
                    self.justLoaded = false
                    let save = SaveToDB()
                    save.sendCode(toDataString: "emailTo=hi@dovhiy.com&Nickname=\(appData.username)&resetCode=1233") { (error) in
                        if error {
                            print("bvghjnb errorsendingcode str:")
                        } else {
                            print("bvghjnb DONN")
                        }
                    }
                }*/
                
              //  if !appData.purchasedOnThisDevice {
 /*                   if self.justLoaded {
                        self.justLoaded = false
                        if !appData.proVersion {
                            self.checkPurchase()
                        }
                    }*/
              //  }
                
               /* if self.justLoaded {
                    self.justLoaded = false
                    self.checkPurchase()
                }*/
                
               /* if appData.proTrial {
                    self.checkProTrial()
                }*/
            }
        }
    }
    
    func toggleNoData(show: Bool, text: String = "No Transactions", fromTop: Bool = false, appeareAnimation: Bool = true, addButtonHidden: Bool = false) {
        
        DispatchQueue.main.async {
            
            self.addTransactionWhenEmptyButton.isHidden = addButtonHidden
            if show {
                self.addTransactionWhenEmptyButton.alpha = 1
                let y = fromTop ? self.mainTableView.frame.minY : (self.bigCalcView.frame.maxY + 10)
                self.noDataView.isHidden = false
                self.noDataLabel.text = text
                UIView.animate(withDuration: appeareAnimation ? 0.25 : 0) {
                    self.noDataView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height - y)
                    //self.darkBackgroundUnderTable.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
                } completion: { (_) in
                  //  self.calculateLabels(noData: true)
                    self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.noDataView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height / 2)
                } completion: { (_) in
                    self.noDataView.isHidden = true
                   // self.calculateLabels(noData: false)
                    self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                }
            }
        }
    }
    
    var justLoaded = true
    var newTransaction: TransactionsStruct?
    var highliteCell: IndexPath?
    var tableDHolder: [tableStuct] = []


    @IBOutlet weak var bigExpensesStack: UIStackView!
    let tableCorners: CGFloat = 14
    var forseSendUnsendedData = true
    var addTransFrame = CGRect.zero
    override func viewDidLoad() {
        super.viewDidLoad()
      //  center.delegate = self
        updateUI()
        

       // mainTableView.isUserInteractionEnabled = false
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bigCalcTaps(_:))))
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    
  /*  lazy var ai: IndicatorView = {
        
        return AppDelegate.shared?.loadingIndicator ?? IndicatorView(frame: self.view.frame)
    }()*/
    
    func updateUI() {
     //   addTransitionButton.translatesAutoresizingMaskIntoConstraints = true
  //      self.mainTableView.backgroundColor = K.Colors.background
        toggleNoData(show: true, text: "Loading", fromTop: true, appeareAnimation: false, addButtonHidden: true)
        downloadFromDB()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        DispatchQueue.main.async {
            self.unsendedDataLabel.superview?.superview?.isHidden = true
            self.enableLocalDataPress = false
            self.dataFromValueLabel.superview?.superview?.isHidden = true
           // for button in self.lightCornerButtons {
            self.addTransactionWhenEmptyButton.layer.cornerRadius = 5
            self.addTransactionWhenEmptyButton.layer.masksToBounds = true
          //  }
           // self.darkBackgroundUnderTable
            //self.noDataView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height / 2)
            //self.noDataView.isHidden = true
        //    self.noDataView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            self.noDataView.translatesAutoresizingMaskIntoConstraints = true
            self.noDataView.layer.masksToBounds = true
            self.noDataView.layer.cornerRadius = self.tableCorners
            self.noDataView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.darkBackgroundUnderTable.layer.masksToBounds = true
            self.darkBackgroundUnderTable.layer.cornerRadius = self.tableCorners
            self.darkBackgroundUnderTable.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.darkBackgroundUnderTable.translatesAutoresizingMaskIntoConstraints = true
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
            self.refreshSubview.frame = CGRect(x: superWidth / 2 - 10, y: 0, width: 20, height: 20)
            print(self.refreshSubview.frame, "ijhyghujijnhj")
            let image = UIImage(named: "plusIcon")
            let button = UIButton(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.layer.frame.width / 2
            button.setImage(image, for: .normal)
            self.refreshSubview.addSubview(button)
           // self.refreshSubview.backgroundColor = K.Colors.background
            self.refreshSubview.alpha = 0
            self.refreshControl.addSubview(self.refreshSubview)
           // self.refreshControl.backgroundColor = .red//K.Colors.background
            self.mainTableView.addSubview(self.refreshControl)
            
            
        }

        if appData.defaults.value(forKey: "firstLaunch") as? Bool ?? true {
            appData.createFirstData {
                self.prepareFilterOptions()
                self.filter()
                UserDefaults.standard.setValue(false, forKey: "firstLaunch")
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Wellcome to Budget Tracker\nGet started by looking through demo data", type: .succsess, windowHeight: 80, bottomAppearence: self.view.frame.width < 500 ? true : false)
                }
            }
        }

    }
    
    var canTouchHandleTap = true
    @objc func bigCalcTaps(_ sender:UITapGestureRecognizer) {
        if canTouchHandleTap {
            //let topSafeAr = self.view.safeAreaInsets.top
            let bigCalcFrame = bigCalcView.frame
            let touchPoint = sender.location(in: self.view)
            //local data pressed
            let topMinus = dataFromTitleLabel.superview?.superview?.superview?.frame ?? .zero
            let width = dataFromTitleLabel.superview?.superview?.frame ?? .zero
            let supDataMinY = dataFromTitleLabel.superview?.superview?.superview?.superview?.frame ?? .zero
            let localDataY = (supDataMinY.minY + bigCalcFrame.minY) + topMinus.minY
            let localDataPosition = CGRect(x: bigCalcFrame.minX, y: localDataY, width: width.width, height: width.height)
            let localDataPressed = localDataPosition.contains(touchPoint)
            //expenses pressed
            let expencesSuperLabel = self.bigExpensesStack.frame
            let expensesPosition = CGRect(x: bigCalcView.frame.minX, y: bigCalcView.frame.minY, width: expencesSuperLabel.width, height: expencesSuperLabel.height)
            let expensesPressed = expensesPosition.contains(touchPoint)
            //incomes pressed
            let incomeLabel = self.incomeLabels.first?.superview?.frame ?? .zero
            let incomePosition = CGRect(x: incomeLabel.minX, y: expensesPosition.minY, width: expensesPosition.width, height: expensesPosition.height)
            let incomePressed = incomePosition.contains(touchPoint)
            //test
            /*let redBox = UIView(frame: localDataPosition)
            redBox.backgroundColor = .red
            self.view.addSubview(redBox)*/
            //actions
            if enableLocalDataPress {
                if localDataPressed {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toUnsendedVC", sender: self)
                    }
                }
            }
            if expensesPressed || incomePressed {
                expenseLabelPressed = expensesPressed
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toStatisticVC", sender: self)
                }
            }
            
            
        }
        
    }
    
    
    var enableLocalDataPress = false
    func updateDataLabels(reloadAndAnimate: Bool = true, noData: Bool = false) {
        print("updateDataLabelsCalled")
        let unsendedCount = appData.unsendedData.count
        let localCount = ((UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String]] ?? []) + (UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String]] ?? []) + (UserDefaults.standard.value(forKey: K.Keys.localDebts) as? [[String]] ?? [])).count
        let prevName = UserDefaults.standard.value(forKey: "prevUserName") as? String ?? "previous account"

        DispatchQueue.main.async {
            self.unsendedDataLabel.text = "\(unsendedCount)"
            self.dataFromTitleLabel.text = "Data from \(prevName == "" ? "previous account" : prevName):"
            self.dataFromValueLabel.text = "\(localCount)"
            if reloadAndAnimate {
                UIView.animate(withDuration: noData ? 0.0 : 0.35) {
                    self.unsendedDataLabel.superview?.superview?.isHidden = unsendedCount == 0 ? true : false
                    self.enableLocalDataPress = localCount == 0 ? false : true
                    self.dataFromValueLabel.superview?.superview?.isHidden = localCount == 0 ? true : false
                } completion: { (_) in
                    self.correctFrameBackground = CGRect(x: 0, y: self.bigCalcView.frame.maxY + 30, width: self.darkBackgroundUnderTable.frame.width, height: self.view.frame.height - self.bigCalcView.frame.maxY)
                    UIView.animate(withDuration: 0.3) {
                        self.darkBackgroundUnderTable.frame = self.correctFrameBackground
                    }
                    
                    //self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                }
            }
        }
    }
    
    func downloadFromDB() {
        _categoriesHolder.removeAll()
        _debtsHolder.removeAll()
        print("downloadFromDBdownloadFromDB")
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
                load.Transactions{(loadedTransactions, error) in
                    if error == "" {
                        print("loaded \(loadedTransactions.count) transactions from DB")
                        var transactionsResult: [TransactionsStruct] = []
                        for i in 0..<loadedTransactions.count {
                            let value = loadedTransactions[i][3]
                            let category = loadedTransactions[i][1]
                            let date = loadedTransactions[i][2]
                            let comment = loadedTransactions[i][4]
                            transactionsResult.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                        }
                        appData.saveTransations(transactionsResult)
                        self.checkPurchase()
                        self.prepareFilterOptions()
                        self.filter()
                     /*   DispatchQueue.main.async {
                            
                        }*/
                       /* load.Categories{(loadedCategories, error) in
                            if error == "" {
                                print("loaded \(loadedCategories) Categories from DB")
                                var categoriesResult: [CategoriesStruct] = []
                                for i in 0..<loadedCategories.count {
                                    let name = loadedCategories[i][1]
                                    let purpose = loadedCategories[i][2]
                                    categoriesResult.append(CategoriesStruct(name: name, purpose: purpose, count: 0))
                                }
                                appData.saveCategories(categoriesResult)
                                load.Debts { (loadedDebts, debtsError) in
                                    if debtsError == "" {
                                        
                                        print("loaded \(loadedDebts) Debts from DB")
                                        var debtsResult: [DebtsStruct] = []
                                        for i in 0..<loadedDebts.count {
                                            let name = loadedDebts[i][1]
                                            let amountToPay = loadedDebts[i][2]
                                            let dueDate = loadedDebts[i][3]
                                            debtsResult.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
                                        }
                                        appData.saveDebts(debtsResult)
                                        UserDefaults.standard.setValue(Date(), forKey: "LastLoadDataDate")
                                        self.checkPurchase()
                                        self.prepareFilterOptions()
                                        self.filter()
                                        
                                    } else {
                                        
                                        self.filter()
                                        self.prepareFilterOptions()
                                        DispatchQueue.main.async {
                                            self.message.showMessage(text: error, type: .internetError)
                                        }
                                    }
                                }
                                
                            } else {
                                self.filter()
                                self.prepareFilterOptions()
                                DispatchQueue.main.async {
                                    self.message.showMessage(text: error, type: .internetError)
                                }
                            }
                        }*/
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
    var wasSendingUnsended = false

    
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
        print("filterCalled")
        dataTaskCount = (0,0)
        animateCellWillAppear = true
        selectedPeroud = selectedPeroud != "" ? selectedPeroud : "This Month"
        DispatchQueue.main.async {
            self.filterText = "Filtering"
        }
        if !appData.filter.showAll {
            allDaysBetween()
        }
        let allFilteredData = performFiltering(from: appData.filter.from, to: appData.filter.to, all: appData.filter.showAll).sorted{ $0.dateFromString < $1.dateFromString }
     //   calculateLabels()
        newTableData = createTableData(filteredData: allFilteredData)


    }
    
    func checkPurchase() {
     //   DispatchQueue.main.async {
            let nick = appData.username
            let load = LoadFromDB()
            load.Users { (loadedData, error) in
                print(loadedData, "checkPurchase")
                if error {
                    
                } else {
                    for i in 0..<loadedData.count {
                        if loadedData[i][0] == nick {
                            print("checkPurchase for", nick)
                            if !appData.purchasedOnThisDevice {
                                appData.proVersion = loadedData[i][4] == "1" ? true : false
                                
                                print("checkPurchase appData.proVersion", appData.proVersion)
                                if loadedData[i][5] != "" {//test
                                    if UserDefaults.standard.value(forKey: "checkTrialDate") as? Bool ?? true {
                                        appData.trialDate = loadedData[i][5]
                                        self.checkProTrial()
                                    }
                                }
                            }
                            
                            print(loadedData[i][4], "loadedData[i][3]loadedData[i][3]")
                            
                            
                            if loadedData[i][2] != appData.password {
                        
                                UserDefaults.standard.setValue(appData.username, forKey: "UsernameHolder")
                                appData.username = ""
                                //toSingIn
                                if #available(iOS 13.0, *) {
                                    
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "toSingIn", sender: self)
                                    }
                                } else {
                                    self.resetPassword = true
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "toSettingsFullScreen", sender: self)
                                    }
                                }
                                
                            }
                            break
                        }
                    }
                }
                
            }
       // }
    }
    var resetPassword = false
    func checkProTrial() {
        //debts did lo if trial - check pro trial
        let wasStr = appData.trialDate
        let todayStr = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let dates = (dateFrom(sting: wasStr), dateFrom(sting: todayStr))
        print(dates, "bvghujkmnjbhguijk")
        let dif = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dates.0 ?? Date(), to: dates.1 ?? Date())
        print(dif, "bvghujkmnjbhguijk")
        if dif.year == 0 && dif.month == 0 {
            if dif.day ?? 0 <= 7 {
                appData.proTrial = true
                print(dif.day ?? 0, "dif.day ?? 0dif.day ?? 0")
                UserDefaults.standard.setValue(dif.day ?? 0, forKey: "trialToExpireDays")
            } else {
                appData.proTrial = false
                UserDefaults.standard.setValue(false, forKey: "checkTrialDate")
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Pro trial is over", type: .succsess, bottomAppearence: true)
                }
            }
        } else {
            appData.proTrial = false
            UserDefaults.standard.setValue(false, forKey: "checkTrialDate")
            DispatchQueue.main.async {
                self.message.showMessage(text: "Pro trial is over", type: .succsess, bottomAppearence: true)
            }
        }
    }
    
    func dateFrom(sting: String) -> Date? {
        print("dateFrom", sting)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: sting)
        return date
    }
    
    var _Calculations = (0, 0, 0, 0)
    func calculate(filteredData: [TransactionsStruct]) -> (Int, Int, Int, Int) {
        let result = (0, 0, 0, 0)
        let allTrans = Array(appData.getTransactions)
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
    
    
    
    func createTableData(filteredData: [TransactionsStruct]) -> [tableStuct] {
        var result: [tableStuct] = []
        var currentDate = ""
        let otherSections = 1
        //dataTaskCount?.1 = filteredData.count
        for i in 0..<filteredData.count {
            dataTaskCount = (i+1, filteredData.count)
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
            tableData = appData.getTransactions
            allSelectedTransactionsData = tableData
            return allSelectedTransactionsData

        } else {
            print("performFiltering: appending transactions data")
            print("daysBetween count: \(daysBetween.count), appData.transactions: \(appData.getTransactions.count)")
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
                    } else {
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
                }
                timers.append(timer)
            }
        }
    }
    var timers: [Timer] = []


    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("DIDAPPPP")
        center.getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.count
            }
        }
    }
    
    
   // var didloadCalled = false
    var sendSavedData = false
    //here
    func sendUnsaved() {
        let dataCount = appData.unsendedData.count
        
        print(dataCount, "dataCountdataCountdataCountdataCountdataCountdataCount")
        if forseSendUnsendedData {//wasSendingUnsended
            updateDataLabels(reloadAndAnimate: false)
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

                                            self.sendUnsaved()
                                        }
                                    }
                                } else {
                                    if let saveDebt = first["debt"] {
                                        save.Debts(toDataString: saveDebt) { (error) in
                                            if error {
                                                self.forseSendUnsendedData = false
                                                self.filter()
                                                DispatchQueue.main.async {
                                                    self.message.showMessage(text: "Internet Error!", type: .internetError)
                                                }
                                            } else {
                                                appData.unsendedData.removeFirst()

                                                self.sendUnsaved()
                                            }
                                        }
                                    } else {
                                        if let deleteDebt = first["deleteDebt"] {
                                            delete.Debts(toDataString: deleteDebt) { (error) in
                                                if error {
                                                    self.forseSendUnsendedData = false
                                                    self.filter()
                                                    DispatchQueue.main.async {
                                                        self.message.showMessage(text: "Internet Error!", type: .internetError)
                                                    }
                                                } else {
                                                    appData.unsendedData.removeFirst()

                                                    self.sendUnsaved()
                                                }
                                            }
                                        } else {
                                            if let saveUser = first["saveUser"] {
                                                save.Users(toDataString: saveUser) { (error) in
                                                    if error {
                                                        self.forseSendUnsendedData = false
                                                        self.filter()
                                                        DispatchQueue.main.async {
                                                            self.message.showMessage(text: "Internet Error!", type: .internetError)
                                                        }
                                                    } else {
                                                        appData.unsendedData.removeFirst()

                                                        self.sendUnsaved()
                                                    }
                                                }
                                            } else {
                                                if let deleteUser = first["deleteUser"] {
                                                    delete.User(toDataString: deleteUser) { (error) in
                                                        if error {
                                                            self.forseSendUnsendedData = false
                                                            self.filter()
                                                            DispatchQueue.main.async {
                                                                self.message.showMessage(text: "Internet Error!", type: .internetError)
                                                            }
                                                        } else {
                                                            appData.unsendedData.removeFirst()

                                                            self.sendUnsaved()
                                                        }
                                                    }
                                                }
                                            }
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
                    if self._filterText != "Sending" {
                        DispatchQueue.main.async {
                            self.filterText = "Sending"
                        }
                    }
                    
                    self.animateCellWillAppear = false
                    let save = SaveToDB()
                    var newCategories = appData.getCategories(key: K.Keys.localCategories)
                    print("sendUnsaved unsaved cats", newCategories.count)
                    if let categoryy = newCategories.first {
                        let toDataStringg = "&Nickname=\(appData.username)" + "&Title=\(categoryy.name)" + "&Purpose=\(categoryy.purpose)"
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
                                appData.saveCategories(newCategories, key: K.Keys.localCategories)

                                self.sendUnsaved()
                            }
                        }
                    }
                    
                    if newCategories.count == 0 {
                        var trans = appData.getLocalTransactions
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
                                    appData.saveTransations(trans, key: K.Keys.localTrancations)
                                    var alldata = appData.getTransactions
                                    alldata.append(tran)
                                    appData.saveTransations(alldata)

                                    self.sendUnsaved()
                                }
                            }
                        }
                        
                        if trans.count == 0 {
                            var debts = appData.getDebts(key: K.Keys.localDebts)
                            if let debt = debts.first {
                                let todString = "&Nickname=\(appData.username)" + "&name=\(debt.name)" + "&amountToPay=\(debt.amountToPay)" + "&dueDate=\(debt.dueDate)"
                                save.Debts(toDataString: todString) { (error) in
                                    if error {
                                        self.filter()
                                        self.forseSendUnsendedData = false
                                        self.sendSavedData = false
                                        DispatchQueue.main.async {
                                            self.message.showMessage(text: "Internet Error!", type: .internetError)
                                        }
                                    } else {
                                        debts.removeFirst()
                                        appData.saveDebts(debts, key: K.Keys.localDebts)
                                        var resultDebts = appData.getDebts()
                                        resultDebts.append(DebtsStruct(name: debt.name, amountToPay: debt.amountToPay, dueDate: debt.dueDate))
                                        appData.saveDebts(resultDebts)

                                        self.sendUnsaved()
                                    }
                                }
                            } else {
                                self.sendSavedData = false
                                self.forseSendUnsendedData = false
                                self.downloadFromDB()
                                DispatchQueue.main.async {
                                    UIImpactFeedbackGenerator().impactOccurred()
                                }
                               /* DispatchQueue.main.async {
                                    self.message.showMessage(text: "Done!", type: .succsess, windowHeight: 40, bottomAppearence: true)
                                }*/
                            }
                        }
                    }
                } else {
                    //unsavedComplited
                    self.filter()
                    DispatchQueue.main.async {
                        UIImpactFeedbackGenerator().impactOccurred()
                    }
                    
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
                
                var arr = Array(appData.getTransactions)
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
    

    var totalBalance = 0.0
    
    func calculateLabels(noData: Bool = false) {
        let tableTrans = Array(tableData)
        let allTrans = Array(appData.getTransactions)
        recalculation(i: self.incomeLabels, e: self.ecpensesLabels, periudData: tableTrans, noData:noData)
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
                //self.balanceLabel.text = "\(Int(self.totalBalance))"
                for label in self.balanceLabels {
                    label.text = "\(Int(self.totalBalance))"
                }
            }
        } else {
            DispatchQueue.main.async {
                //self.balanceLabel.text = "\(self.totalBalance)"
                for label in self.balanceLabels {
                    label.text = "\(self.totalBalance)"
                }
            }
        }
        if totalBalance < 0.0 {
            DispatchQueue.main.async {
                //self.balanceLabel.textColor = K.Colors.negative
                for label in self.balanceLabels {
                    label.textColor = K.Colors.negative
                }
            }
        } else {
            DispatchQueue.main.async {
               // self.balanceLabel.textColor = K.Colors.balanceV
                for label in self.balanceLabels {
                    label.textColor = K.Colors.balanceV
                }
            }
        }
        
        
        statisticBrain.getlocalData(from: tableTrans)
        sumAllCategories = statisticBrain.statisticData
    }
    
    private func recalculation(i:[UILabel], e: [UILabel], periudData: [TransactionsStruct], noData: Bool = false) {
        var sumIncomes = 0.0
        var sumExpenses = 0.0
        var sumPeriodBalance = 0.0
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
                for label in i {
                    label.text = "\(Int(sumIncomes))"
                }
                for label in e {
                    label.text = "\(Int(sumExpenses) * -1)"
                }
                for label in self.perioudBalanceLabels {
                    label.text = "\(Int(sumPeriodBalance))"
                }
            }
        } else {
            DispatchQueue.main.async {
                for label in i {
                    label.text = "\(sumIncomes)"
                }
                for label in e {
                    label.text = "\(sumExpenses * -1)"
                }
                for label in self.perioudBalanceLabels {
                    label.text = "\(sumPeriodBalance)"
                }
            }
        }
        DispatchQueue.main.async {

            UIView.animate(withDuration: noData ? 0.0 : 0.35) {
                self.perioudBalanceLabels.first?.superview?.isHidden = (self.totalBalance == sumPeriodBalance || sumPeriodBalance == 0) ? true : false
            } completion: { (_) in
                self.updateDataLabels(noData: noData)
            }

        }
        //hide or not
        print("recalculating labels")
    }
    

    

    
//MARK: - Other
    
    var daysBetween = [""]
    var selectedFromDayInt = 0
    var selectedToDayInt = 0
    

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
                    var arr = Array(appData.getTransactions)
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
                var arr = Array(appData.getTransactions)
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
        let arr = Array(appData.getTransactions.sorted{ $0.dateFromString > $1.dateFromString })
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
            
        case "toSettings", "toSettingsFullScreen":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SettingsViewController//segue.destination as! SettingsViewController
           // segue.kin
            vc.delegate = self
            vc.resetPassword = resetPassword
            resetPassword = false

        case "toStatisticVC":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! StatisticVC
            vc.dataFromMain = tableData
        case "toSingIn":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! LoginViewController
            
            vc.messagesFromOtherScreen = "Your password has been changed"
        default: return
        }
 
    }

    @IBOutlet weak var expencesStack: UIStackView!
    @IBOutlet weak var perioudBalanceView: UIStackView!

    
    
    
    //quite seques
    @IBAction func homeVC(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            print("HomeVC called")
            transactionAdded = false
            DispatchQueue.main.async {
                self.dataCountLabel.text = ""
            }
            if needFullReload {
                needFullReload = false
                self.toggleNoData(show: true, text: "Loading", fromTop: true, appeareAnimation: false, addButtonHidden: true)
            }
            self.downloadFromDB()
            
            if appData.fromLoginVCMessage != "" {
                print("appData.fromLoginVCMessage", appData.fromLoginVCMessage)
                DispatchQueue.main.async {
                    self.message.showMessage(text: appData.fromLoginVCMessage, type: .succsess, windowHeight: 45, bottomAppearence: true)
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
        //toSettingsFullScreen
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {//toSettings
                self.performSegue(withIdentifier: "toSettingsFullScreen", sender: self)
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toSettingsFullScreen", sender: self)
            }
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
    
    //@IBOutlet weak var whiteBackground: UIView!

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
    
    
    func compliteScrolling() {
        if mainTableView.contentOffset.y < self.bigCalcView.frame.height {
            if mainTableView.contentOffset.y < self.bigCalcView.frame.height / 2 {
                canTouchHandleTap = true
                
                DispatchQueue.main.async {
                    self.mainTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            } else {
                canTouchHandleTap = false
                DispatchQueue.main.async {
                    self.mainTableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
                }
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      /*  DispatchQueue.main.async {
            self.darkBackgroundUnderTable.frame = self.correctFrameBackground
        }*/
        compliteScrolling()
    }
    
    
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
                print(scrollView.contentOffset.y, "scrollView.contentOffset.yscrollView.contentOffset.y")
             /*   DispatchQueue.main.async {
                    //self.correctFrameBackground
                    self.darkBackgroundUnderTable.frame = CGRect(x: 0, y: self.correctFrameBackground.minY + (scrollView.contentOffset.y * (-1)), width: self.correctFrameBackground.width, height: self.correctFrameBackground.height)
                }*/
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
              //  let safeArea = self.whiteBackground.frame.minY - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom
          /*      print(safeArea, "lknbvghjklmnbhvg")
                
                if scrollView.contentSize.height - 210 <= scrollView.contentOffset.y {
                    scrollView.contentOffset.y = scrollView.contentSize.height - 210
                }*/
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


    @IBAction func addTransactionPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToEditVC", sender: self)
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
    
    
    
    var animateCellWillAppear = true
    var calcViewHeight:CGFloat = 0
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
            let calculationCell = tableView.dequeueReusableCell(withIdentifier: "calcCell") as? calcCell
            calculationCell?.isUserInteractionEnabled = false
            calculationCell?.contentView.isUserInteractionEnabled = false
            
           /* let sendedCount = (UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String]] ?? []) + (UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String]] ?? []) + (UserDefaults.standard.value(forKey: K.Keys.localDebts) as? [[String]] ?? [])

            //prevUserName
            let prevName = UserDefaults.standard.value(forKey: "prevUserName") as? String ?? "previous account"
            calculationCell.prevAcountDataLabel.text = "Data from \(prevName == "" ? "previous account" : prevName):"
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
            }*/
            
            
            return calculationCell ?? UITableViewCell()
            
        case 1..<(1 + newTableData.count):
            let data = newTableData[indexPath.section - 1].transactions[indexPath.row]
            let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
            transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell, indexPath: indexPath)
            return transactionsCell
            
        default: return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            print("firstSection")
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
            print("did sel def")
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
            main.backgroundColor = .clear//section == 1 ? K.Colors.background : UIColor.clear
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

            let monthLabel = UILabel()
            monthLabel.font = .systemFont(ofSize: 10, weight: .regular)
            monthLabel.textColor = K.Colors.balanceT
            
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
            
            if newTableData.count > section - 1 {
                dateLabel.text = "\(makeTwo(n: newTableData[section - 1].date.day ?? 0))"
                monthLabel.text = "\(returnMonth(newTableData[section - 1].date.month ?? 0)),\n\(newTableData[section - 1].date.year ?? 0)"
                amountLabel.text = " \(newTableData[section - 1].amount > 0 ? "+" : "")\(newTableData[section - 1].amount) "
            }
            
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
        if tableView.contentOffset.y > 20 {
            if indexPath.section == 0 {
                DispatchQueue.main.async {
                   /* if self.newTableData.count > 0 {
                       // self.mainTableView.backgroundColor = UIColor(named: "darkTableColor") ?? .black
                    }*/
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
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return bigCalcView.layer.frame.height + 20
        } else {
            return UITableView.automaticDimension
            //tableView.cellForRow(at: indexPath)?.layer.frame.height ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        /*if indexPath.section == 0 && indexPath.row == 0 {
            //calcViewHeight = cell.frame.height
          //  cell.frame = CGRect(x: 0, y: 0, width: 10, height: 30)
            cell.backgroundColor = .red
            cell.layer.frame = CGRect(x: 0, y: 0, width: 10, height: 30)
            print(calcViewHeight, "cgfgujlmnbvfghjm")
        }*/
        
        if transactionAdded {
            transactionAdded = false
            filter()
        }
        if indexPath == highliteCell {
            highliteCell = nil
            DispatchQueue.main.async {

                UIView.animate(withDuration: 0.23) {
                    cell.backgroundColor = UIColor(red: 225/255, green: 114/255, blue: 44/255, alpha: 1)
                } completion: { (_) in
                    UIView.animate(withDuration: 0.36) {
                        cell.backgroundColor = UIColor(named: "darkTableColor")
                    } completion: { (_) in
                      /*  UIView.animate(withDuration: 0.1) {
                           // self.mainTableView.backgroundColor = .clear
                        }*/
                    }
                }

                
                
            }
        }
        
      //  if tableView.contentOffset.y > 20 {
            if indexPath.section == 0 {
                DispatchQueue.main.async {
                    /*if self.newTableData.count > 0 {
                       // self.mainTableView.backgroundColor = .clear
                    }*/
                    self.mainTableView.layer.cornerRadius = 0
                    self.addTransitionButton.isHidden = true//!self.forseShowAddButton ? true : false
                    UIView.animate(withDuration: self.animateCellWillAppear ? 0.3 : 0) {
                        let superframe = self.calculationSView.superview?.frame ?? .zero
                        let selfFrame = self.calculationSView.frame
                        self.calculationSView.frame = CGRect(x: selfFrame.minX, y: -superframe.height, width: selfFrame.width, height: selfFrame.height)
                        self.filterView.frame = self.filterAndCalcFrameHolder.0
                    }
                }
            }
     //   }
        
        
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
            DispatchQueue.main.async {
                self.filterText = "Adding"
            }
            if appData.username != "" {
                let toDataString = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                let save = SaveToDB()
                save.Transactions(toDataString: toDataString) { (error) in
                    if error {
                        let neew: String = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                        appData.unsendedData.append(["transaction": neew])
                    }
                    
                    var trans = appData.getTransactions
                    trans.append(new)
                    appData.saveTransations(trans)
                    if !error {
                        self.forseSendUnsendedData = true
                        self.sendUnsaved()
                    }
                    self.filter()
                }
            } else {
                var trans = appData.getTransactions
                trans.append(new)
                appData.saveTransations(trans)
                self.filter()
            }
        } else {
            print("reloaddd")
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                self.calculateLabels()
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
            calculateLabels()
        } else {
            if deletePressed {
                appData.saveTransations([], key: K.Keys.localTrancations)
                appData.saveCategories([], key: K.Keys.localCategories)
                appData.saveDebts([], key: K.Keys.localDebts)
                calculateLabels()
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
        calculateLabels()
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
            print("hghjknhj")
            if needFiltering {
                print("ViewController needFiltering")
                self.downloadFromDB()
            } else {
               // calculateLabels()
            }
            
        }
    }
    
    
}
