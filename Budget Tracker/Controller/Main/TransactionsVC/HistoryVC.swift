//
//  HistoryVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.03.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMobileAds


var transactionAdded = false

class HistoryVC: SuperViewController {
    typealias TransitionComponents = (albumCoverImageView: UIImageView?, albumNameLabel: UILabel?)
    public var transitionComponents = TransitionComponents(albumCoverImageView: nil, albumNameLabel: nil)
    let transitionAppearenceManager = AnimatedTransitioningManager(duration: 0.28)
    
    
    @IBOutlet weak var addTransButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategory: NewCategories?
    var fromCategories = false
    var allowEditing = true
    var fromAppDelegate = false
    var transactionsManager:TransactionsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionsManager = .init()
        historyDataStruct.forEach({
            if !(transactionsManager?.daysBetween.contains($0.date) ?? false) {
                transactionsManager?.daysBetween.append($0.date)
            }
        })
        print(selectedCategory, " selectedCategoryselectedCategory")
        tableView.registerCell([.amount])
        HistoryVC.shared = self
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if allowEditing {
            //   DispatchQueue.main.async {
            
            
            if mainType == .db  {
                self.addTransButton.alpha = 1
            }
            
            // }
        } else {
            self.addTransButton.alpha = 0
        }
        transactionAdded = false
        historyDataStruct = historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
        totalSumm = Int(totalSum())
        print(historyDataStruct.count, "didlocount")
        tableView.delegate = self
        tableView.dataSource = self
        title = selectedCategory?.name.capitalized
        
        if mainType == .db {
            getDebtData()
        }
        if selectedCategory?.purpose != .debt {
            calcMonthlyLimits()
        }
    }
    
    override func viewDidDismiss() {
        super.viewDidDismiss()
        removeKeyboardObthervers()
    }

    var thisMonthTotal:Double = 0
    
    func calcMonthlyLimits() {
        if selectedCategory?.monthLimit == nil {
            tableView.reloadData()
            return
        }
        thisMonthTotal = transactionsManager?.total(transactions: selectedCategory?.transactions ?? []) ?? 0
        tableView.reloadData()
    }
    
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        showMoreVC()
    }
    var amountToPayEditing = false
    
    @IBOutlet weak var moreButton: UIButton!
    
    private var interstitial: GADFullScreenPresentingAd?

    func monthlyLimitPressed() {
        if selectedCategory?.purpose == .debt {
            self.amountToPayEditing = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.ai?.fastHide()
            }
        } else {
            AppDelegate.shared?.banner.toggleFullScreenAdd(self, type: .categoryLimit, loaded: { GADFullScreenPresentingAd in
                self.interstitial = GADFullScreenPresentingAd
                self.interstitial?.fullScreenContentDelegate = self
            }, closed: { presented in
                self.amountToPayEditing = true
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    // self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                    self.ai?.fastHide()
                }
            })
        }
        
    }
    
    func showMoreVC() {
        let appData = AppData()
        //get screen data

        let addDueDate = {
            self.tocalendatPressed()
            
        }
        
        let moreData = selectedCategory?.purpose == .debt ? [
            MoreVC.ScreenData(name: "Amount to pay".localize, description: "", showAI:false, action: monthlyLimitPressed),
            MoreVC.ScreenData(name: "Due date".localize, description: "", showAI:false, pro: appData.proEnabeled, action: addDueDate),
        ] : [
            MoreVC.ScreenData(name: "Add monthly limit".localize, description: "", showAI:false, action: monthlyLimitPressed),
        ]
        appData.presentMoreVC(currentVC: self, data: moreData, proIndex: 0)
    }
    
    
    weak static var shared: HistoryVC?
    @IBOutlet weak var totalPeriodLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    var svsloaded = false
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !svsloaded {
            addTransButton.backgroundColor = K.Colors.link
            svsloaded = true
        }
        
        
    }
    
    var mainType: HistDataType = .db
    
    enum HistDataType {
        case localData
        case allData
        case unsaved//when transfar data from
        case db
    }
    
    
    var fromStatistic = false

    
    @IBOutlet weak var footerStack: UIStackView!
    func addBennerHelper() {
        if !appData.proEnabeled {
            let view = UIView()
            view.backgroundColor = .clear
            view.isHidden = true
            footerStack.addArrangedSubview(view)
            self.view.addConstraints([
                .init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: AppDelegate.shared?.banner.size ?? 0),
                .init(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.view.frame.width)
            ])
            view.translatesAutoresizingMaskIntoConstraints = false
            UIView.animate(withDuration: 0.3) {
                view.isHidden = false
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)

    }
    var helperViewAdded = false
    var bottomTableInsert:CGFloat = 50
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.delegate = nil
        print(navigationController?.navigationBar.frame.height ?? 0, " trgefrrtfvd")
        if !helperViewAdded {
            helperViewAdded = true
            addBennerHelper()
        }
        
        let inserts = self.totalLabel.superview?.layer.frame.height ?? 50
        self.bottomTableInsert = inserts + defaultTableInset
        self.tableView.contentInset.bottom = self.bottomTableInsert
        if selectedCategory?.purpose == .debt {
            if let cat = self.selectedCategory {
                Notifications.removeNotification(id: "Debts\(cat.id )")
            }
            
        }
        
        
        if allowEditing {
            DispatchQueue.main.async {
                self.tableView.contentInset.bottom = self.addTransButton.frame.height + 20
            }
        }
        
        
    }
    
    func stringToInterval(s: String) -> DateComponents {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let pressedHours = formater.date(from: s)
        if let date = pressedHours {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        } else {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        }
    }
    
    let center = AppDelegate.shared!.center
    
    
    func getDebtData() {
        //  if allowEditing {
        if let id = selectedCategory?.id {
            selectedCategory = db.category("\(id)")
            let hide = selectedCategory?.purpose == .income
                DispatchQueue.main.async {
                    if self.moreButton.isHidden != hide {
                        self.moreButton.isHidden = hide
                        
                    }
                    self.tableView.reloadData()
                }
        }
        
        
    }
    
    
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if keyboardHeight > 1.0 {
                DispatchQueue.main.async {
                    self.tableView.contentInset.bottom = keyboardHeight - self.appData.resultSafeArea.1
                    
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.tableView.contentInset.bottom = self.bottomTableInsert
            self.tableView.reloadData()
            
        }
    }
    var edited:(()->())?
    var _totalSumm: Int  = 0
    var totalSumm: Int {
        get {
            return _totalSumm
        }
        set {
            _totalSumm = newValue
            let hideLabel = newValue == 0
            DispatchQueue.main.async {
                self.totalLabel.text = "\(newValue)"
                if self.totalLabel.superview?.isHidden ?? (!hideLabel) != hideLabel {
                    UIView.animate(withDuration: 0.3) {
                        self.totalLabel.superview?.isHidden = hideLabel
                    } 
                    
                }
            }
        }
    }
    var totalExpenses = 0.0
    func totalSum() -> Double {
        var sum = 0.0
        totalExpenses = 0
        let data = historyDataStruct
        for i in 0..<data.count {
            let value = Double(data[i].value) ?? 0
            sum += value
            if value < 0 {
                totalExpenses += value
            }
        }
        
        return sum
        //let text = (sum < Double(Int.max) ? "\(Int(sum))" : "\(sum)") + (hasTotalAmount ? "/" : "")
        
    }
    
    @IBAction func toTransPressed(_ sender: UIButton) {
        let vc = TransitionVC.configure()
        toAddVC = true
        vc.delegate = self
        vc.fromDebts = fromCategories ? true : false
        vc.editingCategory = "\(self.selectedCategory?.id ?? 0)"
        vc.selectedPurpose = selectedPurposeH
        transitionAppearenceManager.beginTransactionPressedView = addTransButton
        navigationController?.delegate = transitionAppearenceManager
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    var selectedPurposeH: Int?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toTransVC":
          //  self.navigationController?.delegate = transitionAppearenceManager

            break
        case "toCalendar":
            let vc = segue.destination as! CalendarVC
            vc.delegate = self
            let string = self.selectedCategory?.dueDate
            let stringDate = "\(AppData.makeTwo(n: string?.day ?? 0)).\(AppData.makeTwo(n: string?.month ?? 0)).\(string?.year ?? 0)"
            let time = "\(AppData.makeTwo(n: string?.hour ?? 0)):\(AppData.makeTwo(n: string?.minute ?? 0)):\(AppData.makeTwo(n: string?.second ?? 0))"
            vc.selectedFrom = (string == nil) ? "" : stringDate
            vc.datePickerDate = string != nil ? time : ""
            vc.vcHeaderData = headerData(title: "Create".localize + " " + "notification".localize, description: "Get notification reminder on specific date".localize)
            vc.needPressDone = true
            vc.canSelectOnlyOne = true
            vc.selectingDate = false
            //headerData
            //vc.selectedFrom
        default:
            break
        }
    }
    
    var toAddVC = false
    
    @objc func toCalendarPressed(_ sender: UITapGestureRecognizer) {
        tocalendatPressed()
        
    }
    
    
    func changeDueDate(fullDate: String) {
        if let category = selectedCategory {
            let comp = DateComponents()
            let newDate = comp.stringToCompIso(s: fullDate)
            self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
                var newCategory = category
                newCategory.dueDate = fullDate == "" ? nil : newDate
                SaveToDB.shared.newCategories(newCategory) { _ in
                    self.changed = true
                    self.selectedCategory = newCategory
                    DispatchQueue.main.async {
                        self.ai?.fastHide { (_) in
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
        
    }
    
    
    
    func tocalendatPressed() {
        if appData.proEnabeled {
            Notifications.requestNotifications()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toCalendar", sender: self)
            }
        } else {
            appData.presentBuyProVC(selectedProduct: 0)
        }
        
        
    }
    
    func dbLoadRemoveBeforeUpdate(completion: @escaping ([NewCategories], Bool) -> ()) {
        
        
        //   let load = LoadFromDB()
        
        DispatchQueue(label: "api", qos: .userInitiated).async {
            LoadFromDB.shared.newCategories { data, error in
                if let id = self.selectedCategory?.id {
                    if let category = self.db.category("\(id)") {
                        let delete = DeleteFromDB()
                        delete.CategoriesNew(category: category) { errorBool in
                            completion(data, errorBool)
                        }
                    }
                }
                
            }
        }
        
        
        
    }
    
    func changeAmountToPay(enteredAmount:String, completion: @escaping (Any?) -> ()) {
        //here
        if let category = selectedCategory {
            self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
                var newCategory = category
                if self.selectedCategory?.purpose == .debt {
                    newCategory.amountToPay = Double(enteredAmount)
                } else {
                    newCategory.monthLimit = Double(enteredAmount)
                }
                
                SaveToDB.shared.newCategories(newCategory) { _ in
                    self.changed = true
                    self.selectedCategory = newCategory
                    completion(nil)
                }
                
            }
        }
        
    }
    
    
    
    
    func removeAlert() {
        //set dbalert ""
        //
    }
    
    var calendarAmountPressed = (false, false)
    
    
    var changed:Bool = false
    func sendAmountToPay(_ text: String) {
        if let _ = Double(text) {
            self.ai?.show(title: "Sending".localize) { _ in
                self.changed = true
                self.changeAmountToPay(enteredAmount: text) { (_) in
                    self.amountToPayEditing = false
                    self.ai?.fastHide { (_) in
                        
                        DispatchQueue.main.async {
                          //  self.tableView.reloadData()
                            self.calcMonthlyLimits()
                        }
                    }
                }
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < -100.0) && fromAppDelegate {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    
                }
            }
        }
    }
    
}

extension HistoryVC:GADFullScreenContentDelegate {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        AppDelegate.shared?.banner.adDidPresentFullScreenContent(ad)
    }
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        AppDelegate.shared?.banner.adDidDismissFullScreenContent(ad)
    }
}
