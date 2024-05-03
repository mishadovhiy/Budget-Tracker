//
//  ViewModelHomeView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 02.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI
import Foundation

@available(watchOS 10.0, *)
class ViewModelHomeView:ObservableObject {
    
    private let transactionManager = TransactionsManager.init()
    var calculations = Calculations.init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
    
    private var allApiTransactions:[TransactionsStruct] = [] {
        didSet {
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
            self.transactions = new
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
                DispatchQueue.main.async {
                    self.allApiTransactions = list
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
}
