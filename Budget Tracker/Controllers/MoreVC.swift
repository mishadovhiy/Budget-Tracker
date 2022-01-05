//
//  DataOptionsVC.swift
//  TSD HSAGA
//
//  Created by Mikhailo Dovhyi on 08.10.2021.
//

import UIKit

class MoreVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var cellBackground = K.Colors.secondaryBackground2//UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)//darker seconadrybacground
    
    @IBOutlet weak var tableView: UITableView!
    var dataHolder:[ScreenData] = []
    var cellHeightCust: CGFloat = 60
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
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
       
        
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
        var showAI: Bool = true
        var selected: Bool = false
        var pro: Bool = true
        let action: (() -> ())?
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100.0 {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            DispatchQueue.main.async {
                if touch.view != self.tableView {
                    self.dismiss(animated: true) {
                        
                    }
                }
            }
        }
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
            let data = tableData[indexPath.row]
            cell.contentView.backgroundColor = data.selected ? K.Colors.yellow : cellBackground
            cell.titleLabel.text = data.name
            cell.titleLabel.textColor = data.distructive ? .red : K.Colors.category
            cell.descriptionLabel.text = data.description
            cell.titleLabel.font = .systemFont(ofSize: 15, weight: data.distructive ? .semibold : .regular)
            cell.proView.isHidden = data.pro
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
    
    

    var selectedProIndex = 0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    
                }
            }
        } else {
            if indexPath.section == 1 {
                if !tableData[indexPath.row].pro {
                    appData.presentBuyProVC(currentVC: self, selectedProduct: selectedProIndex)
                    tableView.deselectRow(at: indexPath, animated: true)
                } else {
                if let function = tableData[indexPath.row].action {
                    if tableData[indexPath.row].showAI {
                        
                        AppDelegate.shared?.ai.show(completion: { _ in
                            DispatchQueue.main.async {
                                self.dismiss(animated: true) {
                                   // AppDelegate.shared?.ai.fastHide(completionn: { _ in
                                        function()
                                 //   })
                                }
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                function()
                            }
                        }
                        
                    }
                    
                }
            }
        }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //firstCellHeight
        //tableView.frame.height - tableView.contentSize.height
        return indexPath.section == 0 ? firstCellHeight : cellHeightCust
    }
    
    
    
    
}













class DataOptionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var proView: UIView!
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        proView.layer.cornerRadius = 6
    }
}
