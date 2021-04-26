//
//  HistoryVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.03.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
var transactionAdded = false
class HistoryVC: UIViewController {
    
    @IBOutlet weak var addTransButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategoryName = ""
    var fromCategories = false
    var allowEditing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedPurposeH, "selectedPurposeselectedPurposeH didlo")
        if !allowEditing {
            DispatchQueue.main.async {
                self.addTransButton.alpha = 0
            }
        } else {
            addTransButton.layer.shadowColor = UIColor.black.cgColor
            addTransButton.layer.shadowOpacity = 0.1
            addTransButton.layer.shadowOffset = .zero
            addTransButton.layer.shadowRadius = 10
        }
        transactionAdded = false
        historyDataStruct = historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
        tableView.delegate = self
        tableView.dataSource = self
        title = selectedCategoryName.capitalized


        
    }

    var fromStatistic = false

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    


    func totalSum(label: UILabel) {
        var sum = 0.0
        for i in 0..<historyDataStruct.count {
            sum += Double(historyDataStruct[i].value) ?? 1.0
        }

        DispatchQueue.main.async {
            label.text = sum < Double(Int.max) ? "\(Int(sum))" : "\(sum)"
        }
    }
    
    @IBAction func toTransPressed(_ sender: UIButton) {
        DispatchQueue.main.async {

            self.performSegue(withIdentifier: "toTransVC", sender: self)
            
        }
    }

    var selectedPurposeH: Int?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(selectedPurposeH, "historyVC selectedPurposeH")
        if segue.identifier == "toTransVC" {
            toAddVC = true
            let nav = segue.destination as! NavigationController
            let vc = nav.topViewController as! TransitionVC
            vc.delegate = self
            vc.fromDebts = fromCategories ? true : false
            vc.editingCategory = self.selectedCategoryName
            vc.selectedPurpose = selectedPurposeH
        }
    }

    var toAddVC = false
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return historyDataStruct.count
        } else { return 2 }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if historyDataStruct.count > 1 {
            return 2
        } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.historyCellIdent, for: indexPath) as! HistoryCell
            let data = historyDataStruct[indexPath.row]
            
            if Double(data.value) ?? 0.0 > 0.0 {
                cell.valueLabel.textColor = UIColor(named: "darkTableColor")
            } else { cell.valueLabel.textColor = K.Colors.negative }
            cell.dateLabel.text = data.date
            if Double(data.value) ?? 0.0 < Double(Int.max) {
                cell.valueLabel.text = "\(Int(Double(data.value) ?? 0.0))"
            } else { cell.valueLabel.text = "\(data.value)" }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.historyCellTotalIdent, for: indexPath) as! HistoryCellTotal
            
            totalSum(label: cell.valueLabel)
            if fromCategories {
                cell.perioudLabel.isHidden = true
            } else {
                cell.perioudLabel.text = selectedPeroud
            }
            cell.contentView.alpha = indexPath.row == 0 ? 1 : 0
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section == 0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                
                let mainFrame = view.frame
                let ai = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: mainFrame.height))
                ai.style = .gray
                view.addSubview(ai)
                ai.startAnimating()
                
                let transactions = Array(appData.getTransactions)
                var result: [TransactionsStruct] = []
                var newTableData: [TransactionsStruct] = []
                var found = false
                for i in 0..<transactions.count {
                    if !found {
                        if transactions[i].comment == self.historyDataStruct[indexPath.row].comment && transactions[i].date == self.historyDataStruct[indexPath.row].date && transactions[i].value == self.historyDataStruct[indexPath.row].value && transactions[i].category == self.historyDataStruct[indexPath.row].category{
                            found = true
                        } else {
                            result.append(transactions[i])
                            if transactions[i].category == self.historyDataStruct[indexPath.row].category {
                                newTableData.append(transactions[i])
                            }
                        }
                    } else {
                        result.append(transactions[i])
                        if transactions[i].category == self.historyDataStruct[indexPath.row].category {
                            newTableData.append(transactions[i])
                        }
                    }
                }
                
                if appData.username != "" {
                    let toDataString = "&Nickname=\(appData.username)" + "&Category=\(self.historyDataStruct[indexPath.row].category)" + "&Date=\(self.historyDataStruct[indexPath.row].date)" + "&Value=\(self.historyDataStruct[indexPath.row].value)" + "&Comment=\(self.historyDataStruct[indexPath.row].comment)"
                    let delete = DeleteFromDB()
                    delete.Transactions(toDataString: toDataString, completion: { (error) in
                        if error {
                            appData.unsendedData.append(["deleteTransaction": toDataString])
                        }
                        transactionAdded = true
                        appData.saveTransations(result)
                        self.historyDataStruct.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }

                    })
                } else {
                    transactionAdded = true
                    appData.saveTransations(result)
                    self.historyDataStruct.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
            deleteAction.backgroundColor = K.Colors.negative
            return UISwipeActionsConfiguration(actions: allowEditing ? [deleteAction] : [])
        } else {
            return nil
        } 
    }
    
   /* func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let i = newItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
           // DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.selectRow(at: i, animated: true, scrollPosition: .middle)
                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
                    self.tableView.deselectRow(at: i, animated: true)
                    self.newItem = nil
                    self.tableView.endUpdates()
                }
            }
        }
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

extension HistoryVC: TransitionVCProtocol {
    func addNewTransaction(value: String, category: String, date: String, comment: String) {
        toAddVC = false
        let new = TransactionsStruct(value: value, category: category, date: date, comment: comment)
        print(new, "newnewnewnew")
        
        if value != "" && category != "" && date != "" {
            transactionAdded = true
            if appData.username != "" {
                let toDataString = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                let save = SaveToDB()
                save.Transactions(toDataString: toDataString) { (error) in
                    if error {
                        let neew: String = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                        appData.unsendedData.append(["transaction": neew])
                    }
                    
                    var trans = appData.getTransactions
                    trans.append(new)
                    appData.saveTransations(trans)
                    
                    self.historyDataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                    self.historyDataStruct = self.historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    var indexPath: IndexPath?
                    for i in 0..<self.historyDataStruct.count {
                        if self.historyDataStruct[i].category == new.category && self.historyDataStruct[i].comment == new.comment && self.historyDataStruct[i].date == new.date && self.historyDataStruct[i].value == new.value {
                            indexPath = IndexPath(row: i, section: 0)
                            break
                        }
                    }
                    if let i = indexPath {
                        DispatchQueue.main.async {
                            self.tableView.selectRow(at: i, animated: true, scrollPosition: .middle)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            self.tableView.deselectRow(at: i, animated: true)
                        }
                    }
                }
            } else {
                var trans = appData.getTransactions
                trans.append(new)
                appData.saveTransations(trans)
                
                self.historyDataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                self.historyDataStruct = self.historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    func quiteTransactionVC() {
        
    }
}
