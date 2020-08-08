//
//  CategoriesVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

class CategoriesVC: UIViewController {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoriesTableView: UITableView!
    var catData = appData.categoryVC
    var refreshControl = UIRefreshControl()
    var tableData = appData.getCategories()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        
        catData.purposPicker.delegate = self
        catData.purposPicker.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        addRefreshControll()
        whenNoCategories()
        let hiseCatsSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(hideCats(_:)))
        hiseCatsSwipe.direction = .left
        view.addGestureRecognizer(hiseCatsSwipe);
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
        load.Categories { (loadedData) in
            print("loaded \(loadedData.count) Categories from DB")
            var dataStruct: [CategoriesStruct] = []
            for i in 0..<loadedData.count {
                
                let name = loadedData[i][1]
                let purpose = loadedData[i][2]
                dataStruct.append(CategoriesStruct(name: name, purpose: purpose))
            }
            appData.saveCategories(dataStruct)
            self.tableData = appData.getCategories()
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            self.refreshControl.endRefreshing()
        }
    }
    
    func whenNoCategories() {
        
        if tableData.count == 0 {
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
    
    func sendToDB() {
        
        let Nickname = appData.username()
        if Nickname != "" {
            let Title = catData.categoryTextField.text ?? ""
            let Purpose = catData.allPurposes[catData.selectedPurpose]
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(Title)" + "&Purpose=\(Purpose)"
            let save = SaveToDB()
            save.Categories(toDataString: toDataString)
            
        } else {
            print(Nickname, "Nickname is nil")
        }

    }
    
    func deteteFromDB(at: Int) {
        let delete = DeleteFromDB()
        
        let Nickname = appData.username()
        let Title = tableData[at].name
        let Purpose = tableData[at].purpose
        let toDataString = "&Nickname=\(Nickname)" + "&Title=\(Title)" + "&Purpose=\(Purpose)"
        delete.Categories(toDataString: toDataString)
    }
    
    @IBAction func addCategoryPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertTextFields(alert: alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            if self.catData.categoryTextField.text != "" {
                let name = self.catData.categoryTextField.text ?? ""
                let value = self.catData.allPurposes[self.catData.selectedPurpose]
                self.tableData.insert(CategoriesStruct(name: name, purpose: value), at: 0)
                appData.saveCategories(self.tableData)
                self.whenNoCategories()
                self.sendToDB()
                
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
        
        cell.categoryNameLabel.text = "\(tableData[indexPath.row].name),"
        cell.categoryPurposeLabel.text = tableData[indexPath.row].purpose
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {

            deteteFromDB(at: indexPath.row)
            tableData.remove(at: indexPath.row)
            appData.saveCategories(tableData)
            whenNoCategories()
            
            DispatchQueue.main.async {
                self.categoriesTableView.reloadData()
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
