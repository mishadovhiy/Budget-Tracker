//
//  SideBar.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 06.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SideBar: UIView, UITableViewDelegate, UITableViewDataSource {
    var appData:AppData {
        AppDelegate.shared?.appData ?? .init()
    }
    func getData(){
        let db = DataBase()
        let debts = db.debts.count
        let pro = appData.proEnabeled
        let notifications = Notifications.notificationsCount
        
        var accpuntCell:CellData {
            var accountSegue:String {
                return "toAccount"
            }
            return CellData(name: "Account".localize, value: appData.username == "" ? "Log in".localize : appData.username, segue: accountSegue, image: "person.fill")
        }
        
        let settingsCell:CellData = .init(name: "Settings".localize, value: "", segue: "toSettingsVC", image: "gearshape.fill")
        
        let dbb = DataBase().db
        let catsCo = dbb["categoriesDataNew"] as? [[String:Any]] ?? []
        
        var categories:[CellData] = [
            .init(name: "Categories".localize, value: "\(catsCo.count - debts)", segue: "toCategories", image: "folder.fill"),
            .init(name: "Debts".localize, value: "\(debts)", segue: "toDebts", image: "rectangle.3.group.fill", pro: nil, notifications: notifications.0)//!(pro) ? 3 : nil
        ]
        let localCount = ((dbb[K.Keys.localTrancations] as? [[String:Any]] ?? []) + (dbb[K.Keys.localCategories] as? [[String:Any]] ?? [])).count
        if localCount > 0 {
            categories.append(CellData(name: "Local Data".localize, value: "\(localCount)", segue: "toLocalData", image: "tray.fill"))
        }
        
        let statistic:CellData = .init(name: "Statistic".localize, value: "", segue: "toStatisticVC", image: "chart.pie.fill")
        let trialDays = dbb["trialToExpireDays"] as? Int ?? 0
        let trialCell = CellData(name: "Trail till", value: "\(7 - trialDays)", segue: "toProVC", image: "clock.fill")


        var accountSection:[CellData] {
            return trialDays == 0 ? [accpuntCell, settingsCell] : [accpuntCell, settingsCell, trialCell]
        }
        
        let upcommingRemiders:CellData = .init(name: "Payment reminders".localize, value: "", segue: "toReminders", image: "bell.fill", pro: nil, notifications: notifications.1)//!(pro) ? 0 : nil
        
        tableData = [
            .init(section: accountSection, title: "", hidden: false),
            .init(section: categories, title: "", hidden: false),
            .init(section: [upcommingRemiders], title: "", hidden: false),
            .init(section: [statistic], title: "", hidden: false),
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideBardCell", for: indexPath) as! SideBardCell
        cell.nameLabel.superview?.alpha = tableData[indexPath.section].section[indexPath.row].name == "" ? 0 : 1
        cell.nameLabel.text = tableData[indexPath.section].section[indexPath.row].name
        cell.valueLabel.text = tableData[indexPath.section].section[indexPath.row].value
        cell.notificationsView.isHidden = tableData[indexPath.section].section[indexPath.row].notifications == 0
        cell.notificationsLabel.text = "\(tableData[indexPath.section].section[indexPath.row].notifications)"
        cell.proView.isHidden = tableData[indexPath.section].section[indexPath.row].pro == nil
        if (AppDelegate.shared?.symbolsAllowed ?? false) {
            cell.optionIcon.image = AppData.iconSystemNamed(tableData[indexPath.section].section[indexPath.row].image)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let proID = tableData[indexPath.section].section[indexPath.row].pro {
            appData.presentBuyProVC(selectedProduct: proID)
        } else {
            if tableData[indexPath.section].section[indexPath.row].name != "" {
                let segue = tableData[indexPath.section].section[indexPath.row].segue
                if segue != "" {
                    ViewController.shared?.fromSideBar = true
                    DispatchQueue.main.async {
                        ViewController.shared?.performSegue(withIdentifier: segue, sender: self)
                    }
                } else {
                    if let action = tableData[indexPath.section].section[indexPath.row].selectAction {
                        action()
                    }
                }
            }
        }
        
        
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
        var pro: Int? = nil
        var notifications:Int = 0
        var selectAction:(()->())? = nil
        
    }
}

class SideBardCell: UITableViewCell {
    
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var notificationsView: BasicView!
    @IBOutlet weak var proView: BasicView!
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

