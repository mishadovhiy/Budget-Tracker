//
//  CategoriesMethods.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 02.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


extension CategoriesVC {
    enum ScreenType:String {
        case categories = "Categories"
        case debts = "Debts"
        case localData = "LocalData"
    }

    public func loadTableData(loadFromUD: Bool = false) {
        DispatchQueue.init(label: "dbLoad", qos: .userInteractive).async {
            if !self.fromSettings {
                self.categories = self.db.categories
                self.allCategoriesHolder = self.categories
            } else {
                if self.screenType == .categories || self.screenType == .debts {
                    AppDelegate.shared?.properties?.notificationManager.loadNotifications { unsees in
                        self.unseenIDs = unsees
                        self.loadData(loadFromUD: loadFromUD)
                    }
                } else {
                    self.loadData(loadFromUD: loadFromUD)
                }
                
            }
        }
    }
    
    func loadData(showError:Bool = false, loadFromUD: Bool = false) {

        if screenType != .localData {
            if !loadFromUD && appData.db.username != "" {
                prerformDownload(showError: showError) { loadedData in
                    self.allCategoriesHolder = loadedData
                    self.categories = self.categoriesContains(self.searchingText)
                    
                }
            } else {
                allCategoriesHolder = db.categories
                _categories = allCategoriesHolder
                categories = categoriesContains(searchingText)
            }
            
        } else {
            if let transfare = transfaringCategories {
                allCategoriesHolder = transfare.categories
                categories = categoriesContains(searchingText)
            } else {
                allCategoriesHolder = db.localCategories
                categories = categoriesContains(searchingText)
            }
        }
        
    }
    func deteteCategory(at: IndexPath, reload:Bool = false) {
        let delete = DeleteFromDB()
        delete.CategoriesNew(category: tableData[at.section].data[at.row].category) { _ in
            let id = "Debts" + "\(self.tableData[at.section].data[at.row].category.id)"
            Notifications.removeNotification(id: id, pending: true)
            self.categories = self.db.categories
            self.searchingText = ""
            DispatchQueue.main.async {
                self.searchBar.endEditing(true)
                self.searchBar.text = ""
                if reload {
                    self.loadTableData(loadFromUD: false)
                }
            }
        }
    }
    
    @objc func newCategoryPressed(_ sender: UITapGestureRecognizer) {
        if let double = Double(sender.name ?? "") {
            let section = Int(double) //{
            
                addCategoryPerform(section: section)
        }
    }
    func saveToLocal() {
        if let transfaring = transfaringCategories {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.db.localCategories = transfaring.categories
                self.db.localTransactions = transfaring.transactions
                self.transfaringCategories = nil
                self.screenType = .localData
                self.loadData()
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        
    }
    func saveNewCategory(section: Int, category: ScreenCategory) {
        LoadFromDB.shared.newCategories { loadedData, error in
            var newCategory = category
            let all = loadedData.sorted{ $0.id > $1.id }
            let newID = (all.first?.id ?? 0) + 1
            
            print("new:", newCategory.category.name)
            print("new id:", newID)
            newCategory.category.id = newID
            SaveToDB.shared.newCategories(newCategory.category) { error in
                self.editingTF = nil
                self.allCategoriesHolder = loadedData
                self.tableData[section].data.insert(newCategory, at: 0)
                self._categories.insert(newCategory.category, at: 0)
                self.tableData[section].newCategory.category.name = ""
                self.selectingIconFor = (nil,nil)
                DispatchQueue.main.async {
                    UIImpactFeedbackGenerator().impactOccurred()
                    self.tableView.reloadData()
                    self.view.endEditing(true)
                }
            }
        }
        
    }
    func addCategoryPerform(section:Int, category:ScreenCategory? = nil) {
            UIImpactFeedbackGenerator().impactOccurred()
            let category = category ?? self.tableData[section].newCategory
            if category.category.name != "" {
                self.ai?.show(title:"Saving".localize, notShowIfLoggedUser: true) { _ in
                    DispatchQueue.main.async {
                        if let editTF = self.editingTF {
                            self.editingTF = nil
                            editTF.endEditing(true)
                        }
                    }
                    
                    self.saveNewCategory(section: section, category: category)
                }
            } else {
                DispatchQueue.main.async {
                    if let editTF = self.editingTF {
                        self.editingTF = nil
                        editTF.endEditing(true)
                    }
                }
            }
    }
    
    func prerformDownload(showError:Bool, completion:@escaping([NewCategories])->()) {
        let download = {
            LoadFromDB.shared.newCategories { data, error in
                if error != .none {
                    if showError {
                        DispatchQueue.main.async {
                            self.newMessage?.show(type: .internetError)
                        }
                    }
                }
                completion(data)
            }
        }
        download()
    }
    
    
    
    
    func containsINUnseen(id:String) -> Bool {
        let all = Array(unseenIDs)
        for i in 0..<all.count {
            if all[i] == "Debts\(id)" {
                return true
            }
        }
        return false
    }
    
    func defaultCategory(icon:String, color:String, purpose:NewCategories.CategoryPurpose) -> ScreenCategory {
        return ScreenCategory(category: NewCategories(id: -1, name: "", icon: icon, color: color, purpose: purpose), transactions: [])
    }
    func purpose(_ purpose:NewCategories.CategoryPurpose) -> String {
        return purpose.rawValue
    }
    var categories:[NewCategories] {
        get {
            return _categories
        }
        set {
            _categories = newValue
            var resultDict: [String:[ScreenCategory]] = [:]
            var allTransactionsLocal:[TransactionsStruct] {
                if let transfaring = transfaringCategories  {
                    return transfaring.transactions
                } else {
                    return db.localTransactions
                }
            }
            
            for i in 0..<newValue.count {
                let purpose = newValue[i].purpose
                let strPurpose = purpose.rawValue
                var data = resultDict[strPurpose] ?? []

                var transactions:[TransactionsStruct] {
                    if self.screenType != .localData {
                        return db.transactions(for: newValue[i])
                    } else {
                        let all = Array(allTransactionsLocal)
                        var transResult:[TransactionsStruct] = []
                        for t in 0..<all.count {
                            if "\(newValue[i].id)" == all[t].categoryID {
                                transResult.append(all[t])
                            }
                        }
                        return transResult

                    }

                }

                
                
                data.append(ScreenCategory(category: newValue[i], transactions: transactions, progress: newValue[i].monthlyProgress))
                
                let newD = sort(data)
                resultDict.updateValue(newD, forKey: strPurpose)
            }

            switch self.screenType {
            case .categories:
                var randomIcon: String {
                    let ic = Icons()
                    let data = ic.icons.first?.data ?? []
                    return data[Int.random(in: 0..<data.count)]
                }
                let debtColor = appData.db.lastSelected.gett(setterType: .color, valueType: .debt) ?? appData.db.randomColorName
                let debtImg = appData.db.lastSelected.gett(setterType: .icon, valueType: .debt) ?? ""
                
                let expenseColor = appData.db.lastSelected.gett(setterType: .color, valueType: .expense) ?? appData.db.randomColorName
                let expenseImg = appData.db.lastSelected.gett(setterType: .icon, valueType: .expense) ?? ""
                
                let incomeColor = appData.db.lastSelected.gett(setterType: .color, valueType: .income) ?? appData.db.randomColorName
                let incomeImg = appData.db.lastSelected.gett(setterType: .icon, valueType: .income) ?? ""
                
                var resultData:[ScreenDataStruct] = []
               
                resultData = [
                    ScreenDataStruct(title: K.expense.localize, data: resultDict[purpose(.expense)] ?? [], newCategory: defaultCategory(icon: expenseImg, color: expenseColor, purpose: .expense)),
                    ScreenDataStruct(title: K.income.localize, data: resultDict[purpose(.income)] ?? [], newCategory: defaultCategory(icon: incomeImg, color: incomeColor, purpose: .income))
                ]
                if fromSettings {
                    self.tableData = resultData
                } else {
                    resultData.append(ScreenDataStruct(title:purpose(.debt).localize, data: resultDict[purpose(.debt)] ?? [], newCategory: defaultCategory(icon: debtImg, color: debtColor, purpose: .debt)))
                    
                    self.tableData = resultData
                }
                
            case .debts:
                var randomIcon: String {
                    let ic = Icons()
                    let data = ic.icons.first?.data ?? []
                    return data[Int.random(in: 0..<data.count)]
                }
                let debtColor = appData.db.lastSelected.gett(setterType: .color, valueType: .debt) ?? appData.db.linkColor
                let debtImg = appData.db.lastSelected.gett(setterType: .icon, valueType: .debt) ?? ""
                self.tableData = [
                    ScreenDataStruct(title: "", data: resultDict[purpose(.debt)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: debtImg, color: debtColor, purpose: .debt), transactions: [])),
                ]
            case .localData:
                var allTransactions: [TransactionsStruct] {
                    if let transfaring = transfaringCategories  {
                        return transfaring.transactions
                    } else {
                        return db.localTransactions
                    }
                }
                self.tableData = [
                    ScreenDataStruct(title: "", data: [ScreenCategory(category: NewCategories(id: -1, name: "All transaction".localize, icon: "", color: "", purpose: .expense), transactions: allTransactions)], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .expense), transactions: [])),
                    ScreenDataStruct(title: K.expense.localize, data: resultDict[purpose(.expense)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .expense), transactions: [])),
                    ScreenDataStruct(title: K.income.localize, data: resultDict[purpose(.income)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .income), transactions: [])),
                    ScreenDataStruct(title: purpose(.debt).localize, data: resultDict[purpose(.debt)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .debt), transactions: []))
                ]
            }
            DispatchQueue.main.async {
                self.selectingIconFor = (nil,nil)
                self.editingTF?.endEditing(true)
                self.editingTF = nil
                self.tableView.reloadData()

            }
            
        }
    }
    
    func categoriesContains(_ searchText: String, fromHolder: Bool = true) -> [NewCategories] {
        if searchText == "" {
            return fromHolder ? allCategoriesHolder : _categories
        } else {
            print(fromHolder, " tyrhtgerfegt")
            let data = fromHolder ? allCategoriesHolder : _categories
            return data.filter({
                return $0.name.uppercased().contains(searchText.uppercased())
            })
        }
    }
    
    
    
    struct ScreenDataStruct {
        let title: String?
        var data: [ScreenCategory]
        var newCategory: ScreenCategory
    }
    
    
    struct ScreenCategory {
        var category:NewCategories
        var transactions: [TransactionsStruct]
        var proLocked: Bool = false
        var showDisclosure:Bool = true
        var editing:NewCategories? = nil
        var progress:CGFloat?//gerfwda
    }
}




extension CategoriesVC {
    //sort
    func sort(_ data: [ScreenCategory]) -> [ScreenCategory] {
        switch sortOption {
        case .id:
            return data.sorted{ $0.category.id > $1.category.id }
        case .name:
            return data.sorted{ $0.category.name > $1.category.name }
        case .transactionsCount:
            let nameSort = data.sorted{ $0.category.name > $1.category.name }
            return nameSort.sorted{ $0.transactions.count > $1.transactions.count }
        }
    }
    

    var sortOption: SortOption {
        get {
            let ud = db.viewControllers.sortOption
            return .init(rawValue: ud[screenType.rawValue] ?? "") ?? .id
            
        }
        set {
          //  var newString = newValue.rawValue
  /*          var ud = db.viewControllers.sortOption
            ud.updateValue(newString, forKey: screenType.rawValue)*/
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.db.viewControllers.sortOption.updateValue(newValue.rawValue, forKey: self.screenType.rawValue)
            }
        }
    }
    
    enum SortOption:String {
        case id = "id"
        case name = "name"
        case transactionsCount = "transactionsCount"
        
        init?(rawValue: String) {
            switch rawValue {
            case "id":
                self = .id
            case "name":
                self = .name
            case "transactionsCount":
                self = .transactionsCount
            default :
                self = .id
            }
        }
    }
    
    
    
    
}




