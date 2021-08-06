//
//  CategoriesVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData


///TODO:
//no data cell
var _categoriesHolder: [CategoriesStruct] = []

protocol CategoriesVCProtocol {
    func categorySelected(category: String, purpose: Int, fromDebts: Bool, amount: Int)
}

class CategoriesVC: SuperViewController, UNUserNotificationCenterDelegate {
    //@IBOutlet weak var addButton: UIButton!
   // @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var catData = appData.categoryVC
    var refreshControl = UIRefreshControl()
    //@IBOutlet weak var headerView: UIView!
    var hideTitle = false
    var fromSettings = false
    var delegate: CategoriesVCProtocol?
    var darkAppearence = false
    
    var safeAreaButton: CGFloat = 0.0

    
    
    //(categories[i].name, categories[i].count, categories[i].debt)
    var expenses: [(String, Int)] = []
    var incomes: [(String, Int)] = []
    
    lazy var viewTap:UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(pressedToDismiss(_:)))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        center.delegate = self
        updateUI()
        if _categoriesHolder.count == 0 {
            if appData.username != "" {
                let load = LoadFromDB()
                load.Categories{ (loadedData, error) in
                    
                    if error == "" {
                        print("loaded \(loadedData.count) Categories from DB")
                        var dataStruct: [CategoriesStruct] = []
                        for i in 0..<loadedData.count {
                            
                            let name = loadedData[i][1]
                            let purpose = loadedData[i][2]
                            let isDebt = loadedData[i][3] == "0" ? false : true
                            dataStruct.append(CategoriesStruct(name: name, purpose: purpose, count: 0))
                        }
                        _categoriesHolder = dataStruct
                        appData.saveCategories(dataStruct)
                        self.getDataFromLocal()
                    } else {
                        self.getDataFromLocal()
                    }
                    DispatchQueue.main.async {
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                    }
                }
            } else {
                getDataFromLocal()
                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                }
            }
        } else {
            
            self.getDataFromLocal()
            DispatchQueue.main.async {
                self.tableView.delegate = self
                self.tableView.dataSource = self
            }
        }

        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    @objc func pressedToDismiss(_ sender: UITapGestureRecognizer) {
        if self.newCategoryTextField.isFirstResponder {
            DispatchQueue.main.async {
                self.newCategoryTextField.endEditing(true)
                
            }
        }
    }
    
    var tableContentOf:UIEdgeInsets = UIEdgeInsets.zero
    @objc func keyboardWillHide(_ notification: Notification) {
          self.view.removeGestureRecognizer(viewTap)
        DispatchQueue.main.async {
            self.tableView.contentInset = self.tableContentOf
            self.editingValue = nil
            self.tableView.reloadData()
            
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
                    self.tableView.contentInset.bottom = keyboardHeight - self.safeAreaButton
                   // self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y - keyboardHeight)
                }

            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        toHistory = false

        navigationController?.setNavigationBarHidden(false, animated: true)
       /* //if iphone
        DispatchQueue.main.async {
            let mainFrame = self.view.frame
            if self.safeAreaButton > 0 {
                let window = UIApplication.shared.keyWindow ?? UIWindow()
            }

        }*/
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {

        if fromSettings {
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        print("didApp")
        //getDataFromLocal()
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.tableContentOf = self.tableView.contentInset
            self.tableView.reloadData()
        }
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if !toHistory {

        }

        if !toHistory {
            if fromSettings {
                if !wasEdited {
                    delegate?.categorySelected(category: "", purpose: 0, fromDebts: false, amount: 0)
                } else {
                    delegate?.categorySelected(category: "", purpose: 0, fromDebts: false, amount: 0)
                }
            }
        }
    }
    
    var wasEdited = false
    func updateUI() {
    
        
        newCategoryTextField.delegate = self
        catData.purposPicker.delegate = self
        catData.purposPicker.dataSource = self
        if appData.username != "" {
            addRefreshControll()
        }
        whenNoCategories()
        let hiseCatsSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(hideCats(_:)))
        hiseCatsSwipe.direction = .left
        view.addGestureRecognizer(hiseCatsSwipe);
        
        if #available(iOS 13.0, *) {
            if darkAppearence {
                self.newCategoryTextField.textColor = .white
                self.newCategoryTextField.keyboardAppearance = .dark
                self.view.backgroundColor = UIColor(named: "darkTableColor")
                self.tableView.backgroundColor = UIColor(named: "darkTableColor")
                self.tableView.separatorColor = UIColor(named: "darkSeparetor")
            }
        } else {
            DispatchQueue.main.async {
                if self.darkAppearence {
                    self.newCategoryTextField.textColor = .white
                    self.view.backgroundColor = UIColor(named: "darkTableColor")
                    self.tableView.backgroundColor = UIColor(named: "darkTableColor")
                    self.tableView.separatorColor = UIColor(named: "darkSeparetor")
                }
            }
        }
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        DispatchQueue.main.async {
            self.title = "Categories"
           // self.tableView.translatesAutoresizingMaskIntoConstraints = true
            self.newCategoryTextField.returnKeyType = .done
            self.newCategoryTextField.font = .systemFont(ofSize: 17, weight: .semibold)
            self.newCategoryTextField.clearButtonMode = .always
        }
    }
    

    func getDataFromLocal() {

        expenses = []
        incomes = []
        let categories = Array(appData.getCategories())
        for i in 0..<categories.count {
            if categories[i].purpose == K.expense {
                expenses.append((categories[i].name, categories[i].count))
            } else {
                incomes.append((categories[i].name, categories[i].count))
            }
        }
        whenNoCategories()
        expenses = expenses.sorted { $0.1 > $1.1 }
        incomes = incomes.sorted { $0.1 > $1.1 }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            if self.newCategoryTextField.isFirstResponder {
                self.newCategoryTextField.endEditing(true)
            } else {
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    
    
    @objc func hideCats(_ gesture: UISwipeGestureRecognizer) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func addRefreshControll() {
        DispatchQueue.main.async {
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            self.tableView.addSubview(self.refreshControl)
        }
    }
    @IBAction func addButtonPressedNavBar(_ sender: UIButton) {
        addPressed()
    }

    
    @objc func refresh(sender:AnyObject) {
        if appData.username != "" {
            let load = LoadFromDB()
            load.Categories{ (loadedData, error) in
                if error == "" {
                    print("loaded \(loadedData.count) Categories from DB")
                    var dataStruct: [CategoriesStruct] = []
                    for i in 0..<loadedData.count {
                        
                        let name = loadedData[i][1]
                        let purpose = loadedData[i][2]
                       // let isDebt = loadedData[i][3] == "0" ? false : true
                        dataStruct.append(CategoriesStruct(name: name, purpose: purpose, count: 0))
                    }
                    appData.saveCategories(dataStruct)
                    self.getDataFromLocal()
                    
                } else {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: error, type: .internetError)
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        } else {
            getDataFromLocal()
        }
    }
    
    func whenNoCategories() {
        if expenses.count == 0 && incomes.count == 0 {

        } else {

        }
    }
    
    func alertTextFields(alert: UIAlertController) {
        alert.addTextField { (category) in
            category.placeholder = "Category name"
            self.catData.categoryTextField = category
        }
        
        alert.addTextField { (purpose) in
            purpose.inputView = self.catData.purposPicker
            purpose.placeholder = "\(self.catData.allPurposes[self.catData.selectedPurpose])"
            self.catData.purposeField = purpose
        }
    }
    
    func sendToDBCategory(title: String, purpose: String) {
        wasEdited = true
        transactionAdded = true
        let Nickname = appData.username
        if Nickname != "" {
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(title)" + "&Purpose=\(purpose)" + "&ExpectingPayment=0"
            let save = SaveToDB()
            save.Categories(toDataString: toDataString) { (error) in
                var categories = Array(appData.getCategories())
                categories.append(CategoriesStruct(name: title, purpose: purpose, count: 0))
                appData.saveCategories(categories)
                self.getDataFromLocal()
                if error {
                    appData.unsendedData.append(["category": toDataString])
                }
            }
        }
    }
    
    func deteteCategory(at: IndexPath) {

        transactionAdded = true
        let delete = DeleteFromDB()
        let Nickname = appData.username
        let Title = at.section == 0 ? expenses[at.row].0 : incomes[at.row].0
        let Purpose = at.section == 0 ? K.expense : K.income
        wasEdited = true
        if appData.username != "" {
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(Title)" + "&Purpose=\(Purpose)" + "&ExpectingPayment=0"
            print("deleting:", toDataString)
            delete.Categories(toDataString: toDataString, completion: { (error) in
                if error {
                    print("Errordeletingcategory")
                    appData.unsendedData.append(["deleteCategory": toDataString])
                }
            })
        }
        if at.section == 0 {
            self.expenses.remove(at: at.row)
        } else {
            if at.section == 1 {
                self.incomes.remove(at: at.row)
            }
            
        }
        var result: [CategoriesStruct] = []
        for i in 0..<self.incomes.count {
            result.append(CategoriesStruct(name: self.incomes[i].0, purpose: K.income, count: 0))
        }
        for i in 0..<self.expenses.count {
            result.append(CategoriesStruct(name: self.expenses[i].0, purpose: K.expense, count: 0))
        }
        appData.saveCategories(result)
        self.getDataFromLocal()
        
    }
    
    @IBAction func addCategoryPressed(_ sender: UIButton) {
        addPressed()
    }
    //here
    func addPressed() {
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertTextFields(alert: alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in

            DispatchQueue.main.async {
                if let name = self.catData.categoryTextField.text {
                    if name != "" {
                        let purpose = self.catData.allPurposes[self.catData.selectedPurpose]
                        if appData.username != "" {
                            self.whenNoCategories()
                            self.sendToDBCategory(title: name, purpose: purpose)
                        } else {
                            var categories = Array(appData.getCategories())
                            categories.append(CategoriesStruct(name: name, purpose: purpose, count: 0))
                            appData.saveCategories(categories)
                            self.getDataFromLocal()
                        }
                    }
                }
            }

        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategoryName = ""
    func toHistory(category: String) {
        historyDataStruct = []
        let trans =  UserDefaults.standard.value(forKey: "transactionsData") as? [[String]] ?? []
        var totValue = 0.0
        for i in 0..<trans.count {
            if trans[i][2] == category {
                
                totValue = (Double(trans[i][1]) ?? 0.0) + totValue
                historyDataStruct.append(TransactionsStruct(value: trans[i][1], category: trans[i][2], date: trans[i][3], comment: trans[i][4]))
            }
        }

        
        selectedCategoryName = category
        if historyDataStruct.count > 0 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toHistory", sender: self)
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }

    var toHistory = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toHistory" {
            toHistory = true
            let vc = segue.destination as! HistoryVC
            vc.historyDataStruct = historyDataStruct
            vc.selectedCategoryName = selectedCategoryName
            vc.fromCategories = true
            vc.allowEditing = false
            
        } else {
            if segue.identifier == "toDebts" {
                let vc = segue.destination as! DebtsVC
      //          vc.debts = debts
                if !fromSettings {
                    vc.delegate = self
                    vc.darkAppearence = self.darkAppearence
                    vc.safeAreaButton = safeAreaButton
                }
            }
        }
    }
    
    let darkSectionBackground = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    
    var editingValue: editingType?
    enum editingType {
        case expenses
        case income
    }
    
    var editingString: String?
    
    @objc func addPressed(_ sender: UITapGestureRecognizer) {
        
        if let section = Int(sender.name ?? "") {
            self.showAnimatonOnSwitch = true
            self.newCategoryTextField.removeFromSuperview()
            switch section {
            case 0:
                editingValue = .expenses
            case 1:
                editingValue = .income
            default:
                return
            }
            
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
                //self.tableView.reloadData()
                //self.tableView.scrollToRow(at: IndexPath(row: self.editingValue! == .expenses ? self.expenses.count-1 : self.incomes.count-1, section: section), at: .bottom, animated: true)
                self.newCategoryTextField.text = ""
                self.tableView.reloadData()
            }
        }
    }
    
    let footerHeight:CGFloat = 35
    
    let newCategoryTextField = UITextField(frame: .zero)
    var showAnimatonOnSwitch = true
    //keyboardWillShoe and willHide - remove textfield
    
}


//MARK: - Table View

extension CategoriesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return expenses.count
        case 1: return incomes.count
        case 2: return darkAppearence ? 1 : 0
        default:
            return expenses.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return K.expense
        case 1: return K.income
        case 2: return nil
        default:
            return K.income
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
        cell.proView.layer.cornerRadius = 4
        if darkAppearence {
            cell.backgroundColor = UIColor(named: "darkTableColor")
        } else {
            cell.backgroundColor = K.Colors.background
        }
        
        switch indexPath.section {
        case 0:
            cell.proView.alpha = 0
            cell.categoryNameLabel.text = expenses[indexPath.row].0
            cell.qntLabel.text = "\(expenses[indexPath.row].1)"
        case 1:
            cell.proView.alpha = 0
            cell.categoryNameLabel.text = incomes[indexPath.row].0
            cell.qntLabel.text = "\(incomes[indexPath.row].1)"
        case 2:
            cell.proView.alpha = (appData.proVersion || appData.proTrial) ? 0 : 1
            cell.categoryNameLabel.text = "Debts"
            cell.qntLabel.text = "\((UserDefaults.standard.value(forKey: "allDebts") as? [[String]] ?? []).count)"
        default:
            cell.categoryNameLabel.text = incomes[indexPath.row].0
        }
        
        
        
        if darkAppearence {
            cell.categoryNameLabel.textColor = K.Colors.background
            cell.qntLabel.text = ""
            cell.accessoryType = indexPath.section == 2 ? .disclosureIndicator : .none
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lightBackground = K.Colors.background //UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1)
        view.backgroundColor = self.view.backgroundColor == K.Colors.background ? lightBackground : darkSectionBackground
        let mainFrame = self.view.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: 25))
        view.backgroundColor = self.view.backgroundColor == K.Colors.background ? lightBackground : darkSectionBackground
        let label = UILabel(frame: CGRect(x: 15, y: 5, width: mainFrame.width - 40, height: 20))
        label.text = section == 0 ? K.expense : K.income
        label.textColor = view.backgroundColor == lightBackground ? K.Colors.balanceT : K.Colors.balanceV
        label.font = .systemFont(ofSize: 14, weight: .medium)
        view.addSubview(label)
        switch section {
        case 0: label.text = K.expense
        case 1: label.text = K.income
        default:
            label.text = ""
        }
        return view
        
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return footerHeight// + (safeAreaButton > 0 ? 10 : 0)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
        //    let h = footerHeight + (safeAreaButton > 0 ? 10 : 0)
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: footerHeight + 20))
            view.backgroundColor = editingValue != nil ? ((section == 0 && editingValue! == .expenses) || (section == 1 && editingValue! == .income) ? self.tableView.backgroundColor : .clear) : .clear
            view.layer.masksToBounds = false
            view.layer.zPosition = 1
            view.superview?.layer.masksToBounds = false

            let button = UIButton(frame: CGRect(x: (tableView.frame.width / 2) - 55, y: self.safeAreaButton > 0 ? (darkAppearence ? 0 : 5) : 0, width: 110, height: footerHeight))
            let title = "New \(section == 0 ? "expense" : "income")"
            button.setTitle(title, for: .normal)
            button.layer.cornerRadius = 6
            button.backgroundColor = self.editingValue == nil ? (darkAppearence ? K.Colors.category : K.Colors.darkTable) : K.Colors.pink
            //button.tintColor = darkAppearence ? K.Colors.darkTable : K.Colors.category
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            button.setTitleColor(darkAppearence ? K.Colors.darkTable : K.Colors.category, for: .normal)
            view.addSubview(button)
            button.isUserInteractionEnabled = true
            button.layer.shadowPath = UIBezierPath(rect: button.bounds).cgPath
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.25
            button.layer.shadowOffset = .zero
            button.layer.shadowRadius = 6
            
            let addNew = UITapGestureRecognizer(target: self, action: #selector(addPressed(_:)))
            addNew.name = "\(section)"
            button.addGestureRecognizer(addNew)
            button.alpha = editingValue == nil ? 1 : 0.4
            if let isEditing = editingValue {
                if (section == 0 && isEditing == .expenses) || (section == 1 && isEditing == .income) {
                   
                    button.alpha = 0
                    self.newCategoryTextField.frame = CGRect(x: 15, y: 0, width: self.view.frame.width - 30, height: self.footerHeight)
                    view.addSubview(self.newCategoryTextField)
                    self.newCategoryTextField.becomeFirstResponder()
                    
                    
                    
                    
                }
            }
            return view
        } else {
            return nil
        }
    }

    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section != 2 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                //self.tableActionActivityIndicator.startAnimating()
                self.deteteCategory(at: indexPath)
            }
            deleteAction.backgroundColor = K.Colors.negative
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            return nil//UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if editingValue == nil {
            if indexPath.section == 2 {
                if appData.proVersion || appData.proTrial {
                    historyDataStruct = []
                    selectedCategoryName = ""
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toDebts", sender: self)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
                
            } else {
                if !fromSettings {
                    delegate?.categorySelected(category: indexPath.section == 0 ? expenses[indexPath.row].0 : incomes[indexPath.row].0, purpose: indexPath.section, fromDebts: false, amount: 0)
                    navigationController?.popToRootViewController(animated: true)
                } else {
                    switch indexPath.section {
                    case 0:
                        toHistory(category: expenses[indexPath.row].0)
                    case 1:
                        toHistory(category: incomes[indexPath.row].0)
                    default:
                        self.dismiss(animated: true)
                    }
                }
            }
        } else {
           /* DispatchQueue.main.async {
                self.newCategoryTextField.endEditing(true)
            }*/
        }
        
    }
    
}


//MARK: - PickerView

extension CategoriesVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return catData.allPurposes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        catData.purposeField.text = "\(catData.allPurposes[row])"
        catData.selectedPurpose = row
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return catData.allPurposes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = catData.allPurposes[row]
        let myTitle = NSAttributedString(string: "\(titleData)")
        return myTitle
    }
    
}


extension CategoriesVC: DebtsVCProtocol {
    func catDebtSelected(name: String, amount: Int) {
        delegate?.categorySelected(category: name, purpose: 1, fromDebts: true, amount: amount)
        navigationController?.popToRootViewController(animated: true)
    }
    
    
}

extension CategoriesVC: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("clear")
        DispatchQueue.main.async {
            
            self.newCategoryTextField.endEditing(true)
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            if let name = self.newCategoryTextField.text {
                if name != "" {
                    if let puposee = self.editingValue {
                        let purpose = puposee == .expenses ? K.expense : K.income
                        if appData.username != "" {
                            self.whenNoCategories()
                            self.sendToDBCategory(title: name, purpose: purpose)
                        } else {
                            var categories = Array(appData.getCategories())
                            categories.append(CategoriesStruct(name: name, purpose: purpose, count: 0))
                            appData.saveCategories(categories)
                            self.getDataFromLocal()
                        }
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
