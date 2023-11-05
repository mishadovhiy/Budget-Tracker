//
//  TableViewDelegate_ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 28.01.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
            
        } else {
            return newTableData.count == 0 ? 1 : newTableData[section - 1].transactions.count //+ 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (newTableData.count == 0 ? 1 : newTableData.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let calculationCell = tableView.dequeueReusableCell(withIdentifier: "calcCell", for: indexPath) as? calcCell
            return calculationCell ?? UITableViewCell()
        } else {
            if newTableData.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "mainVCemptyCell", for: indexPath) as! mainVCemptyCell
                return cell
            } else {
                    let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
                    transactionsCell.isUserInteractionEnabled = true
                    transactionsCell.contentView.isUserInteractionEnabled = true
                    let data = newTableData[indexPath.section - 1].transactions[indexPath.row]
                    transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell, indexPath: indexPath)
                    return transactionsCell
                }
            
            
        }

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 && newTableData.count != 0 {
            if newTableData[indexPath.section-1].transactions.count - 1 >= indexPath.row {
                self.editingTransaction = self.newTableData[indexPath.section - 1].transactions[indexPath.row]
                let cell = tableView.cellForRow(at: indexPath) as! mainVCcell
                self.toAddTransaction(editing: true, pressedView: cell.contentView)
            }
            
        }
    }

    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != 0 && newTableData.count != 0 {
            return "\(newTableData[section - 1].date)"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if newTableData.count == 0 || section == 0 {
            return UIView.init(frame: .zero)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainHeaderCell") as! mainHeaderCell
            
            cell.dateLabel.textColor = K.Colors.link
            let date = newTableData[section - 1].date
            cell.dateLabel.text = "\(AppData.makeTwo(n: date.day ?? 0))"
            cell.monthLabel.text =  date.stringMonth
            cell.yearLabel.text = "\(date.year ?? 0)"
            let contentView = cell.contentView
         //   cell.mainView.layer.cornerRadius = 15
            cell.mainView.layer.cornerRadius(at: .top, value: tableCorners)
            /*let newView = UIView(frame: newViewFrame)
            let helperTopView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: newViewFrame.height / 2))
            helperTopView.backgroundColor = K.Colors.primaryBacground
            newView.addSubview(helperTopView)
            newView.addSubview(v)*/
            return contentView
        }
        

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 || newTableData.count != 0 {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }
    

    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.contentOffset.y > 20 {
            if indexPath.section == 0 {
                DispatchQueue.main.async {
                    self.mainTableView.backgroundColor = K.Colors.primaryBacground
                    UIView.animate(withDuration: self.animateCellWillAppear ? 0.2 : 0) {
                        let superframe = self.filterView.superview?.frame ?? .zero
                        let selfFrame = self.filterView.frame
                        self.filterView.frame = CGRect(x: selfFrame.minX, y: -superframe.height, width: selfFrame.width, height: selfFrame.height)
                        self.calculationSView.frame = self.filterAndCalcFrameHolder.1
                    }
                }
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bigFr = bigCalcView.layer.frame.height + self.calendarContainer.frame.height
        if indexPath.section == 0 && indexPath.row == 0 {
            return bigFr //- 45
        } else {
            if newTableData.count == 0 && indexPath.section == 1{
                let safe = AppDelegate.shared?.window?.safeAreaInsets.top ?? 0 + 20
                return (tableView.layer.frame.height - (bigFr + (safe))).validate(min: 0)
            } else {
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if transactionAdded {
            transactionAdded = false
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.filter()
            }
        }
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: self.animateCellWillAppear ? 0.3 : 0) {
                    self.mainTableView.backgroundColor = .clear
                    let superframe = self.calculationSView.superview?.frame ?? .zero
                    let selfFrame = self.calculationSView.frame
                    self.calculationSView.frame = CGRect(x: selfFrame.minX, y: -superframe.height, width: selfFrame.width, height: selfFrame.height)
                    self.filterView.frame = self.filterAndCalcFrameHolder.0
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 || newTableData.count == 0 {
            return nil
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainFooterCell") as! mainFooterCell
            cell.totalLabel.text = "\(newTableData[section - 1].amount)"
            cell.cornerView.layer.cornerRadius(at: .btn, value: tableCorners)
            cell.separatorInset.left = tableView.frame.width / 2
            cell.separatorInset.right = tableView.frame.width / 2
            return cell.contentView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || newTableData.count == 0 {
            return 0
        } else {
            return 53//UITableView.automaticDimension
        }
    }
}
