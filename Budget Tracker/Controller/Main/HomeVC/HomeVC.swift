//
//  ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import Combine
class HomeVC: SuperViewController {
    typealias TransitionComponents = (albumCoverImageView: UIImageView?, albumNameLabel: UILabel?)
    public var transitionComponents = TransitionComponents(albumCoverImageView: nil, albumNameLabel: nil)
    let transitionAppearenceManager = AnimatedTransitioningManager(duration: 0.267)
    
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
    @IBOutlet weak var mainTableView: RefreshTableView!
    @IBOutlet weak var addTransitionButton: UIButton!
    
    @IBOutlet weak var darkBackgroundUnderTable: UIView!
    @IBOutlet var ecpensesLabels: [UILabel]!
    @IBOutlet var incomeLabels: [UILabel]!
    @IBOutlet var balanceLabels: [UILabel]!
    @IBOutlet var perioudBalanceLabels: [UILabel]!
    @IBOutlet weak var bigCalcView: UIView!
    @IBOutlet weak var notificationsView: BasicView!
    @IBOutlet weak var notificationsLabel: UILabel!
    
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var mainContentViewHelpher: UIView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var bigExpensesStack: UIStackView!
    
    @IBOutlet weak var sideBarContentBlockerView: UIView!
    static var shared: HomeVC?
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
    var forseSendUnsendedData = true
    var addTransFrame = CGRect.zero
    var enableLocalDataPress = false
    var undendedCount = 0
    var filterAndCalcFrameHolder = (CGRect.zero, CGRect.zero)
    var wasSendingUnsended = false
    var correctFrameBackground:CGRect = .zero
    var tableData:[TransactionsStruct] = []
    var _TableData: [tableStuct] = []
    var completedFiltering = false
    let tableCorners:CGFloat = 15
    var actionAfterAdded:((Bool) -> ())?
    var firstAppearence = true
    var _calculations:Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
    var forceLoggedOutUser = ""
    var resetPassword = false
    var _filterText: String = "Filter".localize
    var timers: [Timer] = []
    var safeArreaHelperViewAdded = false
    var safeArreaHelperView: UIView?
    let center = AppDelegate.shared?.properties?.center
    var sendError = false
    var startedSendingUnsended = false
    var highesLoadedCatID: Int?
    var added = false
    var allData: [[TransactionsStruct]] = []
    var calendar:CalendarControlVC?
    var unsavedTransactionsCount = 0
    var selectedCell: IndexPath? = nil
    var animateCellWillAppear = true
    var calcViewHeight:CGFloat = 0
    var refreshData = false
    var lastWhiteBackheight = 0
    var openFiler = false
    var apiLoading = true
    var newTableData: [tableStuct] {
        get { return _TableData }
        set {
            _TableData = newValue
            tableDataLoaded(newValue)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.refreshBackgroundColor = self.view.backgroundColor
        mainTableView.refreshAction = refresh
        transactionManager = .init()
        transactionManager?.taskChanged = {
            self.dataTaskCount = $0
        }
        updateUI()
        
        pinchView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sideBarPinched(_:))))
        self.sideBarContentBlockerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sideBarPinched(_:))))
        HomeVC.shared = self
        sideBar.load()
        toggleSideBar(false, animated: false)
        
        self.mainTableView.contentInset.bottom = AppDelegate.shared?.properties?.banner.size ?? 0
        if #available(iOS 13.0, *) {
            BannerPublisher.valuePublisher.sink(receiveValue: {
                self.bannerUpdated($0)
            }).store(in: &BannerPublisher.cancellableHolder)
        }
        
    }
    
    
    func bannerUpdated(_ value:CGFloat) {
        self.mainTableView.contentInset.bottom = value
    }
    
    var calendarSelectedDate:String?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sbvsLoaded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.keyWindow?.backgroundColor = K.Colors.primaryBacground
        
        super.viewWillDisappear(animated)
        
    }
    
    var vcAppeared = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        viewAppeared()
        AppDelegate.shared?.properties?.banner.setBackground(clear: false)
        if !vcAppeared {
            vcAppeared = true
        } else if AppDelegate.shared?.properties?.banner.adHidden ?? false {
            AppDelegate.shared?.properties?.banner.appeare(force: true)
        }
        
      //  ai?.showAlertWithOK(title: "d")
    }
    
    func monthSelected(_ year:Int, _ month:Int) {
        lastSelectedDate = nil
        DispatchQueue.init(label: "local", qos: .userInitiated).async {
            AppDelegate.shared?.properties?.appData.db.filter.showAll = false
            AppDelegate.shared?.properties?.appData.db.filter.from = "\(1.twoDec).\(month.twoDec).\(year)"
            var lastDay = DateComponents()
            lastDay.year = year
            lastDay.month = month
            print(lastDay.lastDayOfMonth, " trgerfwd")
            AppDelegate.shared?.properties?.appData.db.filter.to = "\((lastDay.lastDayOfMonth ?? 31).twoDec).\(month.twoDec).\(year)"
            if !self.completedFiltering {
                self.transactionManager?.filterChanged = true
            }
            self.filter()
        }
    }
    
    //todo:
    //return UICollectionViewCell
    func dateSelected(_ newDate:DateComponents) {
        self.vibrate()
        self.calendarSelectedDate = newDate.toShortString()
        self.toAddTransaction(pressedView: calendarContainer, isCalendar: false)
        
    }
    func dateSelectedCell(_ newDate:DateComponents, _ cell:CalendarCell) {
        /*    self.vibrate()
         self.calendarSelectedDate = newDate.toShortString()
         self.toAddTransaction(pressedView: calendarContainer, canDivid: true, isCalendar: true)*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("today is", AppDelegate.shared?.properties?.appData.db.filter.getToday())
        UIApplication.shared.keyWindow?.backgroundColor = .clear
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        navigationController?.delegate = nil
        
    }
    
    var transactionManager:TransactionsManager?
    
    var apiTransactions:[TransactionsStruct] = []
    func filter(data:[TransactionsStruct]? = nil) {
        completedFiltering = false
        print("filterCalled")
        let showAll = false//AppDelegate.shared?.properties?.appData.db.filter.showAll ?? false
        print(AppDelegate.shared?.properties?.appData.db.filter.from, " tyhregrfwed")
        print(AppDelegate.shared?.properties?.appData.db.filter.to, " tgerfwd")
        let all = transactionManager?.filtered(apiTransactions) ?? []
        self.filterText = (showAll ? "All transactions".localize : (AppDelegate.shared?.properties?.appData.db.filter.periodText ?? ""))
        tableData = all
        prepareFilterOptions(apiTransactions)
        
        calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
        dataTaskCount = (0,0)
        animateCellWillAppear = true
        let selectedPeriud = AppDelegate.shared?.properties?.appData.db.filter.selectedPeroud ?? ""
        let selectedPer = selectedPeriud != "" ? selectedPeriud : "This Month"
        if AppDelegate.shared?.properties?.appData.db.filter.selectedPeroud != selectedPer {
            AppDelegate.shared?.properties?.appData.db.filter.selectedPeroud = selectedPer
        }
        
        if !showAll {
            allDaysBetween()
        }
        newTableData = transactionManager?.new(transactions: all) ?? []
        self.calculations = transactionManager!.calculation!
        self.monthTransactions.removeAll()
        newTableData.forEach {
            $0.transactions.forEach {
                self.monthTransactions.append($0)
            }
            
        }
    }
    
    var dbTotal:Int = 0
    func refresh() {
        //add transaction
        //scrolltop (other, similier function) - to ask if user whants to refresh db
        forseSendUnsendedData = true
        if AppDelegate.shared?.properties?.appData.db.username != "" {
            if refreshData {
                if AppDelegate.shared?.properties?.appData.db.username != "" {
                    self.downloadFromDB(showError: true)
                } else {
                    mainTableView.refresh?.endRefreshing()
                    self.filter()
                }
            } else {
                mainTableView.refresh?.endRefreshing()
                toAddTransaction()
                
                
                
            }
        } else {
            mainTableView.refresh?.endRefreshing()
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
    var selectedFromDayInt = 0
    var selectedToDayInt = 0
    var editingTransaction: TransactionsStruct?
    var prevSelectedPer:String?
    
    
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
    
    
    func checkDownload(force:Bool = false) {
        if (AppDelegate.shared?.properties?.appData.needFullReload ?? false) {
            AppDelegate.shared?.properties?.appData.needFullReload = false
            self.toggleNoData(show: true, text: "Loading".localize, fromTop: true, appeareAnimation: false, addButtonHidden: true)
            if !force {
                self.downloadFromDB()
            }
        }
        if force {
            
            
            self.downloadFromDB()
        }
    }
    
    @IBAction func homeVC(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            print("HomeVC called")
            DispatchQueue.main.async {
                self.dataCountLabel.text = ""
            }
            self.checkDownload(force: true)
            
            if AppDelegate.shared?.properties?.appData.fromLoginVCMessage != "" {
                print("appData.fromLoginVCMessage", AppDelegate.shared?.properties?.appData.fromLoginVCMessage ?? "-")
                DispatchQueue.main.async {
                    self.newMessage?.show(title:AppDelegate.shared?.properties?.appData.fromLoginVCMessage ?? "", type: .standart)
                    AppDelegate.shared?.properties?.appData.fromLoginVCMessage = ""
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
            if self.prevSelectedPer != AppDelegate.shared?.properties?.appData.db.filter.selectedPeroud {
                self.filter()
            }
        }
    }
    
    
    @objc func monthBalancePressed(_ sender:UITapGestureRecognizer) {
        currentStatistic = true
        if canTouchHandleTap {
            toStatistic(thisMonth: true, isExpenses: true)
        }
    }
    
    func toStatistic(thisMonth:Bool, isExpenses:Bool) {
        let vc = StatisticVC.configure(data: currentStatistic ? monthTransactions : apiTransactions)
        vc.expensesPressed = true
        print(currentStatistic, " currentStatisticcurrentStatistic")
        vc.isAll = !currentStatistic
        vc.fromsideBar = self.fromSideBar
        
        currentStatistic = false
        self.fromSideBar = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func toCategories(type:CategoriesVC.ScreenType = .categories, fromSettings:Bool? = nil) {
        let vc = CategoriesVC.configure(type: type)
        vc.fromSettings = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    var currentStatistic = false
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        currentStatistic = true
        
        var expenses = true
        switch sender.tag {
        case 0: expenses = true
        case 1: expenses = false
        default: expenses = true
        }
        self.toStatistic(thisMonth: true, isExpenses: expenses)
        
    }
    
    @objc func savedTransPressed(_ sender: UITapGestureRecognizer) {
        if !(AppDelegate.shared?.properties?.appData.sendSavedData ?? true) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toUnsendedVC", sender: self)
            }
        }
    }
    
    @IBAction func addTransactionPressedd(_ sender: UIButton) {
        toAddTransaction()
    }
    
    @objc func addTransButtonPressed(_ sender: UIButton) {
        toAddTransaction(editing: false, pressedView: sender, isCalendar: false)
    }
    
    @objc func incomePressed(_ sender: UITapGestureRecognizer) {
        toStatistic(thisMonth: true, isExpenses: false)
    }
    @objc func expensesPressed(_ sender: UITapGestureRecognizer) {
        toStatistic(thisMonth: true, isExpenses: true)
    }
    
    @IBAction func filterPressed(_ sender: UIButton) {
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
    }
    
}

