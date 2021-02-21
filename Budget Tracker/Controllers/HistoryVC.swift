//
//  HistoryVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.03.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategoryName = ""
    var fromCategories = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = selectedCategoryName.capitalized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    
    func totalSum(label: UILabel) {
        var sum = 0.0
        for i in 0..<historyDataStruct.count {
            sum += Double(historyDataStruct[i].value) ?? 1.0
        }
        if sum < Double(Int.max) {
            label.text = "\(Int(sum))"
        } else { label.text = "\(sum)" }
    }

}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return historyDataStruct.count
        } else { return 1 }
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
            return cell
        }
    }
    
}
