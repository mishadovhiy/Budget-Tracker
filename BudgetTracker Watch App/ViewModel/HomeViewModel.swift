//
//  ViewModelHomeView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 02.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI
import Foundation

class HomeViewModel:ObservableObject {
    @State var listViewOffset:CGFloat = 0
    private let transactionManager = TransactionsManager.init()
    var calculations:Calculations {
        transactionManager.calculation ?? .init()
    }
    var selectedDate:DateComponents = .init()
    @Published var presentingTransaction:Bool = false {
        didSet {
            if !presentingTransaction {
                self.selectedTransaction = nil
            }
        }
    }
    private var allApiTransactions:[TransactionsStruct] = [] {
        didSet {
            filterTransactions()
        }
    }
    
    var selectedTransaction:TransactionsStruct? = nil {
        didSet {
            if presentingTransaction {
                self.presentingTransaction = false
            }
            if selectedTransaction != nil {
                self.presentingTransaction = true
            }
            
        }
    }
    
    @Published var transactions:[TransactionsStruct] = []
    var categories:[NewCategories] = []
    
    @Published var error:MessageContent? = nil
    var connectivityError:MessageContent? = nil
    
    var connectivity:WatchConectivityService? = nil
    private let network = LoadFromDB()
    
    func messageReceived(_ message:[String:Any]) {
        if let key = message.keys.first,
           let type = WatchConectivityService.MessageType.init(rawValue: key){
            switch type {
            case .sendUsername:
                if let username = message[type.rawValue] as? String {
                    DispatchQueue(label: "db", qos: .userInitiated).async {
                        AppDelegate.properties?.db.username = username
                        DispatchQueue.main.async(execute: {
                            self.loadData()
                        })
                    }
                }
            default: 
                print(message, " message")
            }
            
        }
    }
    
    init(completion:@escaping()->() = {}) {
        self.connectivity = .init(messageReceived: messageReceived(_:))
        connectivity?.error = {
            self.connectivityError = .init(title: $0)
        }
    }
        
    func loadData(completion:@escaping()->() = {}) {
        let request = {
            self.loadCategories(completion: {
                self.loadTransactions(completion: {
                    completion()
                    if AppDelegate.properties?.db.username == "" {
                        DispatchQueue.main.async {
                            self.askUsername()
                        }
                    }
                    print("transactionswerer: ", self.transactions)
                    print("categoriesadsads: ", self.categories)
                })
            })
        }
        if Thread.isMainThread {
            DispatchQueue(label: "db", qos: .userInteractive).async {
                request()
            }
        } else {
            request()
        }
    }
    
    private func loadTransactions(completion:(()->())? = nil) {
        network.newTransactions { list, error in
            if list.isEmpty || error != .none {
                DispatchQueue.main.async {
                    self.error = error.message
                    completion?()
                }
            } else {
                self.allApiTransactions = list
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
    
    private func loadCategories(completion:(()->())? = nil) {
        network.newCategories { list, error in
            if list.isEmpty || error != .none {
                DispatchQueue.main.async {
                    self.error = error.message
                }
                completion?()
            } else {
                self.categories = list
                completion?()
            }
        }
    }
    
    func addTransaction(_ data:TransactionsStruct, completion:@escaping()->() = {}) {
        let request = {
            var transaction = data
            if transaction.category.purpose == .expense {
                transaction.value = "-" + transaction.value
            }
            SaveToDB().newTransaction(transaction) { _ in
                self.loadData(completion: completion)
            }
        }
        if Thread.isMainThread {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                request()
            }
        } else {
            request()
        }
    }
    
    func deleteTransaction(_ data:TransactionsStruct, reloadData:Bool = true, completion:@escaping()->() = {}) {
        let request = {
            DeleteFromDB().newTransaction(data) { _ in
                if reloadData {
                    self.loadData(completion: completion)
                } else {
                    completion()
                }
            }
        }
        if Thread.isMainThread {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                request()
            }
        } else {
            request()
        }
    }
    
    func changeTransaction(_ oldValue:TransactionsStruct, to value:TransactionsStruct) {
        deleteTransaction(oldValue, reloadData: false) {
            self.addTransaction(value)
        }
    }
    
    func changeMonth(plus:Bool) {
        DispatchQueue(label: "db", qos: .userInitiated).async {
            var from = AppDelegate.properties?.db.filter.fromDate ?? Date().toDateComponents()
            if plus {
                if from.month == 12 {
                    from.year = (from.year ?? 0) + 1
                    from.month = 1
                } else {
                    from.month = (from.month ?? 0) + 1
                }
            } else {
                if from.month == 1 {
                    from.year = (from.year ?? 0) - 1
                    from.month = 12
                } else {
                    from.month = (from.month ?? 0) - 1
                }
            }
            AppDelegate.properties?.db.filter.from = "\(1.twoDec).\((from.month ?? 0).twoDec).\(from.year ?? 0)"
            self.filterTransactions()
        }
    }
    
    func filterTransactions() {
        let all = transactionManager.filtered(allApiTransactions)
        var new:[TransactionsStruct] = []
        print(all.count, " refdws")
        let newData = transactionManager.new(transactions: all)
        print(newData.count, " rgfeds")
        newData.forEach {
            $0.transactions.forEach {
                new.append($0)
            }
        }
        self.selectedDate = AppDelegate.properties?.db.filter.fromDate ?? .init()
        DispatchQueue.main.async {
            self.transactions = new
        }
    }
    
    func askUsername() {
        self.connectivity?.askUsername()
    }
}


extension HomeViewModel {
    enum BalanceViewType:String {
        case balance, expences, income, periodBalance
        var title:String {
            switch self {
            case .periodBalance: return "Perioud balance"
            default: return self.rawValue.capitalized
            }
        }
        
        var fontSize:Font {
            switch self {
            case .balance: return .system(size: 18, weight: .black)
            default: return .system(size: 12, weight: .medium)
            }
        }
        
        func value(_ calc:Calculations)->Int {
            let value:Double
            switch self {
            case .balance: value = calc.balance
            case .expences: value = calc.expenses
            case .income: value = calc.income
            case .periodBalance: value = calc.perioudBalance
            }
            return Int(value)
        }
    }
}
