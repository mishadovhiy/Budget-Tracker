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
    var tableDHolder: [HomeVC.tableStuct] = []
    var forseSendUnsendedData = true
    var addTransFrame = CGRect.zero
    var enableLocalDataPress = false
    var undendedCount = 0
    var filterAndCalcFrameHolder = (CGRect.zero, CGRect.zero)
    var wasSendingUnsended = false
    var correctFrameBackground:CGRect = .zero
    var tableData:[TransactionsStruct] = []
    var completedFiltering = false
    let tableCorners:CGFloat = 15
    var actionAfterAdded:((Bool) -> ())?
    var firstAppearence = true
    var _calculations:HomeVC.Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
    var forceLoggedOutUser = ""
    var resetPassword = false
    var _filterText: String = "Filter".localize
    var timers: [Timer] = []
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
