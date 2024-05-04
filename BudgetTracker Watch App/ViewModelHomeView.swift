//
//  ViewModelHomeView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 02.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI
import Foundation

class ViewModelHomeView:ObservableObject {
    
    private let transactionManager = TransactionsManager.init()
    var calculations = Calculations.init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
    var month:Int = 0
    
    private var allApiTransactions:[TransactionsStruct] = [] {
        didSet {
            filterTransactions()
        }
    }
    
    @Published var transactions:[TransactionsStruct] = []
    var categories:[NewCategories] = []
    
    @Published var error:MessageContent? = nil
    var connectivity:WatchConectivityService? = nil
    private let network = LoadFromDB()

    func messageReceived(_ message:[String:Any]) {
        if let username = message["username"] as? String {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                AppDelegate.properties?.db.username = username
                DispatchQueue.main.async(execute: {
                    self.loadData()
                })
            }
        }
    }
    
    init(completion:@escaping()->() = {}) {
        self.connectivity = .init(messageReceived: messageReceived(_:))
    }
    
    //self.loadData(completion: completion)
    
    func loadData(completion:@escaping()->() = {}) {
        DispatchQueue(label: "db", qos: .userInteractive).async { [weak self] in
            self?.loadCategories(completion: {
                self?.loadTransactions(completion: {
                    completion()
                    if AppDelegate.properties?.db.username == "" {
                        DispatchQueue.main.async {
                            self?.connectivity?.askUsername()
                        }
                    }
                    print("transactionswerer: ", self?.transactions)
                    print("categoriesadsads: ", self?.categories)
                })
            })
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
    
    func addTransaction(_ data:TransactionsStruct) {
        
    }
    
    func addCategory(_ data:NewCategories) {
        
    }
    
    func deleteTransaction(_ data:TransactionsStruct) {
        
    }
    
    func deleteCategory(_ data:NewCategories) {
        
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
        self.month = AppDelegate.properties?.db.filter.fromDate.month ?? 0
        DispatchQueue.main.async {
            self.transactions = new
        }
    }
}
