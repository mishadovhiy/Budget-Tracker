//
//  dbModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 30.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif
import Foundation
struct NetworkModel {
    private static var thread:Bool {
        return Thread.isMainThread
    }
}

extension NetworkModel {
    @available(iOS 13.0, *)
    static func loadCategories(showError:Bool = false) async -> [NewCategories] {
        let response = await NetworkTask.load(urlPath: Keys.dbURL + "NewCategories.php")
        return response.unparseCategories(saveLocally: true) ?? []
    }
    
    @available(iOS 13.0, *)
    static func loadTransactions() async -> [TransactionsStruct] {
        let response = await NetworkTask.load(urlPath: Keys.dbURL + "newTransactions.php")
        return response.unparseTransactions(saveLocally: true) ?? []
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

