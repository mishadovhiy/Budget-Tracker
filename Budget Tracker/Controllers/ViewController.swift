//
//  ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

var appData = AppData()
var statisticBrain = StatisticBrain()//?
var sumAllCategories: [String: Double] = [:]//?
var allSelectedTransactionsData: [TransactionsStruct] = []//for statistic
var expenseLabelPressed = true//make only in vc
var selectedPeroud = ""//try to ud
var sendSavedData = false

var needDownloadOnMainAppeare = false

class ViewController: SuperViewController {
    @IBOutlet weak var sideTableView: UITableView!
    
    @IBOutlet weak var sideBar: SideBar!
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
                

                
                
            //    if self.sendSavedData {
                    if appData.username != "" {
                        self.sendUnsaved()
                    }
             //   }
                print(self.newTransaction, "self.newTransactionself.newTransactionself.newTransaction")
                if let new = self.newTransaction {
             //       self.mainTableView.backgroundColor = UIColor(named: "darkTableColor")
                    self.newTransaction = nil
                    for i in 0..<newValue.count {
                        let date = "\(self.makeTwo(n: newValue[i].date.day ?? 0)).\(self.makeTwo(n: newValue[i].date.month ?? 0)).\(newValue[i].date.year ?? 0)"
                        print("date:", date )
                        if new.date == "\(date)" {
                            for t in 0..<newValue[i].transactions.count {
                                if new.categoryID == newValue[i].transactions[t].categoryID && new.comment == newValue[i].transactions[t].comment && new.value == newValue[i].transactions[t].value
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
    func downloadFromDB(showError: Bool = false) {
        _categoriesHolder.removeAll()
        _debtsHolder.removeAll()
        lastSelectedDate = nil
        DispatchQueue.main.async {
            self.filterText = "Downloading"
        }
        let load = LoadFromDB()
        load.newCategories { categoryes, error in
            if error == .none {
                self.highesLoadedCatID = ((categoryes.sorted{ $0.id > $1.id }).first?.id ?? 0) + 1
                load.newTransactions { loadedData, error in
                    self.tableData = loadedData
                    self.checkPurchase()
                    self.prepareFilterOptions()
                    self.filter()
                }
            } else {
                self.prepareFilterOptions()
                self.filter()
                if showError {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: "Error", type: .internetError)
                    }
                }

            }
        }
       /* let unsend = appData.unsendedData
        undendedCount = unsend.count
        if unsend.count > 0 {
            if appData.username != "" {
                self.sendUnsaved()
            }
        } else {
            
        }*/


    }
    
    
    
    
    static var shared: ViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        ViewController.shared = self
        updateUI()
        if #available(iOS 15.0, *) {
            self.mainTableView.sectionHeaderTopPadding = 0
        }
        self.mainTableView.layer.cornerRadius = 15
       // mainTableView.isUserInteractionEnabled = false
     //   self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bigCalcTaps(_:))))
        sideBar.load()
        toggleSideBar(false, animated: false)
    }
    
    @IBOutlet weak var mainContentViewHelpher: UIView!
    @IBOutlet weak var mainContentView: UIView!
    var sideBarShowing = false
    var firstLod = true
    func toggleSideBar(_ show: Bool, animated:Bool) {
        sideBarShowing = show
        DispatchQueue.main.async {
            let frame = self.sideBar.layer.frame
            UIView.animate(withDuration: animated ? 0.3 : 0) {
                //self.sideBar.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width * (-1) : frame.width * (-1), 0, 0)
                //self.view.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? 0 : frame.width * (-1), 0, 0)
                self.mainContentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width : 0, 0, 0)
                self.mainContentViewHelpher.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width : 0, 0, 0)
            } completion: { _ in
                if self.firstLod {
                    self.firstLod = false
                    self.sideBar.isHidden = false
                    self.menuButton.isEnabled = true
                }
            }

        }
    }
    @IBAction func menuPressed(_ sender: UIButton) {
        toggleSideBar(!sideBarShowing, animated: true)
    }
    
    @IBOutlet weak var menuButton: UIButton!
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    var subviewsLoaded = false
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !subviewsLoaded {
            subviewsLoaded = true
            self.addTransactionWhenEmptyButton.layer.cornerRadius = 5
            self.addTransactionWhenEmptyButton.layer.masksToBounds = true
            self.noDataView.translatesAutoresizingMaskIntoConstraints = true
            self.noDataView.layer.masksToBounds = true
            self.noDataView.layer.cornerRadius = self.tableCorners
            self.noDataView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.darkBackgroundUnderTable.layer.masksToBounds = true
            self.darkBackgroundUnderTable.layer.cornerRadius = self.tableCorners
            self.darkBackgroundUnderTable.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.darkBackgroundUnderTable.translatesAutoresizingMaskIntoConstraints = true
            self.addTransitionButton.layer.cornerRadius = self.addTransitionButton.layer.frame.width / 2
            self.view.addSubview(self.filterHelperView)
            self.shadow(for: self.filterHelperView)
            self.filterView.superview?.layer.masksToBounds = true
            self.filterView.superview?.translatesAutoresizingMaskIntoConstraints = true
            self.filterView.translatesAutoresizingMaskIntoConstraints = true
            self.calculationSView.translatesAutoresizingMaskIntoConstraints = true
            let image = UIImage(named: "plusIcon")
            let button = UIButton(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.layer.frame.width / 2
            button.setImage(image, for: .normal)
            self.refreshSubview.addSubview(button)
            let superWidth = self.view.frame.width
            self.refreshSubview.frame = CGRect(x: superWidth / 2 - 10, y: 0, width: 20, height: 20)
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            self.refreshSubview.alpha = 0
            self.refreshControl.addSubview(self.refreshSubview)
           // self.refreshControl.backgroundColor = .red//K.Colors.background
            self.mainTableView.addSubview(self.refreshControl)
        }
    }
    
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

            
            self.filterAndCalcFrameHolder.0 = self.filterView.frame
            self.filterAndCalcFrameHolder.1 = self.calculationSView.frame
            
            let superframe = self.calculationSView.superview?.frame ?? .zero
            let calcFrame = self.calculationSView.frame
            self.calculationSView.frame = CGRect(x: -superframe.height, y: calcFrame.minY, width: calcFrame.width, height: calcFrame.height)
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
    let tableCorners: CGFloat = 22
    var forseSendUnsendedData = true
    var addTransFrame = CGRect.zero
    
    
    
    var enableLocalDataPress = false
    func updateDataLabels(reloadAndAnimate: Bool = true, noData: Bool = false) {
        print("updateDataLabelsCalled")
        let unsendedCount = appData.unsendedData.count
        let localCount = ((UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String:Any]] ?? []) + (UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String:Any]] ?? [])).count
       // let prevName = UserDefaults.standard.value(forKey: "prevUserName") as? String ?? "previous account"

        DispatchQueue.main.async {
            self.unsendedDataLabel.text = "\(unsendedCount)"
            self.dataFromTitleLabel.text = "Local data:"//"Data from \(prevName == "" ? "previous account" : prevName):"
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
        if nick == "" {
            return
        }
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
                                if loadedData[i][5] != "" {
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
            let db = DataBase()
            tableData = db.transactions
            allSelectedTransactionsData = tableData
            return allSelectedTransactionsData

        } else {
            print("performFiltering: appending transactions data")
            print("daysBetween count: \(daysBetween.count), appData.transactions: \(appData.getTransactions.count)")
            var arr = tableData
            arr.removeAll()
            var matches = 0
            let days = Array(daysBetween)
            let transactions = UserDefaults.standard.value(forKey: "transactionsData") as? [[String:Any]] ?? []
            for number in 0..<days.count {
                for i in 0..<transactions.count {
                    if days.count > number {
                        if days[number] == (transactions[i]["Date"] as? String ?? "") {
                            if let new = db.transactionFrom(transactions[i]) {
                                matches += 1
                                arr.append(new)
                            }
                            
                            
                           // arr.append(TransactionsStruct(value: transactions[i][1], categoryID: transactions[i][2], date: transactions[i][3], comment: transactions[i][4]))
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

    override func viewWillDisappear(_ animated: Bool) {
        safeArreaHelperView?.alpha = 1
    }

    var safeArreaHelperViewAdded = false
    
    var safeArreaHelperView: UIView?
    
    let center = AppDelegate.shared?.center
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("DIDAPPPP")
        sideTableView.reloadData()

        if needDownloadOnMainAppeare {
            needDownloadOnMainAppeare = false
            self.downloadFromDB()
        }

        let safeTop = self.view.safeAreaInsets.top
        self.safeArreaHelperView?.alpha = 0
        if !safeArreaHelperViewAdded {
            safeArreaHelperViewAdded = true
            if let window = AppDelegate.shared?.window {
                DispatchQueue.main.async {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: safeTop))
                    self.safeArreaHelperView = view
                    self.safeArreaHelperView?.alpha = 0
                    view.backgroundColor = K.Colors.primaryBacground
                    window.addSubview(self.safeArreaHelperView!)
                }
            }
        }
        
        appData.safeArea = (safeTop, self.view.safeAreaInsets.bottom)
    }
    
    
   // var didloadCalled = false
    
    //here
    var startedSendingUnsended = false
    var highesLoadedCatID: Int?
    func sendUnsaved() {
        //breaek when error
        let errorAction = {
            self.startedSendingUnsended = false
            if sendSavedData {
                sendSavedData = false
                //show message error, try again later
            }
            self.filter()
        }
        let unsended = appData.unsendedData
        if unsended.count > 0 {
            if let first = unsended.first {
                startedSendingUnsended = true
                updateDataLabels(reloadAndAnimate: false)
                if self._filterText != "Sending" {
                    DispatchQueue.main.async {
                        self.filterText = "Sending"
                    }
                }
                
                let save = SaveToDB()
                let delete = DeleteFromDB()
                /*if let addTransaction = db.transactionFrom(first["transactionNew"] ?? [:]) {
                    save.newTransaction(addTransaction, saveLocally: false) { error in
                        if !error {
                            appData.unsendedData.removeFirst()
                            self.sendUnsaved()
                        } else {
                            errorAction()
                        }
                    }
                } else {
                    if let deleteTransaction = db.transactionFrom(first["deleteTransactionNew"] ?? [:]) {
                        delete.newTransaction(deleteTransaction, saveLocally: false) { error in
                            if !error {
                                appData.unsendedData.removeFirst()
                                self.sendUnsaved()
                            }else {
                                errorAction()
                            }
                        }
                    } else {*/
                        if let addCategory = db.categoryFrom(first["categoryNew"] ?? [:]) {
                            if let highest = highesLoadedCatID {
                                var cat = addCategory
                                cat.id = highest
                                save.newCategories(cat, saveLocally: false) { error in
                                    if !error {
                                        self.highesLoadedCatID! += 1
                                        for i in 0..<unsended.count {
                                            if let newTrans = unsended[i]["transactionNew"] {
                                                if let trans = self.db.transactionFrom(newTrans) {
                                                    if trans.categoryID == "\(cat.id)" {
                                                        var newTransaction = trans
                                                        newTransaction.categoryID = "\(highest)"
                                                        appData.unsendedData[i]["transactionNew"] = self.db.transactionToDict(newTransaction)
                                                    }
                                                }
                                            }
                                        }
                                        appData.unsendedData.removeFirst()
                                        self.sendUnsaved()
                                    } else {
                                        errorAction()
                                    }
                                }
                            } else {
                                let load = LoadFromDB()
                                load.newCategories { loadedCategories, error in
                                    if error == .none {
                                        let allCatSorted = loadedCategories.sorted{ $0.id > $1.id }
                                        let highest = allCatSorted.first?.id ?? 0
                                        self.highesLoadedCatID = highest
                                        
                                        
                                        self.sendUnsaved()
                                    } else {
                                        errorAction()
                                    }
                                }
                            }
                        } else {
                            if let deleteCategory = db.categoryFrom(first["deleteCategoryNew"] ?? [:]) {
                                delete.CategoriesNew(category: deleteCategory, saveLocally: true) { error in
                                    if !error {
                                        appData.unsendedData.removeFirst()
                                        self.sendUnsaved()
                                    } else {
                                        errorAction()
                                    }
                                }
                            } else {
                                if let addTransaction = db.transactionFrom(first["transactionNew"] ?? [:]) {
                                    save.newTransaction(addTransaction, saveLocally: false) { error in
                                        if !error {
                                            appData.unsendedData.removeFirst()
                                            self.sendUnsaved()
                                        } else {
                                            errorAction()
                                        }
                                    }
                                } else {
                                    if let deleteTransaction = db.transactionFrom(first["deleteTransactionNew"] ?? [:]) {
                                        delete.newTransaction(deleteTransaction, saveLocally: false) { error in
                                            if !error {
                                                appData.unsendedData.removeFirst()
                                                self.sendUnsaved()
                                            }else {
                                                errorAction()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    /*}
                }*/
            }
        } else {
            if startedSendingUnsended {
                startedSendingUnsended = false
                downloadFromDB()
            } else {
                //send local data
                if sendSavedData {
                    //update labels
                    updateDataLabels(reloadAndAnimate: false)
                    if self._filterText != "Sending" {
                        DispatchQueue.main.async {
                            self.filterText = "Sending"
                        }
                    }
                    let save = SaveToDB()
                    if let category = db.localCategories.first {
                        if let highest = highesLoadedCatID {
                            var cat = category
                            cat.id = highest
                            save.newCategories(cat) { error in
                                
                                if !error {
                                    self.highesLoadedCatID! += 1
                                    self.db.localCategories.removeFirst()//deleteCategory(id: "\(category.id)", local: true)
                                    let localTransactions = self.db.localTransactions
                                    
                          //          var newCategory = category
                          //          newCategory.id = highest
                                    
                             //       self.db.deleteCategory(id: "\(category.id)", local: true)
                            //        self.db.localCategories.append(newCategory)
                                    
                                    for i in 0..<localTransactions.count {
                                        
                                        if localTransactions[i].categoryID == "\(category.id)" {
                                            var newTransaction = localTransactions[i]
                                            newTransaction.categoryID = "\(cat.id)"

                                            self.db.deleteTransaction(transaction: localTransactions[i], local: true)
                                            self.db.transactions.append(newTransaction)
                                        }
                                        
                                    }
                                    self.sendUnsaved()
                                } else {
                                    errorAction()
                                }
                            }
                        } else {
                            let load = LoadFromDB()
                            load.newCategories { loadedCategories, error in
                                if error == .none {
                                    let allCatSorted = loadedCategories.sorted{ $0.id > $1.id }
                                    let highest = allCatSorted.first?.id ?? 0
                                    self.highesLoadedCatID = highest
                                    
                                    self.sendUnsaved()
                                } else {
                                    errorAction()
                                }
                            }
                        }
                    } else {
                        if let transaction = db.localTransactions.first {
                            save.newTransaction(transaction) { error in
                                if !error {
                                    self.db.localTransactions.removeFirst()
                                    self.sendUnsaved()
                                } else {
                                    errorAction()
                                }
                            }
                        } else {
                            sendSavedData = false
                            downloadFromDB()
                        }
                    }
                }
            }
            
        }

    }
    
   /* func sendUnsaved() {
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
                            let toDataString = "&Nickname=\(appData.username)" + "&Category=\(tran.categoryID)" + "&Date=\(tran.date)" + "&Value=\(tran.value)" + "&Comment=\(tran.comment)"
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
        
        
    }*/
    
    
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
        let delete = DeleteFromDB()
        delete.newTransaction(newTableData[at.section].transactions[at.row]) { _ in
            self.filter()
        }
    }
    
    
    


    override func viewWillAppear(_ animated: Bool) {
        print("today is", appData.filter.getToday(appData.filter.filterObjects.currentDate))
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
        
        
      //  statisticBrain.getlocalData(from: tableTrans) -- change statistic
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
        
        let hidePerioudBalance = (self.totalBalance == sumPeriodBalance || sumPeriodBalance == 0) ? true : false
        DispatchQueue.main.async {
            if self.perioudBalanceLabels.first?.superview?.isHidden ?? false != hidePerioudBalance {
                UIView.animate(withDuration: noData ? 0.0 : 0.35) {
                    self.perioudBalanceLabels.first?.superview?.isHidden = hidePerioudBalance
                } completion: { (_) in
                    self.updateDataLabels(noData: noData)
                }
            } else {
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
    let db = DataBase()
    func prepareFilterOptions(_ data:[TransactionsStruct]? = nil) {
        let dat = data == nil ? Array(db.transactions) : data!
        let arr = Array(dat.sorted{ $0.dateFromString > $1.dateFromString })
        //Array(appData.getTransactions.sorted{ $0.dateFromString > $1.dateFromString })
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
    
    func removeDayFromString(_ s: String) -> String {//-> date comp
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
        toggleSideBar(false, animated: true)
        print("prepare")
        selectedCell = nil
        DispatchQueue.main.async {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        switch segue.identifier {
        case "toDebts":
            print("k")
            let vc = segue.destination as! CategoriesVC
            vc.fromSettings = true
            vc.screenType = .debts
        case "toCategories", "toLocalData":
            let vc = segue.destination as! CategoriesVC
            vc.screenType = segue.identifier == "toLocalData" ? .localData : .categories
            vc.fromSettings = true
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
                let helperFrame = self.mainContentViewHelpher.frame
                let vcFrame = CGRect(x: filterFrame.minX + superFilter.minX, y: filterFrame.minY + superFilter.minY + helperFrame.height, width: filterFrame.width, height: filterFrame.width)
                vc?.frame = vcFrame
                self.filterHelperView.frame = CGRect(x: filterFrame.minX + superFilter.minX, y: vcFrame.minY, width: vcFrame.width, height: vcFrame.height)
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
                vc.editingCategory = transaction.categoryID
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
            let vc = nav.topViewController as! SettingsViewController
            vc.delegate = self
            vc.resetPassword = resetPassword
            resetPassword = false

        case "toStatisticVC":
           // let nav = segue.destination as! UINavigationController
            let vc = segue.destination as! StatisticVC//nav.topViewController as! StatisticVC
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.first, "ghjnbguk")
    }
    
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
        if section == 0 {
            return 1
            
        } else {
            return newTableData[section - 1].transactions.count + 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + newTableData.count
    }
  /*  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles: [String] = ["."]
        let data = newTableData
        for i in 0..<data.count {
            
            titles.append("\(data[i].date.day ?? 0)")
        }
        return titles
    }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let calculationCell = tableView.dequeueReusableCell(withIdentifier: "calcCell") as? calcCell
          //  calculationCell?.isUserInteractionEnabled = false
          //  calculationCell?.contentView.isUserInteractionEnabled = false
            ///add touches in class
            /////send
            return calculationCell ?? UITableViewCell()
        } else {
            if newTableData[indexPath.section - 1].transactions.count == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mainFooterCell") as! mainFooterCell
                cell.totalLabel.text = "\(newTableData[indexPath.section - 1].amount)"
                cell.cornerView.layer.cornerRadius = 15
                cell.cornerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                cell.separatorInset.left = tableView.frame.width / 2
                cell.separatorInset.right = tableView.frame.width / 2
                return cell
            } else {
                let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
                transactionsCell.isUserInteractionEnabled = true
                transactionsCell.contentView.isUserInteractionEnabled = true
                print("row:", indexPath.row)
                print("count:", newTableData[indexPath.section - 1].transactions.count)
                let data = newTableData[indexPath.section - 1].transactions[indexPath.row]
                transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell, indexPath: indexPath)
                return transactionsCell
            }
            
        }

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        if indexPath.section != 0 {
            if newTableData[indexPath.section-1].transactions.count != indexPath.row {
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
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        if indexPath.section != 0 {
            let editeAction = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
               // self.editRow(at: IndexPath(row: indexPath.row, section: indexPath.section - 1)) -- its perform saving,
                // go to trans vc indeed
                self.editingTransaction = self.newTableData[indexPath.section - 1].transactions[indexPath.row]
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToEditVC", sender: self)
                }
            }
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                self.tableActionActivityIndicator.startAnimating()
                self.tableActionActivityIndicator.frame = CGRect(x: view.frame.width / 2 - 5, y: 0, width: 10, height: view.frame.height)
                view.addSubview(self.tableActionActivityIndicator)
                self.deleteFromDB(at: IndexPath(row: indexPath.row, section: indexPath.section - 1))
            }
            editeAction.backgroundColor = K.Colors.yellow
            deleteAction.backgroundColor = K.Colors.negative
            return UISwipeActionsConfiguration(actions: newTableData[indexPath.section - 1].transactions.count != indexPath.row ? [editeAction, deleteAction] : [] )
                                               
                                               } else {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainHeaderCell") as! mainHeaderCell
        
        cell.dateLabel.text = "\(makeTwo(n: newTableData[section - 1].date.day ?? 0))"
        cell.monthLabel.text = "\(returnMonth(newTableData[section - 1].date.month ?? 0)),\n\(newTableData[section - 1].date.year ?? 0)"
        cell.yearLabel.text = "\(newTableData[section - 1].date.year ?? 0)"
        cell.mainView.layer.cornerRadius = 15
        cell.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return cell.contentView

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 60
        } else {
            return 0
        }
    }
    
   /* func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainFooterCell") as! mainFooterCell
            cell.totalLabel.text = "\(newTableData[section - 1].amount)"
            cell.cornerView.layer.cornerRadius = 15
            cell.cornerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            return cell.contentView
        } else {
            return nil
        }
        
    }*/
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.contentOffset.y > 20 {
            if indexPath.section == 0 {
                DispatchQueue.main.async {
                   /* if self.newTableData.count > 0 {
                       // self.mainTableView.backgroundColor = UIColor(named: "darkTableColor") ?? .black
                    }*/
                   /* self.mainTableView.layer.masksToBounds = true
                    self.mainTableView.layer.cornerRadius = self.tableCorners
                    self.mainTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    self.addTransitionButton.isHidden = false*/
                    self.mainTableView.backgroundColor = self.view.backgroundColor
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

               /* UIView.animate(withDuration: 0.23) {
                    cell.backgroundColor = UIColor(red: 225/255, green: 114/255, blue: 44/255, alpha: 1)
                } completion: { (_) in
                    UIView.animate(withDuration: 0.36) {
                        cell.backgroundColor = UIColor(named: "darkTableColor")
                    } completion: { (_) in
                      /*  UIView.animate(withDuration: 0.1) {
                           // self.mainTableView.backgroundColor = .clear
                        }*/
                    }
                }*/

                
                
            }
        }
        
      //  if tableView.contentOffset.y > 20 {
            if indexPath.section == 0 {
                DispatchQueue.main.async {
                    /*if self.newTableData.count > 0 {
                       // self.mainTableView.backgroundColor = .clear
                    }*/
                    //self.mainTableView.layer.cornerRadius = 0
                   // self.addTransitionButton.isHidden = true//!self.forseShowAddButton ? true : false
                    UIView.animate(withDuration: self.animateCellWillAppear ? 0.3 : 0) {
                        self.mainTableView.backgroundColor = .clear
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
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct) {
        let delete = DeleteFromDB()
        delete.newTransaction(was) { _ in
            let save = SaveToDB()
            save.newTransaction(transaction) { _ in
                self.filter()
            }
        }
    }
    
    func addNewTransaction(value: String, category: String, date: String, comment: String) {
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
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
            let save = SaveToDB()
            save.newTransaction(TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)) { error in
                self.filter()
                if !error {
                    self.forseSendUnsendedData = true
                    self.sendUnsaved()
                }
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
    
    func quiteTransactionVC(reload:Bool){

        if reload {
            print("trloaddd")
            filter()
        }
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
    func closeSettings(sendSavedDataa: Bool, needFiltering: Bool) {
        calculateLabels()
        self.animateCellWillAppear = false
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.animateCellWillAppear = true
        }
        if sendSavedData {
            sendSavedData = true
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




class mainHeaderCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
}

class mainFooterCell: UITableViewCell {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
}
