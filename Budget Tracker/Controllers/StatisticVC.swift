//
//  statisticVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.03.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//


import UIKit
var historyDataStruct = [HistoryDataStruct]()
var selectedCategoryName = ""

class StatisticVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    var allData = [GraphDataStruct]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    func updateUI() {
        tableView.delegate = self
        tableView.dataSource = self
        if expenseLabelPressed == true {
            segmentControll.selectedSegmentIndex = 0
        } else { segmentControll.selectedSegmentIndex = 1 }
        allData = tableData()
    }
    
    func tableData() -> [GraphDataStruct] {
        allData = []
        if segmentControll.selectedSegmentIndex == 0 {
            for (key, value) in sumAllCategories {
                if (sumAllCategories[key] ?? 0.0) < 0.0 {
                    allData.append(GraphDataStruct(category: key, value: value))
                }
            }
            titleLabel.text = "Expenses for \(selectedPeroud)"
            ifNoData()
            return allData.sorted(by: { $1.value > $0.value})
        } else {
            for (key, value) in sumAllCategories {
                if (sumAllCategories[key] ?? 0.0) > 0.0 {
                    allData.append(GraphDataStruct(category: key, value: value))
                }
            }
            titleLabel.text = "Incomes for \(selectedPeroud)"
            ifNoData()
            return allData.sorted(by: { $0.value > $1.value})
        }
        
    }
    
    func ifNoData() {
        if allData.count == 0 {
            titleLabel.textAlignment = .center
            titleLabel.text = "No " + (titleLabel.text ?? "Data")
        } else {
            titleLabel.textAlignment = .left
        }
    }
    
    @IBAction func selectedSegment(_ sender: UISegmentedControl) {
        allData = tableData()
        tableView.reloadData()
    }
    
    @IBAction func clodePressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func getHistoryScruct(indexPathRow: Int) {
        
        for i in 0..<allSelectedTransactionsData.count {
            if allData[indexPathRow].category == allSelectedTransactionsData[i].category {
                let data = allSelectedTransactionsData[i]
                historyDataStruct.append(HistoryDataStruct(value: data.value, date: data.date ?? ""))
            }
        }
        selectedCategoryName = allData[indexPathRow].category
    }
    
}

extension StatisticVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.statisticCellIdent, for: indexPath) as! StatisticCell
        let data = allData[indexPath.row]
        
        if data.value > 0.0 {
            cell.amountLabel.textColor = K.Colors.category
        } else { cell.amountLabel.textColor = K.Colors.negative }
        if data.value < Double(Int.max) {
            cell.amountLabel.text = "\(Int(data.value))"
        } else { cell.amountLabel.text = "\(data.value)" }
        cell.categoryLabel.text = data.category
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        historyDataStruct = [HistoryDataStruct]()
        DispatchQueue.init(label: "sort", qos: .userInteractive).async {
            self.getHistoryScruct(indexPathRow: indexPath.row)
            DispatchQueue.main.sync {
                self.performSegue(withIdentifier: K.historySeque, sender: self)
            }
        }
        
    }

}

struct GraphDataStruct {
    var category: String
    var value: Double
}

struct HistoryDataStruct {
    var value: Double
    var date: String
}

