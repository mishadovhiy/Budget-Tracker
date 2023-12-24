//
//  Extensions_ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 29.01.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension HomeVC {
    func scrollHead(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y * -1
        let height = calendarContainer.frame.height * (-2)
        let cantTapBig = scrollView.contentOffset.y >= bigCalcView.frame.height
        self.bigCalcView.alpha = cantTapBig ? 0 : 1
        viewModel.canTouchHandleTap = !cantTapBig
        if height <= offset {
            calendarContainer.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, offset <= 0 ? offset : 0, 0)
        } else {
            calendarContainer.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, height, 0)
        }
    }
    func scrollRefresh(_ scrollView:UIScrollView) {
        let finger = scrollView.panGestureRecognizer.location(in: self.view)
        viewModel.refreshData = finger.x > self.view.frame.width / 2 ? false : true
    }
    
    func toggleSideBar(_ show: Bool, animated:Bool) {
        viewModel.sideBarShowing = show
        DispatchQueue.main.async {
            let frame = self.sideBar.layer.frame
            if show {
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                    self.sideBarContentBlockerView.alpha = show ? 1 : 0
                    
                })
            }
            UIView.animate(withDuration: 0.58, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.allowAnimatedContent, .allowUserInteraction]) {
                self.mainContentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width : 0, 0, 0)
                self.mainContentViewHelpher.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width : 0, 0, 0)
            } completion: {
                if !$0 {
                    return
                }
                if !show {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                        self.sideBarContentBlockerView.alpha = show ? 1 : 0
                        
                    })
                    
                }
                self.sideBar.getData()
                if self.viewModel.firstLod {
                    self.viewModel.firstLod = false
                    self.sideBar.isHidden = false
                    self.menuButton.isEnabled = true
                    let gesture = UITapGestureRecognizer(target: self, action: #selector( self.mainContentTap(_:)))
                    
                    if show {
                        self.mainTableView.addGestureRecognizer(gesture)
                    } else {
                        self.mainTableView.removeGestureRecognizer(gesture)
                    }
                }
            }
            
        }
    }
    func sideBarPinch(_ sender:UIPanGestureRecognizer) {
        if sender.state == .began {
            touchingFromShow = viewModel.sideBarShowing
        }
        let finger = sender.location(in: self.view)
        let max:CGFloat = sideBar.frame.width - 10
        let resultXPos = finger.x
        let testCacl = resultXPos / max
        // let c = testCacl - CGFloat(Int(testCacl))
        let resCalc = testCacl >= 1 ? 1 : testCacl
        self.sideBarContentBlockerView.alpha = resCalc
        
        if sender.state == .began {
            viewModel.sidescrolling = finger.x < 80
            viewModel.wasShowingSideBar = viewModel.sideBarShowing
        }
        if viewModel.sidescrolling || viewModel.sideBarShowing {
            if sender.state == .began || sender.state == .changed {
                let maximum = max + 30
                let newPosition = finger.x >= maximum ? maximum : (finger.x <= 0 ? 0 : finger.x)
                UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
                    self.mainContentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, newPosition, 0, 0)
                    self.mainContentViewHelpher.layer.transform = CATransform3DTranslate(CATransform3DIdentity, newPosition, 0, 0)
                })
                
            } else {
                if sender.state == .ended {
                    let toHide:CGFloat = viewModel.wasShowingSideBar ? 200 : 80
                    toggleSideBar(finger.x > toHide ? true : false, animated: true)
                }
            }
            if sender.state == .cancelled {
                toggleSideBar(false, animated: true)
            }
        }
    }
    func dateFrom(sting: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: sting)
        return date
    }
    
    var filterText: String {
        get {
            return viewModel._filterText
        }
        set {
            viewModel._filterText = newValue
            var dots = ""
            DispatchQueue.main.async {
                self.filterTextLabel.text = newValue
            }
            for i in 0..<self.viewModel.timers.count {
                self.viewModel.timers[i].invalidate()
            }
            if !viewModel.completedFiltering {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
                    if self.viewModel.completedFiltering {
                        timer.invalidate()

                        DispatchQueue.main.async {
                            self.filterTextLabel.text = self.viewModel._filterText
                        }
                        for i in 0..<self.viewModel.timers.count {
                            self.viewModel.timers[i].invalidate()
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
                            self.filterTextLabel.text = self.viewModel._filterText + dots
                        }
                    }
                }
                viewModel.timers.append(timer)
            }
        }
    }
    
    func allDaysBetween() {
        
        if getYearFrom(string: appData.db.filter.to) == getYearFrom(string: appData.db.filter.from) {
            let today = appData.db.filter.getToday()
            let lastDay = "31.\(appData.db.filter.getMonthFromString(s: today).twoDec).\(appData.db.filter.getYearFromString(s: today))"
            let firstDay = "01.\(appData.db.filter.getMonthFromString(s: today).twoDec).\(appData.db.filter.getYearFromString(s: today))"
            if appData.db.filter.to == "" {
                appData.db.filter.to = lastDay
            }
            if appData.db.filter.from == "" {
                appData.db.filter.from = firstDay
                
            }
            let to = appData.db.filter.to
            let monthT = appData.db.filter.getMonthFromString(s: to)
            let yearT = appData.db.filter.getYearFromString(s: to)
            let dayTo = appData.db.filter.getLastDayOf(month: monthT, year: yearT)
            viewModel.selectedToDayInt = dayTo
            viewModel.selectedFromDayInt = appData.db.filter.getDayFromString(s: appData.db.filter.from)
            
            let monthDifference = getMonthFrom(string: appData.db.filter.to) - getMonthFrom(string: appData.db.filter.from)
            var amount = viewModel.selectedToDayInt + (31 - viewModel.selectedFromDayInt) + (monthDifference * 31)
            if amount < 0 {
                amount *= -1
            }
            calculateDifference(amount: amount)
            
        } else {
            let yearDifference = (getYearFrom(string: appData.db.filter.to) - getYearFrom(string: appData.db.filter.from)) - 1
            let monthDifference = (12 - getMonthFrom(string: appData.db.filter.from)) + (yearDifference * 12) + getMonthFrom(string: appData.db.filter.to)
            var amount = viewModel.selectedToDayInt + (31 - viewModel.selectedFromDayInt) + (monthDifference * 31)
            if amount < 0 {
                amount *= -1
            }
            calculateDifference(amount: amount)
        }
        
        
        
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
                } completion: {
                    if !$0 {
                        return
                    }
                    self.mainTableView.reloadData()
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.noDataView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height / 2)
                } completion: {
                    if !$0 {
                        return
                    }
                    self.noDataView.isHidden = true
                    self.mainTableView.reloadData()
                }
            }
        }
    }
    
    func tableDataLoaded(_ newValue:[tableStuct]) {
        
        if transactionManager?.filterChanged ?? false{
            transactionManager?.filterChanged = false
        } else {
            dataTaskCount = nil
            viewModel.selectedCell = nil
            self.viewModel.completedFiltering = true
            DispatchQueue.main.async {
                self.toggleNoData(show: false, addButtonHidden: true)
                self.calculationSView.alpha = 0
                UIView.animate(withDuration: 0.8) {
                    self.calculationSView.alpha = 1
                } completion: {
                    if !$0 {
                        return
                    }
                }
                if self.properties?.appData.db.username != "" {
                    self.sendUnsaved()
                }
                if let _ = self.viewModel.newTransaction {
                    self.viewModel.newTransaction = nil
                }
                
                if let addedAction = self.viewModel.actionAfterAdded {
                    self.viewModel.actionAfterAdded = nil
                    addedAction(true)
                }
            }
        }
        
    }
    
    
    var notificationsCount:(Int, Int) {
        get {
            return viewModel._notificationsCount
        }
        set {
            viewModel._notificationsCount = newValue
            let result = newValue.0 + newValue.1
            let hide = result == 0
            DispatchQueue.main.async {
                self.notificationsLabel.text = "\(result)"
                if self.notificationsView.isHidden != hide {
                    UIView.animate(withDuration: 0.3) {
                        self.notificationsView.isHidden = hide
                    }
                    
                }
                self.sideBar.newNotificationCount()
            }
        }
    }
    
    var calculations:Calculations {
        get {
            return viewModel._calculations
        }
        set {
            viewModel._calculations = newValue
            transactionManager?.calculation = newValue
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
                    let hide = Int(newValue.perioudBalance) == self.viewModel.dbTotal || newValue.perioudBalance == 0
                    let hi:CGFloat = hide ? 0 : 1
                    if (label.superview?.alpha ?? 0) != hi {
                        UIView.animate(withDuration: 0.13) {
                            label.superview?.alpha = hi
                        }
                    }
                    
                }
                for label in self.balanceLabels {
                    let value = self.viewModel.dbTotal
                    label.text = "\(value)"
                    label.textColor = value >= 0 ? K.Colors.category : K.Colors.negative
                }
                
            }
        }
    }
    func sbvsLoaded() {
        if !viewModel.subviewsLoaded {
            self.noDataView.isHidden = false
            viewModel.subviewsLoaded = true
            toggleNoData(show: true, text: "Loading".localize, fromTop: true, appeareAnimation: false, addButtonHidden: true)
            self.unsendedDataLabel.superview?.superview?.isHidden = true
            self.dataFromValueLabel.superview?.superview?.isHidden = true
            viewModel.filterAndCalcFrameHolder.0 = self.filterView.frame
            viewModel.filterAndCalcFrameHolder.1 = self.calculationSView.frame
            
            let superframe = self.calculationSView.superview?.frame ?? .zero
            let calcFrame = self.calculationSView.frame
            self.calculationSView.frame = CGRect(x: -superframe.height, y: calcFrame.minY, width: calcFrame.width, height: calcFrame.height)
            
            self.noDataView.translatesAutoresizingMaskIntoConstraints = true
            self.noDataView.layer.masksToBounds = true
            noDataView.layer.cornerRadius = viewModel.tableCorners
            self.noDataView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.darkBackgroundUnderTable.layer.masksToBounds = true
            self.darkBackgroundUnderTable.layer.cornerRadius = self.viewModel.tableCorners
            self.darkBackgroundUnderTable.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.darkBackgroundUnderTable.translatesAutoresizingMaskIntoConstraints = true
            self.addTransitionButton.layer.cornerRadius = self.addTransitionButton.layer.frame.width / 2
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
        }
    }
    
    func checkPurchase(completion:@escaping(Bool?)-> (), local:Bool = false) {
        let nick = self.properties?.appData.db.username
        if nick == "" || local {
            completion(true)
            return
        }
        LoadFromDB.shared.Users { (loadedData, error) in
            if !error {
                let checkPassword = LoadFromDB.checkPassword(from: loadedData, nickname: self.properties?.appData.db.username, password: self.properties?.appData.db.password)
                let wrongPassword = checkPassword.0
                if let userData = checkPassword.1 {
                    if wrongPassword {
                        self.apiPasswordChanged()
                        completion(false)
                    } else {
                        let _ = self.properties?.appData.db.emailFromLoadedDataPurch(loadedData)
                        if self.properties?.appData.db.trialDate != userData[5] {
                            self.properties?.appData.db.trialDate = userData[5]
                        }
                        if !self.properties!.appData.db.purchasedOnThisDevice && !self.properties!.appData.db.proVersion {
                            print("checkPurchase appData.proVersion", self.properties?.appData.db.proVersion)
                            if userData[5] != "" {
                                // self.checkProTrial()
                            }
                        }
                        completion(true)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.newMessage?.show(title:"User not found".localize, type: .error)
                    }
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            
            
        }
    }
    
    func viewAppeared() {
        navigationController?.delegate = nil
        self.notificationsCount = Notifications.notificationsCount
        if appData.needFullReload || self.properties!.appData.needDownloadOnMainAppeare {
            appData.needDownloadOnMainAppeare = false
            appData.needFullReload = false
            self.downloadFromDB(title: "Fetching".localize)
        }
        let safeTop = self.view.safeAreaInsets.top
        UIView.animate(withDuration: 0.3) {
            self.safeArreaHelperView?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.safeArreaHelperViewCalc * -1, 0)
        }
        if safeArreaHelperView == nil {
            if let window = UIApplication.shared.keyWindow {
                DispatchQueue.main.async {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: safeTop))
                    self.safeArreaHelperView = view
                    
                    view.backgroundColor = K.Colors.primaryBacground
                    window.addSubview(self.safeArreaHelperView!)
                    self.safeArreaHelperView?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.safeArreaHelperViewCalc * -1, 0)
                }
            }
        }
    }
    var safeArreaHelperViewCalc:CGFloat {
        return self.view.safeAreaInsets.top + (safeArreaHelperView?.frame.height ?? 0)
    }
    func apiUpdated(_ loadedData: [TransactionsStruct]? = nil) {
        let db = db.transactions
        let data = loadedData ?? db
        self.viewModel.dbTotal = 0
        self.viewModel.apiTransactions = data
        var resultt:[String:CGFloat] = [:]
        data.forEach { transaction in
            let date = transaction.date.stringToCompIso()
            let model = "\(date.year ?? 0).\(date.month ?? 0).\(date.day ?? 0)"
                //.init(year: date.year ?? 0, month: date.month ?? 0)
            let val = (resultt[model] ?? 0)
            let new = val + (Double(transaction.value) ?? 0)
            resultt.updateValue(new, forKey: model)
        }
        db.forEach { value in
            viewModel.dbTotal += (Int(value.value) ?? 0)
        }
        viewModel.calendar?.values = resultt
        DispatchQueue.main.async {
            self.viewModel.calendar?.collectionView.reloadData()
            self.mainContentView.isUserInteractionEnabled = true
        }
    }
    
    func downloadFromDB(showError: Bool = false, title: String = "Downloading".localize, local:Bool = false) {
        viewModel.sendError = false
        viewModel.completedFiltering = false
        self.filterText = title
        viewModel.apiLoading = true
        mainTableView.startAnimating()
        DispatchQueue.init(label: "download", qos: .userInitiated).async {
            self.db.transactionDate = nil
            LoadFromDB.shared.newCategories(local:local) { categoryes, error in
                
                if error == .none {
                    self.viewModel.highesLoadedCatID = ((categoryes.sorted{ $0.id > $1.id }).first?.id ?? 0) + 1
                    LoadFromDB.shared.newTransactions(completion:  { loadedData, error in
                        self.apiUpdated(loadedData)
                        self.checkPurchase(completion:  { _ in
                            self.viewModel.apiLoading = false
                            self.filter(data: loadedData)
                        }, local:local)
                    }, local:local)
                } else {
                    self.filter()
                    if showError {
                        DispatchQueue.main.async {
                            self.newMessage?.show(type: .internetError)
                        }
                    }
                    
                }
            }
        }
        
    }
    
    
    
    
    func updateUI() {
        mainTableView.refreshBackgroundColor = self.view.backgroundColor
        mainTableView.refreshAction = refresh
        transactionManager = .init()
        transactionManager?.taskChanged = {
            self.dataTaskCount = $0
        }
        
        viewModel.calendar = self.createCalendar(calendarContainer, currentSelected: nil, selected: dateSelected(_:), cellSelected: dateSelectedCell(_:_:))
        viewModel.calendar?.monthChanged = self.monthSelected(_:_:)
        downloadFromDB(local: true)
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        viewModel.enableLocalDataPress = false

        
        balanceHelperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(monthBalancePressed(_:))))
        (
            balanceHelperView as? TouchView
        )?.touchAction = { pressed in
            UIView.animate(withDuration: 0.3, animations: {
                self.bigExpensesStack.backgroundColor = pressed ? K.Colors.darkTable?.withAlphaComponent(0.2) : .clear
            })
        }
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
    
    func apiPasswordChanged() {
        print(appData.db.password)
        viewModel.forceLoggedOutUser = appData.db.username
        appData.db.username = ""
        appData.db.password = ""
        viewModel.resetPassword = true
        let segue = "toSingIn"
        print(#function, " ", segue)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    func checkProTrial() {
        let wasStr = appData.db.trialDate
        let todayStr = appData.db.filter.getToday()
        let dates = (dateFrom(sting: wasStr), dateFrom(sting: todayStr))
        let dif = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dates.0 ?? Date(), to: dates.1 ?? Date())
        if dif.year == 0 && dif.month == 0 {
            if dif.day ?? 0 <= 7 {
                appData.db.proTrial = true
                db.viewControllers.trial.expireDays = dif.day ?? 0
            } else {
                appData.db.proTrial = false
                db.viewControllers.trial.checkTrial = false
                if db.viewControllers.trial.trialPressed {
                    DispatchQueue.main.async {
                        self.newMessage?.show(title: "Pro trial is over".localize, type: .standart)
                    }
                }
            }
        } else {
            appData.db.proTrial = false
            db.viewControllers.trial.checkTrial = false

            if db.viewControllers.trial.trialPressed {
                DispatchQueue.main.async {
                    self.newMessage?.show(title: "Pro trial is over".localize, type: .standart)
                }
            }
            
        }
    }
    
    var dataTaskCount: (Int, Int)? {
        get { return nil }
        set {
            self.transactionManager?.dataTaskCount = newValue
            if let new = newValue {
                let statusText = new.0 > 0 ? "\(new.0)/\(new.1)" : ""
                DispatchQueue.main.async {
                    self.dataTaskCountLabel.text = statusText
                }
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.6) {
                        self.dataTaskCountLabel.alpha = 0
                    } completion: {
                        if !$0 {
                            return
                        }
                        self.dataTaskCountLabel.text = ""
                        self.dataTaskCountLabel.alpha = 1
                    }
                }
            }
            
        }
    }
}


extension HomeVC: TransitionVCProtocol {
    func deletePressed() {
        if let editing = viewModel.editingTransaction {
            viewModel.editingTransaction = nil
            viewModel.selectedCell = nil
            let delete = DeleteFromDB()
            print(editing, " gghdfsdaewreg")
            delete.newTransaction(editing) { _ in
                self.apiUpdated()
                self.filter()
            }
        } else {
            DispatchQueue.main.async {
                self.newMessage?.show(title:"Error deleting transaction".localize, description: "Try again".localize, type: .error)
            }
        }
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct, reminderTime:DateComponents?, repeated:Bool?, idx:Int?) {
        if let editingTransaction = viewModel.editingTransaction {
            let delete = DeleteFromDB()
            delete.newTransaction(editingTransaction) { _ in
                // let save = SaveToDB()
                SaveToDB.shared.newTransaction(transaction) { _ in
                    self.apiUpdated()
                    self.viewModel.editingTransaction = nil
                    self.filter()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.newMessage?.show(title:"Error deleting transaction".localize, description: "Try again".localize, type: .error)
            }
        }
        
    }
    
    
    private func addNewTransaction(_ new:TransactionsStruct) {
        viewModel.newTransaction = new
        viewModel.animateCellWillAppear = false
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.viewModel.animateCellWillAppear = true
        }
        
        if new.value != "" && new.date != "" {
                self.filterText = "Adding".localize
            SaveToDB.shared.newTransaction(TransactionsStruct(value: new.value, categoryID: "\(new.category.id)", date: new.date, comment: new.comment)) { error in
                self.apiUpdated()
                self.filter()
                self.viewModel.editingTransaction = nil
                if !error {
                    self.viewModel.forseSendUnsendedData = true
                    self.sendUnsaved()
                }
            }
            
        } else {
            print("reloaddd")
            self.viewModel.editingTransaction = nil

        }
    }
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime:DateComponents?, repeated:Bool?) {
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        addNewTransaction(new)
    }
    
    
    func quiteTransactionVC(reload:Bool){
        viewModel.editingTransaction = nil
        if reload {
            filter()
        }
    }
    
    func calculateDifference(amount: Int) {
        viewModel.allData = []
        if appData.db.filter.to != appData.db.filter.from {
            var dayA: Int = viewModel.selectedFromDayInt
            var monthA: Int = getMonthFrom(string: appData.db.filter.from)
            var yearA: Int = getYearFrom(string: appData.db.filter.from)
            
            var daysBetween: [String] = transactionManager?.daysBetween ?? []
            daysBetween.append(appData.db.filter.from)
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
                let new: String = "\(dayA.twoDec).\(monthA.twoDec).\(yearA.twoDec)"
                daysBetween.append(new)
                if new == appData.db.filter.to {
                    break
                }
            }
            transactionManager?.daysBetween = daysBetween
        } else {
            transactionManager?.daysBetween.removeAll()
            transactionManager?.daysBetween.append(appData.db.filter.from)
        }
    }
    
    func prepareFilterOptions(_ data:[TransactionsStruct]? = nil) {
        let dat = data == nil ? Array(viewModel.apiTransactions) : data!
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
        if appData.db.filter.filteredData["months"] != months || appData.db.filter.filteredData["years"] != years {
            appData.db.filter.filteredData = [
                "months":months,
                "years":years
            ]
        }
        
    }
    func toAddTransaction(editing:Bool = false, pressedView:UIView? = nil, canDivid:Bool = true, isCalendar:Bool = false) {
        if !editing {
            viewModel.editingTransaction = nil
        }
        DispatchQueue.main.async {
            if !isCalendar {
                self.navigationController?.delegate = self.transitionAppearenceManager
                self.transitionAppearenceManager.beginTransactionPressedView = pressedView ?? self.addTransitionButton
                self.transitionAppearenceManager.canDivideFrame = canDivid
            } else {
                self.navigationController?.delegate = nil
            }
            
            let vc = TransitionVC.configure()
            vc.delegate = self
            let defDate = Date().toDateComponents()
            let filterDate = AppDelegate.shared?.properties?.appData.db.filter.fromDate ?? .init()
            let thisMonth = defDate.month == filterDate.month && defDate.year == filterDate.year
            vc.dateSet = self.viewModel.calendarSelectedDate ?? (thisMonth ? defDate.toShortString() : nil)
            self.viewModel.calendarSelectedDate = nil
            if let transaction = self.viewModel.editingTransaction {
                vc.editingDate = transaction.date
                let val = Double(transaction.value) ?? 0.0
                vc.editingValue = val
                vc.editingCategory = transaction.categoryID
                vc.editingComment = transaction.comment
            }
            if isCalendar {
                self.present(TransactionNav.configure(vc), animated: true)
            } else {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func removeDayFromString(_ s: String) -> String {
        let component = s.stringToDateComponent()
        print(component, " gerfsewreg")
        return (component.month?.twoDec ?? "") + ".\(component.year ?? 0)"
    }
    
    func removeDayMonthFromString(_ s: String) -> String {
        let component = s.stringToDateComponent()
        print(component, " gerfsewreg")
        return "\(component.year ?? 0)"
    }
    
    func sendUnsaved() {
        if viewModel.sendError {
            return
        }
        let errorAction = {
            self.viewModel.sendError = true
            self.viewModel.startedSendingUnsended = false
            if self.properties!.appData.sendSavedData {
                self.properties?.appData.sendSavedData = false
                DispatchQueue.main.async {
                    self.newMessage?.show(title:"Error sending data".localize, description: "Try again later".localize, type: .error)
                }
            }
            self.filter()
        }
        let unsended = self.properties?.appData.db.unsendedData ?? []
        if unsended.count > 0 {
            if let first = unsended.first {
                viewModel.startedSendingUnsended = true
                if self.filterText != "Sending".localize {
                        self.filterText = "Sending".localize
                }
                
                let delete = DeleteFromDB()
                if let addCategory:NewCategories = .create(dict: first["categoryNew"] ?? [:]) {
                    if let highest = viewModel.highesLoadedCatID {
                        var cat = addCategory
                        let newID = highest + 1
                        cat.id = newID
                        SaveToDB.shared.newCategories(cat, saveLocally: false) { error in
                            if !error {
                                self.properties?.appData.db.unsendedData.removeFirst()
                                self.viewModel.highesLoadedCatID! += 1
                                var newTransactions: [[String:Any]] = []
                                for i in 0..<unsended.count {
                                    if let trans:TransactionsStruct = .create(dictt: unsended[i]["transactionNew"]) {
                                        if trans.categoryID == "\(addCategory.id)" {
                                            var newTransaction = trans
                                            newTransaction.categoryID = "\(newID)"
                                            newTransactions.append(newTransaction.dict)
                                            self.deleteUnsendedTransactions(id: "\(addCategory.id)")
                                        }
                                    }
                                }
                                
                                for i in 0..<newTransactions.count {
                                    self.properties?.appData.db.unsendedData.append(["transactionNew":newTransactions[i]])
                                }
                                self.sendUnsaved()
                            } else {
                                errorAction()
                            }
                        }
                    } else {
                        LoadFromDB.shared.newCategories { loadedCategories, error in
                            if error == .none {
                                let allCatSorted = loadedCategories.sorted{ $0.id > $1.id }
                                let highest = allCatSorted.first?.id ?? 0
                                self.viewModel.highesLoadedCatID = highest
                                
                                
                                self.sendUnsaved()
                            } else {
                                errorAction()
                            }
                        }
                    }
                } else {
                    if let deleteCategory = NewCategories.create(dict: first["deleteCategoryNew"] ?? [:]) {
                        delete.CategoriesNew(category: deleteCategory, saveLocally: false) { error in
                            if !error {
                                self.properties?.appData.db.unsendedData.removeFirst()
                                self.sendUnsaved()
                            } else {
                                errorAction()
                            }
                        }
                    } else {
                        if let addTransaction = TransactionsStruct.create(dictt: first["transactionNew"] ?? [:]) {
                            SaveToDB.shared.newTransaction(addTransaction, saveLocally: false) { error in
                                if !error {
                                    self.properties?.appData.db.unsendedData.removeFirst()
                                    self.sendUnsaved()
                                } else {
                                    errorAction()
                                }
                            }
                        } else {
                            if let deleteTransaction = TransactionsStruct.create(dictt: first["deleteTransactionNew"] ?? [:]) {
                                delete.newTransaction(deleteTransaction, saveLocally: false) { error in
                                    if !error {
                                        self.properties?.appData.db.unsendedData.removeFirst()
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
            if viewModel.startedSendingUnsended {
                viewModel.startedSendingUnsended = false
                downloadFromDB(local: AppDelegate.shared?.properties?.appData.db.username ?? "" == "")
            } else {
                if appData.sendSavedData {
                    if self.filterText != "Sending".localize {
                            self.filterText = "Sending"
                    }
                    let save = SaveToDB()
                    if let category = db.localCategories.first {
                        if let highest = viewModel.highesLoadedCatID {
                            var cat = category
                            cat.id = highest + 1
                            save.newCategories(cat) { error in
                                
                                if !error {
                                    self.viewModel.highesLoadedCatID! += 1
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
                            LoadFromDB.shared.newCategories { loadedCategories, error in
                                if error == .none {
                                    let allCatSorted = loadedCategories.sorted{ $0.id > $1.id }
                                    let highest = allCatSorted.first?.id ?? 0
                                    self.viewModel.highesLoadedCatID = highest
                                    
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
                            downloadFromDB(local: AppDelegate.shared?.properties?.appData.db.username ?? "" == "")
                        }
                    }
                }
            }
            
        }
        
    }

    
    
    func deleteUnsendedTransactions(id: String) {
        let all = appData.db.unsendedData
        var resultt:[[String : [String : Any]]] = []
        for i in 0..<all.count {
            if let transaction = TransactionsStruct.create(dictt: all[i]["transactionNew"]) {
                if transaction.categoryID != id {
                    resultt.append(all[i])
                }
            } else {
                resultt.append(all[i])
            }
        }
        appData.db.unsendedData = resultt
    }
}



extension HomeVC {
    enum ViewControllerType {
        case home
        case paymentReminders
    }
    
    struct Calculations {
        var expenses:Double
        var income:Double
        var balance:Double
        var perioudBalance:Double
    }
    struct tableStuct {
        let date: DateComponents
        let amount: Int
        var transactions: [TransactionsStruct]
    }
}

extension HomeVC {
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
            guard let key = presses.first?.key else { return }
            print(key.characters, "key.characterskey.characters")
            switch key.keyCode {
            case .keyboardN:
                if AppDelegate.shared?.canPerformAction ?? false {
                    toAddTransaction()
                }
               
            default:
                super.pressesBegan(presses, with: event)
            }
            
        }
}
