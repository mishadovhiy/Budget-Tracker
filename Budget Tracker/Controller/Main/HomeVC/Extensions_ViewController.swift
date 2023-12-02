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
        canTouchHandleTap = !cantTapBig
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
       /* if !show {
            UIView.animate(withDuration: 0.3, animations: {
                self.sideBarContentBlockerView.alpha = 0
            })
        }*/
        DispatchQueue.main.async {
            let frame = self.sideBar.layer.frame
            //UIView.animate(withDuration: animated ? 0.25 : 0) {
            if show {
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                    self.sideBarContentBlockerView.alpha = show ? 1 : 0

                })
            }
            UIView.animate(withDuration: 0.58, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.allowAnimatedContent, .allowUserInteraction]) {
                self.mainContentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width : 0, 0, 0)
                self.mainContentViewHelpher.layer.transform = CATransform3DTranslate(CATransform3DIdentity, show ? frame.width : 0, 0, 0)
            } completion: { _ in
                /*UIView.animate(withDuration: 0.3, animations: {
                    self.sideBarContentBlockerView.alpha = show ? 1 : 0

                })*/
                if !show {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                        self.sideBarContentBlockerView.alpha = show ? 1 : 0

                    })
                    
                }
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
        if sender.state == .began {
            touchingFromShow = sideBarShowing
        }
        let finger = sender.location(in: self.view)
        let max:CGFloat = sideBar.frame.width - 10
        let resultXPos = finger.x
        let testCacl = resultXPos / max
       // let c = testCacl - CGFloat(Int(testCacl))
        let resCalc = testCacl >= 1 ? 1 : testCacl
        self.sideBarContentBlockerView.alpha = resCalc
        
        if sender.state == .began {
            sidescrolling = finger.x < 80
            wasShowingSideBar = sideBarShowing
        }
        if sidescrolling || sideBarShowing {
            if sender.state == .began || sender.state == .changed {
                let maximum = max + 30
                let newPosition = finger.x >= maximum ? maximum : (finger.x <= 0 ? 0 : finger.x)
                UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
                    self.mainContentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, newPosition, 0, 0)
                    self.mainContentViewHelpher.layer.transform = CATransform3DTranslate(CATransform3DIdentity, newPosition, 0, 0)
                })
                
            } else {
                if sender.state == .ended {
                    let toHide:CGFloat = wasShowingSideBar ? 200 : 80
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
//                        DispatchQueue.main.async {
//                            self.filterTextLabel.text = "Filter".localize + ": \(appData.filter.selectedPeroud)"
//                        }
                        DispatchQueue.main.async {
                            self.filterTextLabel.text = self._filterText
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
            let lastDay = "31.\(appData.filter.getMonthFromString(s: today).makeTwo()).\(appData.filter.getYearFromString(s: today))"
            let firstDay = "01.\(appData.filter.getMonthFromString(s: today).makeTwo()).\(appData.filter.getYearFromString(s: today))"
            if appData.filter.to == "" {
                appData.filter.to = lastDay
            }
            if appData.filter.from == "" {
                appData.filter.from = firstDay

            }
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

    
   
    

    func updateDataLabels(reloadAndAnimate: Bool = true, noData: Bool = false) {
   //     let unsendedCount = appData.unsendedData.count
   //     let hideLocal = localCount == 0 ? true : false
        
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
           /* self.unsendedDataLabel.text = "\(unsendedCount)"
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
            }*/
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
                    self.mainTableView.reloadData()
             //       if self.mainTableView.visibleCells.count > 1 {
                        
                        //self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
             //       }
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.noDataView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height / 2)
                } completion: { (_) in
                    self.noDataView.isHidden = true
                  //  if self.mainTableView.visibleCells.count > 1 {
                    //    self.mainTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                        self.mainTableView.reloadData()
                 //   }
                }
            }
        }
    }
    
    func tableDataLoaded(_ newValue:[tableStuct]) {
       
        if transactionManager?.filterChanged ?? false{
            transactionManager?.filterChanged = false
           // filter()
            
        } else {
            dataTaskCount = nil
            selectedCell = nil
            self.completedFiltering = true
          //  let from = appData.filter.fromDate
          //  let showAll = appData.filter.showAll
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                
                //here //c
                self.toggleNoData(show: false, addButtonHidden: true)
         //       let filterPeriod = (from.month?.stringMonth ?? "-").capitalized + ", \(from.year ?? 0)"
             //   self.filterText = (showAll ? "All transactions" : filterPeriod).localize
                //"Filter".localize + ": " + appData.filter.selectedPeroud
                self.calculationSView.alpha = 0
                UIView.animate(withDuration: 0.8) {
                    self.calculationSView.alpha = 1
                } completion: { _ in
                    self.updateDataLabels(noData: newValue.count == 0)
                }
                self.tableActionActivityIndicator.removeFromSuperview()
                if self.appData.username != "" {
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
                    self.firstAppearence = false
                    self.downloadFromDB()
                }
            }
        }
        
    }
    
    var calculations:Calculations {
        get { return _calculations }
        set {
            _calculations = newValue
            print(newValue, " tgrfeweertgref")
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
                    let hide = Int(newValue.perioudBalance) == self.dbTotal || newValue.perioudBalance == 0
                    let hi:CGFloat = hide ? 0 : 1
                    if (label.superview?.alpha ?? 0) != hi {
                        UIView.animate(withDuration: 0.13) {
                            label.superview?.alpha = hi
                        }
                    }
                    
                }
                for label in self.balanceLabels {
                    let value = self.dbTotal
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
    func checkPurchase(completion:@escaping(Bool?)-> (), local:Bool = false) {
        let nick = self.appData.username
        if nick == "" || local {
            completion(true)
            return
        }
        LoadFromDB.shared.Users { (loadedData, error) in
            if !error {
                let checkPassword = LoadFromDB.checkPassword(from: loadedData, nickname: self.appData.username, password: self.appData.password)
                let wrongPassword = checkPassword.0
                if let userData = checkPassword.1 {
                    if wrongPassword {
                        self.wrongPassword()
                        completion(false)
                    } else {
                        let _ = self.appData.emailFromLoadedDataPurch(loadedData)
                        if self.appData.trialDate != userData[5] {
                            self.appData.trialDate = userData[5]
                        }
                        if !self.appData.purchasedOnThisDevice && !self.appData.proVersion {
                            print("checkPurchase appData.proVersion", self.appData.proVersion)
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
        //    self.mainTableView.contentInset.top = self.calendarContainer.frame.height
//        mainTableView.contentOffset.y = 0
        if self.ai?.isShowing ?? false {
            DispatchQueue.main.async {
                self.ai?.fastHide()
            }
        }
        if appData.needDownloadOnMainAppeare {
            appData.needDownloadOnMainAppeare = false
            self.downloadFromDB(title: "Fetching".localize)
        }
        let safeTop = self.view.safeAreaInsets.top
        UIView.animate(withDuration: 0.3) {
            self.safeArreaHelperView?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.safeArreaHelperViewCalc * -1, 0)
           // self.safeArreaHelperView?.alpha = 0
        }
        if !safeArreaHelperViewAdded {
            safeArreaHelperViewAdded = true
            if let window = AppDelegate.shared?.window {
                DispatchQueue.main.async {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: safeTop))
                    self.safeArreaHelperView = view
                    
                    view.backgroundColor = K.Colors.primaryBacground
                    window.addSubview(self.safeArreaHelperView!)
                    self.safeArreaHelperView?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.safeArreaHelperViewCalc * -1, 0)
                }
            }
        }
      //  appData.safeArea = (safeTop, self.view.safeAreaInsets.bottom)
    }
    var safeArreaHelperViewCalc:CGFloat {
        return self.view.safeAreaInsets.top + (safeArreaHelperView?.frame.height ?? 0)
    }
    func apiUpdated(_ loadedData: [TransactionsStruct]? = nil) {
        let db = db.transactions
        let data = loadedData ?? db
        self.dbTotal = 0
        self.apiTransactions = data
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
            dbTotal += (Int(value.value) ?? 0)
        }
        calendar?.values = resultt
        DispatchQueue.main.async {
            self.calendar?.collectionView.reloadData()
            self.mainContentView.isUserInteractionEnabled = true
        }
    }
    
    func downloadFromDB(showError: Bool = false, title: String = "Downloading".localize, local:Bool = false) {
     //   self.editingTransaction = nil
        self.sendError = false
        completedFiltering = false
        
        lastSelectedDate = nil
   //     DispatchQueue.main.async {
            self.filterText = title
     //   }
        apiLoading = true
        DispatchQueue.init(label: "download", qos: .userInitiated).async {
            LoadFromDB.shared.newCategories(local:local) { categoryes, error in
                
                AppData.categoriesHolder = categoryes
                if error == .none {
                    self.highesLoadedCatID = ((categoryes.sorted{ $0.id > $1.id }).first?.id ?? 0) + 1
                    LoadFromDB.shared.newTransactions(completion:  { loadedData, error in
                        self.apiUpdated(loadedData)
                        self.checkPurchase(completion:  { _ in
                            self.apiLoading = false
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
                self.sideBar.newNotificationCount()
            }
        }
    }
    
    func updateUI() {
        self.calendar = self.createCalendar(calendarContainer, currentSelected: nil, selected: dateSelected(_:), cellSelected: dateSelectedCell(_:_:))
        calendar?.monthChanged = self.monthSelected(_:_:)
        downloadFromDB(local: true)
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.enableLocalDataPress = false
        
        DispatchQueue.init(label: "local", qos: .userInitiated).async {
            if self.db.viewControllers.firstLaunch[.home] ?? false {
                self.appData.createFirstData {
                    self.prepareFilterOptions()
                    self.filter()
                    self.db.viewControllers.firstLaunch[.home] = false
                    DispatchQueue.main.async {
                        self.newMessage?.show(title: "Wellcome to Budget Tracker".localize, description: "Demo data has been created".localize, type: .standart)
                        
                        
                    }
                }
            }
        }
        balanceHelperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(monthBalancePressed(_:))))
        (
            balanceHelperView as? TouchView
        )?.touchAction = { pressed in
            UIView.animate(withDuration: 0.3, animations: {
                self.bigExpensesStack.backgroundColor = pressed ? K.Colors.darkTable?.withAlphaComponent(0.2) : .clear
            })
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
                db.viewControllers.trial.expireDays = dif.day ?? 0
            } else {
                appData.proTrial = false
                db.viewControllers.trial.checkTrial = false
                if db.viewControllers.trial.trialPressed {
                    DispatchQueue.main.async {
                        self.newMessage?.show(title: "Pro trial is over".localize, type: .standart)
                    }
                }
                
            }
        } else {
            appData.proTrial = false
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
                    } completion: { (_) in
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
        if let editing = editingTransaction {
            editingTransaction = nil
            selectedCell = nil
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
        if let editingTransaction = editingTransaction {
            let delete = DeleteFromDB()
            delete.newTransaction(editingTransaction) { _ in
                // let save = SaveToDB()
                SaveToDB.shared.newTransaction(transaction) { _ in
                    self.apiUpdated()
                    self.editingTransaction = nil
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
        self.newTransaction = new
   //     editingTransaction = nil
        self.animateCellWillAppear = false
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.animateCellWillAppear = true
        }
        
        if new.value != "" && new.date != "" {
           // DispatchQueue.main.async {
                self.filterText = "Adding".localize
            //}
            //let save = SaveToDB()
            SaveToDB.shared.newTransaction(TransactionsStruct(value: new.value, categoryID: "\(new.category.id)", date: new.date, comment: new.comment)) { error in
                self.apiUpdated()
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
            
            transactionManager?.daysBetween = [appData.filter.from]
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
                transactionManager?.daysBetween.append(new) // was bellow break: last day in month wasnt displeying
                if new == appData.filter.to {
                    break
                }
                
            }
        } else {
            transactionManager?.daysBetween.removeAll()
            transactionManager?.daysBetween.append(appData.filter.from)
        }
        
    }
    
    func prepareFilterOptions(_ data:[TransactionsStruct]? = nil) {
        let dat = data == nil ? Array(apiTransactions) : data!
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
        if appData.filter.filteredData["months"] != months || appData.filter.filteredData["years"] != years {
            appData.filter.filteredData = [
                "months":months,
                "years":years
            ]
        }
        
    }
    func toAddTransaction(editing:Bool = false, pressedView:UIView? = nil, canDivid:Bool = true, isCalendar:Bool = false) {
        if !editing {
            editingTransaction = nil
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
            let filterDate = AppDelegate.shared?.appData.filter.fromDate ?? .init()
            let thisMonth = defDate.month == filterDate.month && defDate.year == filterDate.year
            vc.dateSet = self.calendarSelectedDate ?? (thisMonth ? defDate.toShortString() : nil)
            self.calendarSelectedDate = nil
            if let transaction = self.editingTransaction {
                vc.editingDate = transaction.date
                vc.editingValue = Double(transaction.value) ?? 0.0
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
    
    func compliteScrolling() {
       /* if mainTableView.contentOffset.y < self.bigCalcView.frame.height {
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
        }*/
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
            if self.appData.sendSavedData {
                self.appData.sendSavedData = false
                //show message error, try again later
                DispatchQueue.main.async {
                    self.newMessage?.show(title:"Error sending data".localize, description: "Try again later".localize, type: .error)
                }
            }
            self.filter()
        }
        let unsended = self.appData.unsendedData
        if unsended.count > 0 {
            if let first = unsended.first {
                startedSendingUnsended = true
                updateDataLabels(reloadAndAnimate: false)
                if self._filterText != "Sending".localize {
              //      DispatchQueue.main.async {
                        self.filterText = "Sending".localize
                //    }
                }
                
                // let save = SaveToDB()
                let delete = DeleteFromDB()
                if let addCategory:NewCategories = .create(dict: first["categoryNew"] ?? [:]) {
                    if let highest = highesLoadedCatID {
                        var cat = addCategory
                        let newID = highest + 1
                        cat.id = newID
                        SaveToDB.shared.newCategories(cat, saveLocally: false) { error in
                            if !error {
                                self.appData.unsendedData.removeFirst()
                                self.highesLoadedCatID! += 1
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
                                    self.appData.unsendedData.append(["transactionNew":newTransactions[i]])
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
                    if let deleteCategory = NewCategories.create(dict: first["deleteCategoryNew"] ?? [:]) {
                        delete.CategoriesNew(category: deleteCategory, saveLocally: false) { error in
                            if !error {
                                self.appData.unsendedData.removeFirst()
                                self.sendUnsaved()
                            } else {
                                errorAction()
                            }
                        }
                    } else {
                        if let addTransaction = TransactionsStruct.create(dictt: first["transactionNew"] ?? [:]) {
                            SaveToDB.shared.newTransaction(addTransaction, saveLocally: false) { error in
                                if !error {
                                    self.appData.unsendedData.removeFirst()
                                    self.sendUnsaved()
                                } else {
                                    errorAction()
                                }
                            }
                        } else {
                            if let deleteTransaction = TransactionsStruct.create(dictt: first["deleteTransactionNew"] ?? [:]) {
                                delete.newTransaction(deleteTransaction, saveLocally: false) { error in
                                    if !error {
                                        self.appData.unsendedData.removeFirst()
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
                     //   DispatchQueue.main.async {
                            self.filterText = "Sending"
                       // }
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
     //   toggleSideBar(false, animated: true)
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
            
        case "toFiterVC":
            let vc = segue.destination as? FilterTVC
            self.mainTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.prevSelectedPer = self.appData.filter.selectedPeroud
                vc?.months = self.appData.filter.filteredData["months"] ?? []
                vc?.years = self.appData.filter.filteredData["years"] ?? []
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
            }
            

        case "toSingIn":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! LoginViewController
            DispatchQueue(label: "db",  qos: .userInitiated).async {
                self.appData.username = ""
                self.appData.password = ""
                vc.forceLoggedOutUser = self.forceLoggedOutUser
                vc.messagesFromOtherScreen = "Your password has been changed".localize
            }
        default: return
        }
    }
    
    func deleteUnsendedTransactions(id: String) {
        let all = appData.unsendedData
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
        appData.unsendedData = resultt
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
