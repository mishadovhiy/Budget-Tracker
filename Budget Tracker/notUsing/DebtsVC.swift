//
//  DebtsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 14.03.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

var _debtsHolder: [DebtsStruct] = []
///TODO:
// add due date and amount view, add labels in cells

//no data cell

//first cell - description (если там тоже самое что и в noDataView то не отобр description если dataCount == 0)


/// todo:
//get delivered notifications
//get pending notifications
//show unseen indicator
//show if not on this device text
//|?- show if delivered - not found on this account (when login, create account, logout - remove all pending/delivered notifications) --

// - account vc -
// login transfare data from (acount)

class DebtsVC: SuperViewController {
    @IBOutlet weak var tableView: UITableView!

    var delegate: DebtsVCProtocol?
    var debts: [DebtsStruct] = []
    var emptyValuesTableData: [DebtsTableStruct] = []
    var plusValues: [DebtsTableStruct] = []
    var _tableData: [DebtsTableStruct] = []
    var safeAreaButton: CGFloat = 0.0
    var tableData: [DebtsTableStruct] {
        get {
            return _tableData
        }
        set {
            _tableData = newValue
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                self.tableView.reloadData()
            }
        }
    }
    var hideTitle = false
   // var darkAppearence = false
    var fromSettings = false
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    let footerHeight:CGFloat = 40
    
    let newDebtField = UITextField(frame: .zero)
    var showAnimatonOnSwitch = true
    
    var refreshControl = UIRefreshControl()
    func addRefreshControll() {
        DispatchQueue.main.async {
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            self.tableView.addSubview(self.refreshControl)
        }
    }
    
 //   @IBOutlet weak var newDebtTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //  newDebtTextField.delegate = self
      //  newDebtTextField.superview?.backgroundColor = darkAppearence ? .black : .white
      //  newDebtTextField.superview?.layer.cornerRadius = 6
        tableView.layer.cornerRadius = 6
        DispatchQueue.main.async {
            if appData.username != "" {
                self.addRefreshControll()
            }
            self.newDebtButton.layer.cornerRadius = 6
            self.newDebtField.returnKeyType = .done
            self.newDebtField.font = .systemFont(ofSize: 17, weight: .semibold)
            self.newDebtField.clearButtonMode = .always

            self.newDebtButton.layer.shadowPath = UIBezierPath(rect: self.newDebtButton.bounds).cgPath
            self.newDebtButton.layer.shadowColor = UIColor.black.cgColor
            self.newDebtButton.layer.shadowOpacity = 0.25
            self.newDebtButton.layer.shadowOffset = .zero
            self.newDebtButton.layer.shadowRadius = 6
        }
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

       /* if darkAppearence {
            DispatchQueue.main.async {
                self.newDebtField.textColor = .white
                self.tableView.translatesAutoresizingMaskIntoConstraints = true
                self.newDebtButton.setTitleColor(K.Colors.darkTable, for: .normal)
                self.newDebtButton.backgroundColor = K.Colors.category
            }
        }*/
        
        tableView.backgroundColor = .clear//darkAppearence ? .black : .white
        
     /*   if #available(iOS 13.0, *) {
            if darkAppearence {
                self.newDebtField.keyboardAppearance = .dark
                self.view.backgroundColor = UIColor(named: "darkTableColor")
                self.tableView.separatorColor = UIColor(named: "darkSeparetor")
                
            }
        } else {
            DispatchQueue.main.async {
                if self.darkAppearence {
                    self.view.backgroundColor = UIColor(named: "darkTableColor")
                    self.tableView.separatorColor = UIColor(named: "darkSeparetor")
                }
            }
        }*/
        tableView.delegate = self
        tableView.dataSource = self

        if appData.username != "" {
            if _debtsHolder.count == 0 {
                let load = LoadFromDB()
                load.Debts { (loadedDebts, debtsError) in
                    if debtsError == "" {
                        print("loaded \(loadedDebts) Debts from DB")
                        var debtsResult: [DebtsStruct] = []
                        for i in 0..<loadedDebts.count {
                            let name = loadedDebts[i][1]
                            let amountToPay = loadedDebts[i][2]
                            let dueDate = loadedDebts[i][3]
                            debtsResult.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
                        }
                        _debtsHolder = debtsResult
                        appData.saveDebts(debtsResult)
                        self.getDataFromLocal()
                    }
                }
            } else {
                getDataFromLocal()
            }
        } else {
            getDataFromLocal()
        }
        
      //  getDataFromLocal()

    }
    
    @objc func refresh(sender:AnyObject) {
        let load = LoadFromDB()
        load.Debts { (loadedDebts, debtsError) in
            if debtsError == "" {
                print("loaded \(loadedDebts) Debts from DB")
                var debtsResult: [DebtsStruct] = []
                for i in 0..<loadedDebts.count {
                    let name = loadedDebts[i][1]
                    let amountToPay = loadedDebts[i][2]
                    let dueDate = loadedDebts[i][3]
                    debtsResult.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
                }
                _debtsHolder = debtsResult
                appData.saveDebts(debtsResult)
                self.getDataFromLocal()
                
            }
            
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    
    @objc func pressedToDismiss(_ sender: UITapGestureRecognizer) {
        if self.newDebtField.isFirstResponder {
            DispatchQueue.main.async {
                self.newDebtField.endEditing(true)
            }
        }
    }
    lazy var viewTap:UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(pressedToDismiss(_:)))
    }()
    var tableContentOf:UIEdgeInsets = UIEdgeInsets.zero
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.removeGestureRecognizer(viewTap)
        self.addingNew = false
        DispatchQueue.main.async {
            self.newDebtButton.superview?.backgroundColor = .clear
            self.newDebtField.removeFromSuperview()
            self.tableView.contentInset = self.tableContentOf
            self.newDebtButton.alpha = 1
            UIView.animate(withDuration: 0.3) {
                //self.newDebtButton.superview?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            } completion: { (_) in
                
            }

        }
    }
    
    var keyHeight: CGFloat = 0.0
    @objc func keyboardWillShow(_ notification: Notification) {
        self.view.addGestureRecognizer(viewTap)
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if keyboardHeight > 1.0 {
                DispatchQueue.main.async {
                    self.tableView.contentInset.bottom = keyboardHeight - appData.safeArea.1//keyboardHeight - self.safeAreaButton + (self.newDebtTextField.superview?.layer.frame.height ?? 0)
                   // self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y - keyboardHeight)


                }

            }
        }
    }
    
    func getDataFromLocal() {
        debts = Array(appData.getDebts())

        let transactions = Array(appData.getTransactions)
        var result:[DebtsTableStruct] = []
        emptyValuesTableData.removeAll()
        plusValues.removeAll()
        for category in debts {
            var amount = 0.0
            var resultTransactions: [TransactionsStruct] = []
            for transaction in transactions {
                if category.name == transaction.categoryID {
                    amount = amount + (Double(transaction.value) ?? 0.0)
                    resultTransactions.append(transaction)
                    print(resultTransactions, "appended c1/c2: \(category.name)/\(transaction.categoryID)")
                }
            }
            let new = DebtsTableStruct(name: category.name, amount: Int(amount), transactions: transactions, amountToPay: category.amountToPay, dueDate: category.dueDate)
            if resultTransactions.count == 0 {
                emptyValuesTableData.append(new)
            } else {

                if amount >= 0 {
                    plusValues.append(new)
                } else {
                    result.append(new)
                }
                
            }
            
            print(resultTransactions)
        }
        plusValues = plusValues.sorted { $0.amount > $1.amount }
        let res = emptyValuesTableData + plusValues
        tableData = result.sorted { $0.amount < $1.amount } + res
     //   addingNew = false
        DispatchQueue.main.async {
            self.tableView.reloadData()
          //  if self.newDebtTextField.isFirstResponder {
          //      self.newDebtTextField.endEditing(true)
          //  }
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }



    func sendToDBDebt(title: String, purpose: String) {
        let Nickname = appData.username
        if Nickname != "" {
            let toDataString = "&Nickname=\(Nickname)" + "&name=\(title)" + "&amountToPay=\("")" + "&dueDate=\("")"
            let save = SaveToDB()
            save.Debts(toDataString: toDataString) { (error) in
                if error {//add in mainVC test
                    //showError      appData.unsendedData.append(["debt": toDataString])
                }
                var allDebts = Array(appData.getDebts())
                allDebts.append(DebtsStruct(name: title, amountToPay: "", dueDate: ""))
                appData.saveDebts(allDebts)
                self.getDataFromLocal()
            }
        }
    }

    struct DebtsTableStruct {
        let name: String
        let amount: Int
        let transactions: [TransactionsStruct]
        let amountToPay: String
        let dueDate: String
        
    }
    
    var selectedCellData:DebtsTableStruct?

    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistory" {

            let vc = segue.destination as! HistoryVC
            if let data = selectedCellData {
                print("prepare data.transactions", data.transactions)
                var result:[TransactionsStruct] = []
                let allTrans = Array(appData.getTransactions)
                for i in 0..<allTrans.count{
                    if allTrans[i].categoryID == data.name {
                        result.append(allTrans[i])
                    }
                }
                vc.historyDataStruct = result
                vc.selectedCategoryName = data.name
                vc.fromCategories = true
            }
            
        }
    }*/

    override func viewWillDisappear(_ animated: Bool) {
        print("will disap")
        if fromSettings {
            delegate?.catDebtSelected(name: "", amount: 0)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        //navigationController?.setNavigationBarHidden(darkAppearence ? false : true, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    var viewLoadedd = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            //let edg = UIEdgeInsets(top: self.tableView.contentInset.top, left: self.tableView.contentInset.left, bottom: self.view.safeAreaInsets.bottom + (self.newDebtButton.superview?.layer.frame.height ?? 0), right: self.tableView.contentInset.right)
            //self.tableView.contentInset = edg
            //self.tableContentOf = edg
            self.tableContentOf = self.tableView.contentInset
            self.tableView.reloadData()

        }
        if viewLoadedd {
            getDataFromLocal()
        } else {
            viewLoadedd = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("mainTouches")
    }

    
    var addingNew = false
    @IBOutlet weak var newDebtButton: UIButton!
    @IBAction func newDebtPressed(_ sender: Any) {
        addingNew = true
        showAnimatonOnSwitch = true
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
            self.newDebtButton.superview?.backgroundColor = self.view.backgroundColor
            self.newDebtField.text = ""
            self.newDebtButton.alpha = 0
            let sup = self.newDebtButton.superview?.frame ?? .zero
            self.newDebtField.frame = CGRect(x: 15, y: 0, width: sup.width - 30, height: sup.height)
            self.newDebtButton.superview?.addSubview(self.newDebtField)
            self.newDebtField.becomeFirstResponder()

        }
    }
    
    
}

extension DebtsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 4 //income debts // expences debts //complited //empty
        return 1//3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "debtCell", for: indexPath) as! debtCell
        //let data = indexPath.section == 0 ? tableData[indexPath.row] : emptyValuesTableData[indexPath.row]
        
       // cell.backgroundColor = darkAppearence ? .black : .white
        
        cell.amountToPay.isHidden = true
        let data: DebtsTableStruct = tableData[indexPath.row]
      //  switch indexPath.section {
    //    case 0: data = tableData[indexPath.row]
       /* case 1: data = plusValues[indexPath.row]
        case 2: data = emptyValuesTableData[indexPath.row]
        default:
            data = tableData[indexPath.row]
        }*/
   //     if let dat = data {
            cell.categoryLabel.text = data.name
            //let withTotal = data?.amountToPay == "" || data?.amountToPay == "0" ? "\(dat.amount)" : "\(dat.amount)\n\(dat.amountToPay)"

        cell.amountLabel.text = tableData[indexPath.row].transactions.count == 0 && tableData[indexPath.row].amount == 0 ? "No records" : "\(data.amount)"
        cell.amountToPay.text = "\(data.amountToPay)"
        
            if data.amountToPay != "" {
                if cell.amountToPay.isHidden != false {
                    cell.amountToPay.isHidden = false
                }
                
            } else {
                if cell.amountToPay.isHidden != true {
                    cell.amountToPay.isHidden = true
                }
                
            }
            
   //     }
        let dateComp = stringToCompIso(s: data.dueDate, dateFormat: K.fullDateFormat) //stringToDateComponent(s: data.dueDate, dateFormat: K.fullDateFormat)
        let expired = dateExpired(data.dueDate)
        let diff = dateExpiredCount(startDate: data.dueDate)
        cell.dueDate.textColor = expired ? K.Colors.negative : K.Colors.balanceV
        
        let dueDateText = data.dueDate == "" ? "" : "Due date: \(dateComp.day ?? 0) of \(returnMonth(dateComp.month ?? 0)), \(dateComp.year ?? 0)"
        let expText = expiredText(diff)
        cell.dueDate.text = dateComp.description //data.dueDate == "" ? "" : (!expired ? dueDateText : "Expired:" + "\(expText == "" ? " recently" : (expText + " ago"))" )
        cell.dueDate.isHidden = data.dueDate == "" ? true : false
  //      cell.categoryLabel.textColor = darkAppearence ? K.Colors.category : .black
       // cell.amountLabel.textColor = (data.amount) >= 0 ? (darkAppearence ? K.Colors.category : K.Colors.balanceV) : K.Colors.negative
        cell.amountLabel.textColor = (data.amount) >= 0 ? K.Colors.category : K.Colors.negative
        cell.amountLabel.alpha = tableData[indexPath.row].transactions.count == 0 && tableData[indexPath.row].amount == 0 ? 0.4 : 1//indexPath.section == 2 ? 0.4 : 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            let ai = UIActivityIndicatorView(frame: view.frame)
            ai.style = .gray
            ai.startAnimating()
            view.addSubview(ai)

            transactionAdded = true

            let title = self.tableData[indexPath.row].name
            let amountToPay = self.tableData[indexPath.row].amountToPay
            let dueDate = self.tableData[indexPath.row].dueDate
            
            
            
            var allDebts = Array(appData.debts)
            for i in 0..<allDebts.count {
                if allDebts[i].amountToPay == amountToPay && allDebts[i].dueDate == dueDate && allDebts[i].name == title {
                    let center = AppDelegate.shared?.center
                    center?.getPendingNotificationRequests { (requests) in
                        var ids:[String] = []
                        for i in 0..<requests.count {
                            print(requests[i], "requestsrequestsrequests")
                            
                            let id = "Debts\(allDebts[i].name)"
                            
                            if requests[i].identifier == id {
                                ids.append(id)
                            }
                        }
                        center?.removePendingNotificationRequests(withIdentifiers: ids)
                        allDebts.remove(at: i)
                        appData.saveDebts(allDebts)
                        
                        if appData.username != "" {
                            let delete = DeleteFromDB()
                            let tods = "&Nickname=\(appData.username)" + "&name=\(title)" + "&amountToPay=\(amountToPay)" + "&dueDate=\(dueDate)"
                            print(tods, "todstodstods")
                            delete.Debts(toDataString: tods) { (error) in
                                if error {
                                    //showError                   appData.unsendedData.append(["deleteDebt": tods])
                                }
                                self.getDataFromLocal()
                            }
                        }
                        
                        
                        
                    }
                    break
                }
            }
            
            
            
        }
        deleteAction.backgroundColor = K.Colors.negative
        return UISwipeActionsConfiguration(actions: [deleteAction])

        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let data = tableData[indexPath.row]
        if addingNew {
            DispatchQueue.main.async {
                self.newDebtField.endEditing(true)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            if !fromSettings {
                DispatchQueue.main.async {
                    self.delegate?.catDebtSelected(name: data.name, amount: data.amount)
                }
            } else {
                selectedCellData = data
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toHistory", sender: self)
                }
            }
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "debtHeader") as! debtHeader
        let view = cell.contentView
        view.backgroundColor = K.Colors.secondaryBackground//darkAppearence ? .black : .white
        view.layer.cornerRadius = 6
        cell.contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }
    
    
    
  /*  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCategoryCell") as! newCategoryCell
        cell.categoryTextField.placeholder = "New Debt Category"
        cell.categoryTextField.delegate = self
        cell.categoryTextField.tag = 2
        let view = cell.contentView
        view.layer.cornerRadius = 6
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.backgroundColor = K.Colors.secondaryBackground
        return view
    }
    */
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }

    
}

protocol DebtsVCProtocol {
    func catDebtSelected(name: String, amount: Int)
}




extension DebtsVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            addingNew = true
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.endEditing(true)
            if let name = textField.text {
                if name != "" {
                    textField.text = ""
                    if appData.username != "" {
                        self.sendToDBDebt(title: name, purpose: K.expense)
                    } else {
                        var allDebts = Array(appData.getDebts())
                        allDebts.append(DebtsStruct(name: name, amountToPay: "", dueDate: ""))
                        appData.saveDebts(allDebts)
                        self.getDataFromLocal()
                    }
                    
                } else {
                    self.getDataFromLocal()
                }
            } else {
                self.getDataFromLocal()
            }
        }
        return true
    }
}


class debtCell: UITableViewCell {
    
    @IBOutlet weak var amountToPay: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    
}



class debtHeader:UITableViewCell {
    
}
