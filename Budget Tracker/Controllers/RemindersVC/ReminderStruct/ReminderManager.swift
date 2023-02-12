//
//  Reminders.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class ReminderManager {
    private let db = DataBase()
    
    
    var reminders:[ReminderStruct] {
        get {
            let data = db.db["PaymentReminder"] as? [[String:Any]] ?? []
            var result:[ReminderStruct] = []
            for item in data {
                
                if let transaction:TransactionsStruct = .create(dictt: item) {
                    result.append(.init(transaction: transaction, dict: item))
                }
                
            }
            print(data, " paymentReminders")
            print(result, " resultresultresult")
            return result
        }
        set {
            var result:[[String:Any]] = []
            for val in newValue {
                result.append(val.transaction.dict)
            }
            db.db.updateValue(result, forKey: "PaymentReminder")
        }
    }

    
    func deleteReminder(id:String) {
        DispatchQueue.main.async {
            AppDelegate.shared?.center.removePendingNotificationRequests(withIdentifiers: [id])
        }
        let data = Array(self.reminders)
        var result:[ReminderStruct] = []
        var found = false
        for i in 0..<data.count {
            if data[i].id != id || found {
                result.append(data[i])
            } else {
                if data[i].id == id {
                    found = true
                }
            }
            
         }
        self.reminders = result
    }
    
    func saveReminder(transaction:TransactionsStruct, newReminder:ReminderStruct, completionn: @escaping (Bool) -> ()) {
        let notifications = Notifications()
        let title = "Payment reminder".localize + "\n" + "For category".localize + ": " + transaction.category.name
        let body = "Amount".localize + ": " + transaction.value

        if let date = newReminder.time {
            if date.expired {
                completionn(false)
            } else {
                if let id = newReminder.id {
                    notifications.addLocalNotification(date: date, title: title, id: id, body: body) { added in
                        if added {
                            var newTransaction = transaction
                            newTransaction.reminder = newReminder.dict
                            self.reminders.append(.init(transaction: newTransaction, dict: newReminder.dict))
                            completionn(true)
                        } else {
                            completionn(false)
                        }
                    }
                } else {
                    completionn(false)
                }
                
            }
            
        } else {
            completionn(false)
        }
        
    }
}
