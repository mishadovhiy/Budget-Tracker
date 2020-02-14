//
//  ViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData
var appData = AppData()

class ViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var addTransitionButton: UIButton!
    @IBOutlet weak var customDatesLabel: UILabel!
    @IBOutlet weak var noTableDataLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    var tableData = appData.transactions.sorted{ $0.dateFromString > $1.dateFromString }
    var alerts = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        filterSegmentedControl.selectedSegmentIndex = 1
        filterPressed(filterSegmentedControl)
    }
    
    func updateUI() {
        
        addTransitionButton.layer.cornerRadius = 15
        mainTableView.delegate = self
        mainTableView.dataSource = self
        loadItems()
    }
    
    func performFiltering() {
        
        var mydates: [String] = []
        var dateFrom = Date()
        var dateTo = Date()
        let fmt = DateFormatter()
        if appData.filter.showAll == true {
            tableData = appData.transactions
            appData.recalculation(b: balanceLabel, i: incomeLabel, e: expenseLabel, data: tableData)
        } else {
            fmt.dateFormat = "dd.MM.yyyy"
            dateFrom = fmt.date(from: appData.filter.from)!
            while fmt.date(from: appData.filter.to) == nil {
                appData.filter.lastNumber -= 1
                appData.filter.to = appData.filter.getLastDay(appData.filter.filterObjects.currentDate)
            }
            dateTo = fmt.date(from: appData.filter.to)!
            while dateFrom <= dateTo {
                mydates.append(fmt.string(from: dateFrom))
                dateFrom = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom)!
            }
            appendFiltered(dates: mydates)
        }
        showNoDataLabel()
    }
    
    func appendFiltered(dates: [String]) {
        
        var arr = appData.transactions
        arr.removeAll()
        for number in 0..<dates.count {
            
            for i in 0..<appData.transactions.count {
                if dates[number] == appData.transactions[i].date {
                    arr.append(appData.transactions[i])
                }}}
        tableData = arr.sorted{ $0.dateFromString > $1.dateFromString }
    }
    
    func loadItems(_ request: NSFetchRequest<Transactions> = Transactions.fetchRequest(), predicate: NSPredicate? = nil) {
        
        do { appData.transactions = try appData.context.fetch(request).sorted{ $0.dateFromString > $1.dateFromString }
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}
        mainTableView.reloadData()
        appData.recalculation(b: balanceLabel, i: incomeLabel, e: expenseLabel, data: tableData)
    }
    
    func saveItems() {
        
        do { try appData.context.save()
        } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
        loadItems()
    }
    
    func showFilterAlert() {
        
        let alert = UIAlertController(title: "Custom Periud", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { (acrion) in
            self.setFilterDates()
            self.performFiltering()
            self.loadItems()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (cancel) in
            self.filterSegmentedControl.selectedSegmentIndex = 1
            self.filterPressed(self.filterSegmentedControl)
        }))
        alerts.alertTextField(alert: alert)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func setFilterDates() {
        
        appData.filter.showAll = false
        if appData.filter.filterObjects.startDateField.text == "" {
            appData.filter.filterObjects.startDateField.text = "\(appData.stringDate(appData.filter.filterObjects.startDatePicker))"
        }
        
        if appData.filter.filterObjects.endDateField.text == "" {
            appData.filter.filterObjects.endDateField.text = "\(appData.stringDate(appData.filter.filterObjects.endDatePicker))"
        }
        
        appData.filter.from = appData.filter.filterObjects.startDateField.text!
        appData.filter.to = appData.filter.filterObjects.endDateField.text!
        showCutomDateLabel(show: true)
    }
    
    func showCutomDateLabel(show: Bool) {
        
        if show == true {
            UIView.animate(withDuration: 0.2) {
                self.customDatesLabel.alpha = 0.5
                self.customDatesLabel.text = "\(appData.filter.from) →  \(appData.filter.to)" }
        } else {
            self.customDatesLabel.alpha = 0
            self.customDatesLabel.text = ""
        }
    }
    
    func showNoDataLabel() {
        
        if tableData.count == 0 {
            UIView.animate(withDuration: 0.2) {
                self.noTableDataLabel.alpha = 0.5 }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.noTableDataLabel.alpha = 0
            }
        }
    }

    @IBAction func filterPressed(_ sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex
        switch index {
           
        case 0:
            appData.filter.showAll = true
            appData.filter.from = ""
            appData.filter.to = ""
            performFiltering()
            loadItems()
            showCutomDateLabel(show: false)

        case 1:
            appData.filter.showAll = false
            appData.filter.from = appData.filter.getFirstDay(appData.filter.filterObjects.currentDate)
            appData.filter.to = appData.filter.getLastDay(appData.filter.filterObjects.currentDate)
            performFiltering()
            loadItems()
            showCutomDateLabel(show: false)

        case 2:
            appData.filter.showAll = false
            appData.filter.from = appData.stringDate(appData.filter.filterObjects.currentDate)
            appData.filter.to = appData.stringDate(appData.filter.filterObjects.currentDate)
            performFiltering()
            loadItems()
            showCutomDateLabel(show: false)
            
        case 3:
            showFilterAlert()
            
        default:
            appData.filter.showAll = true
            appData.filter.from = ""
            appData.filter.to = ""
            performFiltering()
            loadItems()
        }
    }
    
    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.performFiltering()
                self.loadItems()
            }
        }
    }
}

//MARK: - extension
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
        
        if data.value > 0 {
            cell.valueLabel.textColor = K.Colors.category
        } else {
            cell.valueLabel.textColor = K.Colors.negative
        }
        cell.valueLabel.text = "\(Int(data.value))"
        cell.categoryLabel.text = "\(data.category ?? K.Text.unknCat)"
        cell.dateLabel.text = data.date
        
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            appData.context.delete(self.tableData[indexPath.row])
            self.tableData.remove(at: indexPath.row)
            self.saveItems()
            self.loadItems()
        }
    }

}
