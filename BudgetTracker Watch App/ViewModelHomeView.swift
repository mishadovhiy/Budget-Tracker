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
    
    init(completion:@escaping()->() = {}) {
        self.loadData(completion: completion)
    }
    
    func loadData(completion:@escaping()->() = {}) {
        DispatchQueue(label: "db", qos: .userInteractive).async { [weak self] in
            guard let username = UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.value(forKey: "username") as? String else {
                DispatchQueue.main.async {
                    self?.error = .init(title: "No username")
                    completion()
                }
                return
            }
            print(username, " rgterfwedw")
            self?.loadCategories(completion: {
                self?.loadTransactions(completion: {
                    completion()
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
