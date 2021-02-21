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
    func categorySelected(category: String, purpose: Int)
}

class CategoriesVC: UIViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var catData = appData.categoryVC
    var refreshControl = UIRefreshControl()
    var allCategoriesData = Array(appData.getCategories())
    @IBOutlet weak var headerView: UIView!
    var hideTitle = false
    var fromSettings = false
    var delegate: CategoriesVCProtocol?
    var darkAppearence = false
    
    var transactions: [TransactionsStruct] {
        get {
            if fromSettings {
                return appData.transactions
            } else {
                return []
            }
        }
    }
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
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
        print("expenses: \(expenses.count), incomes: \(incomes.count)")
        expenses = expenses.sorted { $0.1 > $1.1 }
        incomes = incomes.sorted { $0.1 > $1.1 }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    var expenses: [(String, Int)] = []
    var incomes: [(String, Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        navigationController?.setNavigationBarHidden(fromSettings ? true : false, animated: true)
        for i in 0..<tableView.visibleCells.count {
            let indexPath = IndexPath(row: i, section: 0)
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if fromSettings {
            if wasEdited {
                delegate?.categorySelected(category: "", purpose: 0)
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
        addRefreshControll()
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
        let Nickname = appData.username
        if Nickname != "" {
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(title)" + "&Purpose=\(purpose)"
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
    
    //here
    func deteteCategory(at: IndexPath) {
        let delete = DeleteFromDB()
        let Nickname = appData.username
        let Title = at.section == 0 ? expenses[at.row].0 : incomes[at.row].0
        let Purpose = at.section == 0 ? K.expense : K.income
        wasEdited = true
        if appData.username != "" {
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(Title)" + "&Purpose=\(Purpose)"
            delete.Categories(toDataString: toDataString, completion: { (error) in
                if error {
                    print("Errordeletingcategory")
                    appData.unsendedData.append(["deleteCategory": toDataString])
                }
                if at.section == 0 {
                    self.expenses.remove(at: at.row)
                } else {
                    self.incomes.remove(at: at.row)
                }
                var result: [CategoriesStruct] = []
                for i in 0..<self.incomes.count {
                    result.append(CategoriesStruct(name: self.incomes[i].0, purpose: K.income, count: 0))
                }
                for i in 0..<self.expenses.count {
                    result.append(CategoriesStruct(name: self.expenses[i].0, purpose: K.expense, count: 0))
                }
                self.allCategoriesData = result
                appData.saveCategories(self.allCategoriesData)
                self.getDataFromLocal()
                
            })
        }
        

        
    }
    
    @IBAction func addCategoryPressed(_ sender: UIButton) {
        addPressed()
    }
    
    func addPressed() {
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertTextFields(alert: alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            if self.catData.categoryTextField.text != "" {
                let name = self.catData.categoryTextField.text ?? ""
                let purpose = self.catData.allPurposes[self.catData.selectedPurpose]
                if appData.username != "" {
                    self.getDataFromLocal()
                    self.whenNoCategories()
                    self.sendToDBCategory(title: name, purpose: purpose)
                } else {
                    var categories = Array(appData.getCategories())
                    categories.append(CategoriesStruct(name: name, purpose: purpose, count: 0))
                    appData.saveCategories(categories)
                    self.getDataFromLocal()
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
        for i in 0..<transactions.count {
            if transactions[i].category == category {
                historyDataStruct.append(transactions[i])
            }
        }
        
        selectedCategoryName = category
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toHistory", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistory" {
            let vc = segue.destination as! HistoryVC
            vc.historyDataStruct = historyDataStruct
            vc.selectedCategoryName = selectedCategoryName
            vc.fromCategories = true
        }
    }
    
}


//MARK: - Table View

extension CategoriesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return expenses.count
        case 1: return incomes.count
        default:
            return expenses.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return K.expense
        case 1: return K.income
        default:
            return K.income
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
        
        switch indexPath.section {
        case 0:
            cell.categoryNameLabel.text = expenses[indexPath.row].0
            cell.qntLabel.text = "\(expenses[indexPath.row].1)"
        case 1:
            cell.categoryNameLabel.text = incomes[indexPath.row].0
            cell.qntLabel.text = "\(incomes[indexPath.row].1)"
            
        default:
            cell.categoryNameLabel.text = incomes[indexPath.row].0
        }
        
        if darkAppearence {
            cell.backgroundColor = UIColor(named: "darkTableColor")
        } else {
            cell.backgroundColor = K.Colors.background
        }
        
        if darkAppearence {
            cell.categoryNameLabel.textColor = K.Colors.background
            cell.qntLabel.text = ""
            cell.accessoryType = .none
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainFrame = self.view.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: 25))
        let lightBackground = K.Colors.background //UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1)
        let darkBackground = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        view.backgroundColor = self.view.backgroundColor == K.Colors.background ? lightBackground : darkBackground
        let label = UILabel(frame: CGRect(x: 15, y: 5, width: mainFrame.width - 40, height: 20))
        label.text = section == 0 ? K.expense : K.income
        label.textColor = view.backgroundColor == lightBackground ? K.Colors.balanceT : K.Colors.balanceV
        label.font = .systemFont(ofSize: 14, weight: .medium)
        view.addSubview(label)
        return view
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            deteteCategory(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !fromSettings {
            delegate?.categorySelected(category: indexPath.section == 0 ? expenses[indexPath.row].0 : incomes[indexPath.row].0, purpose: indexPath.section)
            navigationController?.popToRootViewController(animated: true)
        } else {
            if indexPath.section == 0 {
                toHistory(category: expenses[indexPath.row].0)
            } else {
                if indexPath.section == 1 {
                    toHistory(category: incomes[indexPath.row].0)
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
