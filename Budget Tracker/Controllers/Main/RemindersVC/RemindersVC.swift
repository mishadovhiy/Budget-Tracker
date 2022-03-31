//
//  RemindersVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class RemindersVC: SuperViewController {

    var tableData:[ReminderStruct] = []
    @IBOutlet weak var tableView: UITableView!
    static var shared:RemindersVC?
    lazy var reminders = ReminderManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RemindersVC.shared = self
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        title = "Payment reminders".localize
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    lazy var today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
    var editingReminder:Int?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToEditVC":
            DispatchQueue.main.async {
                AppDelegate.shared?.center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                    if !granted {
                        self.ai.showAlertWithOK(title: "Notifications not permitted", text: "Allow to use user notifications for this app", error: true, okTitle:"Go to settings") { _ in
                            
                        }
                    }
                }
            }
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
        cell.unseenIndicator.isHidden = !data.higlightUnseen
        cell.repeatedIndicator.isHidden = !(data.repeated ?? false)
        cell.editAction = editReminder(idx:)
        cell.deleteAction = deleteReminder(idx:)
        cell.addTransactionAction = addTransaction(idx:)
        return cell
    }
    
    
}

extension RemindersVC :TransitionVCProtocol {
    
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime: DateComponents?, repeated: Bool?) {
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        addReminder(was: nil, transaction: new, reminderTime: reminderTime, repeated: repeated)
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct,reminderTime: DateComponents?, repeated: Bool?) {
        addReminder(was: was, transaction: transaction, reminderTime: reminderTime, repeated: repeated)
    }
    
    func quiteTransactionVC(reload: Bool) {

    }
    
    func deletePressed() {

    }
    
    
}



