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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoriesTableView: UITableView!
    var catData = appData.categoryVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        
        loadData()
        catData.purposPicker.delegate = self
        catData.purposPicker.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
    }
    
    func loadData(_ request: NSFetchRequest<Categories> = Categories.fetchRequest(), predicate: NSPredicate? = nil) {
        
        do { appData.categories = try appData.context().fetch(request)
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}
        categoriesTableView.reloadData()
        whenNoCategories()
    }
    
    func whenNoCategories() {
        
        if appData.categories.count == 0 {
            titleLabel.text = "No categories"
            titleLabel.textAlignment = .center
        } else {
            titleLabel.text = "Categories"
            titleLabel.textAlignment = .left
        }
    }
    
    func saveItems() {
        
        do { try appData.context().save()
        } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
        categoriesTableView.reloadData()
        whenNoCategories()
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
    
    @IBAction func addCategoryPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertTextFields(alert: alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            if self.catData.categoryTextField.text != "" {
                let new = Categories(context: appData.context())
                new.purpose = self.catData.allPurposes[self.catData.selectedPurpose]
                new.name = self.catData.categoryTextField.text
                appData.categories.insert(new, at: 0)
                self.saveItems()
            }
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - extensions
extension CategoriesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appData.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
        
        cell.categoryNameLabel.text = "\(appData.categories[indexPath.row].name ?? K.Text.unknCat),"
        cell.categoryPurposeLabel.text = appData.categories[indexPath.row].purpose
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            appData.context().delete(appData.categories[indexPath.row])
            appData.categories.remove(at: indexPath.row)
            self.saveItems()
            
        }
    }
}

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
