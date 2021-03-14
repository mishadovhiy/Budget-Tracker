//
//  DebtsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 14.03.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class DebtsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: DebtsVCProtocol?
    var debts: [CategoriesStruct] = []
    var _tableData: [DebtsTableStruct] = []
    var tableData: [DebtsTableStruct] {
        get {
            return _tableData
        }
        set {
            _tableData = newValue
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let transactions = Array(appData.transactions)
        var result:[DebtsTableStruct] = []
        
        for category in debts {
            var amount = 0.0
            var resultTransactions: [TransactionsStruct] = []
            for transaction in transactions {
                if category.name == transaction.category {
                    amount = amount + (Double(transaction.value) ?? 0.0)
                    resultTransactions.append(transaction)
                    print(resultTransactions, "appended c1/c2: \(category.name)/\(transaction.category)")
                }
            }
            result.append(DebtsTableStruct(name: category.name, amount: Int(amount), transactions: transactions))
            print(resultTransactions)
        }
        tableData = result
    }
    

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
    }

    struct DebtsTableStruct {
        let name: String
        let amount: Int
        let transactions: [TransactionsStruct]
    }
    
    var selectedCellData:DebtsTableStruct?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistory" {

            let vc = segue.destination as! HistoryVC
            if let data = selectedCellData {
                print("prepare data.transactions", data.transactions)
                var result:[TransactionsStruct] = []
                let allTrans = Array(appData.transactions)
                for i in 0..<allTrans.count{
                    if allTrans[i].category == data.name {
                        result.append(allTrans[i])
                    }
                }
                vc.historyDataStruct = result
                vc.selectedCategoryName = data.name
                vc.fromCategories = true
            }
            
        }
    }
}

extension DebtsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 4 //income debts // expences debts //complited //empty
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "debtCell", for: indexPath) as! debtCell
        
        cell.categoryLabel.text = tableData[indexPath.row].name
        cell.amountLabel.text = "\(tableData[indexPath.row].amount)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            DispatchQueue.main.async {
                self.delegate?.catDebtSelected(name: self.tableData[indexPath.row].name)
                
            }
        } else {
            //go to historyVC and past data
            print(tableData[indexPath.row].name, "bvghjjnbh")
            selectedCellData = tableData[indexPath.row]
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toHistory", sender: self)
            }
        }
        
    }
    
}

protocol DebtsVCProtocol {
    func catDebtSelected(name: String)
}

class debtCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}
