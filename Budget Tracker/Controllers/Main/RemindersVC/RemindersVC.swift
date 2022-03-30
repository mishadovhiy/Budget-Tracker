//
//  RemindersVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class RemindersVC: SuperViewController {

    var tableData:[RemindersData] = []
    @IBOutlet weak var tableView: UITableView!
    static var shared:RemindersVC?
    lazy var reminders = Reminders()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RemindersVC.shared = self
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        title = "Payment reminders".localize
    }
    
    
    func loadData() {
        
        AppDelegate.shared?.notificationManager.loadNotifications { unsees in
            self.loadReminders(unseen: unsees)
        }
        
    }
    
    private func loadReminders(unseen:[String]) {
        let data = reminders.reminders
        var result:[RemindersData] = []
        for raw in data {
            var new:RemindersData = .init(transaction: raw.transaction, dict: raw.dict)
            new.higlightUnseen = (AppDelegate.shared?.notificationManager.containsUnseen(id: new.id ?? "", unseen: unseen) ?? false)
            print(new, "newnewnewnewnew")
            result.append(new)
            
        }
        let comp = DateComponents()
        tableData = result.sorted{
            Calendar.current.date(from: $0.time ?? comp ) ?? Date.distantFuture >
                    Calendar.current.date(from: $1.time ?? comp ) ?? Date.distantFuture
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.ai.fastHide { _ in
                
            }
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToEditVC":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! TransitionVC
            vc.delegate = self
            vc.paymentReminderAdding = true
            if let row = editingReminder {
                editingReminder = nil
                let data = tableData[row]
                vc.reminder_Repeated = data.repeated
                vc.reminder_Time = data.time
                vc.editingDate = data.transaction.date
                vc.editingValue = Double(data.transaction.value) ?? 0.0
                vc.editingCategory = data.transaction.categoryID
                vc.editingComment = data.transaction.comment
            }
        default:
            break
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func addTransaction(idx:Int) {
        let reminder = tableData[idx]
        ai.show { _ in
            self.addNextReminder(reminder: reminder) { added in
                let completion:(Bool) -> () = { _ in
                    self.loadData()
                    self.newMessage.show(title: Text.success, description: "Transaction has been added!".localize, type: .succsess)
                }
                ViewController.shared?.actionAfterAdded = completion
                ViewController.shared?.addNewTransaction(value: reminder.transaction.value, category: reminder.transaction.categoryID, date: self.today, comment: reminder.transaction.comment, reminderTime: nil, repeated: nil)
            }
        }
    }
    
    lazy var today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
    
    private func addNextReminder(reminder:RemindersData, completion:@escaping(Bool) -> ()) {
        reminders.deleteReminder(id: reminder.id ?? "")
        if !(reminder.repeated ?? false) {
            completion(true)
        } else {
            if let newDate = self.addMonth(reminder) {
                print("add month", newDate)
                var newReminder = reminder
                newReminder.time = newDate
                newReminder.repeated = true
                reminders.saveReminder(transaction: newReminder.transaction, newReminder: newReminder) { addded in
                    if addded {
                        completion(true)
                    } else {
                        self.ai.showAlert(title: "Error adding reminder", error: true)
                    }
                }

            }
        }
        
    }
    
    private func addMonth(_ reminder:RemindersData) -> DateComponents? {
        var date = reminder.time
        var newMonth = (date?.month ?? 0) + 1
        if newMonth >= 13 {
            newMonth = 1
            let newYear = (date?.year ?? 0) + 1
            date?.year = newYear
        }
        date?.month = newMonth
        return date
    }
    
    
    private var editingReminder:Int?
    
    func editReminder(idx:Int) {
        editingReminder = idx
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToEditVC", sender: self)
        }
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

extension RemindersVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        cell.row = indexPath.row
        let data = tableData[indexPath.row]
        cell.amountLabel.text = data.transaction.value
        let date = data.time
        cell.dayNumLabel.text = "\(AppData.makeTwo(n: date?.day))"
        cell.dateLabel.text = (date?.stringMonth ?? "") + "\n\(date?.year ?? 0)"
        cell.timeLabel.text = date?.stringTime
        cell.expiredLabel.isHidden = !(date?.expired ?? false)
        cell.commentLabel.text = data.transaction.comment + "//\((data.repeated ?? false) ? "1" : "0")"
        cell.categoryLabel.text = data.transaction.category.name
        cell.actionsView.isHidden = !data.selected
        cell.editAction = editReminder(idx:)
        cell.deleteAction = deleteReminder(idx:)
        cell.addTransactionAction = addTransaction(idx:)
        return cell
    }
    
    
}

extension RemindersVC :TransitionVCProtocol {
    
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime: DateComponents?, repeated: Bool?) {
        ai.show { _ in
            let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
            var reminder:RemindersData = .init(transaction: new, dict: [:])
            reminder.time = reminderTime?.createDateComp(date: new.date, time: reminderTime)
            reminder.id = "paymentReminder" + UUID().uuidString
            reminder.repeated = repeated
            self.reminders.saveReminder(transaction: new, newReminder: reminder) { added in
                self.loadData()
                if !added {
                    self.newMessage.show(title: "Error creating reminder".localize, description: "Try again".localize, type: .error)
                }
            }
        }
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct,reminderTime: DateComponents?, repeated: Bool?) {
        ai.show { _ in
            let wasID:RemindersData = .init(transaction: was, dict: was.reminder ?? [:])
            self.reminders.deleteReminder(id: wasID.id ?? "")
            var newReminder:RemindersData = .init(transaction: transaction, dict: transaction.reminder ?? [:])
            newReminder.time = reminderTime?.createDateComp(date: transaction.date, time: reminderTime)
            newReminder.id = "paymentReminder" + UUID().uuidString
            newReminder.repeated = repeated
            //newReminder.time?.createDateComp(date: transaction.date, time: newReminder.time) {
            self.reminders.saveReminder(transaction: transaction, newReminder: newReminder) { added in
                self.loadData()
                if !added {
                    self.newMessage.show(title: "Error creating reminder".localize, type: .error)
                }
            }
            
        }
        
    }
    
    func quiteTransactionVC(reload: Bool) {

    }
    
    func deletePressed() {

    }
    
    
}



