//
//  RemindersData.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


extension RemindersVC {
    
    struct RemindersData {
        let transaction: TransactionsStruct

        var dict:[String:Any]
        
        
        var id:String {
            get {
                let timeStr = dict["id"] as? String ?? ""
                return timeStr
            }
            set {
                dict.updateValue(newValue, forKey: "id")
                
            }
        }
        
        
        var time:DateComponents? {
            get {
                let timeStr = dict["time"] as? String
                let time = transaction.compToIso(dateStringOp: timeStr)
                return time
            }
            set {
                if let strTime = newValue?.toIsoString() {
                    dict.updateValue(strTime, forKey: "time")
                }
                
            }
        }
        
        var repeatedMonths:String? {
            get {
                return dict["addedMonthNumber"] as? String
            }
            set {
                if let val = newValue {
                    dict.updateValue(val, forKey: "addedMonthNumber")
                }
               
            }
        }

        /**
         -expired and repidedMonth != current month number
         */
        var higlightUnseen:Bool = false
        var selected = false
        
        
    }
}
