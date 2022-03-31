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

class HistoryVC: SuperViewController {

    @IBOutlet weak var addTransButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategory: NewCategories?
    var fromCategories = false
    var allowEditing = true
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        showMoreVC()
    }
    var amountToPayEditing = false
    
    @IBOutlet weak var moreButton: UIButton!
    
    func showMoreVC() {
        let appData = AppData()
        //get screen data
        let addAmountToPay = {
            self.amountToPayEditing = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
               // self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                self.ai.fastHide()
            }
        }
        
        let addDueDate = {
            self.tocalendatPressed()
            
        }
        
        let moreData = [
            MoreVC.ScreenData(name: "Amount to pay".localize, description: "", showAI:false, action: addAmountToPay),
            MoreVC.ScreenData(name: "Due date".localize, description: "", showAI:false, pro: appData.proVersion || appData.proTrial, action: addDueDate),
        ]
        appData.presentMoreVC(currentVC: self, data: moreData, proIndex: 0)
    }
    
    
    static var shared: HistoryVC?
    @IBOutlet weak var totalPeriodLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    var svsloaded = false
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !svsloaded {
            addTransButton.backgroundColor = K.Colors.link
            svsloaded = true
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        HistoryVC.shared = self
        print(selectedPurposeH, "selectedPurposeselectedPurposeH didlo")
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if allowEditing {
         //   DispatchQueue.main.async {


            if mainType == .db  {
                self.addTransButton.alpha = 1
            }

           // }
        } else {
            self.addTransButton.alpha = 0
        }
        transactionAdded = false
        historyDataStruct = historyDataStruct.sorted{ $0.dateFromString < $1.dateFromString }
        totalSumm = Int(totalSum())
        print(historyDataStruct.count, "didlocount")
        tableView.delegate = self
        tableView.dataSource = self
        title = selectedCategory?.name.capitalized

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
    
 
    var fromStatistic = false

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    var bottomTableInsert:CGFloat = 50
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let inserts = self.totalLabel.superview?.layer.frame.height ?? 50
        self.tableView.contentInset.bottom = inserts
        self.bottomTableInsert = inserts
        if selectedCategory?.purpose == .debt {
            if let cat = self.selectedCategory {
                AppDelegate.shared!.removeNotification(id: "Debts\(cat.id )")
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
    
    let center = AppDelegate.shared!.center
    

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
                self.tableView.contentInset.bottom = self.bottomTableInsert
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
    var totalExpenses = 0.0
    func totalSum() -> Double {
        var sum = 0.0
        totalExpenses = 0
        let data = historyDataStruct
        for i in 0..<data.count {
            let value = Double(data[i].value) ?? 0
            sum += value
            if value < 0 {
                totalExpenses += value
            }
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
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! TransitionVC
            vc.delegate = self
            vc.fromDebts = fromCategories ? true : false
            vc.editingCategory = "\(self.selectedCategory?.id ?? 0)"
            vc.selectedPurpose = selectedPurposeH
        case "toCalendar":
            let vc = segue.destination as! CalendarVC
            vc.delegate = self
             let string = self.selectedCategory?.dueDate
            let stringDate = "\(AppData.makeTwo(n: string?.day ?? 0)).\(AppData.makeTwo(n: string?.month ?? 0)).\(string?.year ?? 0)"
            let time = "\(AppData.makeTwo(n: string?.hour ?? 0)):\(AppData.makeTwo(n: string?.minute ?? 0)):\(AppData.makeTwo(n: string?.second ?? 0))"
            vc.selectedFrom = (string == nil) ? "" : stringDate
            vc.datePickerDate = string != nil ? time : ""
            vc.vcHeaderData = headerData(title: "Create".localize + " " + "notification".localize, description: "Get notification reminder on specific date".localize)
            vc.needPressDone = true
            vc.canSelectOnlyOne = true
            vc.selectingDate = false
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
        if let category = selectedCategory {
            let comp = DateComponents()
            let newDate = comp.stringToCompIso(s: fullDate)
            self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
                var newCategory = category
                newCategory.dueDate = fullDate == "" ? nil : newDate
                SaveToDB.shared.newCategories(newCategory) { _ in
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
            

    
    func tocalendatPressed() {
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in

            DispatchQueue.main.async {
                self.ai.fastHide { _ in
                    self.performSegue(withIdentifier: "toCalendar", sender: self)
                }
            }
        }
    }
    
    func dbLoadRemoveBeforeUpdate(completion: @escaping ([NewCategories], Bool) -> ()) {

        
         //   let load = LoadFromDB()
        
        LoadFromDB.shared.newCategories { data, error in
            if let id = self.selectedCategory?.id {
                if let category = self.db.category("\(id)") {
                    let delete = DeleteFromDB()
                    delete.CategoriesNew(category: category) { errorBool in
                        completion(data, errorBool)
                    }
                }
            }
            
        }
        
    
        
    }
    
    func changeAmountToPay(enteredAmount:String, completion: @escaping (Any?) -> ()) {
        
        if let category = selectedCategory {
            self.dbLoadRemoveBeforeUpdate { (loadedData, _) in
               // let save = SaveToDB()
                var newCategory = category
                newCategory.amountToPay = Double(enteredAmount)
                SaveToDB.shared.newCategories(newCategory) { _ in
                    self.selectedCategory = newCategory
                    completion(nil)
                }

            }
        }
        
    }
    


    
    func removeAlert() {
        //set dbalert ""
        //
    }
    
    var calendarAmountPressed = (false, false)
    
    
    
    func sendAmountToPay(_ text: String) {
    
        print(text, "texttexttexttexttext")
        if let _ = Double(text) {
             //   DispatchQueue.main.async {
            self.ai.show(title: "Sending".localize) { _ in
                        self.changeAmountToPay(enteredAmount: text) { (_) in
                            self.ai.fastHide { (_) in
                                self.amountToPayEditing = false
                                //DispatchQueue.main.async {
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                //}
                            }
                        }
                    }
            //    }
            }
    }
    
}











extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 1: return selectedCategory?.purpose != .debt ? 0 : 1
        case 0: return selectedCategory?.amountToPay != nil || amountToPayEditing ? 1 : 0
        case 2: return historyDataStruct.count == 0 ? 1 : historyDataStruct.count
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
                        self.center.removePendingNotificationRequests(withIdentifiers: [id])
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.ai.fastHide()
                        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DebtDescriptionCell", for: indexPath) as! DebtDescriptionCell
            cell.cellPressed = calendarAmountPressed.0


            let hideBut = calendarAmountPressed.0 ? false : true
            if cell.changeButton.superview?.isHidden != hideBut {
                cell.changeButton.superview?.isHidden = hideBut
            }
            

            let removeActio = {
                self.tocalendatPressed()
            }
            let changeActio = {
                self.removeDueDate()
            }
            cell.changeAction = changeActio
            

            cell.removeAction = removeActio
            
            let dateComponent = selectedCategory?.dueDate
        //    print(dateComponent, "dateComponentdateComponentdateComponent")
            let date = "\(AppData.makeTwo(n: dateComponent?.day ?? 0))"
            let month = "\(returnMonth(dateComponent?.month ?? 0)), \(dateComponent?.year ?? 0)"

            cell.expiredStack.isHidden = !dateExpired(dateComponent)
            
            let defaultBackground = UIColor(red: 199/255, green: 197/255, blue: 197/255, alpha: 1)
            cell.imageBackgroundView.backgroundColor = defaultBackground//expired ? K.Colors.negative : defaultBackground
            cell.imageBackgroundView.layer.masksToBounds = true
            cell.imageBackgroundView.layer.cornerRadius = cell.imageBackgroundView.layer.frame.width / 2
            cell.alertDateLabel.text = selectedCategory?.dueDate != nil ? date : "Due date".localize
            cell.alertMonthLabel.text = selectedCategory?.dueDate != nil ? month : "Unset".localize
            cell.timeLabel.backgroundColor = defaultBackground
            cell.timeLabel.layer.cornerRadius = 4
            cell.timeLabel.layer.masksToBounds = true
            cell.AlertDateStack.axis = selectedCategory?.dueDate != nil ? .horizontal : .vertical
            cell.AlertDateStack.alignment = selectedCategory?.dueDate != nil ? .firstBaseline : .fill
            cell.timeLabel.isHidden = selectedCategory?.dueDate != nil ? false : true
            cell.timeLabel.text = "\(AppData.makeTwo(n: dateComponent?.hour ?? 0)):" + "\(AppData.makeTwo(n: dateComponent?.minute ?? 0))"
         //   cell.mainView.alpha = expired ? (debt?.dueDate == "" ? 1 : 0.4) : 1
          //  cell.mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toCalendarPressed(_:))))
            
            return cell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmountToPayCell") as! AmountToPayCell
    
            let amToPay = Int(selectedCategory?.amountToPay ?? 0.0)
            
            let progress = amToPay == 0 ? 0 : (totalExpenses * -1) / (selectedCategory?.amountToPay ?? 0.0)
            print(progress)
       //     let hideButtons = calendarAmountPressed.1 ? (amountToPayEditing ? true : (selectedCategory?.amountToPay == nil ? true : false)) : true
            
            let removeAmountAction = {
                self.removeAmountToPay()
            }
            
            cell.deleteFunc = removeAmountAction
            
            let changeFunc = {
     //           cell.amountToPayTextField.tag = self.amountToPayTFTag
                self.amountToPayEditing = true
              //  self.calendarAmountPressed = (false,false)

            }
           // if self.amountToPayEditing {
            cell.editingStack.alpha = calendarAmountPressed.1 ?? false ? 1 : 0
           // }
            cell.changeFunc = changeFunc
            cell.isEdit = amountToPayEditing
          //  cell.amountToPayTextField.delegate = self
            let tEx = Int(totalExpenses)
            cell.totalLabel.text = "\(tEx * (-1))"
            cell.restAmountLabel.text = "\(amToPay + tEx)"
            cell.amountToPayLabel.text = "\(amToPay)"
            cell.progressBar.progress = Float(progress)
            cell.progressBar.progressTintColor = AppData.colorNamed(selectedCategory?.color)
            cell.progressBar.isHidden = amToPay == 0
      //      cell.amountToPayTextField.isHidden = !amountToPayEditing
  //          cell.amountToPayLabel.isHidden = amountToPayEditing
           // cell.editingStack.isHidden = !(calendarAmountPressed.0 ?? false)
            return cell
            
            
        case 2:
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

        if indexPath.section == 2 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                switch self.mainType {
                case .localData, .allData:
                    if let cat = self.selectedCategory {
                        self.db.deleteTransaction(transaction: self.historyDataStruct[indexPath.row], local: true)
                        self.historyDataStruct.remove(at: indexPath.row)
                       //here self.historyDataStruct = self.db.transactions(for: cat, local: true)
                        self.totalSumm = Int(self.totalSum())
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                case .db:
                    let delete = DeleteFromDB()
                    delete.newTransaction(self.historyDataStruct[indexPath.row]) { _ in
                        self.historyDataStruct.remove(at: indexPath.row)
                        self.totalSumm = Int(self.totalSum())
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                default :
                    break
                }

                
            }
            deleteAction.image = AppData.iconNamed("trash.red")
            deleteAction.backgroundColor = K.Colors.primaryBacground
            return historyDataStruct.count == 0 ? nil : UISwipeActionsConfiguration(actions: allowEditing && mainType != .unsaved ? [deleteAction] : [])
        } else {
            //check if debts has total amount
            return nil
        } 
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        if mainType  == .db {
            if indexPath.section == 0 {
               /* DispatchQueue.main.async {
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
                }*/
            } else {
                if indexPath.section == 1 {
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
        let ifDueDate = indexPath.section == 1 ? (self.selectedCategory?.dueDate == nil ? 0 : UITableView.automaticDimension) : UITableView.automaticDimension
        
        
        let dueViewHeight:CGFloat = self.selectedCategory?.dueDate == nil ? 70 : 150
        let heightWhenNoData = tableView.frame.height - (appData.safeArea.1 + appData.safeArea.0 + dueViewHeight)
        
        return indexPath.section == 2 ? (historyDataStruct.count == 0 ? heightWhenNoData : UITableView.automaticDimension) : ifDueDate
    }
    
}

extension HistoryVC: TransitionVCProtocol {
    func deletePressed() {
        //not usng
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct, reminderTime: DateComponents?, repeated: Bool?, idx:Int?) {
        //not using
    }
    
    func quiteTransactionVC(reload: Bool) {
        
    }
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime:DateComponents?, repeated:Bool?) {
        toAddVC = false
        transactionAdded = true
        needDownloadOnMainAppeare = true
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        if value != "" && category != "" && date != "" {
                  //  let save = SaveToDB()
            SaveToDB.shared.newTransaction(new) { error in
                        if let category = self.selectedCategory {
                            self.historyDataStruct = self.db.transactions(for: category)
                            self.totalSumm = Int(self.totalSum())
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }

                        
                    }

                }
        }

    
    
    
    
}

extension HistoryVC: CalendarVCProtocol {
    
    func dateSelected(date: String, time: DateComponents?) {
            self.ai.show { (_) in
                let id = "Debts\(self.selectedCategory?.id ?? 0)"
                self.center.removePendingNotificationRequests(withIdentifiers: [id])
                let fullDate = "\(date) \(AppData.makeTwo(n: time?.hour ?? 0)):\(AppData.makeTwo(n: time?.minute ?? 0)):\(AppData.makeTwo(n: time?.second ?? 0))"
                print(fullDate, "fullDatefullDatefullDatefullDate")
                if let dateComp = time?.createDateComp(date: date, time: time) {
                    print(dateComp, "dateCompdateCompdateComp")
                    
                    if let isoFullString = dateComp.toIsoString() {
                        if !self.dateExpired(dateComp) {
                            let nodifCen = Notifications()
                            let notifTitle = "Due date has expired".localize
                            let notifBody = "For category".localize + ": " + (self.selectedCategory?.name ?? "")
                            let notifID = "Debts\(self.selectedCategory?.id ?? 0)"
                            nodifCen.addLocalNotification(date: dateComp, title: notifTitle, id: notifID, body: notifBody) { added in
                                self.changeDueDate(fullDate: isoFullString)
                                if !added {
                                    DispatchQueue.main.async {
                                        self.newMessage.show(title:"Local notification not added".localize, type: .error)
                                    }
                                }
                            }

                          } else {
                            self.changeDueDate(fullDate: isoFullString)
                            DispatchQueue.main.async {
                                self.newMessage.show(title:"Local notification not added".localize, type: .error)
                            }
                        }
                        
                    } else {
                        let errorText = "Error".localize + " " + "adding".localize + " " + "Due date".localize
                        self.ai.fastHide { _ in
                            DispatchQueue.main.async {
                                self.newMessage.show(title: errorText, type: .error)
                            }
                        }
                        
                    }
                    
                    
                } //self.stringToDateComponent(s: fullDate, dateFormat: K.fullDateFormat)
                
                else {
                    let errorText = "Error".localize + " " + "adding".localize + " " + "Due date".localize
                    self.ai.fastHide { _ in
                        DispatchQueue.main.async {
                            self.newMessage.show(title:errorText, type: .error)
                        }
                    }
                }
                
                
            }
            
     //   }
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
     //   DispatchQueue.main.async {
            self.ai.show() { _ in
                if let funcc = self.removeAction {
                    funcc()
                }
            }
     //   }
        

    }
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        changeButton.layer.cornerRadius = changeButton.layer.frame.width / 2
        doneButton.layer.cornerRadius = doneButton.layer.frame.width / 2
        
    }
    
    var changeAction:(() -> ())?
    @IBAction func doneDatePressed(_ sender: Any) {//change
        if let funcc = changeAction {
            funcc()
        }
    }
    

}



extension AmountToPayCell:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.endEditing(true)
            let text = textField.text ?? ""
            HistoryVC.shared?.sendAmountToPay(text)
        }

        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        HistoryVC.shared?.amountToPayEditing = true
        isEdit = true
        showEdit(true, hideStack: false) { _ in
            
        }
        
    }
}
class AmountToPayCell: UITableViewCell {
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var editingStack: UIStackView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var restAmountLabel: UILabel!
    @IBOutlet weak var amountToPayLabel: UILabel!
    
    @IBOutlet weak var amountToPayTextField: NumbersTF!
    //@IBOutlet weak var amountToPayTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let amPress = HistoryVC.shared?.calendarAmountPressed.1 ?? false
        print(amPress, "amPressamPressamPressamPress")
        if amPress {
            if !isEdit {
                if let touch = touches.first {
                    DispatchQueue.main.async {
                        if touch.view != self.changeButton || touch.view != self.deleteButton {
                            UIView.animate(withDuration: 0.3) {
                                self.editingStack.alpha = 0
                            } completion: { _ in
                                HistoryVC.shared?.calendarAmountPressed = (false, false)
                                HistoryVC.shared?.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
            
        } else {
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 0.12) {
                    self.editingStack.alpha = 1
                } completion: { _ in
                    HistoryVC.shared?.calendarAmountPressed.1 = true
                    HistoryVC.shared?.tableView.reloadData()
                }

            }
            
        }
    }
    
    var changeFunc:(() -> ())?
    var deleteFunc:(() -> ())?
    
    var _isEdit = false
    var isEdit:Bool {
        get {
            return _isEdit
        }
        set {
            _isEdit = newValue
            print(newValue, "newValuenewValuenewValuenewValuenewValuenewValuenewValue")
            let deleteIcon = newValue ? "xmark.circle" : "trash"
            let changeIcon = newValue ? "paperplane.fill" : "pencil"
            
            DispatchQueue.main.async {
                if newValue {
                    if self.amountToPayTextField.isHidden != false {
                        self.amountToPayTextField.isHidden = false
                    }
                    if self.amountToPayLabel.isHidden != true {
                        self.amountToPayLabel.isHidden = true
                    }
                }
                
                self.deleteButton.setImage(AppData.iconNamed(deleteIcon), for: .normal)
                self.changeButton.setImage(AppData.iconNamed(changeIcon), for: .normal)
               
            }
        }
    }
    
    func setAmountEditing(_ editing:Bool) {
        DispatchQueue.main.async {
            if self.editingStack.alpha != (editing ? 1 : 0) {
                self.editingStack.alpha = editing ? 1 : 0
            }
            
            if self.amountToPayLabel.isHidden != editing ? true : false {
                self.amountToPayLabel.isHidden = editing ? true : false
            }
            if self.amountToPayTextField.isHidden != editing ? false : true {
                self.amountToPayTextField.isHidden = editing ? false : true
            }
        }
    }
    
    private func showEdit(_ value:Bool, hideStack:Bool , completionn: @escaping (Bool) -> ()) {
        let hideLabel = value ? true : false
        let hideTF = value ? false : true
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                if self.editingStack.alpha != (hideStack ? 0 : 1) {
                    self.editingStack.alpha = hideStack ? 0 : 1
                }
                
                if self.amountToPayLabel.isHidden != hideLabel {
                    self.amountToPayLabel.isHidden = hideLabel
                }
                if self.amountToPayTextField.isHidden != hideTF {
                    self.amountToPayTextField.isHidden = hideTF
                }
            } completion: { _ in
                completionn(true)
            }
        }
    }

    
    @IBAction func changePressed(_ sender: UIButton) {
        if isEdit {
          //  DispatchQueue.main.async {
            HistoryVC.shared?.ai.show(title: "Sending".localize, completion: { _ in
                    self.isEdit = false
                    self.showEdit(false, hideStack: true) { _ in
                        let text = self.amountToPayTextField.text ?? ""
                        HistoryVC.shared?.sendAmountToPay(text)
                    }
                })
            //   }
        } else {
            self.isEdit = true
            showEdit(true, hideStack: false) { _ in
                
                DispatchQueue.main.async {
                    self.amountToPayTextField.becomeFirstResponder()
                }
                if !self.isEdit {
                    if let funcc = self.changeFunc {
                        funcc()
                    }
                }
            }
            
        }
        
    }
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func deletePressed(_ sender: UIButton) {

        let new = !isEdit
        if !isEdit {
            if let funcc = deleteFunc {
            //    DispatchQueue.main.async {
                HistoryVC.shared?.ai.show(title: "Deleting".localize, completion: { _ in
                    self.showEdit(new, hideStack: true) { _ in
                            funcc()
                        
                    }
                })
            //    }
            }
            
        } else {
            self.isEdit = false
            self.showEdit(false, hideStack: true) { _ in
                
                HistoryVC.shared?.calendarAmountPressed = (false,false)
                HistoryVC.shared?.amountToPayEditing = false
                DispatchQueue.main.async {
                    self.amountToPayTextField.endEditing(true)
                }
            }
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        deleteButton.layer.cornerRadius = deleteButton.layer.frame.width / 2
        changeButton.layer.cornerRadius = changeButton.layer.frame.width / 2
        
        amountToPayTextField.delegate = self
    }
    
    
    
    
}
