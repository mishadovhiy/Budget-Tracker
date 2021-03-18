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
    var emptyValuesTableData: [DebtsTableStruct] = []
    var plusValues: [DebtsTableStruct] = []
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
    
    var darkAppearence = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFromLocal()
        if #available(iOS 13.0, *) {
            if darkAppearence {
                self.view.backgroundColor = UIColor(named: "darkTableColor")
                self.tableView.separatorColor = UIColor(named: "darkSeparetor")
            }
        } else {
            DispatchQueue.main.async {
                if self.darkAppearence {
                    self.view.backgroundColor = UIColor(named: "darkTableColor")
                    self.tableView.separatorColor = UIColor(named: "darkSeparetor")
                }
            }
        }
    }
    
    
    func getDataFromLocal() {
        let transactions = Array(appData.transactions)
        var result:[DebtsTableStruct] = []
        emptyValuesTableData.removeAll()
        plusValues.removeAll()
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
            let new = DebtsTableStruct(name: category.name, amount: Int(amount), transactions: transactions)
            if resultTransactions.count == 0 {
                emptyValuesTableData.append(new)
            } else {

                if amount > 0 {
                    plusValues.append(new)
                } else {
                    result.append(new)
                }
                
            }
            
            print(resultTransactions)
        }
        plusValues = plusValues.sorted { $0.amount > $1.amount }
        tableData = result.sorted { $0.amount < $1.amount }
    }
    
    
    
    @IBAction func addPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertTextFields(alert: alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in

            DispatchQueue.main.async {
                if let name = self.alertTextField.text {
                    if name != "" {

                        self.debts.append(CategoriesStruct(name: name, purpose: K.expense, count: 0, debt: true))
                        if appData.username != "" {
                            self.sendToDBCategory(title: name, purpose: K.expense)
                        } else {
                            var categories = Array(appData.getCategories())
                            categories.append(CategoriesStruct(name: name, purpose: K.expense, count: 0, debt: true))
                            appData.saveCategories(categories)
                            //debts append
                            self.getDataFromLocal()
                        }
                    }
                }
            }

        }))
        present(alert, animated: true, completion: nil)
    }
    
    var alertTextField = UITextField()
    func alertTextFields(alert: UIAlertController) {
        alert.addTextField { (category) in
            category.placeholder = "Category name"
            self.alertTextField = category
        }
    }

    func sendToDBCategory(title: String, purpose: String) {
        let Nickname = appData.username
        if Nickname != "" {
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(title)" + "&Purpose=\(purpose)" + "&ExpectingPayment=1"
            let save = SaveToDB()
            save.Categories(toDataString: toDataString) { (error) in
                var categories = Array(appData.getCategories())
                categories.append(CategoriesStruct(name: title, purpose: purpose, count: 0, debt: true))
                appData.saveCategories(categories)
                self.getDataFromLocal()
                if error {
                    appData.unsendedData.append(["category": toDataString])
                }
            }
        }
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
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}

extension DebtsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 4 //income debts // expences debts //complited //empty
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return tableData.count//emptyValuesTableData
        case 1: return plusValues.count//emptyValuesTableData
        case 2: return emptyValuesTableData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "debtCell", for: indexPath) as! debtCell
        //let data = indexPath.section == 0 ? tableData[indexPath.row] : emptyValuesTableData[indexPath.row]
        var data = tableData[indexPath.row]
        switch indexPath.section {
        case 0: data = tableData[indexPath.row]
        case 1: data = plusValues[indexPath.row]
        case 2: data = emptyValuesTableData[indexPath.row]
        default:
            data = tableData[indexPath.row]
        }
        cell.categoryLabel.text = data.name
        cell.amountLabel.text = indexPath.section == 2 ? "No records" : "\(data.amount)"
        cell.categoryLabel.textColor = darkAppearence ? K.Colors.category : .black
        cell.amountLabel.textColor = darkAppearence ? K.Colors.category : .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let data = indexPath.section == 0 ? tableData[indexPath.row] : emptyValuesTableData[indexPath.row]
        var data = tableData[indexPath.row]
        switch indexPath.section {
        case 0: data = tableData[indexPath.row]
        case 1: data = plusValues[indexPath.row]
        case 2: data = emptyValuesTableData[indexPath.row]
        default:
            data = tableData[indexPath.row]
        }
        if delegate != nil {
            DispatchQueue.main.async {
                self.delegate?.catDebtSelected(name: data.name, amount: data.amount)
                
            }
        } else {
            //go to historyVC and past data
            print(data.name, "bvghjjnbh")
            selectedCellData = data
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toHistory", sender: self)
            }
        }
        
    }
    
}

protocol DebtsVCProtocol {
    func catDebtSelected(name: String, amount: Int)
}

class debtCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}
