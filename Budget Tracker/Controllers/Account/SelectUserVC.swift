//
//  SelectUserVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 09.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SelectUserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    

    var users:[String] = []
    var delegate: SelectUserVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.shared?.ai.fastHide { _ in
            
        }
        title = "Select user"
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUserVCCell", for: indexPath) as! SelectUserVCCell
        cell.mainTitleLabel.text = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.delegate?.selected(user: self.users[indexPath.row])
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true) {
                    
                }
            }
        }
    }

}

class SelectUserVCCell: UITableViewCell {
    @IBOutlet weak var mainTitleLabel: UILabel!
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let selected = UIView(frame: .zero)
        selected.backgroundColor = K.Colors.primaryBacground
        self.selectedBackgroundView = selected
    }
}



protocol SelectUserVCDelegate {
    func selected(user: String)
}
