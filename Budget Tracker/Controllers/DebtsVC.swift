//
//  DebtsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 14.03.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

///TODO:
// add due date and amount view, add labels in cells

//no data cell

//first cell - description (если там тоже самое что и в noDataView то не отобр description если dataCount == 0)

class DebtsVC: UIViewController {
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
                self.tableView.reloadData()
            }
        }
    }
    var hideTitle = false
    var darkAppearence = false
    var fromSettings = false
    override func viewDidDisappear(_ animated: Bool) {

    }
    let footerHeight:CGFloat = 35
    
    let newDebtField = UITextField(frame: .zero)
    var showAnimatonOnSwitch = true
    override func viewDidLoad() {
        super.viewDidLoad()

        newDebtField.delegate = self
        DispatchQueue.main.async {
            self.newDebtButton.layer.cornerRadius = 6
            self.newDebtField.returnKeyType = .done
            self.newDebtField.font = .systemFont(ofSize: 17, weight: .semibold)
            self.newDebtField.clearButtonMode = .always

            self.newDebtButton.layer.shadowPath = UIBezierPath(rect: self.newDebtButton.bounds).cgPath
            self.newDebtButton.layer.shadowColor = UIColor.black.cgColor
            self.newDebtButton.layer.shadowOpacity = 0.15
            self.newDebtButton.layer.shadowOffset = .zero
            self.newDebtButton.layer.shadowRadius = 6
        }
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        if darkAppearence {
            DispatchQueue.main.async {
                self.newDebtField.textColor = .white
                self.tableView.translatesAutoresizingMaskIntoConstraints = true

            }
        }
        if #available(iOS 13.0, *) {
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
        }
        tableView.delegate = self
        tableView.dataSource = self

        getDataFromLocal()
        
    }
    
    var tableContentOf:UIEdgeInsets = UIEdgeInsets.zero
    @objc func keyboardWillHide(_ notification: Notification) {
        self.addingNew = false
        DispatchQueue.main.async {
            self.newDebtButton.superview?.backgroundColor = .clear
            self.newDebtField.removeFromSuperview()
            self.tableView.contentInset = self.tableContentOf
            self.newDebtButton.alpha = 1
            UIView.animate(withDuration: 0.3) {
                self.newDebtButton.superview?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            } completion: { (_) in
                
            }

        }
    }
    
    var keyHeight: CGFloat = 0.0
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if keyboardHeight > 1.0 {
                DispatchQueue.main.async {
                    self.tableView.contentInset.bottom = keyboardHeight - self.safeAreaButton + (self.newDebtButton.superview?.layer.frame.height ?? 0)
                   // self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y - keyboardHeight)
                    UIView.animate(withDuration: 0.3) {
                        self.newDebtButton.superview?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, (keyboardHeight - self.safeAreaButton) * (-1), 0)
                    } completion: { (_) in
                        
                    }

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
                if category.name == transaction.category {
                    amount = amount + (Double(transaction.value) ?? 0.0)
                    resultTransactions.append(transaction)
                    print(resultTransactions, "appended c1/c2: \(category.name)/\(transaction.category)")
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
        tableData = result.sorted { $0.amount < $1.amount }
        DispatchQueue.main.async {
            if self.newDebtField.isFirstResponder {
                self.newDebtField.endEditing(true)
            }
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
                    appData.unsendedData.append(["debt": toDataString])
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistory" {

            let vc = segue.destination as! HistoryVC
            if let data = selectedCellData {
                print("prepare data.transactions", data.transactions)
                var result:[TransactionsStruct] = []
                let allTrans = Array(appData.getTransactions)
                for i in 0..<allTrans.count{
                    if allTrans[i].category == data.name {
                        result.append(allTrans[i])
                    }
                }
                vc.historyDataStruct = result
                vc.selectedCategoryName = data.name
                vc.fromCategories = true
            }
            
        }
    }

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

        DispatchQueue.main.async {
            let edg = UIEdgeInsets(top: self.tableView.contentInset.top, left: self.tableView.contentInset.left, bottom: self.tableView.contentInset.bottom + (self.newDebtButton.superview?.layer.frame.height ?? 0), right: self.tableView.contentInset.right)
            self.tableView.contentInset = edg
            self.tableContentOf = edg
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return tableData.count//emptyValuesTableData
        case 1: return plusValues.count//emptyValuesTableData
        case 2: return emptyValuesTableData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "debtCell", for: indexPath) as! debtCell
        //let data = indexPath.section == 0 ? tableData[indexPath.row] : emptyValuesTableData[indexPath.row]
        var data: DebtsTableStruct?
        switch indexPath.section {
        case 0: data = tableData[indexPath.row]
        case 1: data = plusValues[indexPath.row]
        case 2: data = emptyValuesTableData[indexPath.row]
        default:
            data = tableData[indexPath.row]
        }
        if let dat = data {
            cell.categoryLabel.text = dat.name
            cell.amountLabel.text = indexPath.section == 2 ? "No records" : "\(dat.amount)"
        }
        cell.categoryLabel.textColor = darkAppearence ? K.Colors.category : .black
        cell.amountLabel.textColor = (data?.amount ?? 0) >= 0 ? (darkAppearence ? K.Colors.category : K.Colors.balanceV) : K.Colors.negative
        cell.amountLabel.alpha = indexPath.section == 2 ? 0.4 : 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            transactionAdded = true
            let mainFrame = view.frame
            let ai = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: mainFrame.height))
            ai.style = .gray
            view.addSubview(ai)
            ai.startAnimating()
            
            var title = ""
            var amountToPay = ""
            var dueDate = ""
            switch indexPath.section {
            case 0:
                title = self.tableData[indexPath.row].name
                amountToPay = self.tableData[indexPath.row].amountToPay
                dueDate = self.tableData[indexPath.row].dueDate
            case 1:
                title = self.plusValues[indexPath.row].name
                amountToPay = self.plusValues[indexPath.row].amountToPay
                dueDate = self.plusValues[indexPath.row].dueDate
            case 2:
                title = self.emptyValuesTableData[indexPath.row].name
                amountToPay = self.emptyValuesTableData[indexPath.row].amountToPay
                dueDate = self.emptyValuesTableData[indexPath.row].dueDate
            default:
                print("def")
            }
            
            var allDebts = Array(appData.debts)
            for i in 0..<allDebts.count {
                if allDebts[i].amountToPay == amountToPay && allDebts[i].dueDate == dueDate && allDebts[i].name == title {
                    allDebts.remove(at: i)
                    break
                }
            }
            appData.saveDebts(allDebts)
            
            if appData.username != "" {
                let delete = DeleteFromDB()
                let tods = "&Nickname=\(appData.username)" + "&name=\(title)" + "&amountToPay=\(amountToPay)" + "&dueDate=\(dueDate)"
                print(tods, "todstodstods")
                delete.Debts(toDataString: tods) { (error) in
                    if error {
                        appData.unsendedData.append(["deleteDebt": tods])
                    }
                }
            }
            self.getDataFromLocal()
            
            
        }
        deleteAction.backgroundColor = K.Colors.negative
        return UISwipeActionsConfiguration(actions: [deleteAction])
        /*switch indexPath.section {
        case 0:
            return UISwipeActionsConfiguration(actions: [])
        case 1:
            if plusValues[indexPath.row].amount == 0 {
                return UISwipeActionsConfiguration(actions: [deleteAction])
            } else {
                return UISwipeActionsConfiguration(actions: [])
            }
        case 2:
            return UISwipeActionsConfiguration(actions: [deleteAction])
        default:
            return UISwipeActionsConfiguration(actions: [])
        }*/
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var data: DebtsTableStruct?
        switch indexPath.section {
        case 0: data = tableData[indexPath.row]
        case 1: data = plusValues[indexPath.row]
        case 2: data = emptyValuesTableData[indexPath.row]
        default:
            data = tableData[indexPath.row]
        }
        if addingNew {
            DispatchQueue.main.async {
                self.newDebtField.endEditing(true)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            if let dat = data {
                if !fromSettings {
                    DispatchQueue.main.async {
                        self.delegate?.catDebtSelected(name: dat.name, amount: dat.amount)
                    }
                } else {
                    selectedCellData = dat
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toHistory", sender: self)
                    }
                }
            }
        }
        
    }

    
}

protocol DebtsVCProtocol {
    func catDebtSelected(name: String, amount: Int)
}

class debtCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}


extension DebtsVC : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("clear")
        DispatchQueue.main.async {
            
            self.newDebtField.endEditing(true)
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            if let name = self.newDebtField.text {
                if name != "" {
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
