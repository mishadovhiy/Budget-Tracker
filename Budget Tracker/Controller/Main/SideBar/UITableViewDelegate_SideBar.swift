//
//  UITableViewDelegate_SideBar.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension SideBar:UITableViewDelegate, UITableViewDataSource {
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
        if (AppDelegate.properties?.appData.symbolsAllowed ?? false) {
            cell.optionIcon.image = .init(tableData[indexPath.section].section[indexPath.row].image)
            //AppData.iconSystemNamed(tableData[indexPath.section].section[indexPath.row].image)
        }
        cell.setCornered(indexPath: indexPath, dataCount: tableData[indexPath.section].section.count, for: cell.backgroundMainView)
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
                    HomeVC.shared?.viewModel.fromSideBar = true
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
}
