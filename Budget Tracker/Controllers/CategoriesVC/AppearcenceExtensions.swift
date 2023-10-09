//
//  AppearcenceMethods.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 02.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


extension CategoriesVC {
    
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
        hideAll()
    }
    @objc func refresh(sender:AnyObject) {
        DispatchQueue.init(label: "dbLoad", qos: .userInteractive).async {
            self.loadData(showError: true)
        }
    }
    func updateUI() {
        if appData.username != "" && screenType != .localData {
            addRefreshControll()
        }
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addRefreshControll() {
        DispatchQueue.main.async {
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            self.tableView.addSubview(self.refreshControl)
        }
    }
    
    
    func toggleIcons(show:Bool, animated: Bool, category: NewCategories?) {
        showingIcons = show
        if show {
            self.tableView.addGestureRecognizer(viewTap)
        } else {
            self.selectingIconFor = (nil, nil)
            if editingTF == nil {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.removeGestureRecognizer(self.viewTap)
                }
            }
        }
        DispatchQueue.main.async {
            let containerHeight = self.iconsContainer.layer.frame.height
            if show  {
                self.editingTfIndex = (nil,nil)
             //   DispatchQueue.main.async {
                    if let editTF = self.editingTF {
                        self.editingTF = nil
                        editTF.endEditing(true)
                    }
            //    }
            } else {
                if self.editingTF == nil {
                    self.tableView.contentInset.bottom = 0// self.defaultButtonInset
                }
            }//here
            UIView.animate(withDuration: animated ? 0.3 : 0) {
                self.iconsContainer.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, show ? 0 : containerHeight + (self.appData.resultSafeArea.0 + self.appData.resultSafeArea.1 + 50), 0)
            } completion: { _ in
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
                if showingIcons {
                    toggleIcons(show: false, animated: false, category: nil)
                }
            }
            
        }
    }
    func hideAll() {
        if showingIcons {
            toggleIcons(show: false, animated: true, category: nil)
        }
        
             if searchBar.isFirstResponder {
                 DispatchQueue.main.async {
                     self.searchBar.endEditing(true)
                 }
                 
             }
            if let editing = self.editingTF {
                self.editingTF = nil
                DispatchQueue.main.async {
                    editing.endEditing(true)
                    
                }
            }

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
        DispatchQueue.main.async {
            if self.searchBar.isFirstResponder {
                self.searchBar.endEditing(true)
            }
            
            if let editing = self.editingTF {
                self.editingTF = nil
                editing.endEditing(true)
            }
        }
        selectingIconFor = (nil,nil)
        let appData = AppData()
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
        let moreData = [
            MoreVC.ScreenData(name: "Default".localize, description: "", showAI: true, selected: self.sortOption == .id, action: idAction),
            MoreVC.ScreenData(name: "Name".localize, description: "", showAI: true, selected: self.sortOption == .name, action: nameAction),
            MoreVC.ScreenData(name: "Most used".localize, description: "", showAI: true, selected: self.sortOption == .transactionsCount, action: countAction),
        ]
        appData.presentMoreVC(currentVC: self, data: moreData, proIndex: 3)
    }
    
    
    func iconSelected(img:String, color:String) {
        if let selectingIndex = selectingIconFor.0 {
            let cat = tableData[selectingIndex.section].data[selectingIndex.row].editing
            var valType: LastSelected.SelectedTypeEnum {
                switch cat?.purpose {
                case .expense:
                    return .expense
                case .income:
                    return .income
                case .debt:
                    return .debt
                default:
                    return .expense
                }
            }

            
            if img != "" {
                tableData[selectingIndex.section].data[selectingIndex.row].editing?.icon = img
            }
            if color != "" {
                tableData[selectingIndex.section].data[selectingIndex.row].editing?.color = color
            }
            
        } else {
            
            if let selectingFooter = selectingIconFor.1 {
                let cat = tableData[selectingFooter].newCategory.category
                var valType: LastSelected.SelectedTypeEnum {
                    switch cat.purpose {
                    case .expense:
                        return .expense
                    case .income:
                        return .income
                    case .debt:
                        return .debt
                    }
                }

                DispatchQueue(label: "db", qos: .userInitiated).async {
                    if img != "" {
                        self.appData.lastSelected.sett(value: img, setterType: .icon, valueType: valType)
                        self.tableData[selectingFooter].newCategory.category.icon = img
                    }
                    if color != "" {
                        self.appData.lastSelected.sett(value: color, setterType: .color, valueType: valType)
                        self.tableData[selectingFooter].newCategory.category.color = color
                    }
                }
                
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
}



extension CategoriesVC {//keyboard
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
    
    func kayboardAppeared(_ keyboardHeight:CGFloat) {
        DispatchQueue.main.async {
            let height:CGFloat = keyboardHeight - self.appData.resultSafeArea.1 - self.defaultButtonInset
            let cellEditing = (self.editingTF?.layer.name?.contains("cell") ?? false) || self.selectingIconFor.0 != nil
            self.tableView.contentInset.bottom = height + (cellEditing ? (self.regFooterHeight * (-1)) : 0)

        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        editingTfIndex = (nil,nil)
        if !showingIcons {
            selectingIconFor = (nil, nil)
            self.tableView.removeGestureRecognizer(viewTap)
        }
          
        DispatchQueue.main.async {
            if !self.showingIcons {
                self.tableView.contentInset.bottom = self.defaultTableInset
            }
            self.editingTF = nil
            self.tableView.reloadData()
            
        }
    }
    
}




extension CategoriesVC {//textField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTF = textField
        if showingIcons {
            toggleIcons(show: false, animated: true, category: nil)
        }
        
        DispatchQueue.main.async {
            let name = textField.layer.name ?? ""
            
            if name.contains("cell") {
                let rowS = name.replacingOccurrences(of: "cell", with: "")
                if let dob = Double(rowS) {
                    let row = Int(dob)// {
                        self.editingTfIndex = (nil, row)
                    //  }
                }
            } else {
                if name.contains("section") {
                    let rowS = name.replacingOccurrences(of: "section", with: "")
                    if let dob = Double(rowS) {
                        let section = Int(dob)// {
                        print(section)
                        self.editingTfIndex = (section, nil)
                    }

                    
                }
            }

            
            self.tableView.reloadData()
        }
    }
    
    @objc func textfieldValueChanged(_ textField: UITextField) {
        DispatchQueue.main.async {
            let section = textField.tag
            self.tableData[section].newCategory.category.name = textField.text ?? ""
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let section = textField.tag
        addCategoryPerform(section: section)
        return true
    }
}



extension CategoriesVC: UISearchBarDelegate {
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        
        DispatchQueue.main.async {
            searchBar.endEditing(true)
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchingText = ""
            categories = allCategoriesHolder
            DispatchQueue.main.async {
                searchBar.endEditing(true)
                self.tableView.reloadData()
            }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchingText = searchText
        categories = categoriesContains(searchText)
    }

}
