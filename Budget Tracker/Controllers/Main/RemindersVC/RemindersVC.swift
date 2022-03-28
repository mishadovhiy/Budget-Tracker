//
//  RemindersVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class RemindersVC: UIViewController {

    var tableData:[RemindersData] = []
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadData() {
        let db = DataBase()
        let data = db.paymentReminders()
        var result:[RemindersData] = []
        for raw in data {
            let reminder = raw.reminder
        }
        //tableData = data
    }

    
    func dictToReminder(dict:[String:Any], transaction:TransactionsStruct) -> RemindersData? {
        if let reminderDict = dict["Reminder"] as? [String:Any],
           let time = reminderDict["sd"],
           let transactionAdded = reminderDict["sd"],
           let repeated = reminderDict["sd"]
        {
            
            return .init(transaction: transaction, time: <#T##DateComponents#>, transactionAdded: <#T##Bool#>, repidedMonth: <#T##Int?#>)
        } else {
            return nil
        }
        
    }
    
}

extension RemindersVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        return cell
    }
    
    
}



extension RemindersVC {
    struct RemindersData {
        let transaction: TransactionsStruct
        let time:DateComponents
        var transactionAdded = false
        
        /**
         -nil - notif not repeated
         - sets added month number (if now is for, and val - 3 -- not setted)
         */
        let repidedMonth:Int?
        /**
         -expired and repidedMonth != current month number
         */
        let higlightUnseen:Bool = false
        var selected = false
        
    }
}
