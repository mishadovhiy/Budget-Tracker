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
        buttonsFilterView.alpha = 0
    }
    
    func performFiltering() {
        
        var mydates: [String] = []
        var dateFrom = Date()
        var dateTo = Date()
        let fmt = DateFormatter()
        if appData.filter.showAll == true {
            tableData = appData.transactions.sorted{ $0.dateFromString > $1.dateFromString }
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
    
    var totalBalance = 0.0
    func calculateBalance() {
        
        var totalExpenses = 0.0
        var totalIncomes = 0.0
        
        for i in 0..<appData.transactions.count {
            if appData.transactions[i].value > 0.0 {
                totalIncomes = totalIncomes + appData.transactions[i].value
            } else {
                totalExpenses = totalExpenses + appData.transactions[i].value
            }
        }
        
        totalBalance = totalIncomes + totalExpenses
        if totalBalance < Double(Int.max) {
            balanceLabel.text = "\(Int(totalBalance))"
        } else { balanceLabel.text = "\(totalBalance)" }
        
        if totalBalance < 0.0 {
            balanceLabel.textColor = K.Colors.negative
        } else {
            balanceLabel.textColor = K.Colors.balanceV
        }
        
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
        calculateBalance()
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
    
    func hideFilterView() {
        UIView.animate(withDuration: 0.3) {
            self.buttonsFilterView.alpha = 0
            self.pressToShowFilterButtons.backgroundColor = K.Colors.background
            self.filterTextLabel.textColor = K.Colors.balanceT
            self.pressToShowFilterButtons.layer.shadowColor = UIColor.clear.cgColor
        }
        pressToShowFilterButtons.layer.shadowOpacity = 0
        pressToShowFilterButtons.layer.shadowOffset = .zero
        pressToShowFilterButtons.layer.shadowRadius = 0
    }
    
    func showFilterView() {
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
    
    func toggleFilterView() {
        if buttonsFilterView.alpha == 1 {
            hideFilterView()
        } else { showFilterView() }
    }
    
    @IBAction func showFilterPressed(_ sender: UIButton) {
        toggleFilterView()
    }
    
    @IBAction func filterOptionsPressed(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3) {
            self.pressToShowFilterButtons.backgroundColor = K.Colors.background
        }
        removeBackground()
        sender.backgroundColor = K.Colors.yellow
        
        switch sender.tag {
        case 0:
            appData.filter.showAll = true
            appData.filter.from = ""
            appData.filter.to = ""
            performFiltering()
            loadItems()
            selectedPeroud = "All time"
            
        case 1:
            appData.filter.showAll = false
            appData.filter.from = appData.filter.getFirstDay(appData.filter.filterObjects.currentDate)
            appData.filter.to = appData.filter.getLastDay(appData.filter.filterObjects.currentDate)
            performFiltering()
            loadItems()
            selectedPeroud = "This Month"

        case 2:
            appData.filter.showAll = false
            appData.filter.from = appData.stringDate(appData.filter.filterObjects.currentDate)
            appData.filter.to = appData.stringDate(appData.filter.filterObjects.currentDate)
            performFiltering()
            loadItems()
            selectedPeroud = "Today"
            
        case 3:
            showFilterAlert()
            pressToShowFilterButtons.layer.shadowColor = UIColor.clear.cgColor
            
        default: loadItems() }
        
        filterTextLabel.text = "Filter: \(selectedPeroud)"
        if sender.tag == 3 {
            filterTextLabel.text = "Filter: Custom..."
        }
        
    }
    
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: expenseLabelPressed = true
        case 1: expenseLabelPressed = false
        default: expenseLabelPressed = true
        }
        performSegue(withIdentifier: K.statisticSeque, sender: self)
        
    }
    
    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.performFiltering()
                self.loadItems()
                
                editingDate = ""
                editingCategory = ""
                editingValue = 0.0
            }
        }
    }
    
    func dimNewCell(_ transactionsCell: mainVCcell, index: Int) {

        if transactionsCell.bigDate.text == highliteDate {
            DispatchQueue.main.async {
                self.mainTableView.scrollToRow(at: IndexPath(row: index, section: 1), at: .top, animated: true)
            }
            UIView.animate(withDuration: 0.6) {
                transactionsCell.contentView.backgroundColor = K.Colors.separetor
            }
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                UIView.animate(withDuration: 0.6) {
                    transactionsCell.contentView.backgroundColor = K.Colors.background
                    highliteDate = " "
                }
            }
        }
    }
    
    func delereRow(at: Int) {
        
        appData.context.delete(tableData[at])
        self.tableData.remove(at: at)
        self.saveItems()
        self.loadItems()
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
            calculationCell.setupCell(totalBalance)
            return calculationCell
            
        case 1:
            let data = tableData[indexPath.row]
            //crash after adding scroll to
            let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
            transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData)
            dimNewCell(transactionsCell, index: indexPath.row)
            return transactionsCell
            
        case 2:
            let highestExpenseCell = tableView.dequeueReusableCell(withIdentifier: K.plotCellIdent, for: indexPath) as! PlotCell
            highestExpenseCell.setupCell()
            return highestExpenseCell
            
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            hideFilterView()
            expenseLabelPressed = true
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        case 1:
            hideFilterView()
            editingDate = tableData[indexPath.row].date ?? ""
            editingValue = tableData[indexPath.row].value
            editingCategory = tableData[indexPath.row].category ?? ""
            performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
            delereRow(at: indexPath.row)
            
        case 2:
            hideFilterView()
            expenseLabelPressed = true
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        default:
            hideFilterView()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                delereRow(at: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        switch indexPath.section {
        case 0: return UITableViewCell.EditingStyle.none
        case 1: return UITableViewCell.EditingStyle.delete
        case 2: return UITableViewCell.EditingStyle.none
        default: return UITableViewCell.EditingStyle.none
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            UIView.animate(withDuration: 0.3) {
                self.calculationSView.alpha = 1
            }
            filterView.alpha = 0
            hideFilterView()
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
