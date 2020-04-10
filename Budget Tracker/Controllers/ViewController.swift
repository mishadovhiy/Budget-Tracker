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
    
    @IBOutlet weak var allTimeIpad: UIButton!
    @IBOutlet weak var thisMonthIpad: UIButton!
    @IBOutlet weak var todayIpad: UIButton!
    @IBOutlet weak var customIpad: UIButton!
    @IBOutlet weak var customDateLabelIpad: UILabel!
    
    @IBOutlet weak var calculationSView: UIStackView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var addTransitionButton: UIButton!
    @IBOutlet weak var noTableDataLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    var refreshControl = UIRefreshControl()
    var tableData = appData.transactions.sorted{ $0.dateFromString > $1.dateFromString }
    var alerts = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        filterOptionsPressed(thisMonthFilterButton)
    }
    
    func updateUI() {

        mainTableView.delegate = self
        mainTableView.dataSource = self
        loadItems()
        appData.styles.shadow(view: buttonsFilterView)
        appData.styles.cornerRadius(buttons: [pressToShowFilterButtons, customButton, todayButton, allTimeButton, allTimeIpad, thisMonthIpad, todayIpad, customIpad, thisMonthFilterButton], view: buttonsFilterView)
        buttonsFilterView.alpha = 0
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = K.Colors.separetor
        mainTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender:AnyObject) {
        performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            self.refreshControl.endRefreshing()
        }
    }
    
    func loadItems(_ request: NSFetchRequest<Transactions> = Transactions.fetchRequest(), predicate: NSPredicate? = nil) {
        
        do { appData.transactions = try appData.context().fetch(request).sorted{ $0.dateFromString > $1.dateFromString }
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}
        mainTableView.reloadData()
        appData.calculation.recalculation(i: incomeLabel, e: expenseLabel, data: tableData)
    
        statisticBrain.getData(from: self.tableData)
        sumAllCategories = statisticBrain.statisticData
        appData.calculation.calculateBalance(balanceLabel: balanceLabel)
    }
    
    func saveItems() {
        do { try appData.context().save()
        } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
        loadItems()
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
        appData.styles.showNoDataLabel(noTableDataLabel, tableData: tableData)//
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
    
    func showFilterAlert() {
        
        let alert = UIAlertController(title: "Custom period", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) { (acrion) in
            appData.filter.setFilterDates(iphoneLabel: self.filterTextLabel, ipadLabel: self.customDateLabelIpad)
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
    
    func toggleFilterView(filetButtonsOpasityShadow: Float, viewOpasity: Int, filetButtonsBackground: UIColor?, textColor: UIColor?, shadowColor: CGColor) {
        
        UIView.animate(withDuration: 0.3) {
            self.buttonsFilterView.alpha = CGFloat(viewOpasity)
            self.pressToShowFilterButtons.backgroundColor = filetButtonsBackground
            self.filterTextLabel.textColor = textColor
            self.pressToShowFilterButtons.layer.shadowColor = shadowColor
        }
        pressToShowFilterButtons.layer.shadowOpacity = filetButtonsOpasityShadow / 30
        pressToShowFilterButtons.layer.shadowOffset = .zero
        pressToShowFilterButtons.layer.shadowRadius = CGFloat(filetButtonsOpasityShadow)
        
    }
    
    @IBAction func showFilterPressed(_ sender: UIButton) {
        if buttonsFilterView.alpha == 1 {
            toggleFilterView(filetButtonsOpasityShadow: 0, viewOpasity: 0, filetButtonsBackground:  K.Colors.background, textColor: K.Colors.balanceT, shadowColor: UIColor.clear.cgColor)
        } else {
            toggleFilterView(filetButtonsOpasityShadow: 6, viewOpasity: 1, filetButtonsBackground: K.Colors.pink, textColor: K.Colors.balanceV, shadowColor: UIColor.black.cgColor)
        }
    }
    
    @IBAction func filterOptionsPressed(_ sender: UIButton) {
        
        appData.styles.removeBackground(buttons: [thisMonthFilterButton, customButton, todayButton, allTimeButton, allTimeIpad, thisMonthIpad, todayIpad, customIpad], labels: [customDateLabelIpad], views: [buttonsFilterView])
        UIView.animate(withDuration: 0.3) {
            self.pressToShowFilterButtons.backgroundColor = K.Colors.background
            sender.backgroundColor = K.Colors.yellow
        }
        DispatchQueue.main.async {
            self.filterCases(sender.tag)
        }
        selectedPeroud = sender.titleLabel?.text ?? "kfk"
        filterTextLabel.text = "Filter: \(selectedPeroud)"
        if sender.tag == 3 {
            filterTextLabel.text = "Filter: Custom..."
            customDateLabelIpad.text = "Custom..."
        }
        
    }
    
    func filterCases(_ n: Int) {
        
        if n == 0 {
            appData.filter.showAll = true
        } else {
            appData.filter.showAll = false
        }
        
        switch n {
        case 0:
            appData.filter.from = ""
            appData.filter.to = ""
            
        case 1:
            appData.filter.from = appData.filter.getFirstDay(appData.filter.filterObjects.currentDate)
            appData.filter.to = appData.filter.getLastDay(appData.filter.filterObjects.currentDate)
            
        case 2:
            appData.filter.from = appData.stringDate(appData.filter.filterObjects.currentDate)
            appData.filter.to = appData.stringDate(appData.filter.filterObjects.currentDate)
            
        case 3:
            showFilterAlert()
            pressToShowFilterButtons.layer.shadowColor = UIColor.clear.cgColor
            customDateLabelIpad.alpha = 1
            
        default: loadItems() }
        
        if n != 3 {
            performFiltering()
            loadItems()
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
    
    func deleteRow(at: Int) {
        
        appData.context().delete(tableData[at])
        self.tableData.remove(at: at)
        self.saveItems()
        self.loadItems()
    }
    
    func editRow(at: Int) {
        
        editingDate = tableData[at].date ?? ""
        editingValue = tableData[at].value
        editingCategory = tableData[at].category ?? ""
        performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
        deleteRow(at: at)
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
            calculationCell.setupCell(appData.calculation.totalBalance)
            return calculationCell
            
        case 1:
            let data = tableData[indexPath.row]
            let transactionsCell = tableView.dequeueReusableCell(withIdentifier: K.mainCellIdent, for: indexPath) as! mainVCcell
            transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData)
            appData.styles.dimNewCell(transactionsCell, index: indexPath.row, tableView: mainTableView)
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
            toggleFilterView(filetButtonsOpasityShadow: 0, viewOpasity: 0, filetButtonsBackground:  K.Colors.background, textColor: K.Colors.balanceT, shadowColor: UIColor.clear.cgColor)
            expenseLabelPressed = true
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        case 1:
            toggleFilterView(filetButtonsOpasityShadow: 0, viewOpasity: 0, filetButtonsBackground:  K.Colors.background, textColor: K.Colors.balanceT, shadowColor: UIColor.clear.cgColor)
        case 2:
            toggleFilterView(filetButtonsOpasityShadow: 0, viewOpasity: 0, filetButtonsBackground:  K.Colors.background, textColor: K.Colors.balanceT, shadowColor: UIColor.clear.cgColor)
            expenseLabelPressed = true
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        default:
            toggleFilterView(filetButtonsOpasityShadow: 0, viewOpasity: 0, filetButtonsBackground:  K.Colors.background, textColor: K.Colors.balanceT, shadowColor: UIColor.clear.cgColor)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 {
            let editeAction = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
                self.editRow(at: indexPath.row)
            }
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                self.deleteRow(at: indexPath.row)
            }
            editeAction.backgroundColor = K.Colors.yellow
            deleteAction.backgroundColor = K.Colors.negative
            return UISwipeActionsConfiguration(actions: [editeAction, deleteAction])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            calculationSView.alpha = 1
            filterView.alpha = 0
            toggleFilterView(filetButtonsOpasityShadow: 0, viewOpasity: 0, filetButtonsBackground:  K.Colors.background, textColor: K.Colors.balanceT, shadowColor: UIColor.clear.cgColor)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            filterView.alpha = 1
            calculationSView.alpha = 0
        }
    }
    
}
