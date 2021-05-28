//
//  expectingPaymentsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 09.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class expectingPaymentsVC: SuperViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    //cat
    //amount - could be empty
    //comment
    //dueDate
    
    
    //transactionsReminders
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        center.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }

}

extension expectingPaymentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expectingPaymentsCell", for: indexPath) as! expectingPaymentsCell
        cell.cellBackground.layer.cornerRadius = 6
        return cell
    }
    
    //footer - add button
    
    
}

class expectingPaymentsCell: UITableViewCell {

    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}
