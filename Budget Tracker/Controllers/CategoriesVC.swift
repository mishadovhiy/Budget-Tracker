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
    @IBOutlet weak var categoriesTableView: UITableView!
    var catData = appData.categoryVC
    var refreshControl = UIRefreshControl()
    var allCategoriesData = Array(appData.getCategories())
    @IBOutlet weak var headerView: UIView!
    var hideTitle = false
    var fromSettings = false
    var delegate: CategoriesVCProtocol?
    var darkAppearence = false
    
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
                expenses.append(categories[i].name)
            } else {
                incomes.append(categories[i].name)
            }
        }
        whenNoCategories()
        print("expenses: \(expenses.count), incomes: \(incomes.count)")
        DispatchQueue.main.async {
            self.categoriesTableView.reloadData()
        }
        
        
    }
    
    var expenses: [String] = []
    var incomes: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        if darkAppearence {
            DispatchQueue.main.async {
                self.view.backgroundColor = UIColor(named: "darkTableColor")
                self.headerView.backgroundColor = UIColor(named: "darkTableColor")
                self.categoriesTableView.backgroundColor = UIColor(named: "darkTableColor")
                self.categoriesTableView.separatorColor = UIColor(named: "darkSeparetor")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if delegate != nil {
            navigationController?.setNavigationBarHidden(false, animated: true)
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
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        addRefreshControll()
        whenNoCategories()
        let hiseCatsSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(hideCats(_:)))
        hiseCatsSwipe.direction = .left
        view.addGestureRecognizer(hiseCatsSwipe);
        
        if hideTitle {
            title = "Categories"
            DispatchQueue.main.async {
                let frame = self.headerView.frame
                let selfFrame = self.categoriesTableView.frame
                self.headerView.isHidden = true
                self.categoriesTableView.translatesAutoresizingMaskIntoConstraints = true
                self.categoriesTableView.frame = CGRect(x: 0, y: frame.minY, width: selfFrame.width, height: selfFrame.height + frame.height)
            }
        }
    }
    
    @objc func hideCats(_ gesture: UISwipeGestureRecognizer) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func addRefreshControll() {
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "+")
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.clear
        categoriesTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender:AnyObject) {
        let load = LoadFromDB()
        load.Categories{ (loadedData, error) in
            if error == "" {
                print("loaded \(loadedData.count) Categories from DB")
                var dataStruct: [CategoriesStruct] = []
                for i in 0..<loadedData.count {
                    
                    let name = loadedData[i][1]
                    let purpose = loadedData[i][2]
                    dataStruct.append(CategoriesStruct(name: name, purpose: purpose))
                }
                appData.saveCategories(dataStruct)
                self.getDataFromLocal()
                DispatchQueue.main.async {
                    self.categoriesTableView.reloadData()
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
                categories.append(CategoriesStruct(name: title, purpose: purpose))
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
        let Title = at.section == 0 ? expenses[at.row] : incomes[at.row]
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
                    result.append(CategoriesStruct(name: self.incomes[i], purpose: K.income))
                }
                for i in 0..<self.expenses.count {
                    result.append(CategoriesStruct(name: self.expenses[i], purpose: K.expense))
                }
                self.allCategoriesData = result
                appData.saveCategories(self.allCategoriesData)
                self.getDataFromLocal()
                
            })
        }
        

        
    }
    
    @IBAction func addCategoryPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertTextFields(alert: alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            if self.catData.categoryTextField.text != "" {
                let name = self.catData.categoryTextField.text ?? ""
                let purpose = self.catData.allPurposes[self.catData.selectedPurpose]
                self.getDataFromLocal()
                self.whenNoCategories()
                self.sendToDBCategory(title: name, purpose: purpose)
            }
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
        case 0: cell.categoryNameLabel.text = expenses[indexPath.row]
        case 1: cell.categoryNameLabel.text = incomes[indexPath.row]
        default:
            cell.categoryNameLabel.text = incomes[indexPath.row]
            
        }
        
        if darkAppearence {
            cell.contentView.layer.backgroundColor = UIColor(named: "darkTableColor")?.cgColor
        } else {
            cell.contentView.layer.backgroundColor = K.Colors.background?.cgColor
        }
        
        if darkAppearence {
            cell.categoryNameLabel.textColor = K.Colors.background
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainFrame = self.view.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: 25))
        let lightBackground = K.Colors.background //UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1)
        let darkBackground = UIColor(red: 13/255, green: 15/255, blue: 19/255, alpha: 1)
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
        if delegate != nil {
            delegate?.categorySelected(category: indexPath.section == 0 ? expenses[indexPath.row] : incomes[indexPath.row], purpose: indexPath.section)
            navigationController?.popToRootViewController(animated: true)
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
