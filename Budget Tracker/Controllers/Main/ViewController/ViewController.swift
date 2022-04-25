//
//  ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
//calculateLabels
//downloadFromDB
//sendUnsaved
let appData = AppData()


class ViewController: SuperViewController {
    
    @IBOutlet weak var sideTableView: UITableView!
    @IBOutlet weak var pinchView: UIView!
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
    
    @IBOutlet weak var darkBackgroundUnderTable: UIView!
    @IBOutlet var ecpensesLabels: [UILabel]!
    @IBOutlet var incomeLabels: [UILabel]!
    @IBOutlet var balanceLabels: [UILabel]!
    @IBOutlet var perioudBalanceLabels: [UILabel]!
    @IBOutlet weak var bigCalcView: UIView!
    @IBOutlet weak var notificationsView: View!
    @IBOutlet weak var notificationsLabel: UILabel!
    
    var _notificationsCount = (0,0)
    var notificationsCount:(Int, Int) {
        get { return _notificationsCount }
        set {
            _notificationsCount = newValue
            let result = newValue.0 + newValue.1
            let hide = result == 0
            DispatchQueue.main.async {
                self.notificationsLabel.text = "\(result)"
                if self.notificationsView.isHidden != hide {
                    UIView.animate(withDuration: 0.3) {
                        self.notificationsView.isHidden = hide
                    }
                    
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        let sideBarPinch = UIPanGestureRecognizer(target: self, action: #selector(sideBarPinched(_:)))
        pinchView.addGestureRecognizer(sideBarPinch)
        ViewController.shared = self
        sideBar.load()
        toggleSideBar(false, animated: false)
        
    }
    
    
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
            dataTaskCount = nil
            selectedCell = nil
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                self.toggleNoData(show: false, addButtonHidden: true)
                self.filterText = "Filter".localize + ": " + appData.filter.selectedPeroud
                self.calculationSView.alpha = 0
                UIView.animate(withDuration: 0.8) {
                    self.calculationSView.alpha = 1
                } completion: { _ in
                    self.updateDataLabels(noData: newValue.count == 0)
                }
                self.tableActionActivityIndicator.removeFromSuperview()
                    if appData.username != "" {
                        self.sendUnsaved()
                    }
                if let _ = self.newTransaction {
                    self.newTransaction = nil
                    self.compliteScrolling()
                }
                if self.openFiler {
                    self.openFiler = false
                        self.performSegue(withIdentifier: "toFiterVC", sender: self)
                }
                if let addedAction = self.actionAfterAdded {
                    self.actionAfterAdded = nil
                    addedAction(true)
                }
                
            }
        }
    }
    


    var _calculations:Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
    var calculations:Calculations {
        get { return _calculations }
        set {
            _calculations = newValue
            DispatchQueue.main.async {
                for label in self.self.ecpensesLabels {
                    label.text = "\(Int(newValue.expenses))"
                }
                for label in self.incomeLabels {
                    label.text = "\(Int(newValue.income))"
                }
                for label in self.perioudBalanceLabels {
                    let value = Int(newValue.perioudBalance)
                    label.text = "\(value)"
                    label.textColor = value >= 0 ? K.Colors.category : K.Colors.negative
                }
                for label in self.balanceLabels {
                    let value = Int(newValue.balance)
                    label.text = "\(value)"
                    label.textColor = value >= 0 ? K.Colors.category : K.Colors.negative
                }
                
            }
        }
    }
    struct Calculations {
        var expenses:Double
        var income:Double
        var balance:Double
        var perioudBalance:Double
    }
    
    func dataToDict(_ transactions:[TransactionsStruct]) -> [String:[TransactionsStruct]] {
        var result:[String:[TransactionsStruct]] = [:]
        var i = 0
        let totalCount = transactions.count
        for trans in transactions {
            self.calculations.balance += (Double(trans.value) ?? 0.0)
            dataTaskCount = (i, totalCount)
            i += 1
            if trans.category.purpose != .debt {
                if containsDay(curDay: trans.date) {
                    var transForDay = result[trans.date] ?? []
                    transForDay.append(trans)
                    result.updateValue(transForDay, forKey: trans.date)
                    
                }
            }
        }
        return result
    }
    //here
    func dictToTable(_ dict:[String:[TransactionsStruct]]) -> [tableStuct] {
        var result:[tableStuct] = []
        for (key, value) in dict {
            let co = DateComponents()
            let transactions = value.sorted { Double($0.value) ?? 0.0 < Double($1.value) ?? 0.0 }
            let date = co.stringToDateComponent(s: key)
            let amount = Int(amountForTransactions(transactions))
            let new:tableStuct = .init(date:  date, amount: amount, transactions: transactions)
            result.append(new)
        }
        return result
    }
    
    private func amountForTransactions(_ transactions:[TransactionsStruct]) -> Double {
        var result:Double = 0
        var calcs:Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
        for transaction in transactions {
            let amount = (Double(transaction.value) ?? 0.0)
            result += amount
            
            if amount > 0 {
                calcs.income += amount
            } else {
                calcs.expenses += amount
            }
            calcs.perioudBalance += amount
            
        }
        let currentCalcs = calculations
        calculations = .init(expenses: currentCalcs.expenses + calcs.expenses, income: currentCalcs.income + calcs.income, balance: calculations.balance, perioudBalance: currentCalcs.perioudBalance + calcs.perioudBalance)
        return result
    }
    private func containsDay(curDay:String) -> Bool {
        if appData.filter.showAll {
            return true
        } else {
            for day in daysBetween {
                if day == curDay {
                    return true
                }
            }
            return false
        }
        
    }
    
    func downloadFromDB(showError: Bool = false, title: String = "Downloading".localize) {
        self.editingTransaction = nil
        self.sendError = false

        lastSelectedDate = nil
        DispatchQueue.main.async {
            self.filterText = title
        }
        DispatchQueue.init(label: "download").async {
            LoadFromDB.shared.newCategories { categoryes, error in
                AppData.categoriesHolder = categoryes
                if error == .none {
                    self.highesLoadedCatID = ((categoryes.sorted{ $0.id > $1.id }).first?.id ?? 0) + 1
                    LoadFromDB.shared.newTransactions { loadedData, error in
                        self.checkPurchase()
                        self.filter(data: loadedData)
                    }
                } else {
                    self.filter()
                    if showError {
                        DispatchQueue.main.async {
                            self.newMessage.show(type: .internetError)
                        }
                    }

                }
            }
        }
        
    }

    
    
    var sidescrolling = false
    var wasShowingSideBar = false
    var beginScrollPosition:CGFloat = 0
    @objc func sideBarPinched(_ sender: UIPanGestureRecognizer) {
        let finger = sender.location(in: self.view)
        if sender.state == .began {
            sidescrolling = finger.x < 80
            wasShowingSideBar = sideBarShowing
        }
        if sidescrolling || sideBarShowing {
            if sender.state == .began || sender.state == .changed {
                let newPosition = finger.x
                UIView.animate(withDuration: 0.1) {
                    self.mainContentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, newPosition, 0, 0)
                    self.mainContentViewHelpher.layer.transform = CATransform3DTranslate(CATransform3DIdentity, newPosition, 0, 0)
                }

            } else {
                if sender.state == .ended {
                    let toHide:CGFloat = wasShowingSideBar ? 200 : 80
                    toggleSideBar(finger.x > toHide ? true : false, animated: true)
                }
            }
        }
        
    }
    
    static var shared: ViewController?
    
    
    @IBOutlet weak var mainContentViewHelpher: UIView!
    @IBOutlet weak var mainContentView: UIView!
    var sideBarShowing = false
    var firstLod = true
    
    @IBAction func addTransactionPressed(_ sender: Any) {
        toAddTransaction()
    }
    @objc func mainContentTap(_ sender: UITapGestureRecognizer) {
        toggleSideBar(false, animated: true)
    }
    
    func toggleSideBar(_ show: Bool, animated:Bool) {
        sideBarShowing = show
        DispatchQueue.main.async {
            let frame = self.sideBar.layer.frame
            UIView.animate(withDuration: animated ? 0.25 : 0) {
                self.mainContentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width : 0, 0, 0)
                self.mainContentViewHelpher.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width : 0, 0, 0)
            } completion: { _ in
                self.sideBar.getData()
                if self.firstLod {
                    self.firstLod = false
                    self.sideBar.isHidden = false
                    self.menuButton.isEnabled = true
                    let gesture = UITapGestureRecognizer(target: self, action: #selector( self.mainContentTap(_:)))

                    if show {
                        self.mainTableView.addGestureRecognizer(gesture)
                    } else {
                        self.mainTableView.removeGestureRecognizer(gesture)
                    }
                    self.mainTableView.reloadData()
                }
            }

        }
    }
    @IBAction func menuPressed(_ sender: UIButton) {
        toggleSideBar(!sideBarShowing, animated: true)
    }
    
    @IBOutlet weak var menuButton: UIButton!
    

    var subviewsLoaded = false
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !subviewsLoaded {
            self.noDataView.isHidden = false
            subviewsLoaded = true
            toggleNoData(show: true, text: "Loading".localize, fromTop: true, appeareAnimation: false, addButtonHidden: true)
            self.unsendedDataLabel.superview?.superview?.isHidden = true
            self.dataFromValueLabel.superview?.superview?.isHidden = true
            self.filterAndCalcFrameHolder.0 = self.filterView.frame
            self.filterAndCalcFrameHolder.1 = self.calculationSView.frame
                        
            let superframe = self.calculationSView.superview?.frame ?? .zero
            let calcFrame = self.calculationSView.frame
            self.calculationSView.frame = CGRect(x: -superframe.height, y: calcFrame.minY, width: calcFrame.width, height: calcFrame.height)

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
            self.filterHelperView.shadow()

            self.filterView.superview?.layer.masksToBounds = true
            self.filterView.superview?.translatesAutoresizingMaskIntoConstraints = true
            self.filterView.translatesAutoresizingMaskIntoConstraints = true
            self.calculationSView.translatesAutoresizingMaskIntoConstraints = true
            let image = UIImage(named: "plusSymbol")
            let button = UIButton(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
            button.layer.masksToBounds = true
            button.tintColor = K.Colors.balanceV
            button.layer.cornerRadius = button.layer.frame.width / 2
            button.setImage(image, for: .normal)
            self.refreshSubview.addSubview(button)
            let superWidth = self.view.frame.width
            self.refreshSubview.frame = CGRect(x: superWidth / 2 - 10, y: 0, width: 20, height: 20)
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            self.refreshSubview.alpha = 0
            self.refreshControl.addSubview(self.refreshSubview)
            self.mainTableView.addSubview(self.refreshControl)
        }
    }
    
    var layaled = false

    
    func updateUI() {
        downloadFromDB()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.enableLocalDataPress = false



        if appData.defaults.value(forKey: "firstLaunch") as? Bool ?? true {
            /*appData.createFirstData {
                self.prepareFilterOptions()
                self.filter()
                UserDefaults.standard.setValue(false, forKey: "firstLaunch")
                DispatchQueue.main.async {
                    self.newMessage.show(title: "Wellcome to Budget Tracker".localize, description: "Demo data has been created".localize, type: .standart)
                
                    
                }
            }*/
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
                appData.expenseLabelPressed = expensesPressed
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toStatisticVC", sender: self)
                }
            }
            
            
        }
        
    }
    
    var firstLoaded = false
    func toggleNoData(show: Bool, text: String = "No Transactions".localize, fromTop: Bool = false, appeareAnimation: Bool = true, addButtonHidden: Bool = false) {
        
        DispatchQueue.main.async {
            
            self.addTransactionWhenEmptyButton.isHidden = addButtonHidden
            if show {
                self.addTransactionWhenEmptyButton.alpha = 1
                let y = fromTop ? self.mainTableView.frame.minY : (self.bigCalcView.frame.maxY + 10)
                self.noDataView.isHidden = false
                self.noDataLabel.text = text
                UIView.animate(withDuration: appeareAnimation ? 0.25 : 0) {
                    self.noDataView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height - y)
                } completion: { (_) in
                    if self.mainTableView.visibleCells.count > 1 {
                        self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                    }
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.noDataView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height / 2)
                } completion: { (_) in
                    self.noDataView.isHidden = true
                    if self.mainTableView.visibleCells.count > 1 {
                        self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                    }
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
        let unsendedCount = appData.unsendedData.count
        let localCount = ((UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String:Any]] ?? []) + (UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String:Any]] ?? [])).count
        let hideUnsended = unsendedCount == 0 ? true : false
        let hideLocal = localCount == 0 ? true : false
        
        DispatchQueue.main.async {
            self.unsendedDataLabel.text = "\(unsendedCount)"
            self.dataFromTitleLabel.text = "Local data".localize + ":"
            self.dataFromValueLabel.text = "\(localCount)"
            if reloadAndAnimate {
                UIView.animate(withDuration: noData ? 0.0 : 0.35) {
                    if self.unsendedDataLabel.superview?.superview?.isHidden != hideUnsended {
                        self.unsendedDataLabel.superview?.superview?.isHidden = hideUnsended
                    }
                    self.enableLocalDataPress = !hideLocal
                    if self.dataFromValueLabel.superview?.superview?.isHidden != hideLocal {
                        self.dataFromValueLabel.superview?.superview?.isHidden = hideLocal
                    }
                } completion: { (_) in
                    if self.mainTableView.visibleCells.count > 1 {
                        self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                    } else {
                        self.mainTableView.reloadData()
                    }
                }
            } else {
                if self.mainTableView.visibleCells.count > 1 {
                    self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                } else {
                    self.mainTableView.reloadData()
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
    
    func filter(data:[TransactionsStruct]? = nil) {
        print("filterCalled")
        //here
        DispatchQueue.main.async {
            self.filterText = "Filtering".localize
        }
        let all = db.transactions
        tableData = all
        prepareFilterOptions(all)
        
        calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
        dataTaskCount = (0,0)
        animateCellWillAppear = true
        appData.filter.selectedPeroud = appData.filter.selectedPeroud != "" ? appData.filter.selectedPeroud : "This Month"
        
        if !appData.filter.showAll {
            allDaysBetween()
        }
        let transactions = (data ?? tableData).sorted{ $0.dateFromString < $1.dateFromString }
        let filtered = dataToDict(transactions)
        newTableData = dictToTable(filtered).sorted{
            Calendar.current.date(from: $0.date ) ?? Date.distantFuture >
                    Calendar.current.date(from: $1.date ) ?? Date.distantFuture
        }
        
    }
    
    
    
    func checkPurchase() {//add completion
            let nick = appData.username
        if nick == "" {
            return
        }
        LoadFromDB.shared.Users { (loadedData, error) in
                if !error {
                    let _ = appData.emailFromLoadedDataPurch(loadedData)
                    var wrongPassword = true
                    for i in 0..<loadedData.count {
                        if loadedData[i][0] == nick {
                            print(loadedData[i], " checkPurchase")
                            if loadedData[i][2] == appData.password {
                                wrongPassword = false
                                appData.trialDate = loadedData[i][5]
                                if !appData.purchasedOnThisDevice && !appData.proVersion {
                                    print("checkPurchase appData.proVersion", appData.proVersion)
                                    if loadedData[i][5] != "" {
                                        self.checkProTrial()
                                    }
                                }
                                break
                            }
                            }
                        }
                    if wrongPassword {
                        self.wrongPassword()
                    }
                }
                
            }
    }
    
    func wrongPassword() {
        self.forceLoggedOutUser = appData.username
        if (AppDelegate.shared?.deviceType ?? .mac) != .primary {
            
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
    
    var forceLoggedOutUser = ""
    var resetPassword = false
    func checkProTrial() {
        let wasStr = appData.trialDate
        let todayStr = appData.filter.getToday()
        let dates = (dateFrom(sting: wasStr), dateFrom(sting: todayStr))
        let dif = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dates.0 ?? Date(), to: dates.1 ?? Date())
        if dif.year == 0 && dif.month == 0 {
            if dif.day ?? 0 <= 7 {
                appData.proTrial = true
                UserDefaults.standard.setValue(dif.day ?? 0, forKey: "trialToExpireDays")
            } else {
                appData.proTrial = false
                UserDefaults.standard.setValue(false, forKey: "checkTrialDate")
                if (UserDefaults.standard.value(forKey: "trialPressed") as? Bool ?? false) {
                    DispatchQueue.main.async {
                        self.newMessage.show(title: "Pro trial is over".localize, type: .standart)
                    }
                }
                
            }
        } else {
            appData.proTrial = false
            UserDefaults.standard.setValue(false, forKey: "checkTrialDate")
            if (UserDefaults.standard.value(forKey: "trialPressed") as? Bool ?? false) {
                DispatchQueue.main.async {
                    self.newMessage.show(title: "Pro trial is over".localize, type: .standart)
                }
            }
            
        }
    }
    
    func dateFrom(sting: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: sting)
        return date
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

    func allDaysBetween() {
        
        if getYearFrom(string: appData.filter.to) == getYearFrom(string: appData.filter.from) {
            let today = appData.filter.getToday()
            let lastDay = "31.\(AppData.makeTwo(n: appData.filter.getMonthFromString(s: today))).\(appData.filter.getYearFromString(s: today))"
            let firstDay = "01.\(AppData.makeTwo(n: appData.filter.getMonthFromString(s: today))).\(appData.filter.getYearFromString(s: today))"
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


    var _filterText: String = "Filter".localize
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
            if newValue != "Filter".localize + ": \(appData.filter.selectedPeroud)" {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
                    if self._filterText == ("Filter".localize + ": \(appData.filter.selectedPeroud)") {
                        timer.invalidate()
                        DispatchQueue.main.async {
                            self.filterTextLabel.text = "Filter".localize + ": \(appData.filter.selectedPeroud)"
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
        AppDelegate.shared?.window?.backgroundColor = K.Colors.primaryBacground
        safeArreaHelperView?.alpha = 1
    }

    var safeArreaHelperViewAdded = false
    
    var safeArreaHelperView: UIView?
    
    let center = AppDelegate.shared?.center
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.notificationsCount = Notifications.notificationsCount
        DispatchQueue.main.async {
            if self.ai.isShowing {
                self.ai.fastHide()
            }
        }
        if appData.needDownloadOnMainAppeare {
            appData.needDownloadOnMainAppeare = false
            self.downloadFromDB(title: "Fetching".localize)
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
    var sendError = false
    //here
    var startedSendingUnsended = false
    var highesLoadedCatID: Int?
    func sendUnsaved() {
        if self.sendError {
            return
        }
        let errorAction = {
            self.sendError = true
            self.startedSendingUnsended = false
            if appData.sendSavedData {
                appData.sendSavedData = false
                //show message error, try again later
                DispatchQueue.main.async {
                    self.newMessage.show(title:"Error sending data".localize, description: "Try again later".localize, type: .error)
                }
            }
            self.filter()
        }
        let unsended = appData.unsendedData
        if unsended.count > 0 {
            if let first = unsended.first {
                startedSendingUnsended = true
                updateDataLabels(reloadAndAnimate: false)
                if self._filterText != "Sending".localize {
                    DispatchQueue.main.async {
                        self.filterText = "Sending".localize
                    }
                }
                
               // let save = SaveToDB()
                let delete = DeleteFromDB()
                        if let addCategory = db.categoryFrom(first["categoryNew"] ?? [:]) {
                            if let highest = highesLoadedCatID {
                                var cat = addCategory
                                let newID = highest + 1
                                cat.id = newID
                                SaveToDB.shared.newCategories(cat, saveLocally: false) { error in
                                    if !error {
                                        appData.unsendedData.removeFirst()
                                        self.highesLoadedCatID! += 1
                                        var newTransactions: [[String:Any]] = []
                                        for i in 0..<unsended.count {
                                            if let trans = self.db.transactionFrom(unsended[i]["transactionNew"]) {
                                                if trans.categoryID == "\(addCategory.id)" {
                                                    var newTransaction = trans
                                                    newTransaction.categoryID = "\(newID)"
                                                    newTransactions.append(self.db.transactionToDict(newTransaction))
                                                    self.deleteUnsendedTransactions(id: "\(addCategory.id)")
                                                }
                                            }
                                        }
                                        
                                        for i in 0..<newTransactions.count {
                                            appData.unsendedData.append(["transactionNew":newTransactions[i]])
                                        }
                                        self.sendUnsaved()
                                    } else {
                                        errorAction()
                                    }
                                }
                            } else {
                              //  let load = LoadFromDB()
                                LoadFromDB.shared.newCategories { loadedCategories, error in
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
                                delete.CategoriesNew(category: deleteCategory, saveLocally: false) { error in
                                    if !error {
                                        appData.unsendedData.removeFirst()
                                        self.sendUnsaved()
                                    } else {
                                        errorAction()
                                    }
                                }
                            } else {
                                if let addTransaction = db.transactionFrom(first["transactionNew"] ?? [:]) {
                                    SaveToDB.shared.newTransaction(addTransaction, saveLocally: false) { error in
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

            }
        } else {
            if startedSendingUnsended {
                startedSendingUnsended = false
                downloadFromDB()
            } else {
                //send local data
                if appData.sendSavedData {
                    //update labels
                    updateDataLabels(reloadAndAnimate: false)
                    if self._filterText != "Sending".localize {
                        DispatchQueue.main.async {
                            self.filterText = "Sending"
                        }
                    }
                    let save = SaveToDB()
                    if let category = db.localCategories.first {
                        if let highest = highesLoadedCatID {
                            var cat = category
                            cat.id = highest + 1
                            save.newCategories(cat) { error in
                                
                                if !error {
                                    self.highesLoadedCatID! += 1
                                    self.db.localCategories.removeFirst()
                                    let localTransactions = self.db.localTransactions
                                    for i in 0..<localTransactions.count {
                                        if localTransactions[i].categoryID == "\(category.id)" {
                                            var newTransaction = localTransactions[i]
                                            newTransaction.categoryID = "\(cat.id)"
                                            self.db.deleteTransaction(transaction: localTransactions[i], local: true)
                                            self.db.localTransactions.append(newTransaction)
                                        }
                                    }
                                    self.sendUnsaved()
                                } else {
                                    errorAction()
                                }
                            }
                        } else {
                        //    let load = LoadFromDB()
                            LoadFromDB.shared.newCategories { loadedCategories, error in
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
                            appData.sendSavedData = false
                            downloadFromDB()
                        }
                    }
                }
            }
            
        }

    }
    
    func deleteUnsendedTransactions(id: String) {
        let all = appData.unsendedData
        var resultt:[[String : [String : Any]]] = []
        for i in 0..<all.count {
            if let transaction = db.transactionFrom(all[i]["transactionNew"]) {
                if transaction.categoryID != id {
                    resultt.append(all[i])
                }
            } else {
                resultt.append(all[i])
            }
        }
        appData.unsendedData = resultt
    }
    var added = false

    
    var allData: [[TransactionsStruct]] = []
    
    func calculateDifference(amount: Int) {
        allData = []
        if appData.filter.to != appData.filter.from {
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
                let new: String = "\(AppData.makeTwo(n: dayA)).\(AppData.makeTwo(n: monthA)).\(AppData.makeTwo(n: yearA))"
                daysBetween.append(new) // was bellow break: last day in month wasnt displeying
                if new == appData.filter.to {
                    break
                }
                
            }
        } else {
            daysBetween.removeAll()
            daysBetween.append(appData.filter.from)
        }
        
    }
    

    @objc func refresh(sender:AnyObject) {
        //add transaction
        //scrolltop (other, similier function) - to ask if user whants to refresh db
        
        forseSendUnsendedData = true
        if appData.username != "" {
            if refreshData {
                if appData.username != "" {
                    self.downloadFromDB(showError: true)
                } else {
                    self.filter()
                }
            } else {
                toAddTransaction()
                
            }
        } else {
            toAddTransaction()
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
        print("today is", appData.filter.getToday())
        AppDelegate.shared?.window?.backgroundColor = .clear
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

    
    
    
//MARK: - Calculation
    

    var totalBalance = 0.0

    

    
//MARK: - Other
    
    var daysBetween = [""]
    var selectedFromDayInt = 0
    var selectedToDayInt = 0
    

    var editingTransaction: TransactionsStruct?
    
    var prevSelectedPer = appData.filter.selectedPeroud
    
    var filteredData:[String: [String]] {
        get {
            return UserDefaults.standard.value(forKey: "filterOptions") as? [String: [String]] ?? [:]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "filterOptions")
        }
    }
    lazy var db:DataBase = {
        return DataBase()
    }()
    func prepareFilterOptions(_ data:[TransactionsStruct]? = nil) {
        let dat = data == nil ? Array(db.transactions) : data!
        let arr = Array(dat.sorted{ $0.dateFromString > $1.dateFromString })
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
        self.sendError = false
        toggleSideBar(false, animated: true)
        print("prepare")
        selectedCell = nil
        DispatchQueue.main.async {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        switch segue.identifier {
        case "toReminders":
       //     let nav = segue.destination as! UINavigationController
            let vc = segue.destination as! RemindersVC
            
        case "toDebts":
            let vc = segue.destination as! CategoriesVC
            vc.fromSettings = true
            vc.screenType = .debts
        case "toCategories", "toLocalData":
            let vc = segue.destination as! CategoriesVC
            vc.screenType = segue.identifier == "toLocalData" ? .localData : .categories
            vc.fromSettings = true
        case "toFiterVC":
            self.mainTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            prevSelectedPer = appData.filter.selectedPeroud
            let vc = segue.destination as? FilterTVC
            vc?.months = filteredData["months"] ?? []
            vc?.years = filteredData["years"] ?? []
            DispatchQueue.main.async {
                let filterFrame = self.filterView.frame//self.filterAndCalcFrameHolder.0
                let superFilter = self.filterView.superview?.frame ?? .zero
                let helperFrame = self.mainContentViewHelpher.frame
                let vcFrame = CGRect(x: filterFrame.minX + superFilter.minX, y: filterFrame.minY + superFilter.minY + helperFrame.height, width: filterFrame.width - 10, height: filterFrame.width)
                vc?.frame = vcFrame
                self.filterHelperView.frame = CGRect(x: filterFrame.minX + superFilter.minX, y: vcFrame.minY, width: vcFrame.width - 10, height: vcFrame.height)
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

        case "toStatisticVC":
            let vc = segue.destination as! StatisticVC
            vc.dataFromMain = tableData
        case "toSingIn":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! LoginViewController
            appData.username = ""
            appData.password = ""
            vc.forceLoggedOutUser = forceLoggedOutUser
            vc.messagesFromOtherScreen = "Your password has been changed".localize
        default: return
        }
 
    }

    
    
    @IBOutlet weak var expencesStack: UIStackView!
    @IBOutlet weak var perioudBalanceView: UIStackView!

    
    
    
    //quite seques
    @IBAction func homeVC(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            print("HomeVC called")

            DispatchQueue.main.async {
                self.dataCountLabel.text = ""
            }
            if needFullReload {
                needFullReload = false
                self.toggleNoData(show: true, text: "Loading".localize, fromTop: true, appeareAnimation: false, addButtonHidden: true)
            }
            self.downloadFromDB()
            
            if appData.fromLoginVCMessage != "" {
                print("appData.fromLoginVCMessage", appData.fromLoginVCMessage)
                DispatchQueue.main.async {
                    self.newMessage.show(title:appData.fromLoginVCMessage, type: .standart)
                    appData.fromLoginVCMessage = ""
                }
            }
        }
    }

    @IBAction func unwindToFilter(segue: UIStoryboardSegue) {
        print("FROM FILTER")
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                self.filterHelperView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.filterTextLabel.alpha = 1
                }
            }
            if self.prevSelectedPer != appData.filter.selectedPeroud {
                self.filter()
                print("unwindToFilter filter: \(appData.filter.selectedPeroud)")
            }
        }
    }

    
    
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 0: appData.expenseLabelPressed = true
        case 1: appData.expenseLabelPressed = false
        default: appData.expenseLabelPressed = true
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.statisticSeque, sender: self)
        }
    }
    
    var refreshData = false


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
        compliteScrolling()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if sideBarShowing {
            toggleSideBar(false, animated: true)
            return
        }
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
        
    }
    

    @objc func savedTransPressed(_ sender: UITapGestureRecognizer) {
        if !appData.sendSavedData {
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toUnsendedVC", sender: self)
            }
        }
    }


    @IBAction func addTransactionPressedd(_ sender: UIButton) {
        toAddTransaction()
    }
    func toAddTransaction() {
        editingTransaction = nil
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
        appData.expenseLabelPressed = false
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toStatisticVC", sender: self)
        }
    }
    @objc func expensesPressed(_ sender: UITapGestureRecognizer) {
        appData.expenseLabelPressed = true
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
            self.performSegue(withIdentifier: "toFiterVC", sender: self)
        }
     //   if self._filterText == "Filter".localize + ": \(appData.filter.selectedPeroud)" {
      /*  } else {
            DispatchQueue.main.async {
                self.openFiler = true
                UIImpactFeedbackGenerator().impactOccurred()
                UIView.animate(withDuration: 0.23) {
                    self.filterTextLabel.alpha = 1
                }
            }
        }*/
    }
    
    
    
    var animateCellWillAppear = true
    var calcViewHeight:CGFloat = 0
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
    }
    var actionAfterAdded:((Bool) -> ())?
}

//MARK: - extension

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
            
        } else {
            return newTableData.count == 0 ? 1 : newTableData[section - 1].transactions.count + 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (newTableData.count == 0 ? 1 : newTableData.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let calculationCell = tableView.dequeueReusableCell(withIdentifier: "calcCell") as? calcCell
            return calculationCell ?? UITableViewCell()
        } else {
            if newTableData.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mainVCemptyCell", for: indexPath) as! mainVCemptyCell
                return cell
            } else {
                if newTableData[indexPath.section - 1].transactions.count == indexPath.row {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "mainFooterCell") as! mainFooterCell
                    cell.totalLabel.text = "\(newTableData[indexPath.section - 1].amount)"
                    
                    cell.separatorInset.left = tableView.frame.width / 2
                    cell.separatorInset.right = tableView.frame.width / 2
                    return cell
                } else {
                    let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
                    transactionsCell.isUserInteractionEnabled = true
                    transactionsCell.contentView.isUserInteractionEnabled = true
                    let data = newTableData[indexPath.section - 1].transactions[indexPath.row]
                    transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell, indexPath: indexPath)
                    return transactionsCell
                }
            }
            
            
        }

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 && newTableData.count != 0 {
            if newTableData[indexPath.section-1].transactions.count != indexPath.row {
                self.editingTransaction = self.newTableData[indexPath.section - 1].transactions[indexPath.row]
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToEditVC", sender: self)
                }
            }
            
        }
    }

    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != 0 && newTableData.count != 0 {
            return "\(newTableData[section - 1].date)"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if newTableData.count == 0 || section == 0 {
            return UIView.init(frame: .zero)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainHeaderCell") as! mainHeaderCell
            
            cell.dateLabel.textColor = K.Colors.link
            let date = newTableData[section - 1].date
            cell.dateLabel.text = "\(AppData.makeTwo(n: date.day ?? 0))"
            cell.monthLabel.text =  date.stringMonth
            cell.yearLabel.text = "\(date.year ?? 0)"
            let v = cell.contentView
            cell.mainView.layer.cornerRadius = 15
            let newViewFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: v.frame.height)//cell.mainView?.frame.width + 6
            v.frame = .init(x: 0, y: 0, width: newViewFrame.width, height: v.frame.height)
            let newView = UIView(frame: newViewFrame)
            let helperTopView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: newViewFrame.height / 2))
            helperTopView.backgroundColor = K.Colors.primaryBacground
            newView.addSubview(helperTopView)
            newView.addSubview(v)
            return newView
        }
        

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 || newTableData.count != 0 {
            return 60 - 15
        } else {
            return 0
        }
    }
    

    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.contentOffset.y > 20 {
            if indexPath.section == 0 {
                DispatchQueue.main.async {
                    self.mainTableView.backgroundColor = K.Colors.primaryBacground
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
        let bigFr = bigCalcView.layer.frame.height
        if indexPath.section == 0 && indexPath.row == 0 {
            return bigFr - 55
        } else {
            if newTableData.count == 0 && indexPath.section == 1{
                
                return tableView.layer.frame.height - (bigFr + 30)
            } else {
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if transactionAdded {
            transactionAdded = false
            filter()
        }
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: self.animateCellWillAppear ? 0.3 : 0) {
                    self.mainTableView.backgroundColor = .clear
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
    func deletePressed() {
        if let editing = editingTransaction {
            editingTransaction = nil
            selectedCell = nil
            let delete = DeleteFromDB()
            delete.newTransaction(editing) { _ in
                self.filter()
            }
        } else {
            DispatchQueue.main.async {
                self.newMessage.show(title:"Error deleting transaction".localize, description: "Try again".localize, type: .error)
            }
        }
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct, reminderTime:DateComponents?, repeated:Bool?, idx:Int?) {
        let delete = DeleteFromDB()
        delete.newTransaction(was) { _ in
           // let save = SaveToDB()
            SaveToDB.shared.newTransaction(transaction) { _ in
                self.editingTransaction = nil
                self.filter()
            }
        }
    }
    
    
    private func addNewTransaction(_ new:TransactionsStruct) {
        self.newTransaction = new
        editingTransaction = nil
        self.animateCellWillAppear = false
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.animateCellWillAppear = true
        }

        if new.value != "" && new.date != "" {
            DispatchQueue.main.async {
                self.filterText = "Adding".localize
            }
            //let save = SaveToDB()
            SaveToDB.shared.newTransaction(TransactionsStruct(value: new.value, categoryID: "\(new.category.id)", date: new.date, comment: new.comment)) { error in
                self.filter()
                self.editingTransaction = nil
                if !error {
                    self.forseSendUnsendedData = true
                    self.sendUnsaved()
                }
            }

        } else {
            print("reloaddd")
            self.editingTransaction = nil
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
               // self.calculateLabels()
            }
        }
    }
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime:DateComponents?, repeated:Bool?) {
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        addNewTransaction(new)
    }

    
    func quiteTransactionVC(reload:Bool){
        self.editingTransaction = nil
        if reload {
            print("trloaddd")
            filter()
        }
        print("quite trans")
    }
    
    
}



extension ViewController {
    enum ViewControllerType {
        case home
        case paymentReminders
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.cornerView.layer.cornerRadius = 15
        self.cornerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}


class mainVCemptyCell: UITableViewCell {
    
    @IBOutlet weak var mainBackgroundView: UIView!
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        mainBackgroundView.layer.cornerRadius = 9//ViewController.shared?.tableCorners ?? 9
    }
}
