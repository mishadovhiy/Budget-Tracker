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
    var selectedCategory: NewCategories?
    var fromCategories = false
    var allowEditing = true
    
    var amountToPayEditing = false
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        let appData = AppData()
        //get screen data
        let addAmountToPay = {
            self.amountToPayEditing = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
               // self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                self.ai.fastHide { _ in
                    
                }
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
    
    @IBOutlet weak var totalPeriodLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        print(selectedPurposeH, "selectedPurposeselectedPurposeH didlo")
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if allowEditing {
         //   DispatchQueue.main.async {

            addTransButton.layer.shadowColor = UIColor.black.cgColor
            addTransButton.layer.shadowOpacity = 0.15
            addTransButton.layer.shadowOffset = .zero
            addTransButton.layer.shadowRadius = 10
            if mainType == .db  {
                self.addTransButton.alpha = 1
            }

           // }
        }
        transactionAdded = false
        historyDataStruct = historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
        totalSumm = Int(totalSum())
        print(historyDataStruct.count, "didlocount")
        tableView.delegate = self
        tableView.dataSource = self
        title = selectedCategory?.name.capitalized

   //     DispatchQueue.main.async {
            self.addTransButton.layer.cornerRadius = self.addTransButton.layer.frame.width / 2
            //self.addTransButton.layer.masksToBounds = true
     //   }
        if mainType == .db {
            getDebtData()
        }
        
        
        //here exp
        
    }

    
    var mainType: HistDataType = .db
    
    enum HistDataType {
        case localData
        case allData
        case unsaved//when transfar data from
        case db
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        if selectedCategory?.purpose == .debt {
      //      center.removePendingNotificationRequests(withIdentifiers: ["Debts\(debt.name)"])
            center?.removeDeliveredNotifications(withIdentifiers: ["Debts\(self.selectedCategory?.id ?? 0)"])
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
        let title = self.selectedCategory?.name ?? ""
        let id = "Debts\(self.selectedCategory?.id ?? 0)"
        center?.removePendingNotificationRequests(withIdentifiers: [id])
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

    let db = DataBase()
    func getDebtData() {
      //  if allowEditing {
            if let id = selectedCategory?.id {
                selectedCategory = db.category("\(id)")
                if selectedCategory?.purpose == .debt {
                    DispatchQueue.main.async {
                        if self.moreButton.isHidden != false {
                            self.moreButton.isHidden = false
                            
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
          /*newCat  let debts = Array(appData.debts)
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
                
            }*/
            
            
      //  }
    }
    

    
    
    @objc func keyboardWillShow(_ notification: Notification) {

            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                if keyboardHeight > 1.0 {
                    DispatchQueue.main.async {
                                self.tableView.contentInset.bottom = keyboardHeight - appData.safeArea.1

                            }
                }
            }
        }
    
    @objc func keyboardWillHide(_ notification: Notification) {
           
            DispatchQueue.main.async {
                self.tableView.contentInset.bottom = 0
                self.tableView.reloadData()
                
            }
        }
    var _totalSumm: Int  = 0
    var totalSumm: Int {
        get {
            return _totalSumm
        }
        set {
            _totalSumm = newValue
            let hideLabel = newValue == 0
            DispatchQueue.main.async {
                self.totalLabel.text = "\(newValue)"
                if self.totalLabel.superview?.isHidden != hideLabel {
                    UIView.animate(withDuration: 0.3) {
                        self.totalLabel.superview?.isHidden = hideLabel
                    } 

                }
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
            vc.editingCategory = "\(self.selectedCategory?.id ?? 0)"
            vc.selectedPurpose = selectedPurposeH
        case "toCalendar":
            let vc = segue.destination as! CalendarVC
            vc.delegate = self
             let string = self.selectedCategory?.dueDate
            let stringDate = "\(self.makeTwo(n: string?.day ?? 0)).\(self.makeTwo(n: string?.month ?? 0)).\(string?.year ?? 0)"
            vc.selectedFrom = (string == nil) ? "" : stringDate
            vc.datePickerDate = string != nil ? stringDate : ""
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
        if let category = selectedCategory {
            let newDate = stringToCompIso(s: fullDate)
            self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
                let save = SaveToDB()
                var newCategory = category
                newCategory.dueDate = newDate
                save.newCategories(newCategory) { _ in
                    self.selectedCategory = newCategory
                    DispatchQueue.main.async {
                        self.ai.fastHide { (_) in
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
        
    }
            
                /*let saveToDs = "&Nickname=\(appData.username)" + "&name=\(self.debt?.name ?? "")" + "&amountToPay=\(self.debt?.amountToPay ?? "")" + "&dueDate=\(fullDate)"
                save.Debts(toDataString: saveToDs) { (error) in
                    self.selectedCategory?.dueDate = fullDate
                    print(self.selectedCategory?.dueDate, "self.debt?.dueDateself.debt?.dueDate")
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
                    
                }*/
            
        //}
    
    
    func tocalendatPressed() {
        
        center?.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in

            DispatchQueue.main.async {
                self.ai.fastHide { _ in
                    self.performSegue(withIdentifier: "toCalendar", sender: self)
                }
            }
        }
    }
    
    func dbLoadRemoveBeforeUpdate(completion: @escaping ([NewCategories], Bool) -> ()) {
        //self.loadingIndicator.show(title: "Updating data", appeareAnimation: true)
       // self.loadingIndicator?.show(title: "", appeareAnimation: true) { (_) in
        
        
        
            let load = LoadFromDB()
        
        load.newCategories { data, error in
            if let id = self.selectedCategory?.id {
                if let category = self.db.category("\(id)") {
                    let delete = DeleteFromDB()
                    delete.CategoriesNew(category: category) { errorBool in
                        completion(data, errorBool)
                    }
                }
            }
            
        }
        
        
           /* load.Debts { (loadedDebts, error) in
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
                
            }*/
       // }
        
    }
    
    func changeAmountToPay(enteredAmount:String, completion: @escaping (Any?) -> ()) {
        
        if let category = selectedCategory {
            self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
                let save = SaveToDB()
                var newCategory = category
                newCategory.amountToPay = Double(enteredAmount)
                save.newCategories(newCategory) { _ in
                    self.selectedCategory = newCategory
                    completion(nil)
                }
                /*let save = SaveToDB()
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
                    
                }*/
            }
        }
        
    }
    
    func changeAmountToPayWithtextField() {
        self.ai.showTextField(type: .amount, textFieldText: "\(self.selectedCategory?.amountToPay ?? 0.0)", title: "Amount to pay", description: "Enter how much is rest to pay") { (enteredAmount, _) in
            

            self.changeAmountToPay(enteredAmount: enteredAmount) { (_) in
                self.ai.fastHide { (_) in
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
        case 0: return selectedCategory?.purpose != .debt ? 0 : 1
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
                        
                        let id = "Debts\(self.selectedCategory?.name ?? "")"
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
            
            let dateComponent = selectedCategory?.dueDate
        //    print(dateComponent, "dateComponentdateComponentdateComponent")
            let date = "\(makeTwo(n: dateComponent?.day ?? 0))"
            let month = "\(returnMonth(dateComponent?.month ?? 0)), \(dateComponent?.year ?? 0)"
           /* let expired = dateExpired(debt?.dueDate ?? "")
            cell.expired = expired
            let diff = dateExpiredCount(startDate: debt?.dueDate ?? "")
            let expText = expiredText(diff)
            cell.expiredDaysCount.text = "Expired:" + (expText == "" ? " recently" : "\(expText) ago")
            cell.expiredDaysCount.superview?.isHidden = expired ? ((debt?.dueDate == "" ? true : false)) : true
            print(expired, "expiredexpiredexpired")*/

            cell.expiredStack.isHidden = dateExpired(dateComponent)
            
            let defaultBackground = UIColor(red: 199/255, green: 197/255, blue: 197/255, alpha: 1)
            cell.imageBackgroundView.backgroundColor = defaultBackground//expired ? K.Colors.negative : defaultBackground
            cell.imageBackgroundView.layer.masksToBounds = true
            cell.imageBackgroundView.layer.cornerRadius = cell.imageBackgroundView.layer.frame.width / 2
            cell.alertDateLabel.text = selectedCategory?.dueDate != nil ? date : "Due date"
            cell.alertMonthLabel.text = selectedCategory?.dueDate != nil ? month : "Unset"
            cell.timeLabel.backgroundColor = defaultBackground
            cell.timeLabel.layer.cornerRadius = 4
            cell.timeLabel.layer.masksToBounds = true
            cell.AlertDateStack.axis = selectedCategory?.dueDate != nil ? .horizontal : .vertical
            cell.AlertDateStack.alignment = selectedCategory?.dueDate != nil ? .firstBaseline : .fill
            cell.timeLabel.isHidden = selectedCategory?.dueDate != nil ? false : true
            cell.timeLabel.text = "\(makeTwo(n: dateComponent?.hour ?? 0)):" + "\(makeTwo(n: dateComponent?.minute ?? 0))"
         //   cell.mainView.alpha = expired ? (debt?.dueDate == "" ? 1 : 0.4) : 1
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
                cell.valueLabel.textColor = K.Colors.category
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
            
            
            
            let hideButtons = calendarAmountPressed.1 ? (amountToPayEditing ? true : (selectedCategory?.amountToPay == nil ? true : false)) : true
            if cell.changeButton.superview?.isHidden ?? true != hideButtons {
                cell.changeButton.superview?.isHidden = hideButtons
            }
            let hasTotalSum = selectedCategory?.amountToPay == nil || selectedCategory?.amountToPay ?? 0.0 == 0.0 ? false : true
            let totalSumm = totalSum()
            cell.valueLabel.text = (totalSumm < Double(Int.max) ? "\(Int(totalSumm))" : "\(totalSumm)")
            
            cell.totalToPayLabel.text = "\(selectedCategory?.amountToPay)"
            let rest = (selectedCategory?.amountToPay ?? 0.0) - totalSumm
            cell.restToPayyLabel.text = (rest < Double(Int.max) ? "\(Int(rest))" : "\(rest)") //+ (rest > 0.0 ? " Complited" : "") //"\(rest)"
            cell.totalToPayLabel.superview?.isHidden = hasTotalSum ? false : true
            cell.restToPayyLabel.superview?.isHidden = hasTotalSum ? false : true
            cell.restToPayyLabel.superview?.superview?.isHidden = hasTotalSum ? false : true
            if fromCategories {
                cell.perioudLabel.isHidden = true
            } else {
                cell.perioudLabel.text = selectedPeroud
            }
            if selectedCategory?.purpose != .debt {
              //  cell.noRestToPay.isHidden = true
                cell.totalToPayLabel.isHidden = true
            } else {
               // cell.noRestToPay.layer.masksToBounds = true
              //  cell.noRestToPay.layer.cornerRadius = 4
                if selectedCategory?.amountToPay ?? 0.0 == 0.0 {
             //       cell.noRestToPay.isHidden = false
                    cell.totalToPayLabel.isHidden = true
                } else {
               //     cell.noRestToPay.isHidden = true
                    cell.totalToPayLabel.isHidden = false
                    cell.totalToPayLabel.text = "\(selectedCategory?.amountToPay ?? 0.0)"
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
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section == 1 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                switch self.mainType {
                case .localData, .allData:
                    if let cat = self.selectedCategory {
                        self.db.deleteTransaction(transaction: self.historyDataStruct[indexPath.row], local: true)
                        self.historyDataStruct = self.db.transactions(for: cat, local: true)
                        self.totalSumm = Int(self.totalSum())
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                case .db:
                    let delete = DeleteFromDB()
                    delete.newTransaction(self.historyDataStruct[indexPath.row]) { _ in
                        self.historyDataStruct.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                default :
                    break
                }
                
                /*let mainFrame = view.frame
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
                        if transactions[i].comment == self.historyDataStruct[indexPath.row].comment && transactions[i].date == self.historyDataStruct[indexPath.row].date && transactions[i].value == self.historyDataStruct[indexPath.row].value && transactions[i].categoryID == self.historyDataStruct[indexPath.row].categoryID{
                            found = true
                        } else {
                            result.append(transactions[i])
                            if transactions[i].categoryID == self.historyDataStruct[indexPath.row].categoryID {
                                newTableData.append(transactions[i])
                            }
                        }
                    } else {
                        result.append(transactions[i])
                        if transactions[i].categoryID == self.historyDataStruct[indexPath.row].categoryID {
                            newTableData.append(transactions[i])
                        }
                    }
                }
                
                if appData.username != "" {
                    let toDataString = "&Nickname=\(appData.username)" + "&Category=\(self.historyDataStruct[indexPath.row].categoryID)" + "&Date=\(self.historyDataStruct[indexPath.row].date)" + "&Value=\(self.historyDataStruct[indexPath.row].value)" + "&Comment=\(self.historyDataStruct[indexPath.row].comment)"
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
                }*/
                
            }
            deleteAction.image = iconNamed("trash.red")
            deleteAction.backgroundColor = K.Colors.primaryBacground
            return historyDataStruct.count == 0 ? nil : UISwipeActionsConfiguration(actions: allowEditing && mainType != .unsaved ? [deleteAction] : [])
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
        if mainType  == .db {
            if indexPath.section == 2 {
                DispatchQueue.main.async {
                    if self.selectedCategory?.purpose != .debt {
                        return
                    }
                    if self.selectedCategory?.amountToPay ?? 0.0 != 0.0 && !self.calendarAmountPressed.1 {
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
                    if self.selectedCategory?.dueDate != nil && !self.calendarAmountPressed.0 {
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
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ifDueDate = indexPath.section == 0 ? (self.selectedCategory?.dueDate == nil ? 0 : UITableView.automaticDimension) : UITableView.automaticDimension
        
        
        let dueViewHeight:CGFloat = self.selectedCategory?.dueDate == nil ? 70 : 150
        let heightWhenNoData = tableView.frame.height - (appData.safeArea.1 + appData.safeArea.0 + dueViewHeight)
        
        return indexPath.section == 1 ? (historyDataStruct.count == 0 ? heightWhenNoData : UITableView.automaticDimension) : ifDueDate
    }
    
}

extension HistoryVC: TransitionVCProtocol {
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct) {
        //not using
    }
    
    func quiteTransactionVC(reload: Bool) {
        
    }

    func addNewTransaction(value: String, category: String, date: String, comment: String) {
        toAddVC = false
        transactionAdded = true
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        if value != "" && category != "" && date != "" {
                    let save = SaveToDB()
                    save.newTransaction(new) { error in
                        if let category = self.selectedCategory {
                            self.historyDataStruct = self.db.transactions(for: category)
                            self.totalSumm = Int(self.totalSum())
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }

                        
                    }

                }
       /* let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        print(new, "newnewnewnew")
        
        if value != "" && category != "" && date != "" {
            
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
                    
                    self.historyDataStruct.append(TransactionsStruct(value: value, categoryID: category, date: date, comment: comment))
                    self.historyDataStruct = self.historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    var indexPath: IndexPath?
                    for i in 0..<self.historyDataStruct.count {
                        if self.historyDataStruct[i].categoryID == new.categoryID && self.historyDataStruct[i].comment == new.comment && self.historyDataStruct[i].date == new.date && self.historyDataStruct[i].value == new.value {
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
                
                self.historyDataStruct.append(TransactionsStruct(value: value, categoryID: category, date: date, comment: comment))
                self.historyDataStruct = self.historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }*/
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
    
    
    
    func dateSelected(date: String, time: DateComponents?) {
        DispatchQueue.main.async {
            self.ai.show { (_) in

                //check if has am pm
                //or save as isoDate without
                let fullDate = "\(date) \(self.makeTwo(n: time?.hour ?? 0)):\(self.makeTwo(n: time?.minute ?? 0)):\(self.makeTwo(n: time?.second ?? 0))"
                print(fullDate, "fullDatefullDatefullDatefullDate")
                if let dateComp = self.createDateComp(date: date, time: time) {
                    print(dateComp, "dateCompdateCompdateComp")
                    
                    if let isoFullString = dateCompToIso(isoComp: dateComp) {
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
    @IBOutlet weak var expiredStack: UIStackView!
    
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
                self.amountTF.text = self.totalToPayLabel.text
                self.amountTF.placeholder = self.totalToPayLabel.text
            }
            if let funcc = self.changeFunc {
                funcc()
            }
        }
    }
    var changeFunc: (() -> ())?
    var deleteFunc:(() -> ())?
}
