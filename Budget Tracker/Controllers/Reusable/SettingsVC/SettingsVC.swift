//
//  SettingsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 10.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SettingsVC: SuperViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableData:[TableData]  = []
    var additionalData:[TableData]?

    func loadData() {
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let dataModel = AppSettingsData(vc: self, data: self.additionalData)
            self.tableData = dataModel.getData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.shadows()
        tableView.contentInset.top = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        title = "Settings".localize
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toColors":
            let vc = segue.destination as! IconsVC
            vc.delegate = self
            vc.selectedColorName = AppData.linkColor
            vc.screenType = .colorsOnly
        default:
            break
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func toEnterValue(data:EnterValueVC.EnterValueVCScreenData?) {
        if let data = data {
            DispatchQueue.main.async {
                if let nav = self.navigationController {
                    EnterValueVC.shared.presentScreen(in: nav, with: data, defaultValue:nil)
                    
                }
            }
        } else {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(self, animated: true)
            }
        }
    }
    
    
    func toChooseIn(data:[String], title:String, selectedAction:@escaping(Int) -> ()) {
        if let nav = self.navigationController {
            SelectValueVC.shared.presentScreen(in: nav, with: data, title: title, selected: selectedAction)
        }
        
    }
    
}


extension SettingsVC: IconsVCDelegate {
    func categorySelected(_ category: NewCategories) {
        
    }
    
    func selected(img: String, color: String) {
        DispatchQueue(label: "db", qos: .userInitiated).async {
            AppData.linkColor = color
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.loadData()
            }
        }
    }
    
    
}




extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let triggerData = tableData[indexPath.section].cells[indexPath.row] as? TriggerCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TriggerSettingsCell", for: indexPath) as! TriggerSettingsCell
            cell.nameLabel.text = triggerData.title
            cell.switchedAction = triggerData.action
            cell.valueSwitcher.isOn = triggerData.isOn
            cell.proView.isHidden = triggerData.pro == nil
            cell.valueSwitcher.isHidden = !(triggerData.pro == nil)
            return cell
        } else {
            if let standartData = tableData[indexPath.section].cells[indexPath.row] as? StandartCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StandartSettingsCell", for: indexPath) as! StandartSettingsCell
                cell.nameLabel.text = standartData.title + (standartData.description == "" ? "" : (": " + standartData.description))
                cell.colorView.isHidden = standartData.colorNamed == "" ? true : (standartData.pro == nil ? false : true)
                if standartData.colorNamed != "" {
                    cell.colorView.backgroundColor = AppData.colorNamed(standartData.colorNamed)
                }
                cell.accessoryType = standartData.showIndicator ? (standartData.pro == nil ? .disclosureIndicator : .none): .none
                cell.proView.isHidden = standartData.pro == nil
                return cell
            } else {
                return UITableViewCell()
            }
        }
        

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let standartData = tableData[indexPath.section].cells[indexPath.row] as? StandartCell {
            if let proID = standartData.pro {
                AppDelegate.shared?.appData.presentBuyProVC(selectedProduct: proID)
            } else {
                standartData.action()
            }
        } else {
            if let trigger = tableData[indexPath.section].cells[indexPath.row] as? TriggerCell {
                if let proID = trigger.pro {
                    AppDelegate.shared?.appData.presentBuyProVC(selectedProduct: proID)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension SettingsVC {
    struct TableData {
        let sectionTitle:String
        let cells: [Any]
    }

    struct StandartCell {
        let title: String
        var description:String = ""
        var colorNamed:String = ""
        var showIndicator:Bool = true
        var pro:Int? = nil
        let action: () -> ()
    }
    
    struct TriggerCell {
        let title: String
        let isOn: Bool
        var pro:Int? = nil
        let action: (Bool) -> ()
    }
}










class StandartSettingsCell: UITableViewCell {
    
    @IBOutlet weak var proView: BasicView!
    @IBOutlet weak var colorView: BasicView!
    @IBOutlet weak var nameLabel: UILabel!
}

class TriggerSettingsCell: UITableViewCell {
    
    var switchedAction:((Bool) -> ())?
    
    @IBOutlet weak var proView: BasicView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBAction func switchChanged(_ sender: UISwitch) {
        if let isON = switchedAction {
            DispatchQueue.main.async {
                isON(sender.isOn)
            }
        }
    }
    @IBOutlet weak var valueSwitcher: UISwitch!
}


extension SettingsVC {
    static func configure(additionalData:[TableData]? = nil) -> SettingsVC {
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        vc.additionalData = additionalData
        return vc
    }
}
