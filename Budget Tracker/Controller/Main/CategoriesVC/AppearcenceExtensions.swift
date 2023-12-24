//
//  AppearcenceMethods.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 02.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


extension CategoriesVC {
    @MainActor func tableLoaded() {
        tableDataLoaded = true
        stopEditing(keepIcons: false)
        tableView.reloadData()
    }
    @objc func iconTapped(_ sender: UITapGestureRecognizer) {
        if let dob = Double(sender.name ?? "") {
            let section = Int(dob)
            selectingIconFor.1 = section
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    @objc func pressedToDismiss(_ sender: UITapGestureRecognizer) {
        stopEditing()
    }
    
    func updateUI() {
        searchBar.placeholder = "Category search".localize
        CategoriesVC.shared = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        selectingIconFor = (nil,nil)
        title = screenType.title
        if appData.db.username != "" && screenType != .localData {
            self.tableView.refreshAction = {
                self.loadData(showError: true)
            }
        }
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if screenType != .debts {
            moreNavButton.setTitle("", for: .normal)
            if #available(iOS 13.0, *) {
                moreNavButton.setImage(.init(systemName: "ellipsis")!, for: .normal)
            } else {
                moreNavButton.setTitle("・・・", for: .normal)
            }
        }
    }
    
    
    func toggleIcons(show:Bool, animated: Bool, category: NewCategories?) {
        showingIcons = show
        if toSelectCategory && show {
            toSelectCategory = false
            IconsVC.shared?.defaultCategories = .defaultCategories
            IconsVC.shared?.screenType = .defaultCategories
        } else {
            IconsVC.shared?.screenType = .all
        }
        if show {
            self.tableView.addGestureRecognizer(viewTap)
        } else {
            self.toSelectCategory = false
            self.selectingIconFor = (nil, nil)
            if editingTF == nil {
                DispatchQueue.main.async {
                    if self.tableDataLoaded {
                        self.tableView.reloadData()
                    }
                    self.tableView.removeGestureRecognizer(self.viewTap)
                }
            }
        }
        performAnimateIcons(show: show, animated: animated, category: category)
    }
    
    private func performAnimateIcons(show:Bool, animated:Bool, category: NewCategories?) {
        let containerHeight = self.iconsContainer.layer.frame.height
        if show  {
            self.editingTfIndex = (nil,nil)
            self.stopEditing(keepIcons: true)
        } else {
            if self.editingTF == nil && IconsVC.shared?.screenType != .defaultCategories && self.selectingIconFor == (nil, nil) {
                self.tableView.contentInset.bottom = self.defaultTableInset
            }
        }
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.iconsContainer.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, show ? 0 : containerHeight + (self.properties!.appData.resultSafeArea.0 + self.properties!.appData.resultSafeArea.1 + 50), 0)
        } completion: {
            if !$0 {
                return
            }
            if self.iconsContainer.isHidden != false {
                self.iconsContainer.isHidden = false
            }
            if show {
                IconsVC.shared?.selectedIconName = category?.icon ?? ""
                IconsVC.shared?.selectedColorName = category?.color ?? ""
                
                self.kayboardAppeared(containerHeight)
                IconsVC.shared?.collectionView.reloadData()
                IconsVC.shared?.scrollToSelected()
            }
        }
    }
    
    var selectingIconFor:(IndexPath?, Int?) {
        get {
            return _selectingIconFor
        }
        set {
            _selectingIconFor = newValue
            if newValue != (nil, nil) {
                if let editIndex = newValue.0 {
                    prevSwowingIcons = editIndex
                    toggleIcons(show: true, animated: true, category: tableData[editIndex.section].data[editIndex.row].editing)
                } else {
                    if let section = newValue.1 {
                        toggleIcons(show: true, animated: true, category: tableData[section].newCategory.category)
                    }
                }
            } else {
                if showingIcons && IconsVC.shared?.screenType != .defaultCategories {
                    toggleIcons(show: false, animated: false, category: nil)
                }
            }
            
        }
    }
    func stopEditing(keepIcons:Bool = false) {
        if showingIcons && !keepIcons {
            toggleIcons(show: false, animated: true, category: nil)
        }
        
        UIApplication.shared.keyWindow?.endEditing(true)
        self.editingTF = nil
    }
    
    func toHistory(index: IndexPath) {
        historyDataStruct = tableData[index.section].data[index.row].transactions
        selectedCategory = tableData[index.section].data[index.row].category
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.performSegue(withIdentifier: "toHistory", sender: self)
        }
    }

    
    func showMoreVC() {
        stopEditing(keepIcons: false)
        let idAction = {
            self.sortOption = .id
            self.categories = self._categories
        }
        let nameAction = {
            self.sortOption = .name
            self.categories = self._categories
            
        }
        let countAction = {
            self.sortOption = .transactionsCount
            self.categories = self._categories
        }
        MoreVC.presentMoreVC(currentVC: self, data: [
            MoreVC.ScreenData(name: "Default".localize, description: "", showAI: true, selected: self.sortOption == .id, action: idAction),
            MoreVC.ScreenData(name: "Name".localize, description: "", showAI: true, selected: self.sortOption == .name, action: nameAction),
            MoreVC.ScreenData(name: "Most used".localize, description: "", showAI: true, selected: self.sortOption == .transactionsCount, action: countAction),
        ], proIndex: 3)
    }
    
    
    func iconHeaderSelected(values:[LastSelected.SettingTypeEnum:String], selectingIndex:IndexPath, img:String, color:String) {
        let cat = tableData[selectingIndex.section].data[selectingIndex.row].editing
        var valType = cat?.purpose.lastSelected ?? .expense
        
        values.forEach({
            if $0.value != "" {
                switch $0.key {
                case .icon:
                    self.tableData[selectingIndex.section].data[selectingIndex.row].editing?.icon = img
                case .color:
                    self.tableData[selectingIndex.section].data[selectingIndex.row].editing?.color = color
                default:
                    break
                }
                self.properties?.appData.db.lastSelected.sett(value: $0.value, setterType: $0.key, valueType: valType)
            }
        })
    }
    
    func iconFooterSelected(values:[LastSelected.SettingTypeEnum:String], selectingFooter:Int, img:String, color:String) {
        let cat = self.tableData[selectingFooter].newCategory.category
        var valType = cat.purpose.lastSelected
        
        values.forEach({
            if $0.value != "" {
                self.properties?.appData.db.lastSelected.sett(value: $0.value, setterType: $0.key, valueType: valType)
                switch $0.key {
                case .icon:
                    self.tableData[selectingFooter].newCategory.category.icon = img
                case .color:
                    self.tableData[selectingFooter].newCategory.category.color = color
                default:break
                }
            }
        })
    }
    
    func iconSelected(img:String, color:String) {
        let values:[LastSelected.SettingTypeEnum:String] = [
            .icon:img, .color:color
        ]
        if let selectingIndex = selectingIconFor.0 {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.iconHeaderSelected(values: values, selectingIndex: selectingIndex, img: img, color: color)
            }
        } else if let selectingFooter = selectingIconFor.1 {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.iconFooterSelected(values: values, selectingFooter: selectingFooter, img: img, color: color)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
}



extension CategoriesVC {
    @objc func keyboardWillShow(_ notification: Notification) {
        self.selectingIconFor = (nil,nil)
        self.tableView.addGestureRecognizer(viewTap)
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if keyboardHeight > 1.0 {
                kayboardAppeared(keyboardHeight)
            }
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIApplication.shared.keyWindow?.endEditing(true)
        if !showingIcons {
            selectingIconFor = (nil, nil)
            self.tableView.removeGestureRecognizer(viewTap)
        }
        if !self.showingIcons {
            self.tableView.contentInset.bottom = self.defaultTableInset
        }
        self.editingTF = nil
        self.tableView.reloadData()
    }
    
}




extension CategoriesVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTF = textField
        if showingIcons {
            toggleIcons(show: false, animated: true, category: nil)
        }
        
        DispatchQueue.main.async {
            let name = textField.layer.name ?? ""
            if let type = ["cell", "section"].first(where: {$0 == name}) {
                let rowString = name.replacingOccurrences(of: type, with: "")
                if let double = Double(rowString) {
                    let row = Int(double)
                    self.editingTfIndex = type == "cell" ? (nil, row) : (row, nil)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    @objc func textfieldValueChanged(_ textField: UITextField) {
        let section = textField.tag
        self.tableData[section].newCategory.category.name = textField.text ?? ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let section = textField.tag
        addCategoryPerform(section: section)
        return true
    }
    
}



extension CategoriesVC: UISearchBarDelegate {
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchingText = ""
        categories = allCategoriesHolder
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchingText = searchText
        categories = categoriesContains(searchText)
    }
    
}
