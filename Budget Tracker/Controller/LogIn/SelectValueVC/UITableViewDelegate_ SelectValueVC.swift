//
//  UITableViewDelegate_ SelectValueVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension SelectValueVC:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let regular = tableData[indexPath.section].cells[indexPath.row].regular {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUserVCCell", for: indexPath) as! SelectUserVCCell
            cell.mainTitleLabel.text = tableData[indexPath.section].cells[indexPath.row].name
            cell.mainDescriptionLabel.isHidden = tableData[indexPath.section].cells[indexPath.row].regular?.description ?? "" == ""
            cell.mainDescriptionLabel.text = tableData[indexPath.section].cells[indexPath.row].regular?.description
            return cell
        } else if let switcher = tableData[indexPath.section].cells[indexPath.row].switcher {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            let data = tableData[indexPath.section].cells[indexPath.row].forProUsers
            cell.set(title:tableData[indexPath.section].cells[indexPath.row].name,
                     isOn: switcher.isOn, proEnabled: data != nil && !(AppDelegate.shared?.appData.proEnabeled ?? false), changed: switcher.switched)
            return cell
        } else if let data = tableData[indexPath.section].cells[indexPath.row].slider {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderCell
            cell.set(data)
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].sectionName != "" ? tableData[section].sectionName : nil
    }
    
    private func dismissOnSelect() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true) {
                
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let proID = self.tableData[indexPath.section].cells[indexPath.row].forProUsers, !(AppDelegate.shared?.appData.proEnabeled ?? false) {
            AppDelegate.shared?.appData.presentBuyProVC(selectedProduct: proID)
        } else {
            if let delegate = self.delegate {
                delegate.selected(user: self.tableData[indexPath.section].cells[indexPath.row].name)
                dismissOnSelect()
            } else if let selectedIdx = self.selectedIdxAction {
                selectedIdx(indexPath.row)
                dismissOnSelect()
            } else {
                self.tableData[indexPath.section].cells[indexPath.row].regular?.didSelect()
            }
        }
            
            
    }
}
