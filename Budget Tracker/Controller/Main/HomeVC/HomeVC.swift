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
    @IBOutlet weak var sideTableView: RefreshTableView!
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
    @IBOutlet weak var expencesStack: UIStackView!
    @IBOutlet weak var perioudBalanceView: UIStackView!
    @IBOutlet weak var sideBarContentBlockerView: UIView!
    static var shared: HomeVC? {
        let nav = UIApplication.shared.sceneKeyWindow?.rootViewController as? UINavigationController
        return nav?.viewControllers.first(where: {$0 is HomeVC}) as? HomeVC
    }
    var safeArreaHelperView: UIView?
    var transactionManager:TransactionsManager?
    var viewModel:ViewModelHomeVC = .init()
    let center = AppDelegate.properties?.center

    var newTableData: [tableStuct] = [] {
        didSet {
            tableDataLoaded(newTableData)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Thread.isMainThread {
            fatalError()
        }
        updateUI()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sbvsLoaded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.sceneKeyWindow?.backgroundColor = K.Colors.primaryBacground
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        viewAppeared()
        AppDelegate.properties?.banner.setBackground(clear: false)
        if !viewModel.vcAppeared {
            viewModel.vcAppeared = true
        } else if AppDelegate.properties?.banner.adHidden ?? false {
            AppDelegate.properties?.banner.appeare(force: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.sceneKeyWindow?.backgroundColor = .clear
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        navigationController?.delegate = nil
    }
    
    
    func bannerUpdated(_ value:CGFloat) {
        self.additionalSafeAreaInsets.bottom = value
       // self.mainTableView.contentInset.bottom = value
    }
    
    func monthSelected(_ year:Int, _ month:Int) {
        DispatchQueue.init(label: "local", qos: .userInitiated).async {
            self.db.transactionDate = nil
            AppDelegate.properties?.db.filter.showAll = false
            AppDelegate.properties?.db.filter.from = "\(1.twoDec).\(month.twoDec).\(year)"
            var lastDay = DateComponents()
            lastDay.year = year
            lastDay.month = month
            AppDelegate.properties?.db.filter.to = "\((lastDay.lastDayOfMonth ?? 31).twoDec).\(month.twoDec).\(year)"
            if !self.viewModel.completedFiltering {
                self.transactionManager?.filterChanged = true
            }
            self.filter()
        }
    }
    

    func dateSelected(_ newDate:DateComponents) {
        self.vibrate()
        self.viewModel.calendarSelectedDate = newDate.toShortString()
        self.toAddTransaction(pressedView: calendarContainer, isCalendar: false)
    }
    
    func dateSelectedCell(_ newDate:DateComponents, _ cell:CalendarCell) {
        /*    self.vibrate()
         self.calendarSelectedDate = newDate.toShortString()
         self.toAddTransaction(pressedView: calendarContainer, canDivid: true, isCalendar: true)*/
    }
    
    func filter(data:[TransactionsStruct]? = nil) {
        viewModel.completedFiltering = false
        let all = transactionManager?.filtered(viewModel.apiTransactions) ?? []
        self.filterText = AppDelegate.properties?.db.filter.periodText ?? ""
        viewModel.tableData = all
        prepareFilterOptions(viewModel.apiTransactions)
        
        calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
        dataTaskCount = (0,0)
        viewModel.animateCellWillAppear = true
        let selectedPeriud = AppDelegate.properties?.db.filter.selectedPeroud ?? ""
        let selectedPer = selectedPeriud != "" ? selectedPeriud : "This Month"
        if AppDelegate.properties?.db.filter.selectedPeroud != selectedPer {
            AppDelegate.properties?.db.filter.selectedPeroud = selectedPer
        }
        
        allDaysBetween()
        newTableData = transactionManager?.new(transactions: all) ?? []
        self.calculations = transactionManager!.calculation!
        viewModel.monthTransactions.removeAll()
        newTableData.forEach {
            $0.transactions.forEach {
                viewModel.monthTransactions.append($0)
            }
            
        }
    }
    
    func refresh() {
        viewModel.forseSendUnsendedData = true
        if AppDelegate.properties?.db.username != "" {
            if viewModel.refreshData {
                if AppDelegate.properties?.db.username != "" {
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
        viewModel.selectedCell = nil
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
            toggleSideBar(false, animated: true)
    }
    
    @IBAction func menuPressed(_ sender: UIButton) {
        toggleSideBar(!viewModel.sideBarShowing, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewModel.sideBarShowing {
            self.scrollHead(scrollView)
            return
        }
        self.scrollRefresh(scrollView)
        self.scrollHead(scrollView)
    }
    
    //MARK: - Other
    func checkDownload(force:Bool = false) {
        if (AppDelegate.properties?.appData.needFullReload ?? false) {
            AppDelegate.properties?.appData.needFullReload = false
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
     //   DispatchQueue.global(qos: .userInteractive).async {
            print("HomeVC called")
        //    DispatchQueue.main.async {
                self.dataCountLabel.text = ""
       //     }
            self.checkDownload(force: true)
            if AppDelegate.properties?.appData.fromLoginVCMessage != "" {
                print("appData.fromLoginVCMessage", AppDelegate.properties?.appData.fromLoginVCMessage ?? "-")
                DispatchQueue.main.async {
                    self.newMessage?.show(title:AppDelegate.properties?.appData.fromLoginVCMessage ?? "", type: .standart)
                    AppDelegate.properties?.appData.fromLoginVCMessage = ""
                    if self.viewModel.sideBarShowing {
                        self.toggleSideBar(false, animated: true)
                    }
                }
            }
     //   }
    }
    
    @IBAction func unwindToFilter(segue: UIStoryboardSegue) {
        print("FROM FILTER")
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.filterTextLabel.alpha = 1
                }
            }
            if self.viewModel.prevSelectedPer != AppDelegate.properties?.db.filter.selectedPeroud {
                self.filter()
            }
        }
    }
    
    
    @objc func monthBalancePressed(_ sender:UITapGestureRecognizer) {
        viewModel.currentStatistic = true
        if viewModel.canTouchHandleTap {
            toStatistic(thisMonth: true, isExpenses: true)
        }
    }
    
    func toStatistic(thisMonth:Bool, isExpenses:Bool) {
        let vc = StatisticVC.configure(data: viewModel.currentStatistic ? viewModel.monthTransactions : viewModel.apiTransactions)
        vc.expensesPressed = true
        vc.isAll = !viewModel.currentStatistic
        vc.fromsideBar = viewModel.fromSideBar
        viewModel.currentStatistic = false
        viewModel.fromSideBar = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func toCategories(type:CategoriesVC.ScreenType = .categories, fromSettings:Bool? = nil) {
        let vc = CategoriesVC.configure(type: type)
        vc.fromSettings = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        viewModel.currentStatistic = true
        var expenses = true
        switch sender.tag {
        case 0: expenses = true
        case 1: expenses = false
        default: expenses = true
        }
        self.toStatistic(thisMonth: true, isExpenses: expenses)
        
    }
    
    @objc func savedTransPressed(_ sender: UITapGestureRecognizer) {
        if !(AppDelegate.properties?.appData.sendSavedData ?? true) {
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

extension HomeVC {
    static func configure() -> UIViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationController")
    }
}
