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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        title = selectedCategoryName.capitalized
    }
    
    func totalSum(label: UILabel) {
        var sum = 0.0
        for i in 0..<historyDataStruct.count {
            sum += historyDataStruct[i].value
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
        if historyDataStruct.count > 2 {
            return 2
        } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.historyCellIdent, for: indexPath) as! HistoryCell
            let data = historyDataStruct[indexPath.row]
            
            if data.value > 0.0 {
                cell.valueLabel.textColor = K.Colors.category
            } else { cell.valueLabel.textColor = K.Colors.negative }
            cell.dateLabel.text = data.date
            if data.value < Double(Int.max) {
                cell.valueLabel.text = "\(Int(data.value))"
            } else { cell.valueLabel.text = "\(data.value)" }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.historyCellTotalIdent, for: indexPath) as! HistoryCellTotal
            
            totalSum(label: cell.valueLabel)
            cell.perioudLabel.text = selectedPeroud
            return cell
        }
    }
    
    
}
