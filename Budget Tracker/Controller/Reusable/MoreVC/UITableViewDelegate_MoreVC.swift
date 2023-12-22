//
//  UITableViewDelegate_MoreVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension MoreVC:UITableViewDelegate, UITableViewDataSource {
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
            cell.contentView.backgroundColor = data.selected ? K.Colors.link : cellBackground
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
    
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    
                }
            }
        } else {
            if indexPath.section == 1 {
                if !tableData[indexPath.row].pro {
                    AppDelegate.shared?.properties?.appData.presentBuyProVC(selectedProduct: selectedProIndex)
                    tableView.deselectRow(at: indexPath, animated: true)
                } else {
                if let function = tableData[indexPath.row].action {
                    let goNext = {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                function()
                            }
                        }
                    }
                    if tableData[indexPath.row].showAI {
                        AppDelegate.shared?.properties?.ai.showLoading(completion: {
                            goNext()
                        })
                    } else {
                        goNext()
                    }
                    
                }
            }
        }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //firstCellHeight
        //tableView.frame.height - tableView.contentSize.height
        return indexPath.section == 0 ? firstCellHeight : cellHeightCust
    }
}
