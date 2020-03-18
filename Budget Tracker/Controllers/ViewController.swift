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
var statisticBrain = StatisticBrain()
var sumAllCategories: [String: Double] = [:]
var allSelectedTransactionsData: [Transactions] = []
var expenseLabelPressed = true
var selectedPeroud = ""

class ViewController: UIViewController {

    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var buttonsFilterView: UIView!
    @IBOutlet weak var pressToShowFilterButtons: UIButton!
    @IBOutlet weak var thisMonthFilterButton: UIButton!
    @IBOutlet weak var customButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var allTimeButton: UIButton!
    @IBOutlet weak var filterTextLabel: UILabel!
    
    @IBOutlet weak var calculationSView: UIStackView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var addTransitionButton: UIButton!
    @IBOutlet weak var noTableDataLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    var tableData = appData.transactions.sorted{ $0.dateFromString > $1.dateFromString }
    var alerts = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        buttonsFilterView.alpha = 0
        filterOptionsPressed(thisMonthFilterButton)
    }
    
    func updateUI() {
        
        addTransitionButton.layer.cornerRadius = 15
        mainTableView.delegate = self
        mainTableView.dataSource = self
        loadItems()
        pressToShowFilterButtons.layer.cornerRadius = 6
        buttonsFilterView.layer.cornerRadius = 6
        buttonsFilterView.layer.shadowColor = UIColor.black.cgColor
        buttonsFilterView.layer.shadowOpacity = 0.2
        buttonsFilterView.layer.shadowOffset = .zero
        buttonsFilterView.layer.shadowRadius = 6
        customButton.layer.cornerRadius = 6
        todayButton.layer.cornerRadius = 6
        allTimeButton.layer.cornerRadius = 6
        thisMonthFilterButton.layer.cornerRadius = 6
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
        allSelectedTransactionsData = tableData
        
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
    
        statisticBrain.getData(from: self.tableData)
        sumAllCategories = statisticBrain.statisticData
    }
    
    func saveItems() {
        
        do { try appData.context.save()
        } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
        loadItems()
    }
    
    func showFilterAlert() {
        
        let alert = UIAlertController(title: "Custom period", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { (acrion) in
            self.setFilterDates()
            self.performFiltering()
            self.loadItems()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (cancel) in
            self.filterOptionsPressed(self.thisMonthFilterButton)
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
        selectedPeroud = "\(appData.filter.from) → \(appData.filter.to)"
        filterTextLabel.text = "Filter: \(selectedPeroud)"
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
    
    func removeBackground() {
        
        buttonsFilterView.alpha = 0
        thisMonthFilterButton.backgroundColor = K.Colors.pink
        customButton.backgroundColor = K.Colors.pink
        todayButton.backgroundColor = K.Colors.pink
        allTimeButton.backgroundColor = K.Colors.pink

    }
    
    func toggleFilterView() {
        if buttonsFilterView.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.buttonsFilterView.alpha = 0
                self.pressToShowFilterButtons.backgroundColor = K.Colors.background
                self.filterTextLabel.textColor = K.Colors.balanceT
                self.pressToShowFilterButtons.layer.shadowColor = UIColor.clear.cgColor
            }
            pressToShowFilterButtons.layer.shadowOpacity = 0
            pressToShowFilterButtons.layer.shadowOffset = .zero
            pressToShowFilterButtons.layer.shadowRadius = 0
        } else {
            UIView.animate(withDuration: 0.3) {
                self.buttonsFilterView.alpha = 1
                self.pressToShowFilterButtons.backgroundColor = K.Colors.pink
                self.filterTextLabel.textColor = K.Colors.balanceV
                self.pressToShowFilterButtons.layer.shadowColor = UIColor.black.cgColor
            }
            pressToShowFilterButtons.layer.shadowOpacity = 0.2
            pressToShowFilterButtons.layer.shadowOffset = .zero
            pressToShowFilterButtons.layer.shadowRadius = 6
        }
    }
    
    @IBAction func showFilterPressed(_ sender: UIButton) {
        toggleFilterView()
    }
    
    @IBAction func filterOptionsPressed(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3) {
            self.pressToShowFilterButtons.backgroundColor = K.Colors.background
        }
        
        switch sender.tag {
        case 0:
            appData.filter.showAll = true
            appData.filter.from = ""
            appData.filter.to = ""
            performFiltering()
            loadItems()
            selectedPeroud = "All time"
            filterTextLabel.text = "Filter: All Time"
            removeBackground()
            sender.backgroundColor = K.Colors.yellow
            
        case 1:
            appData.filter.showAll = false
            appData.filter.from = appData.filter.getFirstDay(appData.filter.filterObjects.currentDate)
            appData.filter.to = appData.filter.getLastDay(appData.filter.filterObjects.currentDate)
            performFiltering()
            loadItems()
            selectedPeroud = "This month"
            filterTextLabel.text = "Filter: This month"
            removeBackground()
            sender.backgroundColor = K.Colors.yellow

        case 2:
            appData.filter.showAll = false
            appData.filter.from = appData.stringDate(appData.filter.filterObjects.currentDate)
            appData.filter.to = appData.stringDate(appData.filter.filterObjects.currentDate)
            performFiltering()
            loadItems()
            selectedPeroud = "Today"
            filterTextLabel.text = "Filter: Today"
            removeBackground()
            sender.backgroundColor = K.Colors.yellow
            
        case 3:
            showFilterAlert()
            removeBackground()
            filterTextLabel.text = "Filter: Custom..."
            pressToShowFilterButtons.layer.shadowColor = UIColor.clear.cgColor
            sender.backgroundColor = K.Colors.yellow
            
        default:
            loadItems()
        }
        
    }
    
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            expenseLabelPressed = true
        case 1:
            expenseLabelPressed = false
        default:
            expenseLabelPressed = true
        }
        performSegue(withIdentifier: K.statisticSeque, sender: self)
        
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
        
        switch section {
        case 0: return 1
        case 1: return tableData.count
        case 2:
            if tableData.count < 3 {
                return 0
            } else { return 1 }
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let calculationCell = tableView.dequeueReusableCell(withIdentifier: K.calcCellIdent, for: indexPath) as! calcCell
            appData.recalculation(b: calculationCell.balanceLabel, i: calculationCell.incomeLabel, e: calculationCell.expensesLabel, data: tableData)
            return calculationCell
            
        case 1:
            let data = tableData[indexPath.row]
            let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
            transactionsCell.setupCell(data)
            return transactionsCell
            
        case 2:
            let highestExpenseCell = tableView.dequeueReusableCell(withIdentifier: K.plotCellIdent, for: indexPath) as! PlotCell
            highestExpenseCell.setupCell()
            return highestExpenseCell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            expenseLabelPressed = true
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        case 1:
            print("")
        case 2:
            expenseLabelPressed = true
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        default:
            print("")
        }
        
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                appData.context.delete(self.tableData[indexPath.row])
                self.tableData.remove(at: indexPath.row)
                self.saveItems()
                self.loadItems()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        switch indexPath.section {
        case 0:
            return UITableViewCell.EditingStyle.none
        case 1:
            return UITableViewCell.EditingStyle.delete
        case 2:
            return UITableViewCell.EditingStyle.none
        default:
            return UITableViewCell.EditingStyle.none
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            UIView.animate(withDuration: 0.3) {
                self.calculationSView.alpha = 1
            }
            filterView.alpha = 0
            buttonsFilterView.alpha = 0
            pressToShowFilterButtons.backgroundColor = K.Colors.background
            filterTextLabel.textColor = K.Colors.balanceT
            pressToShowFilterButtons.layer.shadowColor = UIColor.clear.cgColor
            pressToShowFilterButtons.layer.shadowOpacity = 0.2
            pressToShowFilterButtons.layer.shadowOffset = .zero
            pressToShowFilterButtons.layer.shadowRadius = 6
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            filterView.alpha = 1
            UIView.animate(withDuration: 0.3) {
                self.calculationSView.alpha = 0
            }
        }
    }
    
}
