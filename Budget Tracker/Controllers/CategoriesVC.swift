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
    
    var delegate: CategoriesVCProtocol?
    
    func getDataFromLocal() {
        expenses = []
        incomes = []
        for i in 0..<allCategoriesData.count {
            if allCategoriesData[i].purpose == K.expense {
                expenses.append(allCategoriesData[i].name)
            } else {
                incomes.append(allCategoriesData[i].name)
            }
        }
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if delegate != nil {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
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
        
        if delegate != nil {
            headerView.isHidden = true
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
        load.Categories(mainView: self) { (loadedData) in
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
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            self.refreshControl.endRefreshing()
        }
    }
    
    func whenNoCategories() {
        
        if expenses.count == 0 && incomes.count == 0 {
            titleLabel.text = "No categories"
            titleLabel.textAlignment = .center
        } else {
            titleLabel.text = "Categories"
            titleLabel.textAlignment = .left
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
    
    func sendToDBCategory() {
        
        let Nickname = appData.username
        if Nickname != "" {
            let Title = catData.categoryTextField.text ?? ""
            let Purpose = catData.allPurposes[catData.selectedPurpose]
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(Title)" + "&Purpose=\(Purpose)"
            let save = SaveToDB()
          //  save.Categories(toDataString: toDataString, mainView: self)
            
        }

    }
    
    func deteteCategory(at: IndexPath) {
        
        let delete = DeleteFromDB()
        let Nickname = appData.username
        let Title = at.section == 0 ? expenses[at.row] : incomes[at.row]
        let Purpose = at.section == 0 ? K.expense : K.income
        
        if appData.username != "" {
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(Title)" + "&Purpose=\(Purpose)"
            delete.Categories(toDataString: toDataString, mainView: self)
        }
        

        if at.section == 0 {
            expenses.remove(at: at.row)
        } else {
            incomes.remove(at: at.row)
        }
        var result: [CategoriesStruct] = []
        for i in 0..<incomes.count {
            result.append(CategoriesStruct(name: incomes[i], purpose: K.income))
        }
        for i in 0..<expenses.count {
            result.append(CategoriesStruct(name: expenses[i], purpose: K.expense))
        }
        allCategoriesData = result
        appData.saveCategories(allCategoriesData)
    }
    
    @IBAction func addCategoryPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertTextFields(alert: alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            if self.catData.categoryTextField.text != "" {
                let name = self.catData.categoryTextField.text ?? ""
                let purpose = self.catData.allPurposes[self.catData.selectedPurpose]
                self.allCategoriesData.append(CategoriesStruct(name: name, purpose: purpose))
                appData.saveCategories(self.allCategoriesData)
                self.getDataFromLocal()
                self.whenNoCategories()
                
                if appData.internetPresend != nil {
                    if appData.internetPresend! == false {
                        self.sendToDBCategory()
                    }
                }
                
                
                DispatchQueue.main.async {
                    self.categoriesTableView.reloadData()
                }
            }
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
            cell.categoryNameLabel.text = expenses[indexPath.row]
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
            cell.categoryNameLabel.text = incomes[indexPath.row]
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
            cell.categoryNameLabel.text = incomes[indexPath.row]
            return cell
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {

            deteteCategory(at: indexPath)
            whenNoCategories()
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
            }
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
