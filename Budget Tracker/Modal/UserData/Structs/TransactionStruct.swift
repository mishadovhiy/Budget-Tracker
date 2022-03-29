//
//  TransactionStruct.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


struct TransactionsStruct {
    let value: String
    var categoryID: String
    var date: String
    let comment: String
    
    var reminder:[String:Any]? = nil
    
    func compToIso(dateStringOp:String? = nil) -> DateComponents?  {
        let date = dateStringOp ?? self.date
      //  if let dateString = date {
            let dateCo = DateComponents()
            return date == "" ? nil : dateCo.stringToCompIso(s: date)
    //    } else {
      //      return nil
       // }
        
    }
    
    
    
    var category:NewCategories {
        let db = DataBase()
        return db.category(categoryID) ?? NewCategories(id: -1, name: "Unknown", icon: "", color: "", purpose: .expense)
    }
}
