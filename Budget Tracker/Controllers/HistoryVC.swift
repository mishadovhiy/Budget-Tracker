//
//  HistoryVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.03.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import UserNotifications


var transactionAdded = false

///TODO:
// if from debts - first section (dif beckground, cornerRadios) - add/edit time (2 cells: date, amount to pay)


class HistoryVC: SuperViewController {
    
    @IBOutlet weak var addTransButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategoryName = ""
    var fromCategories = false
    var allowEditing = true
    var debt: DebtsStruct? //use this indeed
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(selectedPurposeH, "selectedPurposeselectedPurposeH didlo")
        if !allowEditing {
            DispatchQueue.main.async {
                self.addTransButton.alpha = 0
            }
        } else {
            addTransButton.layer.shadowColor = UIColor.black.cgColor
            addTransButton.layer.shadowOpacity = 0.15
            addTransButton.layer.shadowOffset = .zero
            addTransButton.layer.shadowRadius = 10
        }
        transactionAdded = false
        historyDataStruct = historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
        tableView.delegate = self
        tableView.dataSource = self
        title = selectedCategoryName.capitalized

        
        
    }

    var fromStatistic = false

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getDebtData()
        
        
        //  addLocalNotification(date: "")
        center.getPendingNotificationRequests { (requests) in
            for i in 0..<requests.count {
                print(requests[i], "requestsrequestsrequests")
            }
        }
       
    }
    
    func stringToInterval(s: String) -> DateComponents {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let pressedHours = formater.date(from: s)
        if let date = pressedHours {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        } else {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        }
    }
    
    
    func addLocalNotification(date: DateComponents, title: String, completion: @escaping (Bool) -> ()) {
        
        //if date > today
        let id = "Debts\(title)"
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
            // Notifications not allowed
          }
        }
        
        let content = UNMutableNotificationContent()
        content.title = title//"Kirill"
        content.body = "Due date is expiring today"
        content.sound = UNNotificationSound.default
        let was = UIApplication.shared.applicationIconBadgeNumber
        content.badge = NSNumber(value: was + 1)
        content.categoryIdentifier = title
        content.threadIdentifier = "Debts"
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
     //   dateComponents.weekday = 5
        dateComponents.year = date.year
        dateComponents.month = date.month
        dateComponents.day = date.day
        dateComponents.hour = date.hour
        dateComponents.minute = date.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
        let request = UNNotificationRequest(identifier: id,
                    content: content, trigger: trigger)
        

        //center.removeAllPendingNotificationRequests()
        center.add(request) { (error) in
            if error != nil {
                print("notif add error")
            } else {
                print("no errorrs")
                var all = UserDefaults.standard.value(forKey: "notifications") as? [UNNotificationRequest] ?? []
                all.append(request)
                completion(true)
            }
        }
    }

    func getDebtData() {
        if allowEditing {
            let debts = Array(appData.debts)
            print(debts, "debtsdebtsdebts")
            for i in 0..<debts.count {
                if selectedCategoryName == debts[i].name {
                    self.debt = DebtsStruct(name: debts[i].name, amountToPay: debts[i].amountToPay, dueDate: debts[i].dueDate)
                    break
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

    func totalSum(label: UILabel, hasTotalAmount: Bool) {
        var sum = 0.0
        for i in 0..<historyDataStruct.count {
            sum += Double(historyDataStruct[i].value) ?? 1.0
        }

        let text = (sum < Double(Int.max) ? "\(Int(sum))" : "\(sum)") + (hasTotalAmount ? "/" : "")
        DispatchQueue.main.async {
            label.text = text
        }
    }
    
    @IBAction func toTransPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toTransVC", sender: self)
        }
    }

    var selectedPurposeH: Int?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toTransVC":
            toAddVC = true
            let nav = segue.destination as! NavigationController
            let vc = nav.topViewController as! TransitionVC
            vc.delegate = self
            vc.fromDebts = fromCategories ? true : false
            vc.editingCategory = self.selectedCategoryName
            vc.selectedPurpose = selectedPurposeH
        case "toCalendar":
            let vc = segue.destination as! CalendarVC
            vc.delegate = self
            let string = stringToDateComponent(s: self.debt?.dueDate ?? "", dateFormat: K.fullDateFormat)
            vc.selectedFrom = self.debt?.dueDate ?? "" == "" ? "" : "\(self.makeTwo(n: string.day ?? 0)).\(self.makeTwo(n: string.month ?? 0)).\(string.year ?? 0)"
            vc.datePickerDate = self.debt?.dueDate ?? ""
            vc.vcHeaderData = headerData(title: "Create notification", description: "Get notification reminder on specific date")
            vc.needPressDone = true
            vc.canSelectOnlyOne = true
            //headerData
            //vc.selectedFrom
        default:
            break
        }
    }

    var toAddVC = false
    
    @objc func toCalendarPressed(_ sender: UITapGestureRecognizer) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toCalendar", sender: self)
            }
        }
        
    }
    
    
    func dbLoadRemoveBeforeUpdate(completion: @escaping ([DebtsStruct], Bool) -> ()) {
        //self.loadingIndicator.show(title: "Updating data", appeareAnimation: true)
        self.loadingIndicator.show(title: "Updating data", appeareAnimation: true) { (_) in
            let load = LoadFromDB()
            load.Debts { (loadedDebts, error) in
                if error == "" {
                    let username = appData.username

                    var debtsResult: [DebtsStruct] = []
                    for i in 0..<loadedDebts.count {
                        let name = loadedDebts[i][1]
                        let amountToPay = loadedDebts[i][2]
                        let dueDate = loadedDebts[i][3]
                        debtsResult.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
                        if name == self.debt?.name {
                            self.debt?.amountToPay = amountToPay
                            self.debt?.dueDate = dueDate
                        }
                    }
                    appData.saveDebts(debtsResult)
                    
                    let delete = DeleteFromDB()
                    let deleteTods = "&Nickname=\(username)" + "&name=\(self.debt?.name ?? "")" + "&amountToPay=\(self.debt?.amountToPay ?? "")" + "&dueDate=\(self.debt?.dueDate ?? "")"
                    delete.Debts(toDataString: deleteTods) { (error) in
                        if error {
                            appData.unsendedData.append(["deleteDebt": deleteTods])
                        }
                        completion(debtsResult, true)
                    }
                    
                } else {
                    self.loadingIndicator.completeWithActions(buttonsTitles: (nil, "OK"), rightButtonActon: { (_) in
                        self.loadingIndicator.hideIndicator(fast: true) { (_) in
                        }
                    }, title: "No internet", description: "Enable to edit debts data in offline mode, come back later when you will be connected to the internet", error: true)
                }
                
            }
        }
        
    }
    
    func changeAmountToPay(enteredAmount:String, completion: @escaping (Any?) -> ()) {
        self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
            let save = SaveToDB()
            let saveToDs = "&Nickname=\(appData.username)" + "&name=\(self.debt?.name ?? "")" + "&amountToPay=\(enteredAmount)" + "&dueDate=\(self.debt?.dueDate ?? "")"
            
            save.Debts(toDataString: saveToDs) { (error) in
                if error {
                    appData.unsendedData.append(["debt": saveToDs])
                }
                
                var dataToSafe = loadedData
                for i in 0..<dataToSafe.count {
                    if dataToSafe[i].name == self.debt?.name {
                        dataToSafe[i].amountToPay = enteredAmount
                        break
                    }
                }
                appData.saveDebts(dataToSafe)
                completion(nil)
                
            }
        }
    }
    
    func changeAmountToPayWithtextField() {
        self.loadingIndicator.showTextField(type: .amount, textFieldText: self.debt?.amountToPay ?? "", title: "Amount to pay", description: "Enter how much is rest to pay") { (enteredAmount, _) in
            

            self.changeAmountToPay(enteredAmount: enteredAmount) { (_) in
                self.loadingIndicator.fastHide { (_) in
                    let result = enteredAmount == "0" ? "" : enteredAmount
                    self.debt?.amountToPay = result
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            //here
        }
    }

    
    func removeAlert() {
        //set dbalert ""
        //
    }
    
    
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0: return debt == nil ? 0 : 1
        case 1: return historyDataStruct.count
        case 2: return 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DebtDescriptionCell", for: indexPath) as! DebtDescriptionCell
            let dateComponent = stringToDateComponent(s: debt?.dueDate ?? "", dateFormat: K.fullDateFormat)
            print(dateComponent, "dateComponentdateComponentdateComponent")
            let date = "\(makeTwo(n: dateComponent.day ?? 0))"
            let month = "\(returnMonth(dateComponent.month ?? 0)), \(dateComponent.year ?? 0)"
            let expired = dateExpired(debt?.dueDate ?? "")
            let defaultBackground = cell.imageBackgroundView.backgroundColor
            cell.imageBackgroundView.backgroundColor = expired ? K.Colors.negative : defaultBackground
            cell.imageBackgroundView.layer.masksToBounds = true
            cell.imageBackgroundView.layer.cornerRadius = cell.imageBackgroundView.layer.frame.width / 2
            cell.alertDateLabel.text = debt?.dueDate != "" ? date : "Due date"
            cell.alertMonthLabel.text = debt?.dueDate != "" ? month : "Unset"
            cell.mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toCalendarPressed(_:))))
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.historyCellIdent, for: indexPath) as! HistoryCell
            let data = historyDataStruct[indexPath.row]
            
            if Double(data.value) ?? 0.0 > 0.0 {
                cell.valueLabel.textColor = UIColor(named: "darkTableColor")
            } else {
                cell.valueLabel.textColor = K.Colors.negative
                
            }
            cell.dateLabel.text = data.date
            if Double(data.value) ?? 0.0 < Double(Int.max) {
                cell.valueLabel.text = "\(Int(Double(data.value) ?? 0.0))"
            } else {
                cell.valueLabel.text = "\(data.value)"
                
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.historyCellTotalIdent) as! HistoryCellTotal
            cell.valueLabel.font = .systemFont(ofSize: debt?.amountToPay == "" ? 21 : 15, weight: debt?.amountToPay == "" ? .medium : .regular)
            totalSum(label: cell.valueLabel, hasTotalAmount: debt?.amountToPay ?? "" == "" ? false : true)
            if fromCategories {
                cell.perioudLabel.isHidden = true
            } else {
                cell.perioudLabel.text = selectedPeroud
            }
            if debt == nil {
                cell.noRestToPay.isHidden = true
                cell.restToPayLabel.isHidden = true
            } else {
                cell.noRestToPay.layer.masksToBounds = true
                cell.noRestToPay.layer.cornerRadius = 4
                if debt?.amountToPay == "" || debt?.amountToPay == "0" {
                    cell.noRestToPay.isHidden = false
                    cell.restToPayLabel.isHidden = true
                } else {
                    cell.noRestToPay.isHidden = true
                    cell.restToPayLabel.isHidden = false
                    cell.restToPayLabel.text = debt?.amountToPay
                }
            }
            
            cell.contentView.alpha = indexPath.row == 0 ? 1 : 0
            return cell
        default:
            return UITableViewCell()
        }
        

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section == 1 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                
                let mainFrame = view.frame
                let ai = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: mainFrame.height))
                ai.style = .gray
                view.addSubview(ai)
                ai.startAnimating()
                
                let transactions = Array(appData.getTransactions)
                var result: [TransactionsStruct] = []
                var newTableData: [TransactionsStruct] = []
                var found = false
                for i in 0..<transactions.count {
                    if !found {
                        if transactions[i].comment == self.historyDataStruct[indexPath.row].comment && transactions[i].date == self.historyDataStruct[indexPath.row].date && transactions[i].value == self.historyDataStruct[indexPath.row].value && transactions[i].category == self.historyDataStruct[indexPath.row].category{
                            found = true
                        } else {
                            result.append(transactions[i])
                            if transactions[i].category == self.historyDataStruct[indexPath.row].category {
                                newTableData.append(transactions[i])
                            }
                        }
                    } else {
                        result.append(transactions[i])
                        if transactions[i].category == self.historyDataStruct[indexPath.row].category {
                            newTableData.append(transactions[i])
                        }
                    }
                }
                
                if appData.username != "" {
                    let toDataString = "&Nickname=\(appData.username)" + "&Category=\(self.historyDataStruct[indexPath.row].category)" + "&Date=\(self.historyDataStruct[indexPath.row].date)" + "&Value=\(self.historyDataStruct[indexPath.row].value)" + "&Comment=\(self.historyDataStruct[indexPath.row].comment)"
                    let delete = DeleteFromDB()
                    delete.Transactions(toDataString: toDataString, completion: { (error) in
                        if error {
                            appData.unsendedData.append(["deleteTransaction": toDataString])
                        }
                        transactionAdded = true
                        appData.saveTransations(result)
                        self.historyDataStruct.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }

                    })
                } else {
                    transactionAdded = true
                    appData.saveTransations(result)
                    self.historyDataStruct.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
            deleteAction.backgroundColor = K.Colors.negative
            return UISwipeActionsConfiguration(actions: allowEditing ? [deleteAction] : [])
        } else {
            //check if debts has total amount
            return nil
        } 
    }
    
   /* func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let i = newItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
           // DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.selectRow(at: i, animated: true, scrollPosition: .middle)
                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
                    self.tableView.deselectRow(at: i, animated: true)
                    self.newItem = nil
                    self.tableView.endUpdates()
                }
            }
        }
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        if indexPath.section == 2 {
            DispatchQueue.main.async {
                if self.debt?.name == "" {
                    return
                }
                if self.debt?.amountToPay ?? "" == "" || self.debt?.amountToPay ?? "" == "0" {
                    self.changeAmountToPayWithtextField()
                } else {
                    self.loadingIndicator.completeWithActions(buttonsTitles: ("Remove","Change"), showCloseButton: true, leftButtonActon: { (_) in
                        //remove amount to pay

                        self.changeAmountToPay(enteredAmount: "") { (_) in
                            self.loadingIndicator.fastHide { (_) in
                                self.debt?.amountToPay = ""
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                    }, rightButtonActon: { (_) in
                        self.changeAmountToPayWithtextField()
                    }, title: "Do you want to change amount", error: false)
                }

                
            }
        }
    }
    
}

extension HistoryVC: TransitionVCProtocol {
    func quiteTransactionVC(){
    }
    func addNewTransaction(value: String, category: String, date: String, comment: String) {
        toAddVC = false
        let new = TransactionsStruct(value: value, category: category, date: date, comment: comment)
        print(new, "newnewnewnew")
        
        if value != "" && category != "" && date != "" {
            transactionAdded = true
            if appData.username != "" {
                let toDataString = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                let save = SaveToDB()
                save.Transactions(toDataString: toDataString) { (error) in
                    if error {
                        let neew: String = "&Nickname=\(appData.username)" + "&Category=\(category)" + "&Date=\(date)" + "&Value=\(value)" + "&Comment=\(comment)"
                        appData.unsendedData.append(["transaction": neew])
                    }
                    
                    var trans = appData.getTransactions
                    trans.append(new)
                    appData.saveTransations(trans)
                    
                    self.historyDataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                    self.historyDataStruct = self.historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    var indexPath: IndexPath?
                    for i in 0..<self.historyDataStruct.count {
                        if self.historyDataStruct[i].category == new.category && self.historyDataStruct[i].comment == new.comment && self.historyDataStruct[i].date == new.date && self.historyDataStruct[i].value == new.value {
                            indexPath = IndexPath(row: i, section: 1)
                            break
                        }
                    }
                    if let i = indexPath {
                        DispatchQueue.main.async {
                            self.tableView.selectRow(at: i, animated: true, scrollPosition: .middle)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            self.tableView.deselectRow(at: i, animated: true)
                        }
                    }
                }
            } else {
                var trans = appData.getTransactions
                trans.append(new)
                appData.saveTransations(trans)
                
                self.historyDataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
                self.historyDataStruct = self.historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    
    
    
}


class DebtDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var noAlertIndicator: UILabel!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var alertDateLabel: UILabel!
    @IBOutlet weak var alertMonthLabel: UILabel!
}


extension HistoryVC: CalendarVCProtocol {
    func dateSelected(date: String, time: DateComponents?) {
        DispatchQueue.main.async {
            self.loadingIndicator.show { (_) in

                let fullDate = "\(date) \(self.makeTwo(n: time?.hour ?? 0)):\(self.makeTwo(n: time?.minute ?? 0)):\(self.makeTwo(n: time?.second ?? 0))"
                print(fullDate, "fullDatefullDatefullDatefullDate")
                let dateComp = self.stringToDateComponent(s: fullDate, dateFormat: K.fullDateFormat)
                print(dateComp, "dateCompdateCompdateComp")
                
                
                self.addLocalNotification(date: dateComp, title: self.debt?.name ?? "") { (_) in
                    self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
                        let save = SaveToDB()
                        let saveToDs = "&Nickname=\(appData.username)" + "&name=\(self.debt?.name ?? "")" + "&amountToPay=\(self.debt?.amountToPay ?? "")" + "&dueDate=\(fullDate)"
                        save.Debts(toDataString: saveToDs) { (error) in
                            if error {
                                appData.unsendedData.append(["debt": saveToDs])
                            }
                            
                            var dataToSafe = loadedData
                            for i in 0..<dataToSafe.count {
                                if dataToSafe[i].name == self.debt?.name {
                                    dataToSafe[i].dueDate = fullDate
                                    break
                                }
                            }
                            appData.saveDebts(dataToSafe)
                            
                            self.loadingIndicator.fastHide { (_) in
                                self.debt?.dueDate = fullDate
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    
}
