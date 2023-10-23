//
//  SelectUserVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 09.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SelectValueVC: SuperViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak static var shared:SelectValueVC?
    var users:[String] = []
    var delegate: SelectUserVCDelegate?
    var titleText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SelectValueVC.shared = self
        AppDelegate.shared!.ai.fastHide()
        title = titleText
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    var selectedIdxAction:((Int) -> ())?
    
    
    
    public func presentScreen(in nav:UINavigationController, with data: [String], title:String, selected:@escaping (Int) -> ()) {

        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SelectUserVC") as! SelectValueVC
            vc.users = data
            vc.selectedIdxAction = selected
            vc.titleText = title
            nav.pushViewController(vc, animated: true)
        }

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
            
            if let delegate = self.delegate {
                delegate.selected(user: self.users[indexPath.row])
            } else {
                if let selectedIdx = self.selectedIdxAction {
                    selectedIdx(indexPath.row)
                }
            }
            
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
