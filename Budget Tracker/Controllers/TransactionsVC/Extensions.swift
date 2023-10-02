//
//  Extensions.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 26.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 1: return 1//selectedCategory?.purpose != .debt ? 0 : 1
        case 0: return (selectedCategory?.amountToPay ?? selectedCategory?.monthLimit) != nil || amountToPayEditing ? 1 : 0
        case 2: return historyDataStruct.count == 0 ? 1 : historyDataStruct.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func removeDueDate() {
        self.changeDueDate(fullDate: "")
                        
                        let id = "Debts\(self.selectedCategory?.name ?? "")"
                        
                        DispatchQueue.main.async {
                            self.center.removePendingNotificationRequests(withIdentifiers: [id])
                            self.tableView.reloadData()
                          //  self.ai.fastHide()
                        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DebtDescriptionCell", for: indexPath) as! DebtDescriptionCell
            cell.cellPressed = calendarAmountPressed.0


            let hideBut = calendarAmountPressed.0 ? false : true
            if cell.changeButton.superview?.isHidden != hideBut {
                cell.changeButton.superview?.isHidden = hideBut
            }
            
            cell.changeAction = self.removeDueDate
            cell.removeAction = self.tocalendatPressed
            
            let dateComponent = selectedCategory?.dueDate
        //    print(dateComponent, "dateComponentdateComponentdateComponent")
            let date = "\(AppData.makeTwo(n: dateComponent?.day ?? 0))"
            let month = "\(returnMonth(dateComponent?.month ?? 0)), \(dateComponent?.year ?? 0)"

            cell.expiredStack.isHidden = !dateExpired(dateComponent)
            
            let defaultBackground = UIColor(red: 199/255, green: 197/255, blue: 197/255, alpha: 1)
            cell.imageBackgroundView.backgroundColor = defaultBackground//expired ? K.Colors.negative : defaultBackground
            cell.imageBackgroundView.layer.masksToBounds = true
            cell.imageBackgroundView.layer.cornerRadius = cell.imageBackgroundView.layer.frame.width / 2
            cell.alertDateLabel.text = selectedCategory?.dueDate != nil ? date : "Due date".localize
            cell.alertMonthLabel.text = selectedCategory?.dueDate != nil ? month : "Unset".localize
            cell.timeLabel.backgroundColor = defaultBackground
            cell.timeLabel.layer.cornerRadius = 4
            cell.timeLabel.layer.masksToBounds = true
            cell.AlertDateStack.axis = selectedCategory?.dueDate != nil ? .horizontal : .vertical
            cell.AlertDateStack.alignment = selectedCategory?.dueDate != nil ? .firstBaseline : .fill
            cell.timeLabel.isHidden = selectedCategory?.dueDate != nil ? false : true
            cell.timeLabel.text = "\(AppData.makeTwo(n: dateComponent?.hour ?? 0)):" + "\(AppData.makeTwo(n: dateComponent?.minute ?? 0))"
         //   cell.mainView.alpha = expired ? (debt?.dueDate == "" ? 1 : 0.4) : 1
          //  cell.mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toCalendarPressed(_:))))
            
            return cell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmountToPayCell") as! AmountToPayCell
            cell.set(selectedCategory, 
                     changeAmountState: calendarAmountPressed,
                     catTotal: selectedCategory?.purpose == .debt ? totalExpenses : thisMonthTotal,
                     isEditing: amountToPayEditing,
                     changePressed: {self.amountToPayEditing = true},
                     removePressed: removeAmountToPay)
            return cell
            
            
        case 2:
            if historyDataStruct.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyCell
                cell.selectionStyle = .none
                return cell
            } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.historyCellIdent, for: indexPath) as! HistoryCell
            let data = historyDataStruct[indexPath.row]
            
            if Double(data.value) ?? 0.0 > 0.0 {
                cell.valueLabel.textColor = K.Colors.category
            } else {
                cell.valueLabel.textColor = K.Colors.negative
                
            }
            cell.dateLabel.text = data.date
            if Double(data.value) ?? 0.0 < Double(Int.max) {
                cell.valueLabel.text = "\(Int(Double(data.value) ?? 0.0))"
            } else {
                cell.valueLabel.text = "\(data.value)"
            }
            return cell
            }

        default:
            return UITableViewCell()
        }
        

    }
    
    
    func removeAmountToPay() {
        self.changeAmountToPay(enteredAmount: "") { (_) in
            self.ai.fastHide { (_) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section == 2 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                switch self.mainType {
                case .localData, .allData:
                    if let _ = self.selectedCategory {
                        self.db.deleteTransaction(transaction: self.historyDataStruct[indexPath.row], local: true)
                        self.historyDataStruct.remove(at: indexPath.row)
                        self.totalSumm = Int(self.totalSum())
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                case .db:
                    let delete = DeleteFromDB()
                    delete.newTransaction(self.historyDataStruct[indexPath.row]) { _ in
                        self.historyDataStruct.remove(at: indexPath.row)
                        self.totalSumm = Int(self.totalSum())
                        
                        DispatchQueue.main.async {
                            self.calcMonthlyLimits()
                            //self.tableView.reloadData()
                        }
                    }
                default :
                    break
                }

                
            }
            deleteAction.image = AppData.iconSystemNamed("trash.red")
            deleteAction.backgroundColor = K.Colors.primaryBacground
            return historyDataStruct.count == 0 ? nil : UISwipeActionsConfiguration(actions: allowEditing && mainType != .unsaved ? [deleteAction] : [])
        } else {
            return nil
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        if mainType  == .db {
            if indexPath.section == 1 {
                if self.selectedCategory?.dueDate != nil && !self.calendarAmountPressed.0 {
                    let isPressed = calendarAmountPressed.0 ? false : true
                    print(isPressed, "isPressedisPressedisPressed")
                    calendarAmountPressed = (isPressed, false)
                    tableView.reloadData()
                } else {
                    calendarAmountPressed = (false,false)
                    tableView.reloadData()
                }
            } else {
                calendarAmountPressed = (false,false)
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ifDueDate = indexPath.section == 1 ? (self.selectedCategory?.dueDate == nil ? 0 : UITableView.automaticDimension) : UITableView.automaticDimension
        
        
        let dueViewHeight:CGFloat = self.selectedCategory?.dueDate == nil ? 70 : 150
        let heightWhenNoData = tableView.frame.height - (appData.resultSafeArea.1 + appData.resultSafeArea.0 + dueViewHeight)
        
        return indexPath.section == 2 ? (historyDataStruct.count == 0 ? heightWhenNoData : UITableView.automaticDimension) : ifDueDate
    }
    
}

extension HistoryVC: TransitionVCProtocol {
    func deletePressed() {
        //not usng
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct, reminderTime: DateComponents?, repeated: Bool?, idx:Int?) {
        //not using
    }
    
    func quiteTransactionVC(reload: Bool) {
        
    }
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime:DateComponents?, repeated:Bool?) {
        toAddVC = false
        transactionAdded = true
        appData.needDownloadOnMainAppeare = true
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        if value != "" && category != "" && date != "" {
                  //  let save = SaveToDB()
            SaveToDB.shared.newTransaction(new) { error in
                        if let category = self.selectedCategory {
                            self.historyDataStruct = self.db.transactions(for: category)
                            self.totalSumm = Int(self.totalSum())
                            DispatchQueue.main.async {
                                self.calcMonthlyLimits()
                               // self.tableView.reloadData()
                            }
                        }

                        
                    }

                }
        }

    
    
    
    
}

extension HistoryVC: CalendarVCProtocol {
    
    func dateSelected(date: String, time: DateComponents?) {
            self.ai.show { (_) in
                let id = "Debts\(self.selectedCategory?.id ?? 0)"
                self.center.removePendingNotificationRequests(withIdentifiers: [id])
                let fullDate = "\(date) \(AppData.makeTwo(n: time?.hour ?? 0)):\(AppData.makeTwo(n: time?.minute ?? 0)):\(AppData.makeTwo(n: time?.second ?? 0))"
                print(fullDate, "fullDatefullDatefullDatefullDate")
                if let dateComp = time?.createDateComp(date: date, time: time) {
                    print(dateComp, "dateCompdateCompdateComp")
                    
                    if let isoFullString = dateComp.toIsoString() {
                        if !self.dateExpired(dateComp) {
                            let nodifCen = Notifications()
                            let notifTitle = "Due date has expired".localize
                            let notifBody = "For category".localize + ": " + (self.selectedCategory?.name ?? "")
                            let notifID = "Debts\(self.selectedCategory?.id ?? 0)"
                            nodifCen.addLocalNotification(date: dateComp, title: notifTitle, id: notifID, body: notifBody) { added in
                                self.changeDueDate(fullDate: isoFullString)
                                if !added {
                                    DispatchQueue.main.async {
                                        self.newMessage.show(title:"Local notification not added".localize, type: .error)
                                    }
                                }
                            }

                          } else {
                            self.changeDueDate(fullDate: isoFullString)
                            DispatchQueue.main.async {
                                self.newMessage.show(title:"Local notification not added".localize, type: .error)
                            }
                        }
                        
                    } else {
                        let errorText = "Error".localize + " " + "adding".localize + " " + "Due date".localize
                        self.ai.fastHide { _ in
                            DispatchQueue.main.async {
                                self.newMessage.show(title: errorText, type: .error)
                            }
                        }
                        
                    }
                    
                    
                } //self.stringToDateComponent(s: fullDate, dateFormat: K.fullDateFormat)
                
                else {
                    let errorText = "Error".localize + " " + "adding".localize + " " + "Due date".localize
                    self.ai.fastHide { _ in
                        DispatchQueue.main.async {
                            self.newMessage.show(title:errorText, type: .error)
                        }
                    }
                }
                
                
            }
            
     //   }
    }
    
    
}
