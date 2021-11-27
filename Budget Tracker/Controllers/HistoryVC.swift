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
    private var amountToPayTFTag = 9
    @IBOutlet weak var addTransButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategoryName = ""
    var fromCategories = false
    var allowEditing = true
    var debt: DebtsStruct? //use this indeed
    
    var amountToPayEditing = false
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        let appData = AppData()
        //get screen data
        let addAmountToPay = {
            self.amountToPayEditing = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
            }
        }
        
        let addDueDate = {
            self.tocalendatPressed()
            
        }
        
        let moreData = [
            MoreVC.ScreenData(name: "Add amount to pay", description: "", action: addAmountToPay),
            MoreVC.ScreenData(name: "Add Due date", description: "", action: addDueDate),
        ]
        appData.presentMoreVC(currentVC: self, data: moreData, dismissOnAction: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(selectedPurposeH, "selectedPurposeselectedPurposeH didlo")
        if !allowEditing {
         //   DispatchQueue.main.async {
                self.addTransButton.alpha = 0
           // }
        } else {
            addTransButton.layer.shadowColor = UIColor.black.cgColor
            addTransButton.layer.shadowOpacity = 0.15
            addTransButton.layer.shadowOffset = .zero
            addTransButton.layer.shadowRadius = 10
        }
        transactionAdded = false
        historyDataStruct = historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
        print(historyDataStruct.count, "didlocount")
        tableView.delegate = self
        tableView.dataSource = self
        title = selectedCategoryName.capitalized

   //     DispatchQueue.main.async {
            self.addTransButton.layer.cornerRadius = self.addTransButton.layer.frame.width / 2
            //self.addTransButton.layer.masksToBounds = true
     //   }
        getDebtData()
        
        //here exp
        
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    var fromStatistic = false

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if let debt = self.debt {
      //      center.removePendingNotificationRequests(withIdentifiers: ["Debts\(debt.name)"])
            center?.removeDeliveredNotifications(withIdentifiers: ["Debts\(debt.name)"])
            center?.getDeliveredNotifications { notifications in
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = notifications.count
                }
            }
        }
        
       
        if allowEditing {
            DispatchQueue.main.async {
                self.tableView.contentInset.bottom = self.addTransButton.frame.height + 20
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
    
    let center = AppDelegate.shared?.center
    func addLocalNotification(date: DateComponents, completion: @escaping (Bool) -> ()) {
        
        //if date > today
        let title = self.debt?.name ?? ""
        let id = "Debts\(self.debt?.name ?? "")"
        center?.removePendingNotificationRequests(withIdentifiers: ["Debts\(self.debt?.name ?? "")"])
        center?.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
            // Notifications not allowed
          }
        }
        
        
        let content = UNMutableNotificationContent()
        content.title = title//"Kirill"
        content.body = "Due date is expiring today"
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        content.categoryIdentifier = title
        content.threadIdentifier = id
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
        center?.add(request) { (error) in
            
            if error != nil {
                print("notif add error")
            } else {
                print("no errorrs")
               // var all = UserDefaults.standard.value(forKey: "notifications") as? [UNNotificationRequest] ?? []
                //all.append(request)
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

            if let name = self.debt?.name {
                DispatchQueue.main.async {
                    if self.moreButton.isHidden != false {
                        self.moreButton.isHidden = false
                    }
                }
                if debt?.dueDate != "" {
                 /*   let expired = dateExpired(debt?.dueDate ?? "")
                    if expired {
                        let id = "Debts\(name)"
                     //   self.center.removePendingNotificationRequests(withIdentifiers: [id])
                    }*/
                }
                
          /*      center.getPendingNotificationRequests { (requests) in
                    DispatchQueue.main.async {
                        UIApplication.shared.applicationIconBadgeNumber = requests.count
                    }
                    for i in 0..<requests.count {
                        print(requests[i], "requestsrequestsrequests")
                    }
                }*/
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

    func totalSum() -> Double {
        var sum = 0.0
        for i in 0..<historyDataStruct.count {
            sum += Double(historyDataStruct[i].value) ?? 1.0
        }

        return sum
        //let text = (sum < Double(Int.max) ? "\(Int(sum))" : "\(sum)") + (hasTotalAmount ? "/" : "")
        
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
        tocalendatPressed()
        
    }
    
    
    func changeDueDate(fullDate: String) {
        //self.addLocalNotification(date: dateComp, title: self.debt?.name ?? "") { (_) in
            self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
                let save = SaveToDB()
                let saveToDs = "&Nickname=\(appData.username)" + "&name=\(self.debt?.name ?? "")" + "&amountToPay=\(self.debt?.amountToPay ?? "")" + "&dueDate=\(fullDate)"
                save.Debts(toDataString: saveToDs) { (error) in
                    self.debt?.dueDate = fullDate
                    print(self.debt?.dueDate, "self.debt?.dueDateself.debt?.dueDate")
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
                    self.ai.fastHide { (_) in
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                }
            }
        //}
    }
    
    func tocalendatPressed() {
        
        center?.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toCalendar", sender: self)
            }
        }
    }
    
    func dbLoadRemoveBeforeUpdate(completion: @escaping ([DebtsStruct], Bool) -> ()) {
        //self.loadingIndicator.show(title: "Updating data", appeareAnimation: true)
       // self.loadingIndicator?.show(title: "", appeareAnimation: true) { (_) in
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
                /*    self.loadingIndicator.completeWithActions(buttonsTitles: (nil, "OK"), rightButtonActon: { (_) in
                        self.loadingIndicator.hideIndicator(fast: true) { (_) in
                        }
                    }, title: "No internet", description: "Enable to edit debts data in offline mode, come back later when you will be connected to the internet", error: true)*/
                }
                
            }
       // }
        
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
        self.ai.showTextField(type: .amount, textFieldText: self.debt?.amountToPay ?? "", title: "Amount to pay", description: "Enter how much is rest to pay") { (enteredAmount, _) in
            

            self.changeAmountToPay(enteredAmount: enteredAmount) { (_) in
                self.ai.fastHide { (_) in
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
    
    var calendarAmountPressed = (false, false)
    
}





extension HistoryVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.endEditing(true)
            
        }
        switch textField.tag {
        case amountToPayTFTag:
            
                
                    let text = textField.text ?? ""
                    if let _ = Int(text) {
                        DispatchQueue.main.async {
                            self.ai.show(title: "Sending") { _ in
                                self.changeAmountToPay(enteredAmount: text) { (_) in
                                    self.ai.fastHide { (_) in
                                        let result = text == "0" ? "" : text
                                        self.debt?.amountToPay = result
                                        self.amountToPayEditing = false
                                        //DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        //}
                                    }
                                }
                            }
                        }
                        
                    }
                
            
        default:
            break
        }
        
        return true
    }
}





extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0: return debt == nil ? 0 : 1
        case 1: return historyDataStruct.count == 0 ? 1 : historyDataStruct.count
        case 2: return 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func removeDueDate() {
        self.changeDueDate(fullDate: "")
                        
                        let id = "Debts\(self.debt?.name ?? "")"
                        self.center?.removePendingNotificationRequests(withIdentifiers: [id])
                        DispatchQueue.main.async {
                            self.ai.fastHide(completionn: { _ in
                                
                            })
                        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DebtDescriptionCell", for: indexPath) as! DebtDescriptionCell
            cell.cellPressed = calendarAmountPressed.0


            
            cell.changeButton.superview?.isHidden = calendarAmountPressed.0 ? false : true
            

            let changeAction = {
                self.tocalendatPressed()
            }
            let removeAction = {
                self.removeDueDate()
            }
            cell.changeAction = changeAction
            

            cell.removeAction = removeAction
            
            let dateComponent = stringToDateComponent(s: debt?.dueDate ?? "", dateFormat: K.fullDateFormat)
            print(dateComponent, "dateComponentdateComponentdateComponent")
            let date = "\(makeTwo(n: dateComponent.day ?? 0))"
            let month = "\(returnMonth(dateComponent.month ?? 0)), \(dateComponent.year ?? 0)"
            let expired = dateExpired(debt?.dueDate ?? "")
            cell.expired = expired
            let diff = dateExpiredCount(startDate: debt?.dueDate ?? "")
            let expText = expiredText(diff)
            cell.expiredDaysCount.text = "Expired:" + (expText == "" ? " recently" : "\(expText) ago")
            cell.expiredDaysCount.superview?.isHidden = expired ? ((debt?.dueDate == "" ? true : false)) : true
            print(expired, "expiredexpiredexpired")
            let defaultBackground = UIColor(red: 199/255, green: 197/255, blue: 197/255, alpha: 1)
            cell.imageBackgroundView.backgroundColor = defaultBackground//expired ? K.Colors.negative : defaultBackground
            cell.imageBackgroundView.layer.masksToBounds = true
            cell.imageBackgroundView.layer.cornerRadius = cell.imageBackgroundView.layer.frame.width / 2
            cell.alertDateLabel.text = debt?.dueDate != "" ? date : "Due date"
            cell.alertMonthLabel.text = debt?.dueDate != "" ? month : "Unset"
            cell.timeLabel.backgroundColor = defaultBackground
            cell.timeLabel.layer.cornerRadius = 4
            cell.timeLabel.layer.masksToBounds = true
            cell.AlertDateStack.axis = debt?.dueDate != "" ? .horizontal : .vertical
            cell.AlertDateStack.alignment = debt?.dueDate != "" ? .firstBaseline : .fill
            cell.timeLabel.isHidden = debt?.dueDate != "" ? false : true
            cell.timeLabel.text = "\(makeTwo(n: dateComponent.hour ?? 0)):" + "\(makeTwo(n: dateComponent.minute ?? 0))"
            cell.mainView.alpha = expired ? (debt?.dueDate == "" ? 1 : 0.4) : 1
          //  cell.mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toCalendarPressed(_:))))
            
            return cell
        case 1:
            if historyDataStruct.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyCell
                cell.selectionStyle = .none
                return cell
            } else {
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
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.historyCellTotalIdent) as! HistoryCellTotal
           // cell.valueLabel.font = .systemFont(ofSize: debt?.amountToPay == "" ? 21 : 15, weight: debt?.amountToPay == "" ? .medium : .regular)
            
            
            let removeAmountAction = {
                self.removeAmountToPay()
            }
            
            cell.deleteFunc = removeAmountAction
            
            let changeFunc = {
                self.amountToPayEditing = true
                self.calendarAmountPressed = (false,false)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            cell.changeFunc = changeFunc
            
            let hideTF = amountToPayEditing ? false : true
            if hideTF != cell.amountTF.isHidden {
                cell.amountTF.isHidden = hideTF
                
            }
            
            
            
            
            
            if amountToPayEditing {
                cell.amountTF.tag = amountToPayTFTag
                cell.amountTF.delegate = self
                cell.amountTF.becomeFirstResponder()
            }
            
            let hideButtons = calendarAmountPressed.1 ? (amountToPayEditing ? true : (debt?.amountToPay ?? "0" == "" ? true : false)) : true
            if cell.changeButton.superview?.isHidden ?? true != hideButtons {
                cell.changeButton.superview?.isHidden = hideButtons
            }
            let hasTotalSum = debt?.amountToPay ?? "" == "" || debt?.amountToPay ?? "0" == "" ? false : true
            let totalSumm = totalSum()
            cell.valueLabel.text = (totalSumm < Double(Int.max) ? "\(Int(totalSumm))" : "\(totalSumm)")
            
            cell.totalToPayLabel.text = debt?.amountToPay
            let rest = (Double(debt?.amountToPay ?? "0") ?? 0.0) - totalSumm
            cell.restToPayyLabel.text = (rest < Double(Int.max) ? "\(Int(rest))" : "\(rest)") //+ (rest > 0.0 ? " Complited" : "") //"\(rest)"
            cell.totalToPayLabel.superview?.isHidden = hasTotalSum ? false : true
            cell.restToPayyLabel.superview?.isHidden = hasTotalSum ? false : true
            cell.restToPayyLabel.superview?.superview?.isHidden = hasTotalSum ? false : true
            if fromCategories {
                cell.perioudLabel.isHidden = true
            } else {
                cell.perioudLabel.text = selectedPeroud
            }
            if debt == nil {
              //  cell.noRestToPay.isHidden = true
                cell.totalToPayLabel.isHidden = true
            } else {
               // cell.noRestToPay.layer.masksToBounds = true
              //  cell.noRestToPay.layer.cornerRadius = 4
                if debt?.amountToPay == "" || debt?.amountToPay == "0" {
             //       cell.noRestToPay.isHidden = false
                    cell.totalToPayLabel.isHidden = true
                } else {
               //     cell.noRestToPay.isHidden = true
                    cell.totalToPayLabel.isHidden = false
                    cell.totalToPayLabel.text = debt?.amountToPay
                }
            }
            
            cell.contentView.alpha = indexPath.row == 0 ? 1 : 0
            return cell
        default:
            return UITableViewCell()
        }
        

    }
    
    
    func removeAmountToPay() {
        self.changeAmountToPay(enteredAmount: "") { (_) in
            self.ai.fastHide { (_) in
                self.debt?.amountToPay = ""
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
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
            return historyDataStruct.count == 0 ? nil : UISwipeActionsConfiguration(actions: allowEditing ? [deleteAction] : [])
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
                if self.debt?.amountToPay ?? "" != "" && !self.calendarAmountPressed.1 {
                    let isPressed = self.calendarAmountPressed.1 ? false : true
                    print(isPressed, "isPressedisPressedisPressed")
                    self.calendarAmountPressed = (false, isPressed)
                    tableView.reloadData()
                } else {
                    self.calendarAmountPressed = (false,false)
                    tableView.reloadData()
                }
            }
        } else {
            if indexPath.section == 0 {
                if self.debt?.dueDate ?? "" != "" && !self.calendarAmountPressed.0 {
                    let isPressed = calendarAmountPressed.0 ? false : true
                    print(isPressed, "isPressedisPressedisPressed")
                    calendarAmountPressed = (isPressed, false)
                    tableView.reloadData()
                } else {
                    calendarAmountPressed = (false,false)
                    tableView.reloadData()
                }
            } else {
                calendarAmountPressed = (false,false)
                tableView.reloadData()
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ifDueDate = indexPath.section == 0 ? (self.debt?.dueDate ?? "" == "" ? 0 : UITableView.automaticDimension) : UITableView.automaticDimension
        
        
        let dueViewHeight:CGFloat = self.debt?.dueDate ?? "" == "" ? 70 : 150
        let heightWhenNoData = tableView.frame.height - (appData.safeArea.1 + appData.safeArea.0 + dueViewHeight)
        
        return indexPath.section == 1 ? (historyDataStruct.count == 0 ? heightWhenNoData : UITableView.automaticDimension) : ifDueDate
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





extension HistoryVC: CalendarVCProtocol {
    
    func createDateComp(date:String, time:DateComponents?) -> DateComponents? {
        var date = stringToCompIso(s: date)
        if let time = time {
            date.second = time.second
            date.minute = time.minute
            date.hour = time.hour
            
        }
        return date
    }
    
    func dateCompToIso(isoComp: DateComponents) -> String? {
        if let date = Calendar.current.date(from: isoComp){ //isoComp.date {
            return date.iso8601withFractionalSeconds
        }
        return nil
    }
    
    func dateSelected(date: String, time: DateComponents?) {
        DispatchQueue.main.async {
            self.ai.show { (_) in

                //check if has am pm
                //or save as isoDate without
                let fullDate = "\(date) \(self.makeTwo(n: time?.hour ?? 0)):\(self.makeTwo(n: time?.minute ?? 0)):\(self.makeTwo(n: time?.second ?? 0))"
                print(fullDate, "fullDatefullDatefullDatefullDate")
                if let dateComp = self.createDateComp(date: date, time: time) {
                    print(dateComp, "dateCompdateCompdateComp")
                    
                    if let isoFullString = self.dateCompToIso(isoComp: dateComp) {
                        self.addLocalNotification(date: dateComp) { (added) in
                            
                            
                            self.changeDueDate(fullDate: isoFullString)
                            if !added {
                                //todo: show message error
                            }

                        }
                    } else {
                        print("error convering to comp from iso")
                        self.ai.fastHide { _ in
                            
                        }
                        
                    }
                    
                    
                } //self.stringToDateComponent(s: fullDate, dateFormat: K.fullDateFormat)
                
                else {
                    //todo: show message error
                    print("error creating iso")
                    self.ai.fastHide { _ in
                        
                    }
                }
                
                
            }
            
        }
    }
    
    
}











//cells
class DebtDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var AlertDateStack: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var noAlertIndicator: UILabel!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var alertDateLabel: UILabel!
    @IBOutlet weak var alertMonthLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var expiredDaysCount: UILabel!
    
    var cellPressed = false
    var _expired = false
    var expired:Bool {
        get {
            return _expired
        }
        set {
            _expired = newValue
            DispatchQueue.main.async {
                self.changeButton.superview?.isHidden = newValue ? false : (self.cellPressed ? false : true)
            }
        }
    }

    private let ai = AppDelegate.shared?.ai ?? IndicatorView.instanceFromNib() as! IndicatorView
    
    var removeAction:(() -> ())?
    @IBAction func changeDatePressed(_ sender: Any) {//remove
        DispatchQueue.main.async {
            self.ai.show(title: "Wait") { _ in
                if let funcc = self.removeAction {
                    funcc()
                }
            }
        }
        

    }
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    
    
    var changeAction:(() -> ())?
    @IBAction func doneDatePressed(_ sender: Any) {//change
        if let funcc = changeAction {
            funcc()
        }
    }
    

}


class HistoryCellTotal: UITableViewCell {
    
    @IBOutlet weak var totalToPayLabel: UILabel!
    @IBOutlet weak var noRestToPay: UIButton!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var perioudLabel: UILabel!
    @IBOutlet weak var restToPayyLabel: UILabel!
    
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    
    private let ai = AppDelegate.shared?.ai ?? IndicatorView.instanceFromNib() as! IndicatorView
    
    @IBAction func changePressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.ai.show(title: "Wait") { _ in
                if let funcc = self.deleteFunc {
                    funcc()
                }
            }
        }
        
    }
    @IBAction func donePressed(_ sender: Any) {//change
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.amountTF.text = self.restToPayyLabel.text
                self.amountTF.placeholder = self.restToPayyLabel.text
            }
            if let funcc = self.changeFunc {
                funcc()
            }
        }
    }
    var changeFunc: (() -> ())?
    var deleteFunc:(() -> ())?
}
