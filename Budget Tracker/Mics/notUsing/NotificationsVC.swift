//
//  NotificationsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 23.06.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class NotificationsVC: SuperViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableData: [String] = []
    
    let center = AppDelegate.shared!.center
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        self.title = "Notification center".localize
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       /* center.getDeliveredNotifications { (requests) in
            var res:[String] = []
            for i in 0..<requests.count {
                
                let text = requests[i].request.identifier + "\n" + requests[i].request.content.title + "\n" + requests[i].request.content.subtitle + "\n" + requests[i].request.content.body
                res.append(text + "\n" + requests[i].request.content.categoryIdentifier + "\n" + String(describing: requests[i].request.trigger))
            }
            self.tableData = res
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }*/
       /* center.getPendingNotificationRequests { (requests) in
            
            var res:[String] = []
            for i in 0..<requests.count {
                
                let text = requests[i].identifier + "\n" + requests[i].content.title + "\n" + requests[i].content.subtitle + "\n" + requests[i].content.body
                res.append(text + "\n" + requests[i].content.categoryIdentifier + "\n" + String(describing: requests[i].trigger))
            }
            self.tableData = res
            DispatchQueue.main.async {
              //  self.title = "Notification center"
                self.tableView.reloadData()
            }
        }*/
        
        center.getDeliveredNotifications { delivered in
            var res:[String] = []
            for i in 0..<delivered.count {
                let text = delivered[i].request.identifier + "\n" + delivered[i].request.content.title + "\n" + delivered[i].request.content.subtitle + "\n" + delivered[i].request.content.body
                res.append(text + "\n" + delivered[i].request.content.categoryIdentifier + "\n" + String(describing: delivered[i].request.trigger))
            }
            self.tableData = res
            DispatchQueue.main.async {
              //  self.title = "Notification center"
                self.tableView.reloadData()
            }
        }
    }
    

}

extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsVCCell", for: indexPath) as! NotificationsVCCell
        
        cell.mainLabel.text = tableData[indexPath.row]
        
        return cell
    }
    
    
}

class NotificationsVCCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    
}
