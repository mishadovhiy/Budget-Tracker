//
//  Extensions_ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 29.01.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension ViewController {
    func scrollHead(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y * -1
        let height = calendarContainer.frame.height * (-2)
        self.bigCalcView.alpha = scrollView.contentOffset.y >= bigCalcView.frame.height ? 0 : 1
        if height <= offset {
            calendarContainer.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, offset <= 0 ? offset : 0, 0)
        } else {
            calendarContainer.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, height, 0)
        }
    }
    func scrollRefresh(_ scrollView:UIScrollView) {
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
    func sideBarPinch(_ sender:UIPanGestureRecognizer) {
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
    func dateFrom(sting: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: sting)
        return date
    }
    
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
            if !completedFiltering {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
                    if self.completedFiltering {
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
    
    var newTableData: [tableStuct] {
        get {
            return _TableData
        }
        set {
            _TableData = newValue
            tableDataLoaded(newValue)
        }
    }
    
    
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
    
    func tableDataLoaded(_ newValue:[tableStuct]) {
        dataTaskCount = nil
        selectedCell = nil
        self.completedFiltering = true
        let from = appData.filter.fromDate
        let showAll = appData.filter.showAll
        //here
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.toggleNoData(show: false, addButtonHidden: true)
            let filterPeriod = (from.month?.stringMonth ?? "-").capitalized + ", \(from.year ?? 0)"
            self.filterText = (showAll ? "All transactions" : filterPeriod).localize
            //"Filter".localize + ": " + appData.filter.selectedPeroud
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
            
            if let addedAction = self.actionAfterAdded {
                self.actionAfterAdded = nil
                addedAction(true)
            }
            if self.firstAppearence {
                
            }
        }
    }
    
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
                    let hide = newValue.perioudBalance == newValue.balance
                    if label.superview?.isHidden ?? false != hide {
                        UIView.animate(withDuration: 0.2) {
                            label.superview?.isHidden = hide
                        }
                    }
                    
                }
                for label in self.balanceLabels {
                    let value = Int(newValue.balance)
                    label.text = "\(value)"
                    label.textColor = value >= 0 ? K.Colors.category : K.Colors.negative
                }
                
            }
        }
    }
    func sbvsLoaded() {
        if !subviewsLoaded {
            self.noDataView.isHidden = false
            subviewsLoaded = true
            toggleNoData(show: true, text: "Loading".localize, fromTop: true, appeareAnimation: false, addButtonHidden: true)
            self.unsendedDataLabel.superview?.superview?.isHidden = true
            self.dataFromValueLabel.superview?.superview?.isHidden = true
            self.filterAndCalcFrameHolder.0 = self.filterView.frame
            self.filterAndCalcFrameHolder.1 = self.calculationSView.frame
            
            self.view.addSubview(self.filterHelperView)
            self.filterHelperView.shadow(opasity: 0.9, black: true)
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
    func bigLabTaps(_ sender:UITapGestureRecognizer) {
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
    func checkPurchase(completion:@escaping(Bool?)-> ()) {
        let nick = appData.username
        if nick == "" {
            completion(true)
            return
        }
        LoadFromDB.shared.Users { (loadedData, error) in
            if !error {
                let checkPassword = LoadFromDB.checkPassword(from: loadedData, nickname: appData.username, password: appData.password)
                let wrongPassword = checkPassword.0
                if let userData = checkPassword.1 {
                    if wrongPassword {
                        self.wrongPassword()
                        completion(false)
                    } else {
                        let _ = appData.emailFromLoadedDataPurch(loadedData)
                        appData.trialDate = userData[5]
                        if !appData.purchasedOnThisDevice && !appData.proVersion {
                            print("checkPurchase appData.proVersion", appData.proVersion)
                            if userData[5] != "" {
                                self.checkProTrial()
                            }
                        }
                        completion(true)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.newMessage.show(title:"User not found".localize, type: .error)
                    }
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            
            
        }
    }
    
    func viewAppeared() {
        self.notificationsCount = Notifications.notificationsCount
        //    self.mainTableView.contentInset.top = self.calendarContainer.frame.height
        
        if self.ai.isShowing {
            DispatchQueue.main.async {
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
    
    func downloadFromDB(showError: Bool = false, title: String = "Downloading".localize) {
        self.editingTransaction = nil
        self.sendError = false
        completedFiltering = false
        
        lastSelectedDate = nil
        DispatchQueue.main.async {
            self.filterText = title
        }
        apiLoading = true
        DispatchQueue.init(label: "download").async {
            LoadFromDB.shared.newCategories { categoryes, error in
                
                AppData.categoriesHolder = categoryes
                if error == .none {
                    self.highesLoadedCatID = ((categoryes.sorted{ $0.id > $1.id }).first?.id ?? 0) + 1
                    LoadFromDB.shared.newTransactions { loadedData, error in
                        self.checkPurchase { _ in
                            self.apiLoading = false
                            self.filter(data: loadedData)
                        }
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
    
    func updateUI() {
        downloadFromDB()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.enableLocalDataPress = false
        
        if appData.defaults.value(forKey: "firstLaunch") as? Bool ?? true {
            appData.createFirstData {
                self.prepareFilterOptions()
                self.filter()
                UserDefaults.standard.setValue(false, forKey: "firstLaunch")
                DispatchQueue.main.async {
                    self.newMessage.show(title: "Wellcome to Budget Tracker".localize, description: "Demo data has been created".localize, type: .standart)
                    
                    
                }
            }
        }
        
    }
    func wrongPassword() {
        print(appData.password)
        self.forceLoggedOutUser = appData.username
        appData.username = ""
        appData.password = ""
        self.resetPassword = true
        let segue = "toSingIn"
        //(AppDelegate.shared?.deviceType ?? .mac) == .primary ? "toSingIn" : "toSettingsFullScreen"
        print(#function, " ", segue)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    
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
        appData.filter.filteredData = [
            "months":months,
            "years":years
        ]
    }
    func toAddTransaction() {
        editingTransaction = nil
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToEditVC", sender: self)
        }
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
    
    
    
    func prepareSegue(for segue: UIStoryboardSegue, sender: Any?) {
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
            vc?.months = appData.filter.filteredData["months"] ?? []
            vc?.years = appData.filter.filteredData["years"] ?? []
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
}



extension ViewController {
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
