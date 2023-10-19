//
//  ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import Combine
class ViewController: SuperViewController {
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
    @IBOutlet weak var mainTableView: UITableView!
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
    let center = AppDelegate.shared?.center
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
    let tableActionActivityIndicator = UIActivityIndicatorView.init(style: .gray)
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
        transactionManager = .init()
        transactionManager?.taskChanged = {
            self.dataTaskCount = $0
        }
        updateUI()
        
        pinchView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sideBarPinched(_:))))
        self.sideBarContentBlockerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sideBarPinched(_:))))
        ViewController.shared = self
        sideBar.load()
        toggleSideBar(false, animated: false)
        
        self.mainTableView.contentInset.bottom = AppDelegate.shared?.banner.size ?? 0
      //  AppDelegate.shared?.banner.bannerSizePublisher.subscribe(Subscribers.Assign(object: mainTableView, keyPath: \.contentInset.bottom))
        AppDelegate.shared?.banner.valuePublisher.sink(receiveValue: {
            self.mainTableView.contentInset.bottom = $0
        }).store(in: &cancellableHolder)
    }

    var cancellableHolder = Set<AnyCancellable>()
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
        AppDelegate.shared?.banner.setBackground(clear: false)
    }
    
    func monthSelected(_ year:Int, _ month:Int) {
        lastSelectedDate = nil
        DispatchQueue.init(label: "local", qos: .userInitiated).async {
            AppDelegate.shared?.appData.filter.showAll = false
            AppDelegate.shared?.appData.filter.from = "\(1.makeTwo()).\(month.makeTwo()).\(year)"
            AppDelegate.shared?.appData.filter.to = "\(31.makeTwo()).\(month.makeTwo()).\(year)"
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
        self.toAddTransaction(pressedView: calendarContainer, isCalendar: true)

    }
    func dateSelectedCell(_ newDate:DateComponents, _ cell:CalendarCell) {
    /*    self.vibrate()
        self.calendarSelectedDate = newDate.toShortString()
        self.toAddTransaction(pressedView: calendarContainer, canDivid: true, isCalendar: true)*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("today is", AppDelegate.shared?.appData.filter.getToday())
        AppDelegate.shared?.window?.backgroundColor = .clear
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        navigationController?.delegate = nil

    }
    
    var transactionManager:TransactionsManager?
    
    var apiTransactions:[TransactionsStruct] = []
    func filter(data:[TransactionsStruct]? = nil) {
        completedFiltering = false
        print("filterCalled")
        let showAll = AppDelegate.shared?.appData.filter.showAll ?? false
        let all = transactionManager?.filtered(apiTransactions) ?? []
        self.filterText = (showAll ? "All transactions".localize : (AppDelegate.shared?.appData.filter.periodText ?? ""))
        tableData = all
        prepareFilterOptions(all)
        
        calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
        dataTaskCount = (0,0)
        animateCellWillAppear = true
        let selectedPeriud = AppDelegate.shared?.appData.filter.selectedPeroud ?? ""
        AppDelegate.shared?.appData.filter.selectedPeroud = selectedPeriud != "" ? selectedPeriud : "This Month"
        
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
    @objc func refresh(sender:AnyObject) {
        //add transaction
        //scrolltop (other, similier function) - to ask if user whants to refresh db
        forseSendUnsendedData = true
        if AppDelegate.shared?.appData.username != "" {
            if refreshData {
                if AppDelegate.shared?.appData.username != "" {
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

    @IBAction func homeVC(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInteractive).async {
            print("HomeVC called")
            DispatchQueue.main.async {
                self.dataCountLabel.text = ""
            }
            if (AppDelegate.shared?.appData.needFullReload ?? false) {
                AppDelegate.shared?.appData.needFullReload = false
                self.toggleNoData(show: true, text: "Loading".localize, fromTop: true, appeareAnimation: false, addButtonHidden: true)
            }
            self.downloadFromDB()
            
            if AppDelegate.shared?.appData.fromLoginVCMessage != "" {
                print("appData.fromLoginVCMessage", AppDelegate.shared?.appData.fromLoginVCMessage ?? "-")
                DispatchQueue.main.async {
                    self.newMessage.show(title:AppDelegate.shared?.appData.fromLoginVCMessage ?? "", type: .standart)
                    AppDelegate.shared?.appData.fromLoginVCMessage = ""
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
            if self.prevSelectedPer != AppDelegate.shared?.appData.filter.selectedPeroud {
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
        
        DispatchQueue.main.async {
            var expenses = true
            switch sender.tag {
            case 0: expenses = true
            case 1: expenses = false
            default: expenses = true
            }
            self.toStatistic(thisMonth: true, isExpenses: expenses)
        }
        
    }

    @objc func savedTransPressed(_ sender: UITapGestureRecognizer) {
        if !(AppDelegate.shared?.appData.sendSavedData ?? true) {
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

