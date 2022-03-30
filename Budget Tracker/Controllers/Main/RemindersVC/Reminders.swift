//
//  Reminders.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class Reminders {
    private let db = DataBase()
    
    
    var reminders:[RemindersData] {
        get {
            let data = UserDefaults.standard.value(forKey: "PaymentReminder") as? [[String:Any]] ?? []
            var result:[RemindersData] = []
            for item in data {
                
                if let transaction = self.db.transactionFrom(item) {
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
                let new = self.db.transactionToDict(val.transaction)
                result.append(new)
            }
            UserDefaults.standard.setValue(result, forKey: "PaymentReminder")
        }
    }

    
    func deleteReminder(id:String) {
        DispatchQueue.main.async {
            AppDelegate.shared?.center.removePendingNotificationRequests(withIdentifiers: [id])
        }
        let data = Array(self.reminders)
        var result:[RemindersData] = []
        for i in 0..<data.count {
            if data[i].id != id {
                result.append(data[i])
            }
            
         }
        self.reminders = result
    }
    
    func saveReminder(transaction:TransactionsStruct, newReminder:RemindersData, completionn: @escaping (Bool) -> ()) {
        let notifications = Notifications()
        let body = transaction.value + " " + "for category".localize + ": " + transaction.category.name
        if let date = newReminder.time{//newReminder.time?.createDateComp(date: transaction.date, time: newReminder.time) {
            if date.expired {
                completionn(false)
            } else {
                if let id = newReminder.id {
                    notifications.addLocalNotification(date: date, title: "Payment reminder", id: id, body: body) { added in
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
