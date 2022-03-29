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
    lazy var db:DataBase = DataBase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RemindersVC.shared = self
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        title = "Payment reminders".localize
    }
    
    func loadData() {
        let db = DataBase()
        let data = db.paymentReminders()
        var result:[RemindersData] = []
        for raw in data {
            if let reminder = raw.reminder {
                let new:RemindersData = .init(transaction: raw, dict: reminder)
                result.append(new)
            }
            
        }
        let comp = DateComponents()
        tableData = result.sorted{
            Calendar.current.date(from: $0.time ?? comp ) ?? Date.distantFuture >
                    Calendar.current.date(from: $1.time ?? comp ) ?? Date.distantFuture
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToEditVC":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! TransitionVC
            vc.delegate = self
            vc.paymentReminderAdding = true
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
            let completion:(Bool) -> () = { _ in
                self.ai.fastHide { _ in
                    self.loadData()
                }
                self.newMessage.show(title: Text.success, description: "Transaction has been added!".localize, type: .succsess)
            }
            ViewController.shared?.actionAfterAdded = completion
            ViewController.shared?.addNewTransaction(value: reminder.transaction.value, category: reminder.transaction.categoryID, date: reminder.transaction.date, comment: reminder.transaction.comment, reminderTime: nil, repeated: nil)
        }
    }
    
    private var editingReminder:Int?
    
    func editReminder(idx:Int) {
        editingReminder = idx
    }
    
    func deleteReminder(idx:Int) {
        DispatchQueue.main.async {
            let id = self.tableData[idx].id
            self.db.deleteReminder(id: id)
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
        cell.commentLabel.text = data.transaction.comment
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
            reminder.time = reminderTime
            reminder.id = "paymentReminder" + UUID().uuidString
            reminder.repeatedMonths = nil
            self.db.saveReminder(transaction: new, newReminder: reminder) { added in
                self.ai.fastHide { _ in
                    
                }
                if !added {
                    self.newMessage.show(title: "Error creating reminder".localize, description: "Try again".localize, type: .error)
                } else {
                    self.loadData()
                }
            }
        }
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct,reminderTime: DateComponents?, repeated: Bool?) {
        ai.show { _ in
            let wasID:RemindersData = .init(transaction: was, dict: was.reminder ?? [:])
            self.db.deleteReminder(id: wasID.id)
            var newReminder:RemindersData = .init(transaction: transaction, dict: transaction.reminder ?? [:])
            newReminder.time = reminderTime
            newReminder.id = "paymentReminder" + UUID().uuidString
            newReminder.repeatedMonths = nil
            self.db.saveReminder(transaction: transaction, newReminder: newReminder) { added in
                self.loadData()
                self.ai.fastHide { _ in
                    if !added {
                        self.newMessage.show(title: "Error creating reminder".localize, type: .error)
                    }
                }
            }
            
        }
        
    }
    
    func quiteTransactionVC(reload: Bool) {
        
    }
    
    func deletePressed() {
        if let editing = editingReminder {
            editingReminder = nil
            deleteReminder(idx: editing)
        }
    }
    
    
}



