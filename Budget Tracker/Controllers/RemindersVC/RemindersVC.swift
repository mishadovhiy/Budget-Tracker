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
    var fromAppDelegate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RemindersVC.shared = self
        loadData()
        title = "Payment reminders ".localize
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    lazy var today = AppDelegate.shared?.appData.filter.getToday() ?? ""
    var editingReminder:Int?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToEditVC":
            Notifications.requestNotifications()
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! TransitionVC
            vc.delegate = self
            vc.paymentReminderAdding = true
            if let row = editingReminder {
                editingReminder = nil
                let data = tableData[row]
                vc.reminder_Repeated = data.repeated
                vc.reminder_Time = data.time
                let normalDate = data.transaction.date.stringToCompIso()
                vc.editingDate = normalDate.toShortString() ?? ""
                vc.editingValue = Double(data.transaction.value) ?? 0.0
                vc.editingCategory = data.transaction.categoryID
                vc.editingComment = data.transaction.comment
                vc.idxHolder = row
            }
        default:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < -100.0) && fromAppDelegate {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                        
                }
            }
        }
    }
}

extension RemindersVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count == 0 ? 1 : tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableData.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoRemindersCell", for: indexPath) as! NoRemindersCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
            cell.row = indexPath.row
            let data = tableData[indexPath.row]
            cell.amountLabel.text = data.transaction.value
            let date = data.time
            cell.dayNumLabel.text = "\(AppData.makeTwo(n: date?.day))"
            cell.dateLabel.text = (date?.stringMonth ?? "") + "\n\(date?.year ?? 0)"
            cell.timeLabel.text = date?.timeString
            cell.expiredLabel.isHidden = !(date?.expired ?? false)
            cell.commentLabel.text = data.transaction.comment
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableData.count == 0 ? tableView.frame.height : UITableView.automaticDimension
    }
    
  /*  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        cell.select()
    }*/
    
}

extension RemindersVC :TransitionVCProtocol {
    
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime: DateComponents?, repeated: Bool?) {
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        addReminder(wasStringID: nil, transaction: new, reminderTime: reminderTime, repeated: repeated)
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct,reminderTime: DateComponents?, repeated: Bool?, idx:Int?) {
        addReminder(wasStringID: idx, transaction: transaction, reminderTime: reminderTime, repeated: repeated)
    }
    
    func quiteTransactionVC(reload: Bool) {

    }
    
    func deletePressed() {

    }
    
    
}



