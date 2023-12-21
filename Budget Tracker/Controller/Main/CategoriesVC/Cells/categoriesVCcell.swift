//
//  categoriesVCcell.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 21.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class categoriesVCcell: ClearCell {
    
    @IBOutlet weak var progressView: UIProgressView!
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
    @IBOutlet weak var newCategoryTF: TextField!
    
    
    
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
            if !(AppDelegate.shared!.properties?.appData.symbolsAllowed ?? true) {
                iconimage.isHidden = true
            }
            self.touchesBegunAction = { began in
                UIView.animate(withDuration: 0.2, animations: {
                    self.footerBackground.backgroundColor = began ? K.Colors.link : K.Colors.secondaryBackground
                })
            }
        }


    }
    
    func set(index:IndexPath?, footer: Int?) {
        indexPath = index
        footerSection = footer

        var category:CategoriesVC.ScreenCategory {
            if let data = CategoriesVC.shared?.tableData {
                if let index = index {
                    if data.count > index.section {
                        if data[index.section].data.count > index.row {
                            return data[index.section].data[index.row]
                        }
                    }
                } else {
                    if let footer = footer, data.count - 1 >= footer, data.count != 0 {
                        return data[footer].newCategory
                    }
                }
            }
            return CategoriesVC.ScreenCategory(category: NewCategories(id: -2, name: "-", icon: "", color: "", purpose: CategoriesVC.shared?.screenType == .debts ? .debt : .expense), transactions: [])
        }
        currentCategory = category
        let hasProgress = currentCategory?.category.purpose != .debt && currentCategory?.category.monthLimit != nil
        let hideprogress = !(hasProgress && currentCategory?.editing == nil)
        progressView.isHidden = hideprogress
        if !hideprogress {
            let val = Float(currentCategory?.progress ?? 0)
            print(val, " egrwfereg")
                self.progressView.progress = val
            
        } else {
                self.progressView.progress = 0
        }
        progressView.tintColor = .init(named: currentCategory?.category.color ?? "") ?? K.Colors.link
        
        if index != nil {
            self.newCategoryTF.delegate = self
            self.newCategoryTF.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
            if AppDelegate.shared!.properties?.appData.symbolsAllowed ?? false {
                let iconPressed = UITapGestureRecognizer(target: self, action: #selector(self.iconPressed(_:)))//
                self.iconimage.addGestureRecognizer(iconPressed)
            }
            
        }
        if ((CategoriesVC.shared?.tableData.count ?? 0) - 1) >= (index?.section ?? 0) && index != nil && (CategoriesVC.shared?.tableData[index!.section].data.count ?? 0) - 1 >= index!.row {
            let defPlaceHolder = "New category".localize
            newCategoryTF.placeholder = index != nil ? (CategoriesVC.shared?.tableData[index!.section].data[index!.row].category.name ?? defPlaceHolder) : defPlaceHolder
            newCategoryTF.setPlaceHolderColor(K.Colors.textFieldPlaceholder)
        }
        
        
    }
    
    @objc private func iconPressed(_ sender: UITapGestureRecognizer) {
        if let indexPath = indexPath {
            if let category = currentCategory {
                if category.editing != nil {
                    CategoriesVC.shared?.selectingIconFor.0 = indexPath
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            self.footerBackground.backgroundColor = CategoriesVC.shared?.selectionBacground
                        } completion: { 
                            if !$0 {
                                return
                            }
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
                self.editingStack.alpha = 0
                self.qntLabel.superview?.isHidden = false
                self.categoryNameLabel.isHidden = false
                self.dueDateStack.isHidden = false
            } completion: { 
                if !$0 {
                    return
                }
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
                CategoriesVC.shared?.ai?.fastHide()
            }
        }
    }
    
    
    private func saveCategory(_ category: CategoriesVC.ScreenCategory) {
        if category.editing != nil {
            if let index = indexPath {
                if let editingValue = category.editing {
                    let delete = DeleteFromDB()
                    delete.CategoriesNew(category: category.category) { error in
                        SaveToDB.shared.newCategories(editingValue) { error in
                            CategoriesVC.shared?.tableData[index.section].data[index.row].editing = nil
                            CategoriesVC.shared?.tableData[index.section].data[index.row].category = editingValue
                            DispatchQueue.main.async {
                                CategoriesVC.shared?.selectingIconFor = (nil,nil)
                                CategoriesVC.shared?.editingTF?.endEditing(true)
                                CategoriesVC.shared?.editingTF = nil
                                CategoriesVC.shared?.tableView.reloadData()
                                CategoriesVC.shared?.ai?.fastHide()
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    @IBOutlet weak var footerHelperBottomView: UIView!
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
            CategoriesVC.shared?.ai?.show(title:"Saving", notShowIfLoggedUser: true) { _ in
                if let currentCategory = self.currentCategory {
                    if currentCategory.editing?.name != "" {
                        self.saveCategory(currentCategory)
                    } else {
                        self.cancelEditing()
                    }
                }
                CategoriesVC.shared?.selectingIconFor = (nil,nil)
            }
    }
    
    

    
}




extension categoriesVCcell:UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.footerBackground.backgroundColor = K.Colors.secondaryBackground
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
                    }
                }

            
        } else {
            if name.contains("section") {
                let rowS = name.replacingOccurrences(of: "section", with: "")
                let dobRo = Double(rowS) ?? 0.0
                let section = Int(dobRo) 
                    CategoriesVC.shared?.editingTfIndex = (section, nil)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            self.footerBackground.backgroundColor = CategoriesVC.shared?.selectionBacground
                        } completion: { 
                            if !$0 {
                                return
                            }
                            textField.becomeFirstResponder()
                        }

                    }
            }
        }

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
