//
//  categoriesVCcell.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 21.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class categoriesVCcell: UITableViewCell {
    
    @IBOutlet weak var footerBackground: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var qntLabel: UILabel!
    @IBOutlet weak var proView: UIView!
    @IBOutlet weak var iconimage: UIImageView!
    
    
    
    @IBOutlet weak var dueDateIcon: UIImageView!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDateStack: UIStackView!
    @IBOutlet weak var payAmountLabel: UILabel!
    
    @IBOutlet weak var buttonsSeparetor: UIView!
    
    @IBOutlet weak var editingStack: UIStackView!
    @IBOutlet weak var newCategoryTF: UITextField!
    
    
    
    private var indexPath:IndexPath?
    private var footerSection: Int?
    

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var unseenIndicatorView: UIView!
    
    var drawed = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !drawed {
            drawed = true
            if #available(iOS 13.0, *) {
                
            } else {
                iconimage.isHidden = true
            }
        }
        unseenIndicatorView.layer.cornerRadius = 4
       // newCategoryTF.layer.cornerRadius = 6
       // newCategoryTF.setRightPaddingPoints(5)
       // newCategoryTF.setLeftPaddingPoints(5)
        
    }
    
    func lo(index:IndexPath?, footer: Int?) {
        indexPath = index
        footerSection = footer

        var category:CategoriesVC.ScreenCategory {
            let defaultCategory = CategoriesVC.ScreenCategory(category: NewCategories(id: -2, name: "-", icon: "", color: "", purpose: CategoriesVC.shared?.screenType == .debts ? .debt : .expense), transactions: [])
            if let index = index {
                return CategoriesVC.shared?.tableData[index.section].data[index.row] ?? defaultCategory
            } else {
                if let footer = footer {
                    return CategoriesVC.shared?.tableData[footer].newCategory ?? defaultCategory
                } else {
                    return defaultCategory
                }
            }
        }

        currentCategory = category
        if index != nil {
            self.newCategoryTF.delegate = self
            self.newCategoryTF.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
            if #available(iOS 13.0, *) {
                let iconPressed = UITapGestureRecognizer(target: self, action: #selector(self.iconPressed(_:)))//
                self.iconimage.addGestureRecognizer(iconPressed)
            }
            
        }
        let defPlaceHolder = "New category".localize
        newCategoryTF.placeholder = index != nil ? (CategoriesVC.shared?.tableData[index!.section].data[index!.row].category.name ?? defPlaceHolder) : defPlaceHolder
        newCategoryTF.setPlaceHolderColor(K.Colors.textFieldPlaceholder)
        
    }
    
    @objc private func iconPressed(_ sender: UITapGestureRecognizer) {
        if let indexPath = indexPath {
            if let category = currentCategory {
                if category.editing != nil {
                    CategoriesVC.shared?.selectingIconFor.0 = indexPath
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            self.footerBackground.backgroundColor = CategoriesVC.shared?.selectionBacground
                        } completion: { _ in
                            CategoriesVC.shared?.tableView.reloadData()
                        }

                    }
                }
            }
        }
    }

    
    @objc private func textfieldValueChanged(_ textField: UITextField) {
        if let footerSection = footerSection {
            DispatchQueue.main.async {
                CategoriesVC.shared?.tableData[footerSection].newCategory.category.name = textField.text ?? ""
                
            }
        } else {
            if let indexPath = indexPath {
                DispatchQueue.main.async {
                    CategoriesVC.shared?.tableData[indexPath.section].data[indexPath.row].editing?.name = textField.text ?? ""
                    self.currentCategory?.editing?.name = textField.text ?? ""
                }
            }
        }
    }
    
    
    private var currentCategory: CategoriesVC.ScreenCategory?
    
    @IBAction private func cancelPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
            UIView.animate(withDuration: 0.18) {
                self.editingStack.isHidden = true
                self.editingStack.alpha = 0
                self.qntLabel.superview?.isHidden = false
                self.categoryNameLabel.isHidden = false
            } completion: { _ in
                self.cancelEditing()
                self.editingStack.alpha = 1
            }

        }
        
    }
    
    private func cancelEditing() {
        if let index = indexPath {
            CategoriesVC.shared?.tableData[index.section].data[index.row].editing = nil
            DispatchQueue.main.async {
           //     CategoriesVC.shared?.t/oggleIcons(show: false, animated: true, category: nil)
                CategoriesVC.shared?.editingTF?.endEditing(true)
                CategoriesVC.shared?.editingTF = nil
                CategoriesVC.shared?.selectingIconFor = (nil, nil)
                CategoriesVC.shared?.editingTfIndex = (nil, nil)
                CategoriesVC.shared?.tableView.reloadData()
                CategoriesVC.shared?.ai.fastHide { _ in
                    
                }
            }
        }
    }
    
    
    private let db = DataBase()
    
    
    
    
    
    private func saveCategory(_ category: CategoriesVC.ScreenCategory) {

        if category.editing != nil {
            if let index = indexPath {
                if let editingValue = category.editing {
                    let delete = DeleteFromDB()
                    delete.CategoriesNew(category: category.category) { error in
                       // let save = SaveToDB()
                        SaveToDB.shared.newCategories(editingValue) { error in
                            //CategoriesVC.shared?.loadData(loadFromUD: true)
                            CategoriesVC.shared?.tableData[index.section].data[index.row].editing = nil
                            CategoriesVC.shared?.tableData[index.section].data[index.row].category = editingValue
                            DispatchQueue.main.async {
                                CategoriesVC.shared?.selectingIconFor = (nil,nil)
                             //   CategoriesVC.shared?.t/oggleIcons(show: false, animated: true, category: nil)
                                CategoriesVC.shared?.editingTF?.endEditing(true)
                                CategoriesVC.shared?.editingTF = nil
                                CategoriesVC.shared?.tableView.reloadData()
                                CategoriesVC.shared?.ai.fastHide(completionn: { _ in
                              //      UIImpactFeedbackGenerator().impactOccurred()
                                })
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    @IBOutlet weak var footerHelperBottomView: UIView!
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
       // DispatchQueue.main.async {
            CategoriesVC.shared?.ai.show(title:"Saving") { _ in
                if let currentCategory = self.currentCategory {
                    if currentCategory.editing?.name != "" {
                        self.saveCategory(currentCategory)
                    } else {
                        self.cancelEditing()
                    }
                }
                CategoriesVC.shared?.selectingIconFor = (nil,nil)
              /*  if CategoriesVC.shared?.showingIcons ?? false {
                    CategoriesVC.shared?.t/oggleIcons(show: false, animated: true, category: nil)
                }*/
            }
      //  }
    }
    
    
    
    
    //new
    func tfPressed() {
        //table view reload
        //tf begin editing
    }
    
}




extension categoriesVCcell:UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.footerBackground.backgroundColor = K.Colors.secondaryBackground
        } completion: { _ in
            
        }

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        CategoriesVC.shared?.editingTF = textField

        let name = textField.layer.name ?? ""
        if name.contains("cell") {
            let rowS = name.replacingOccurrences(of: "cell", with: "")
            let dobRo = Double(rowS) ?? 0.0
            let row = Int(dobRo)
            let prevRow = CategoriesVC.shared?.editingTfIndex.1
            CategoriesVC.shared?.editingTfIndex = (nil, row)
            CategoriesVC.shared?.selectingIconFor = (nil, nil)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        self.footerBackground.backgroundColor = CategoriesVC.shared?.selectionBacground
                    } completion: { _ in
                        
                    }
                }

            
        } else {
            if name.contains("section") {
                let rowS = name.replacingOccurrences(of: "section", with: "")
                let dobRo = Double(rowS) ?? 0.0
                let section = Int(dobRo) //{
                    CategoriesVC.shared?.editingTfIndex = (section, nil)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            self.footerBackground.backgroundColor = CategoriesVC.shared?.selectionBacground
                        } completion: { _ in
                            textField.becomeFirstResponder()
                        }

                    }
                    //CategoriesVC.shared?.tableView.reloadData()
           //     }
                
            }
        }

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
