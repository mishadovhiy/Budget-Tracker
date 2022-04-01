//
//  SideBar.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 06.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SideBar: UIView, UITableViewDelegate, UITableViewDataSource {
    
    func getData(){
        let db = DataBase()
        let debts = db.debts.count
        let pro = appData.proVersion || appData.proTrial
        
        var accpuntCell:CellData {
            var accountSegue:String {
                return "toAccount"
            }
            return CellData(name: "Account".localize, value: appData.username == "" ? "Log in".localize : appData.username, segue: accountSegue, image: "person.fill")
        }
        
        let settingsCell = CellData(name: "Settings".localize, value: "", segue: "toSettingsVC", image: "gearshape.fill")
        
        
        let catsCo = UserDefaults.standard.value(forKey: "categoriesDataNew") as? [[String:Any]] ?? []
        
        var categories = [
            CellData(name: "Categories".localize, value: "\(catsCo.count - debts)", segue: "toCategories", image: "folder.fill"),
            CellData(name: "Debts".localize, value: "\(debts)", segue: "toDebts", image: "rectangle.3.group.fill", pro: pro)
        ]
        let localCount = ((UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String:Any]] ?? []) + (UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String:Any]] ?? [])).count
        if localCount > 0 {
            categories.append(CellData(name: "local Data".localize, value: "\(localCount)", segue: "toLocalData", image: "tray.fill"))
        }
        
        let statistic = CellData(name: "Statistic".localize, value: "", segue: "toStatisticVC", image: "chart.pie.fill")
        let trialDays = UserDefaults.standard.value(forKey: "trialToExpireDays") as? Int ?? 0
        let trialCell = CellData(name: "Trail till", value: "\(7 - trialDays)", segue: "toProVC", image: "clock.fill")

        let emptySec = TableData(section: [CellData(name: "", value: "", segue: "", image: "")], title: "", hidden: false)
        
        var accountSection:[CellData] {
            return trialDays == 0 ? [accpuntCell, settingsCell] : [accpuntCell, settingsCell, trialCell]
        }
        
        let upcommingRemiders = CellData(name: "Payment reminders".localize, value: "", segue: "toReminders", image: "", pro: true)
        
        tableData = [
            TableData(section: accountSection, title: "", hidden: false),
            emptySec,
            TableData(section: categories, title: "", hidden: false),
            emptySec,
            TableData(section: [upcommingRemiders], title: "", hidden: false),
            emptySec,
            TableData(section: [statistic], title: "", hidden: false),
        ]
        DispatchQueue.main.async {
            ViewController.shared?.sideTableView.reloadData()
        }
        
    }
    
    var tableData:[TableData] = []

    func toRemindersVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vccc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            ViewController.shared?.navigationController?.pushViewController(vccc, animated: true)
        }
    }
    
    func load() {
        DispatchQueue.main.async {
            ViewController.shared?.sideTableView.delegate = self
            ViewController.shared?.sideTableView.dataSource = self
        }
        getData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableData[indexPath.section].section[indexPath.row].name == "" {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
            let selected = UIView(frame: .zero)
            selected.backgroundColor = .clear
            emptyCell.selectedBackgroundView = selected
            return emptyCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideBardCell", for: indexPath) as! SideBardCell
            cell.nameLabel.superview?.alpha = tableData[indexPath.section].section[indexPath.row].name == "" ? 0 : 1
            cell.nameLabel.text = tableData[indexPath.section].section[indexPath.row].name
            cell.valueLabel.text = tableData[indexPath.section].section[indexPath.row].value
            if (AppDelegate.shared?.symbolsAllowed ?? false) {
                cell.optionIcon.image = AppData.iconNamed(tableData[indexPath.section].section[indexPath.row].image)
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableData[indexPath.section].section[indexPath.row].name != "" {
            let segue = tableData[indexPath.section].section[indexPath.row].segue
            if segue != "" {
                DispatchQueue.main.async {
                    ViewController.shared?.performSegue(withIdentifier: segue, sender: self)
                }
            } else {
                if let action = tableData[indexPath.section].section[indexPath.row].selectAction {
                    action()
                }
            }
        }
        tableView.reloadData()
        
    }
    

    struct TableData {
        let section: [CellData]
        let title: String
        let hidden: Bool
    }
    
    struct CellData {
        let name: String
        let value: String
        let segue: String
        let image: String
        var pro: Bool = true
        var selectAction:(()->())? = nil
        
    }
}

class SideBardCell: UITableViewCell {
    
    @IBOutlet weak var optionIcon: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let selected = UIView(frame: .zero)
        selected.backgroundColor = K.Colors.primaryBacground
        self.selectedBackgroundView = selected

        if !(AppDelegate.shared?.symbolsAllowed ?? false) {
            optionIcon.isHidden = true
        }
    }
}

