//
//  dbModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 30.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct NetworkModel {
    private static var thread:Bool {
        return Thread.isMainThread
    }
}

extension NetworkModel {
    static func loadCategories() async -> [NewCategories] {
        let response = await NetworkTask.load(urlPath: Keys.dbURL + "NewCategories.php")
        return response.unparceCategories(saveLocally: true) ?? []
    }
    
    static func loadTransactions() async -> [TransactionsStruct] {
        let response = await NetworkTask.load(urlPath: Keys.dbURL + "newTransactions.php")
        return response.unparceTransactions(saveLocally: true) ?? []
    }
    
//    static func loadUsers() async -> [[String]] {
//        
//    }
}

extension NetworkModel {
//    static func saveCategory() async -> ServerError {
//        
//    }
}

