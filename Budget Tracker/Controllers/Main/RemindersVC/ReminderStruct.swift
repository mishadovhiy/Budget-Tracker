//
//  RemindersData.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

struct ReminderStruct {
    var transaction: TransactionsStruct

    var dict:[String:Any]
    
    
    var id:String? {
        get {
            let dicts = dict["Reminder"] as? [String:Any] ?? dict
            let timeStr = dicts["id"] as? String ?? ""
            return timeStr
        }
        set {
            if let val = newValue {
                dict.updateValue(val, forKey: "id")
            }
        }
    }
    
    
    var time:DateComponents? {
        get {
            let dicts = dict["Reminder"] as? [String:Any] ?? dict
            let timeStr = dicts["time"] as? String
            let time = transaction.compToIso(dateStringOp: timeStr)
            var day =  transaction.compToIso(dateStringOp: transaction.date)
            day?.hour = time?.hour
            day?.minute = time?.minute
            day?.second = time?.second
            return day
        }
        set {
            if let strTime = newValue?.toIsoString() {
                dict.updateValue(strTime, forKey: "time")
            }
        }
    }
    
    //cur month == repeatedMonths check if expired
    var repeated:Bool? {
        get {
            let dicts = dict["Reminder"] as? [String:Any] ?? dict
            let val = dicts["repeated"] as? String
            print(val, "valvalvalvalvalval")
            print(dicts, "dictdictdictdict")
            return val ?? "" == "1" ? true : false
        }
        set {
            let str = (newValue ?? false) ? "1" : "0"
            dict.updateValue(str, forKey: "repeated")
           
        }
    }

    //repreateOptions
    
    
    
    /**
     -expired and repidedMonth != current month number
     */
    ///containsInUnseen
    var higlightUnseen:Bool = false
    var selected = false
    
}
