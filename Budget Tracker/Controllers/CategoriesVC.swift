//
//  CategoriesVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

protocol CategoriesVCProtocol {
    func categorySelected(category: String, purpose: Int, fromDebts: Bool, amount: Int)
}

class CategoriesVC: UIViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var catData = appData.categoryVC
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var headerView: UIView!
    var hideTitle = false
    var fromSettings = false
    var delegate: CategoriesVCProtocol?
    var darkAppearence = false
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    
    //(categories[i].name, categories[i].count, categories[i].debt)
    var expenses: [(String, Int)] = []
    var incomes: [(String, Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helperNavView.backgroundColor = K.Colors.background
        if #available(iOS 13.0, *) {
            if darkAppearence {
                self.view.backgroundColor = UIColor(named: "darkTableColor")
                self.headerView.backgroundColor = UIColor(named: "darkTableColor")
                self.tableView.backgroundColor = UIColor(named: "darkTableColor")
                self.tableView.separatorColor = UIColor(named: "darkSeparetor")
            }
        } else {
            DispatchQueue.main.async {
                if self.darkAppearence {
                    self.view.backgroundColor = UIColor(named: "darkTableColor")
                    self.headerView.backgroundColor = UIColor(named: "darkTableColor")
                    self.tableView.backgroundColor = UIColor(named: "darkTableColor")
                    self.tableView.separatorColor = UIColor(named: "darkSeparetor")
                }
            }
        }
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        toHistory = false
        //navigationController?.setNavigationBarHidden(fromSettings ? true : false, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    let helperNavView = UIView()
    override func viewWillDisappear(_ animated: Bool) {

        if fromSettings {
            DispatchQueue.main.async {
                let window = UIApplication.shared.keyWindow ?? UIWindow()
                self.helperNavView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: safeArTopHeight)
                window.addSubview(self.helperNavView)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("didApp")
        //getDataFromLocal()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if !toHistory {
            DispatchQueue.main.async {
                self.helperNavView.removeFromSuperview()
            }
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
    
        getDataFromLocal()
        catData.purposPicker.delegate = self
        catData.purposPicker.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        if appData.username != "" {
            addRefreshControll()
        }
        whenNoCategories()
        let hiseCatsSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(hideCats(_:)))
        hiseCatsSwipe.direction = .left
        view.addGestureRecognizer(hiseCatsSwipe);
        
        if hideTitle {
            title = "Categories"
            DispatchQueue.main.async {
                let frame = self.headerView.frame
                let selfFrame = self.tableView.frame
                self.headerView.isHidden = true
                self.tableView.translatesAutoresizingMaskIntoConstraints = true
                self.tableView.frame = CGRect(x: 0, y: frame.minY, width: selfFrame.width, height: selfFrame.height + frame.height)
            }
        }
    }
    

    func getDataFromLocal() {
        expenses = []
        incomes = []
 //       debts = []
        let categories = Array(appData.getCategories())
        for i in 0..<categories.count {
            if categories[i].purpose == K.expense {
                expenses.append((categories[i].name, categories[i].count))
            } else {
                incomes.append((categories[i].name, categories[i].count))
            }
        }
        whenNoCategories()
        //print("expenses: \(expenses.count), incomes: \(incomes.count)", "debts: \(debts)")
        expenses = expenses.sorted { $0.1 > $1.1 }
        incomes = incomes.sorted { $0.1 > $1.1 }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    
    
    @objc func hideCats(_ gesture: UISwipeGestureRecognizer) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func addRefreshControll() {
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
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
                        let isDebt = loadedData[i][3] == "0" ? false : true
                        dataStruct.append(CategoriesStruct(name: name, purpose: purpose, count: 0))
                    }
                    appData.saveCategories(dataStruct)
                    self.getDataFromLocal()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: error, type: .internetError)
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    
    func whenNoCategories() {
        if expenses.count == 0 && incomes.count == 0 {
            DispatchQueue.main.async {
                self.titleLabel.text = "No categories"
                self.titleLabel.textAlignment = .center
            }
        } else {
            DispatchQueue.main.async {
                self.titleLabel.text = "Categories"
                self.titleLabel.textAlignment = .left
            }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
                }
            }
        }
    }
    
    let darkSectionBackground = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    
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
        
        if darkAppearence {
            cell.backgroundColor = UIColor(named: "darkTableColor")
        } else {
            cell.backgroundColor = K.Colors.background
        }
        
        switch indexPath.section {
        case 0:
            cell.categoryNameLabel.text = expenses[indexPath.row].0
            cell.qntLabel.text = "\(expenses[indexPath.row].1)"
        case 1:
            cell.categoryNameLabel.text = incomes[indexPath.row].0
            cell.qntLabel.text = "\(incomes[indexPath.row].1)"
        case 2:
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

    
    
   /* func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print(indexPath.section, "indexPath.section")
        if indexPath.section != 0 {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                deteteCategory(at: indexPath)
            }
        }
    }*/
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
        if indexPath.section == 2 {
            historyDataStruct = []
            selectedCategoryName = ""
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toDebts", sender: self)
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
