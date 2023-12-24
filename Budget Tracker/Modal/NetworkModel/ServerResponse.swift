//
//  ServerResponce.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

enum ServerError {
    case internet
    case other
    case none
}

class ServerResponse {
    let error:ServerError?
    
    init(error: ServerError?) {
        self.error = error
    }

    class ArrayType:ServerResponse {
        let array:NSArray?
        
        init(_ array: NSArray, error:ServerError? = nil) {
            self.array = array
            super.init(error: error)
        }
        override init(error: ServerError?) {
            self.array = nil
            super.init(error: error)
        }
    }
    
    class OkType:ServerResponse {
        let ok:Bool?
        
        init(_ array: Bool, error:ServerError? = nil) {
            self.ok = array
            super.init(error: error)
        }
        override init(error: ServerError?) {
            self.ok = nil
            super.init(error: error)
        }
    }
    
    private var requestArray: NSArray? {
        if self.error != nil {
            print("grfdsff")
            return nil
        }
        guard let response = self as? ServerResponse.ArrayType,
              let array = response.array
        else {
            print("grfdsff")
            return nil
        }
        return array
    }
    
    fileprivate var appData:AppProperties? {
        return AppDelegate.shared?.properties
    }
}


extension ServerResponse {
    enum RequestType:String {
        case loadTransaction, loadCategories
        
        var id:UUID {
            return .init()
        }
    }
    
    private func unparceRequest(_ type:RequestType, username:String? = nil, save:Bool) -> [[String : Any]]? {
        guard let requestArray else {
            return nil
        }
        let user = username ?? appData?.db.username
        var loadedData: [[String : Any]] = []
        requestArray.forEach({
            if let dict = $0 as? NSDictionary,
               user == (dict["Nickname"] as? String ?? ""),
               let dictionary = dict as? [String : Any]
            {
                loadedData.append(dictionary)
            }
        })
        let isSelf = user == (appData?.db.username ?? "")
        if isSelf && save {
            switch type {
            case .loadTransaction:
                appData?.db.transactions = loadedData.compactMap({.create(dictt: $0)})
            case .loadCategories:
                appData?.db.categories = loadedData.compactMap({.create(dict: $0)})
            }
        }
        if loadedData.count == 0 && isSelf {
            return nil
        }
        return loadedData
    }
    
    func unparseTransactions(username:String? = nil, saveLocally:Bool) -> [TransactionsStruct]? {
        guard let results = unparceRequest(.loadTransaction, username: username, save: saveLocally) else {
            return appData?.db.transactions
        }
        return results.compactMap({.create(dictt: $0)})
    }
    
    func unparseCategories(username:String? = nil, saveLocally:Bool) -> [NewCategories]? {
        guard let results = unparceRequest(.loadCategories, username: username, save: saveLocally) else {
            return saveLocally ? appData?.db.categories : nil
        }
        return results.compactMap({.create(dict: $0)})
    }
}
