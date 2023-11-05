//
//  SideBar.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 06.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import PassKit

class SideBar: UIView, UITableViewDelegate, UITableViewDataSource {
    var appData:AppData {
        AppDelegate.shared?.appData ?? .init()
    }
    func getData(){
        let db = DataBase()
        let debts = db.debts.count
      //  let pro = appData.proEnabeled
        let notifications = Notifications.notificationsCount
        
        var accpuntCell:CellData {
            return CellData(name: "Account".localize, value: appData.username == "" ? "Log in".localize : appData.username, segue: "", image: "person.fill", selectAction: {
                HomeVC.shared?.navigationController?.pushViewController(LoginViewController.configure(), animated: true)
            })
        }
        
        let settingsCell:CellData = .init(name: "Settings".localize, value: "", segue: "", image: "gearshape.fill", selectAction: {
            HomeVC.shared?.navigationController?.pushViewController(SettingsVC.configure(), animated: true)
        })
        
        let dbb = DataBase().db
        let catsCo = dbb["categoriesDataNew"] as? [[String:Any]] ?? []
        
        var categories:[CellData] = [
            .init(name: "Categories".localize, value: "\(catsCo.count - debts)", segue: "", image: "folder.fill", selectAction: {
                HomeVC.shared?.toCategories()
            }),
            .init(name: "Debts".localize, value: "\(debts)", segue: "", image: "rectangle.3.group.fill", pro: nil, notifications: notifications.0, selectAction: {
                HomeVC.shared?.toCategories(type: .debts)
            })//!(pro) ? 3 : nil
        ]
        let localCount = ((dbb[K.Keys.localTrancations] as? [[String:Any]] ?? []) + (dbb[K.Keys.localCategories] as? [[String:Any]] ?? [])).count
        if localCount > 0 {
            categories.append(CellData(name: "Local Data".localize, value: "\(localCount)", segue: "", image: "tray.fill", selectAction: {
                HomeVC.shared?.toCategories(type: .localData)
            }))
        }
        
        let statistic:CellData = .init(name: "Statistic".localize, value: "", segue: "", image: "chart.pie.fill", selectAction: {
            HomeVC.shared?.toStatistic(thisMonth: false, isExpenses: true)
        })
        let trialDays = dbb["trialToExpireDays"] as? Int ?? 0
        let trialCell = CellData(name: "Trail till", value: "\(7 - trialDays)", segue: "", image: "clock.fill", selectAction: {
            AppDelegate.shared?.present(vc: BuyProVC.configure())
        })


        var accountSection:[CellData] {
            return trialDays == 0 ? [accpuntCell, settingsCell] : [accpuntCell, settingsCell, trialCell]
        }
        
        let upcommingRemiders:CellData = .init(name: "Payment reminders".localize, value: "", segue: "", image: "bell.fill", pro: nil, notifications: notifications.1, selectAction: {
            HomeVC.shared?.navigationController?.pushViewController(RemindersVC.configure(), animated: true)
        })//!(pro) ? 0 : nil
        let applePay:CellData = .init(name: "apple pay".localize, value: "", segue: "", image: "chart.pie.fill", selectAction: applePayPressed)
        tableData = [
            .init(section: accountSection, title: "", hidden: false),
            .init(section: categories, title: "", hidden: false),
            .init(section: [upcommingRemiders], title: "", hidden: false),
            .init(section: [statistic, applePay], title: "", hidden: false),
        ]
        DispatchQueue.main.async {
            HomeVC.shared?.sideTableView.reloadData()
        }
        
    }
    
    func applePayPressed() {
        if PKPassLibrary.isPassLibraryAvailable() {
            PKPassLibrary.requestAutomaticPassPresentationSuppression(responseHandler: { results in
                if results == .success || results == .alreadyPresenting {
                    self.loadAppleTransactions()
                } else if results == .notSupported {
                    AppDelegate.shared?.ai.showAlertWithOK(title:"Not supported", error: true)
                } else {
                    AppDelegate.shared?.ai.showAlert(buttons: (.init(title: "Cancel", style: .regular, close: true, action: nil), .init(title: "To Settings", style: .link, action: { _ in
                        AppData.toDeviceSettings()
                    })), title: "\(results)", description: "Access denied")
                }
            })
            
        }
    }
    
    func loadAppleTransactions() {
        print("loadAppleTransactions")
        let passLibrary = PKPassLibrary()
        let passes = passLibrary.passes()
        for pass in passes {
            if let paymentPass = pass as? PKPaymentPass {
                // Access transaction data from the paymentPass
                let transactions = paymentPass
            //    for transaction in transactions {
                    // Process transaction data
            //    }
            }
        }
    }
    
    
    var tableData:[TableData] = []

    func toRemindersVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vccc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! HomeVC
            HomeVC.shared?.navigationController?.pushViewController(vccc, animated: true)
        }
    }
    
    func load() {
        if HomeVC.shared?.sideTableView.delegate == nil {
                HomeVC.shared?.sideTableView.delegate = self
                HomeVC.shared?.sideTableView.dataSource = self
        }
        
        DispatchQueue(label: "db", qos: .userInitiated).async {
            self.getData()
        }
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
                    HomeVC.shared?.fromSideBar = true
                    DispatchQueue.main.async {
                        HomeVC.shared?.performSegue(withIdentifier: segue, sender: self)
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
    
    func newNotificationCount() {
        load()
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
        selected.backgroundColor = K.Colors.sectionBackground
        self.selectedBackgroundView = selected

        if !(AppDelegate.shared?.symbolsAllowed ?? false) {
            optionIcon.isHidden = true
        }
    }
}

