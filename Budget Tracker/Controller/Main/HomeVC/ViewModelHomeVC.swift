//
//  ViewModelHomeVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

struct ViewModelHomeVC {
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
    var completedFiltering = false
    typealias LimitList = [NewCategories:Int]
    var limits:[NewCategories:Int] = [:]
    var dbAllCategories:[NewCategories] = []
    mutating func fetchCategories(completion:@escaping(_ newCategories:[NewCategories])->()) {
        let app = AppDelegate.properties?.db
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let db = app?.categories ?? []
            DispatchQueue.main.async {
                completion(db)
            }
        }
    }
    mutating func setLimits() {
        let limits = dbAllCategories.filter {
            $0.purpose != .debt && ($0.monthLimit ?? 0) >= 1
        }.sorted(by: {$0.name >= $1.name})
        self.limits.removeAll()
        var transactions = Array(monthTransactions)
        limits.forEach { category in
            if category.purpose != .debt && (category.monthLimit ?? 0) >= 1 {
                let categoryTransactions = transactions.filter({
                    $0.categoryID == "\(category.id)"
                })
                let results = categoryTransactions.reduce(0) { partialResult, transaction in
                    partialResult + (Int(transaction.value) ?? 0)
                }
                transactions.removeAll(where: {$0.category.id == category.id})
                if !categoryTransactions.isEmpty {
                    self.limits.updateValue(Int(results), forKey: category)
                }
            }
            
        }
    }
    let tableCorners:CGFloat = 15
    var actionAfterAdded:((Bool) -> ())?
    var firstAppearence = true
    var _calculations:Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
    var forceLoggedOutUser = ""
    var resetPassword = false
    var _filterText: String = "Filter".localize
    var timers: [Timer] = []
    var sendError = false
    var startedSendingUnsended = false
    var highesLoadedCatID: Int?
    var added = false
    var allData: [[TransactionsStruct]] = []
    #if os(iOS)
    var calendar:CalendarControlVC?
    #endif
    var unsavedTransactionsCount = 0
    var selectedCell: IndexPath? = nil
    var animateCellWillAppear = true
    var calcViewHeight:CGFloat = 0
    var refreshData = false
    var lastWhiteBackheight = 0
    var openFiler = false
    var apiLoading = true
    var calendarSelectedDate:String?
    var vcAppeared = false
    var dbTotal:Int = 0

    var monthTransactions:[TransactionsStruct] = []
    var totalBalance = 0.0
    var selectedFromDayInt = 0
    var selectedToDayInt = 0
    var editingTransaction: TransactionsStruct?
    var prevSelectedPer:String?
    var currentStatistic = false
    var apiTransactions:[TransactionsStruct] = []
}
