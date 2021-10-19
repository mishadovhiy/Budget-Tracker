//
//  DataOptionsVC.swift
//  TSD HSAGA
//
//  Created by Mikhailo Dovhyi on 08.10.2021.
//

import UIKit

class MoreVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var dismissOnAction = false
    var dataHolder:[ScreenData] = []
    
    var firstLaunch = true
    var firstCellHeight:CGFloat = 0
    var tableData:[ScreenData] {
        set {
            dataHolder = newValue
            
            DispatchQueue.main.async {
                if self.tableView != nil {
                    self.tableView.reloadData()
                }
            }
        }
        get {
            return dataHolder
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
       // loadData()
        
        let contentHeight = (tableData.count + 1) * 65
        let safeAt = self.view.safeAreaInsets.top
        let safebt = self.view.safeAreaInsets.bottom
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
        let tableInButtom = (self.view.frame.height - (safeAt + safebt + 150)) - CGFloat(contentHeight)
        print(tableInButtom, "hjkhjk")
        firstCellHeight = CGFloat(contentHeight) > self.view.frame.height / 2 ? self.view.frame.height / 2 : tableInButtom
        
    }

    func loadData() {
        tableData = dataHolder
      /*  let logoutAction = {
            DispatchQueue.main.async {
                
            }
        }
        
        tableData = [
            ScreenData(name: "Log out", description: "", distructive: true, action: logoutAction)
        ]*/
        
    }
    
    
    struct ScreenData {
        let name:String
        let description: String
        var distructive: Bool = false
        var showTF:Bool = false
        let action: (() -> ())?
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section != 0 ? tableData.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataOptionCell", for: indexPath) as! DataOptionCell
            cell.titleLabel.text = tableData[indexPath.row].name
            cell.titleLabel.textColor = tableData[indexPath.row].distructive ? .red : .black
            cell.descriptionLabel.text = tableData[indexPath.row].description
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = UITableViewCell()
                cell.contentView.backgroundColor = .clear
                cell.backgroundView = nil
                cell.backgroundColor = .clear
                //cell.selectedBackgroundView = nil
                cell.selectionStyle = .none
                return cell
            } else {
                return UITableViewCell()
            }
        }
    
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    
                }
            }
        } else {
            if indexPath.section == 1 {
                if let function = tableData[indexPath.row].action {
                    if dismissOnAction {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                function()
                            }
                        }
                    } else {
                        function()
                    }
                    
                }
            }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //firstCellHeight
        //tableView.frame.height - tableView.contentSize.height
        return indexPath.section == 0 ? firstCellHeight : UITableView.automaticDimension
    }
    
}















class DataOptionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
}
