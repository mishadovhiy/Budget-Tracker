//
//  SideBar.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 06.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SideBar: UIView, UITableViewDelegate, UITableViewDataSource {
    //toSettingsVC
    var tableData:[TableData] {
        let db = DataBase()
        let debts = db.debts.count
        let pro = appData.proVersion || appData.proTrial
        
        
        
        
        var accpuntCell:CellData {
            var accountSegue:String {
                let dataCount = (UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String]] ?? []).count + (UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String]] ?? []).count + (UserDefaults.standard.value(forKey: K.Keys.localDebts) as? [[String]] ?? []).count
                return "toAccount"//dataCount > 0 ? "toSavedData" : "toAccount"
            }
            return CellData(name: "Account", value: appData.username == "" ? "Log in" : appData.username, segue: accountSegue, image: "person.fill")
        }
        
        var settingsCell = CellData(name: "Settings", value: "", segue: "toSettingsVC", image: "gearshape.2.fill")
        
        
        
        
        var categories = [
            CellData(name: "Categories", value: "\(db.categories.count - debts)", segue: "toCategories", image: ""),
            CellData(name: "Debts", value: "\(debts)", segue: pro ? "toDebts" : "toProVC", image: "", pro: pro)
        ]
        let localCount = ((UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String:Any]] ?? []) + (UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String:Any]] ?? [])).count
        if localCount > 0 {
            categories.append(CellData(name: "local Data", value: "\(localCount)", segue: "toLocalData", image: ""))
        }
        
        let statistic = [
            CellData(name: "Statistic", value: "", segue: "toStatisticVC", image: "chart.pie.fill")
        ]
        let support = CellData(name: "Support", value: "", segue: "toSupportVC", image: "")
        
        //toSupportVC
        //chart.pie.fill - statistic
        let emptySec = TableData(section: [CellData(name: "", value: "", segue: "", image: "")], title: "", hidden: false)
        
        
        
        return [
            TableData(section: [accpuntCell, support], title: "", hidden: false),
            emptySec,
            TableData(section: categories, title: "", hidden: false),
            emptySec,
            TableData(section: statistic, title: "", hidden: false),
        ]
    }

    
    func load() {
        DispatchQueue.main.async {
            ViewController.shared?.sideTableView.delegate = self
            ViewController.shared?.sideTableView.dataSource = self
            ViewController.shared?.sideTableView.reloadData()
        }
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
            cell.optionIcon.image = iconNamed(tableData[indexPath.section].section[indexPath.row].image)
            return cell
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("sd")
        if tableData[indexPath.section].section[indexPath.row].name != "" {
            DispatchQueue.main.async {
                ViewController.shared?.performSegue(withIdentifier: self.tableData[indexPath.section].section[indexPath.row].segue, sender: self)
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
    }
}

