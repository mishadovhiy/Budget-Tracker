//
//  ViewModelHomeView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 02.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import Foundation

class ViewModelHomeView {
    
    var transactions:[TransactionsStruct] = []
    var categories:[NewCategories] = []
    
    var error:MessageContent? = nil
    lazy var connectivity:WatchConectivityService = .init(messageReceived: messageReceived(_:))
    
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
        self.loadData(completion: completion)
    }
    
    func loadData(completion:@escaping()->() = {}) {
        DispatchQueue(label: "db", qos: .userInteractive).async { [weak self] in
            self?.loadCategories(completion: {
                self?.loadTransactions(completion: {
                    completion()
                    if AppDelegate.properties?.db.username == "" {
                        DispatchQueue.main.async {
                            self?.connectivity.askUsername()
                        }
                    }
                    print("transactionswerer: ", self?.transactions)
                    print("categoriesadsads: ", self?.categories)
                })
            })
        }
        
    }
    private let network = LoadFromDB()
    func loadTransactions(completion:(()->())? = nil) {
        network.newTransactions { list, error in
            if list.isEmpty || error != .none {
                self.error = error.message
            } else {
                self.transactions = list
                completion?()
            }
        }
    }
    
    func loadCategories(completion:(()->())? = nil) {
        network.newCategories { list, error in
            if list.isEmpty || error != .none {
                self.error = error.message
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
