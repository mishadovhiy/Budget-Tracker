//
//  ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

let appData = AppData()

class ViewController: SuperViewController {
    var touchingFromShow = false

    @IBOutlet weak var balanceHelperView: UIView!
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
    
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var mainContentViewHelpher: UIView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var bigExpensesStack: UIStackView!
    
    @IBOutlet weak var sideBarContentBlockerView: UIView!
    static var shared: ViewController?
    var fromSideBar = false
    var _notificationsCount = (0,0)
    var sidescrolling = false
    var wasShowingSideBar = false
    var beginScrollPosition:CGFloat = 0
    
    var sideBarShowing = false
    var firstLod = true
    var subviewsLoaded = false
    var canTouchHandleTap = true
    var firstLoaded = false
    var justLoaded = true
    var newTransaction: TransactionsStruct?
    var highliteCell: IndexPath?
    var tableDHolder: [tableStuct] = []
    let tableCorners: CGFloat = 22
    var forseSendUnsendedData = true
    var addTransFrame = CGRect.zero
    var enableLocalDataPress = false
    var undendedCount = 0
    var filterAndCalcFrameHolder = (CGRect.zero, CGRect.zero)
    var wasSendingUnsended = false
    var refreshSubview = UIView.init(frame: .zero)
    var correctFrameBackground:CGRect = .zero
    var refreshControl = UIRefreshControl()
    var tableData:[TransactionsStruct] = []
    var _TableData: [tableStuct] = []
    var completedFiltering = false
    
    var actionAfterAdded:((Bool) -> ())?
    var firstAppearence = true
    var _calculations:Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
    var forceLoggedOutUser = ""
    var resetPassword = false
    var _filterText: String = "Filter".localize
    var timers: [Timer] = []
    var safeArreaHelperViewAdded = false
    var safeArreaHelperView: UIView?
    let center = AppDelegate.shared?.center
    var sendError = false
    var startedSendingUnsended = false
    var highesLoadedCatID: Int?
    var added = false
    var allData: [[TransactionsStruct]] = []
    
    var unsavedTransactionsCount = 0
    var selectedCell: IndexPath? = nil
    var animateCellWillAppear = true
    var calcViewHeight:CGFloat = 0
    let tableActionActivityIndicator = UIActivityIndicatorView.init(style: .gray)
    var refreshData = false
    var lastWhiteBackheight = 0
    var openFiler = false
    var apiLoading = true
    var filterChanged = false
    var newTableData: [tableStuct] {
        get { return _TableData }
        set {
            _TableData = newValue
            tableDataLoaded(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        pinchView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sideBarPinched(_:))))
        self.sideBarContentBlockerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sideBarPinched(_:))))
        ViewController.shared = self
        sideBar.load()
        toggleSideBar(false, animated: false)
    }

    var calendarSelectedDate:String?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sbvsLoaded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.shared?.window?.backgroundColor = K.Colors.primaryBacground
        
        super.viewWillDisappear(animated)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        viewAppeared()
        
        if let v = CalendarControlVC.shared {
            v.monthChanged = { year, month in
                lastSelectedDate = nil
                DispatchQueue.init(label: "local", qos: .userInitiated).async {
                    appData.filter.showAll = false
                    appData.filter.from = "\(appData.filter.makeTwo(n: 1)).\(appData.filter.makeTwo(n: month)).\(year)"
                    appData.filter.to = "\(appData.filter.makeTwo(n: 31)).\(appData.filter.makeTwo(n: month)).\(year)"
                    if !self.completedFiltering {
                        self.filterChanged = true
                    }
                    self.filter()
                }
            }
            v.dateSelected = { newDate in
                self.vibrate()
                self.calendarSelectedDate = newDate.toShortString()
                self.toAddTransaction()
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("today is", appData.filter.getToday())
        AppDelegate.shared?.window?.backgroundColor = .clear
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        
    }
    
    func filtered(_ data:[TransactionsStruct]) -> [TransactionsStruct] {
        let tod = appData.filter.fromDate
        return data.filter { transaction in
            return (transaction.date.stringToCompIso().year ?? 1) == (tod.year ?? 0)
        }
    }
    var apiTransactions:[TransactionsStruct] = []
    func filter(data:[TransactionsStruct]? = nil) {
        print(Thread.isMainThread, " nhrtgerfwdqwsadsvfdghr")
        completedFiltering = false
        print("filterCalled")
        let showAll = appData.filter.showAll
        let tod = appData.filter.fromDate
//        let filterPeriod = (tod.month?.stringMonth ?? "-").capitalized + ", \(tod.year ?? 0)"
        let all = self.filtered(apiTransactions)
     //   DispatchQueue.main.async {
            //self.filterText = "Filtering".localize
            
            self.filterText = (showAll ? "All transactions".localize : appData.filter.periodText)
   //     }
        

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
        self.monthTransactions.removeAll()
        newTableData.forEach { tr in
            tr.transactions.forEach { transaction in
                self.monthTransactions.append(transaction)
            }
            
        }
    }

    var dbTotal:Int = 0
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

    func deleteFromDB(at: IndexPath) {
        selectedCell = nil
        let delete = DeleteFromDB()
        delete.newTransaction(newTableData[at.section].transactions[at.row]) { _ in
            self.filter()
        }
    }

    @objc func sideBarPinched(_ sender: UIPanGestureRecognizer) {
        sideBarPinch(sender)
    }

    
    @IBAction func addTransactionPressed(_ sender: Any) {
        toAddTransaction()
    }
    
    @objc func mainContentTap(_ sender: UITapGestureRecognizer) {
    //    toggleSideBar(false, animated: true)
    }
    
    @IBAction func menuPressed(_ sender: UIButton) {
        toggleSideBar(!sideBarShowing, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        compliteScrolling()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if sideBarShowing {
          //  toggleSideBar(false, animated: true)
            self.scrollHead(scrollView)
            return
        }
        self.scrollRefresh(scrollView)
        self.scrollHead(scrollView)
    }
    
//MARK: - Other
    
    var monthTransactions:[TransactionsStruct] = []
    var totalBalance = 0.0
    var daysBetween = [""]
    var selectedFromDayInt = 0
    var selectedToDayInt = 0
    var editingTransaction: TransactionsStruct?
    var prevSelectedPer = appData.filter.selectedPeroud

    
    var filterHelperView = UIView(frame: .zero)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UIView.animate(withDuration: 0.19) {
           // self.safeArreaHelperView?.alpha = 1
            self.safeArreaHelperView?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
        }
        self.prepareSegue(for: segue, sender: sender)
 
    }

    @IBOutlet weak var expencesStack: UIStackView!
    @IBOutlet weak var perioudBalanceView: UIStackView!

    @IBAction func homeVC(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            print("HomeVC called")
            DispatchQueue.main.async {
                self.dataCountLabel.text = ""
            }
            if appData.needFullReload {
                appData.needFullReload = false
                self.toggleNoData(show: true, text: "Loading".localize, fromTop: true, appeareAnimation: false, addButtonHidden: true)
            }
            self.downloadFromDB()
            
            if appData.fromLoginVCMessage != "" {
                print("appData.fromLoginVCMessage", appData.fromLoginVCMessage)
                DispatchQueue.main.async {
                    self.newMessage.show(title:appData.fromLoginVCMessage, type: .standart)
                    appData.fromLoginVCMessage = ""
                    if self.sideBarShowing {
                        self.toggleSideBar(false, animated: true)
                    }
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


    @objc func monthBalancePressed(_ sender:UITapGestureRecognizer) {
        currentStatistic = true
        if canTouchHandleTap {
            self.performSegue(withIdentifier: K.statisticSeque, sender: self)
        }
    }
    
    var currentStatistic = false
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        currentStatistic = true
        switch sender.tag {
        case 0: appData.expenseLabelPressed = true
        case 1: appData.expenseLabelPressed = false
        default: appData.expenseLabelPressed = true
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.statisticSeque, sender: self)
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
    
    @objc func addTransButtonPressed(_ sender: UIButton) {
        print("addtrans")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToEditVC", sender: self)
        }
    }
    
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
    
    @IBAction func filterPressed(_ sender: UIButton) {
      /*  DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.filterTextLabel.alpha = 0.2
            }
            self.performSegue(withIdentifier: "toFiterVC", sender: self)
        }*/
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
    }
    
}

