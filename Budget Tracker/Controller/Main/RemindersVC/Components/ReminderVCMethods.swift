//
//  ReminderVCMethods.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension RemindersVC {
    func loadData() {
        AppDelegate.shared?.properties?.notificationManager.loadNotifications { unsees in
            self.loadReminders(unseen: unsees)
        }
    }
    
    
    func addReminder(wasStringID:Int?, transaction:TransactionsStruct, reminderTime: DateComponents?, repeated: Bool?) {
      //  ai?.show { _ in
            if let wasID = wasStringID {
                self.reminders.deleteReminder(id: self.tableData[wasID].id ?? "")
            }
            let newDate = reminderTime?.createDateComp(date: transaction.date, time: reminderTime)
            var newReminder:ReminderStruct = .init(transaction: transaction, dict: transaction.reminder ?? [:])
            newReminder.time = newDate
        newReminder.transaction.date = newDate?.toShortString() ?? ""
            newReminder.id = "paymentReminder" + UUID().uuidString
            newReminder.repeated = repeated
        self.reminders.saveReminder(transaction: newReminder.transaction, newReminder: newReminder) { added in
                self.loadData()
                if !added {
                    DispatchQueue.main.async {
                        self.newMessage?.show(title: "Error creating reminder".localize, type: .error)
                    }
                }
            }
            
    //    }
    }
    
    
    private func loadReminders(unseen:[String]) {
        let data = ReminderManager.reminders
        var result:[ReminderStruct] = []
        for raw in data {
            var new:ReminderStruct = .init(transaction: raw.transaction, dict: raw.dict)
            new.higlightUnseen = (AppDelegate.shared?.properties?.notificationManager.containsUnseen(id: new.id ?? "", unseen: unseen) ?? false)
            print(new, "newnewnewnewnew")
            result.append(new)
            
        }
        let comp = DateComponents()
        tableData = result.sorted{
            Calendar.current.date(from: $0.time ?? comp ) ?? Date.distantFuture >
                    Calendar.current.date(from: $1.time ?? comp ) ?? Date.distantFuture
        }
        DispatchQueue.main.async {
            if self.tableView.delegate == nil {
                self.tableView.delegate = self
                self.tableView.dataSource = self
            }
            self.tableView.reloadData()
            self.ai?.hide()
        }
    }

    
    

    
    private func performAddTransactionToHome(_ reminder: ReminderStruct) {
        self.addNextReminder(reminder: reminder) { added in
            let completion:(Bool) -> () = { _ in
                self.loadData()
                DispatchQueue.main.async {
                    self.newMessage?.show(title: Text.success, description: "Transaction has been added!".localize, type: .succsess)
                }
            }
            HomeVC.shared?.actionAfterAdded = completion
            HomeVC.shared?.addNewTransaction(value: reminder.transaction.value, category: reminder.transaction.categoryID, date: self.today, comment: reminder.transaction.comment, reminderTime: nil, repeated: nil)
        }
    }
    
    func addTransaction(idx:Int) {
        let reminder = tableData[idx]
        ai?.showLoading { 
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performAddTransactionToHome(reminder)
            }
        }
    }
    
    
    
    private func addNextReminder(reminder:ReminderStruct, completion:@escaping(Bool) -> ()) {
        reminders.deleteReminder(id: reminder.id ?? "")
        if !(reminder.repeated ?? false) {
            completion(true)
        } else {
            if let newDate = self.addMonth(reminder) {
                print("add month", newDate)
                var newReminder = reminder
                newReminder.time = newDate
                newReminder.transaction.date = newDate.toIsoString() ?? ""
                newReminder.repeated = true
                reminders.saveReminder(transaction: newReminder.transaction, newReminder: newReminder) { addded in
                    if addded {
                        completion(true)
                    } else {
                        self.ai?.showAlertWithOK(title: "Error adding reminder")
                    }
                }

            }
        }
        
    }
    
    private func addMonth(_ reminder:ReminderStruct) -> DateComponents? {
        let date = reminder.time
        
        let month = (date?.month ?? 0) + 1
        let resultMonth = month >= 13 ? 1 : month
        
        let year = date?.year ?? 0
        let resultYear = month >= 13 ? (year + 1) : year
        
        return DateComponents(year:resultYear, month: resultMonth, day:date?.day, hour: date?.hour, minute: date?.minute, second: date?.second)
    }
    
    
    
    
    func editReminder(idx:Int) {
        editingReminder = idx
        self.performAddReminder()
    }
    
    func deleteReminder(idx:Int) {
        DispatchQueue.main.async {
            let id = self.tableData[idx].id
            self.reminders.deleteReminder(id: id ?? "")
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }
}
