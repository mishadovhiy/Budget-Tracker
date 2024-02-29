//
//  SideBar.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 06.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import PassKit

class SideBar: UIView {
    var tableData:[TableData] = []

    var navVC:UINavigationController? {
        return (UIApplication.shared.delegate as? AppDelegate)?.navigationVC
    }
    
    var appData:AppData {
        AppDelegate.properties?.appData ?? .init()
    }
    func getData(){
        let db = AppDelegate.properties?.db ?? .init()
        let debts = db.debts.count
      //  let pro = appData.proEnabeled
        let notifications = Notifications.notificationsCount
        
        var accpuntCell:CellData {
            return CellData(name: "Account".localize, value: db.username == "" ? "Log in".localize : db.username, segue: "", image: "person.fill", selectAction: {
               // HomeVC.shared?.navigationController?.pushViewController(LoginViewController.configure(), animated: true)
                self.navVC?.pushViewController(LoginViewController.configure(), animated: true)
            })
        }
        
        let settingsCell:CellData = .init(name: "Settings".localize, value: "", segue: "", image: "gearshape.fill", selectAction: {
            self.navVC?.pushViewController(SettingsVC.configure(), animated: true)
        })
        
        let catsCo = db.db["categoriesDataNew"] as? [[String:Any]] ?? []
        
        var categories:[CellData] = [
            .init(name: "Categories".localize, value: "\(catsCo.count - debts)", segue: "", image: "folder.fill", selectAction: {
                HomeVC.shared?.toCategories()
            }),
            .init(name: "Debts".localize, value: "\(debts)", segue: "", image: "rectangle.3.group.fill", pro: nil, notifications: notifications.0, selectAction: {
                HomeVC.shared?.toCategories(type: .debts)
            })//!(pro) ? 3 : nil
        ]
        let localCount = ((db.db[K.Keys.localTrancations] as? [[String:Any]] ?? []) + (db.db[K.Keys.localCategories] as? [[String:Any]] ?? [])).count
        if localCount > 0 {
            categories.append(CellData(name: "Local Data".localize, value: "\(localCount)", segue: "", image: "tray.fill", selectAction: {
                HomeVC.shared?.toCategories(type: .localData)
            }))
        }
        
        let statistic:CellData = .init(name: "Statistic".localize, value: "", segue: "", image: "chart.pie.fill", selectAction: {
            HomeVC.shared?.toStatistic(thisMonth: false, isExpenses: true)
        })
        let trialDays = db.db["trialToExpireDays"] as? Int ?? 0
        let trialCell = CellData(name: "Trail till", value: "\(7 - trialDays)", segue: "", image: "clock.fill", selectAction: {
            AppDelegate.properties?.appData.present(vc: BuyProVC.configure())
        })


        var accountSection:[CellData] {
            return trialDays == 0 ? [accpuntCell, settingsCell] : [accpuntCell, settingsCell, trialCell]
        }
        
        let upcommingRemiders:CellData = .init(name: "Payment reminders".localize, value: "", segue: "", image: "bell.fill", pro: nil, notifications: notifications.1, selectAction: {
            self.navVC?.pushViewController(RemindersVC.configure(), animated: true)
        })//!(pro) ? 0 : nil
        let applePay:CellData = .init(name: "apple pay".localize, value: "", segue: "", image: "chart.pie.fill", selectAction: applePayPressed)
        tableData = [
            .init(section: accountSection, title: "", hidden: false),
            .init(section: categories, title: "", hidden: false),
            .init(section: [upcommingRemiders], title: "", hidden: false),
            .init(section: [statistic], title: "", hidden: false),
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
                    AppDelegate.properties?.ai.showAlertWithOK(title:"Not supported")
                } else {
                    AppDelegate.properties?.ai.showAlertWithOK(title: "Open App Settings Settings".localize, description: "Will open app's page in system settings".localize, button: .with({
                        $0.action = AppData.toDeviceSettings
                        $0.title = "Go to settings".localize
                    }), okTitle: "Cancel".localize)
                    
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
    
    func toRemindersVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vccc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! HomeVC
            self.navVC?.pushViewController(vccc, animated: true)
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
    
    
    func newNotificationCount() {
        load()
    }
}

extension SideBar {
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
