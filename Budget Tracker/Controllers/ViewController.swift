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
var allSelectedTransactionsData: [TransactionsStruct] = []
var expenseLabelPressed = true
var selectedPeroud = ""

class ViewController: UIViewController {
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTextLabel: UILabel!
    
    @IBOutlet weak var calculationSView: UIStackView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var addTransitionButton: UIButton!
    @IBOutlet weak var noTableDataLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    var refreshControl = UIRefreshControl()
    var tableData = appData.getTransactions().sorted{ $0.dateFromString > $1.dateFromString }
    var alerts = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appData.setUsername("Misha")
        updateUI()
        defaultFilter()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("today is", appData.filter.getToday(appData.filter.filterObjects.currentDate))
    }
    
    func updateUI() {

        switchFromCoreData()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        addRefreshControll()
        let showCatsSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showCats(_:)))
        showCatsSwipe.direction = .right
        view.addGestureRecognizer(showCatsSwipe)
        calculateLabels()
        
    }
    
    func defaultFilter() {
        
        selectedPeroud = "This Month"
        filterTextLabel.text = "Filter: \(selectedPeroud)"
        appData.filter.showAll = false

        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let monthInt = appData.filter.getMonthFromString(s: today)
        let yearInt = appData.filter.getYearFromString(s: today)
        let dayTo = appData.filter.getLastDayOf(month: monthInt, year: yearInt)
        appData.filter.from = "01.\(appData.filter.makeTwo(n: monthInt)).\(yearInt)"
        appData.filter.to = "\(dayTo).\(appData.filter.makeTwo(n: monthInt)).\(yearInt)"
        performFiltering(from: appData.filter.from, to: appData.filter.to, all: appData.filter.showAll)
        
    }
    
    @objc func refresh(sender:AnyObject) {
        
        performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            self.refreshControl.endRefreshing()
        }
    }
    
    func performFiltering(from: String, to: String, all: Bool) {
        
        let fromVar = from
        let toVar = to
        var mydates: [String] = []
        var dateFrom = Date()
        var dateTo = Date()
        let fmt = DateFormatter()
        if all == true {
            tableData = appData.getTransactions().sorted{ $0.dateFromString > $1.dateFromString }
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
            print("showing for all time")
        } else {
            fmt.dateFormat = "dd.MM.yyyy"
            dateFrom = fmt.date(from: fromVar)!
            dateTo = fmt.date(from: toVar)!
            while dateFrom <= dateTo {
                mydates.append(fmt.string(from: dateFrom))
                dateFrom = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom)!
            }
            appendFiltered(dates: mydates)
        }
        appData.styles.showNoDataLabel(noTableDataLabel, tableData: tableData)
        allSelectedTransactionsData = tableData
        print("performFiltering FROM: \(from), TO: \(to), SHOW ALL: \(all)")
        
    }
    
    func appendFiltered(dates: [String]) {
           
        var arr = appData.getTransactions()
        arr.removeAll()
        for number in 0..<dates.count {
            
            for i in 0..<appData.getTransactions().count {
                if dates[number] == appData.getTransactions()[i].date {
                    arr.append(appData.getTransactions()[i])
                }
            }
        }
        tableData = arr.sorted{ $0.dateFromString > $1.dateFromString }
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
        
        print("appendFiltered")
    }
    
    @IBAction func statisticLabelPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 0: expenseLabelPressed = true
        case 1: expenseLabelPressed = false
        default: expenseLabelPressed = true
        }
        performSegue(withIdentifier: K.statisticSeque, sender: self)
    }
    
    func deleteRow(at: Int) {
        
        tableData.remove(at: at)
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
        appData.saveTransations(tableData)
        calculateLabels()
    }
    
    func editRow(at: Int) {
        
        print("change edit")
        editingDate = tableData[at].date
        editingValue = Double(tableData[at].value) ?? 0.0
        editingCategory = tableData[at].category
        editingComment = tableData[at].comment
        performSegue(withIdentifier: K.goToEditVCSeq, sender: self)
        deleteRow(at: at)
    }
    
    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.performFiltering(from: appData.filter.from, to: appData.filter.to, all: appData.filter.showAll)
                editingDate = ""
                editingCategory = ""
                editingValue = 0.0
                editingComment = ""
                self.mainTableView.reloadData()
                self.calculateLabels()
            }
        }
    }
    
    @IBAction func unwindToFilter(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if appData.filter.from == "" && appData.filter.to == "" && appData.filter.showAll == false {
                    self.defaultFilter()
                    self.calculateLabels()
                    print("no selected for filter, showing default filter")
                } else {
                    self.filterTextLabel.text = "Filter: \(selectedPeroud)"
                    self.performFiltering(from: appData.filter.from, to: appData.filter.to, all: appData.filter.showAll)
                    self.calculateLabels()
                    print("Filter: \(selectedPeroud)")
                }
            }
        }
    }
    
    func addRefreshControll() {
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "+")
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.clear
        mainTableView.addSubview(refreshControl)
    }
    
    @objc func showCats(_ gesture: UISwipeGestureRecognizer) {
        
        performSegue(withIdentifier: "toCatsVC", sender: self)
    }
    
    func calculateLabels() {
        
        appData.calculation.recalculation(i: incomeLabel, e: expenseLabel, data: tableData)
        statisticBrain.getlocalData(from: self.tableData)
        sumAllCategories = statisticBrain.statisticData
        appData.calculation.calculateBalance(balanceLabel: balanceLabel)
    }
    
    var previusSelected: IndexPath? = nil
    var selectedCell: IndexPath? = nil
    
    
//MARK: - Core Data
    
    func switchFromCoreData() {
        
        loadItemsCoreData()
        if appData.transactionsCoreData.count != 0 {
            var alldata = appData.getTransactions()
            
            for i in 0..<appData.transactionsCoreData.count  {
                let value = "\(appData.transactionsCoreData[i].value)"
                let category = appData.transactionsCoreData[i].category ?? ""
                let date = appData.transactionsCoreData[i].date ?? ""
                let comment = appData.transactionsCoreData[i].comment ?? ""
                
                alldata.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                
            }
            appData.saveTransations(alldata)
            print(appData.getTransactions(), "transactions setted to defaults")
            
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
            
            for i in 0..<appData.transactionsCoreData.count {
                appData.context().delete(appData.transactionsCoreData[i])
                do { try appData.context().save()
                } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
            }
            print("after deleting core data, left: \(appData.transactionsCoreData.count)")
        } else {
            print("Transactions: core data count = \(appData.transactionsCoreData.count)")
        }
        
        if appData.categoriesCoreData.count != 0 {
            var allData = appData.getCategories()
            
            for i in 0..<appData.categoriesCoreData.count {
                let name = appData.categoriesCoreData[i].name ?? ""
                let purpose = appData.categoriesCoreData[i].purpose ?? ""
                
                allData.append(CategoriesStruct(name: name, purpose: purpose))
            }
            appData.saveCategories(allData)
            print(appData.getCategories(), "categories setted to defaults")
        } else {
            print("Categories: core data count = \(appData.categoriesCoreData.count)")
        }
        
    }
    
    func loadItemsCoreData(_ request: NSFetchRequest<Transactions> = Transactions.fetchRequest(), predicate: NSPredicate? = nil) {
        
        do { appData.transactionsCoreData = try appData.context().fetch(request)
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}
        
        let catRequest: NSFetchRequest<Categories> = Categories.fetchRequest()
        do { appData.categoriesCoreData = try appData.context().fetch(catRequest)
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}
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
            transactionsCell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell)
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
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        case 1:
            if selectedCell == indexPath {
                selectedCell = nil
            } else {
                previusSelected = selectedCell
                selectedCell = indexPath
            }
            DispatchQueue.main.async {
                self.mainTableView.reloadRows(at: [indexPath, self.previusSelected ?? indexPath], with: .automatic)
            }
            
        case 2:
            expenseLabelPressed = true
            performSegue(withIdentifier: K.statisticSeque, sender: self)
        default:
            print("1")
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
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            filterView.alpha = 1
            calculationSView.alpha = 0
        }
    }
    
}
