//
//  CategoriesVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation
/***
 loadData
 iconTapped
 newCategoryPressed
 */
var _categoriesHolder: [CategoriesStruct] = []

protocol CategoriesVCProtocol {
    func categorySelected(category: NewCategories?, fromDebts: Bool, amount: Int)
}

class CategoriesVC: SuperViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var catData = appData.categoryVC
        //  var refreshControl = UIRefreshControl()
    var hideTitle = false
    var fromSettings = false
    var delegate: CategoriesVCProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Category search".localize
        CategoriesVC.shared = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        DispatchQueue.init(label: "dbLoad", qos: .userInteractive).async {
            if !self.fromSettings {
           //     if self.screenType != .localData {
                self.categories = self.db.categories
           //     }
            } else {
                self.loadData()
            }
            
            
        }
        selectingIconFor = (nil,nil)
        //t//oggleIcons(show: false, animated: false, category: nil)
        
        var strTitle:String {
            switch screenType {
            case .localData:
                return "Local data".localize
            case .categories:
                return "Categories".localize
            case .debts:
                return "Debts".localize
            }
        }
        title = strTitle
        
        updateUI()
     //   if !fromSettings {
            
      //  }
        
        
    }
    
    
    
    let selectionBacground = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
    static var shared:CategoriesVC?
    var _tableData:[ScreenDataStruct] = []
    var tableData:[ScreenDataStruct] {
        get {
            return _tableData
        }
        set {
            _tableData = newValue
            DispatchQueue.main.async {
                self.ai.fastHide { _ in
                    
                }
              //  self.tableView.reloadData()
            //    if self.refreshControl.isRefreshing {
            //        self.refreshControl.endRefreshing()
            //    }
                if self.tableView.alpha != 1 {
                //    self.tableView.transform =
                //    self.tableView.alpha = 1
                    if self.screenAI.isAnimating {
                        self.screenAI.stopAnimating()
                    }
                    if self.screenAI.isHidden != true {
                        self.screenAI.isHidden = true
                    }
                    self.moreButton.isEnabled = true
                    UIView.animate(withDuration: 0.2) {
                        self.tableView.alpha = 1
                       // self.tableView.transform =// to notmal
                    } /*completion: { _ in
                        
                    }*/

                }
                
            }
        }
    }
    

    
    lazy var viewTap:UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(pressedToDismiss(_:)))
    }()
    
    enum ScreenType {
        
        case categories
        case debts
        case localData
    }
    
    var screenType: ScreenType = .categories
    
    func screenTypeToString(_ type:ScreenType) -> String {
        switch type {
        case .categories:
            return "Categories"
        case .debts:
            return "Debts"
        case .localData:
            return "LocalData"
        }
    }
    
    func defaultCategory(icon:String, color:String, purpose:CategoryPurpose) -> ScreenCategory {
        
        return ScreenCategory(category: NewCategories(id: -1, name: "", icon: icon, color: color, purpose: .expense), transactions: [])
    }
    
    var _categories:[NewCategories] = []
    var categories:[NewCategories] {
        get {
            return _categories
        }
        set {
            _categories = newValue
            var resultDict: [String:[ScreenCategory]] = [:]
            //load transactions (depending on what screen type)
            print("newValue::", newValue.count)

            var allTransactionsLocal:[TransactionsStruct] {
                if let transfaring = transfaringCategories  {
                    return transfaring.transactions
                } else {
                    return db.localTransactions
                }
            }
            
            for i in 0..<newValue.count {
                let purpose = newValue[i].purpose
                let strPurpose = purposeToString(purpose)
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

                data.append(ScreenCategory(category: newValue[i], transactions: transactions))
                
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
                let debtColor = appData.lastSelected.gett(setterType: .color, valueType: .debt) ?? appData.randomColorName
                let debtImg = appData.lastSelected.gett(setterType: .icon, valueType: .debt) ?? ""
                
                let expenseColor = appData.lastSelected.gett(setterType: .color, valueType: .expense) ?? appData.randomColorName
                let expenseImg = appData.lastSelected.gett(setterType: .icon, valueType: .expense) ?? ""
                
                let incomeColor = appData.lastSelected.gett(setterType: .color, valueType: .income) ?? appData.randomColorName
                let incomeImg = appData.lastSelected.gett(setterType: .icon, valueType: .income) ?? ""
                
                var resultData:[ScreenDataStruct] = []
                resultData = [
                    ScreenDataStruct(title: K.expense.localize, data: resultDict[purposeToString(.expense)] ?? [], newCategory: defaultCategory(icon: expenseImg, color: expenseColor, purpose: .expense)),
                    ScreenDataStruct(title: K.income.localize, data: resultDict[purposeToString(.income)] ?? [], newCategory: defaultCategory(icon: incomeImg, color: incomeColor, purpose: .income))
                ]
                if fromSettings {
                    self.tableData = resultData
                } else {
                    resultData.append(ScreenDataStruct(title:purposeToString(.debt).localize, data: resultDict[purposeToString(.debt)] ?? [], newCategory: defaultCategory(icon: debtImg, color: debtColor, purpose: .debt)))
                    
                    self.tableData = resultData
                }
                
            case .debts:
                var randomIcon: String {
                    let ic = Icons()
                    let data = ic.icons.first?.data ?? []
                    return data[Int.random(in: 0..<data.count)]
                }
                let debtColor = appData.lastSelected.gett(setterType: .color, valueType: .debt) ?? AppData.linkColor
                let debtImg = appData.lastSelected.gett(setterType: .icon, valueType: .debt) ?? ""
                self.tableData = [
                    ScreenDataStruct(title: "", data: resultDict[purposeToString(.debt)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: debtImg, color: debtColor, purpose: .debt), transactions: [])),
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
                    ScreenDataStruct(title: K.expense.localize, data: resultDict[purposeToString(.expense)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .expense), transactions: [])),
                    ScreenDataStruct(title: K.income.localize, data: resultDict[purposeToString(.income)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .income), transactions: [])),
                    ScreenDataStruct(title: purposeToString(.debt).localize, data: resultDict[purposeToString(.debt)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .debt), transactions: []))
                ]
            }
            DispatchQueue.main.async {
                self.selectingIconFor = (nil,nil)
            //    self.t/oggleIcons(show: false, animated: true, category: nil)
                self.editingTF?.endEditing(true)
                self.editingTF = nil
                self.tableView.reloadData()
            }
            
        }
    }

    
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
    
    //screen type to string
    var sortOption: SortOption {
        get {
            let ud = UserDefaults.standard.value(forKey: "SortOption") as? [String:String] ?? [:]
            switch ud[screenTypeToString(screenType)] {
            case "id":
                return .id
            case "name":
                return .name
            case "transactionsCount":
                return .transactionsCount
            default :
                return .id
            }
            
        }
        set {
            var newString: String {
                switch newValue {
                case .id:
                    return "id"
                case .name:
                    return "name"
                case .transactionsCount:
                    return "transactionsCount"
                }
            }
            var ud = UserDefaults.standard.value(forKey: "SortOption") as? [String:String] ?? [:]
            ud.updateValue(newString, forKey: screenTypeToString(screenType))
            UserDefaults.standard.setValue(ud, forKey: "SortOption")
        }
    }
    
    enum SortOption {
        case id
        case name
        case transactionsCount
    }
    
    
    
    func categoriesContains(_ searchText: String, fromHolder: Bool = true) -> [NewCategories] {
        if searchText == "" {
          //  if let data = allData {
                return fromHolder ? allCategoriesHolder : _categories
           // }
            
        } else {
            
        //    if let data = allData {
            let data = fromHolder ? allCategoriesHolder : _categories
                var resultt:[NewCategories] = []
                for i in 0..<data.count {
                    let name = data[i].name.uppercased()
                    print(name, "name")
                    let text = searchText.uppercased()
                    if name.contains(text) {
                        resultt.append(data[i])
                    }
                }
                return resultt
            //  }
        }
    }
    
   

    var searchingText = ""
    var allCategoriesHolder: [NewCategories] = []
    var transfaringCategories: LoginViewController.TransferingData?
    func loadData(showError:Bool = false, loadFromUD: Bool = false) {

        if screenType != .localData {
            if !loadFromUD {
               // let load = LoadFromDB()
                LoadFromDB.shared.newCategories { loadedData, error in
                    self.allCategoriesHolder = loadedData
                    self.categories = self.categoriesContains(self.searchingText)
                    if error != .none {
                        if showError {
                            DispatchQueue.main.async {
                                self.newMessage.show(type: .internetError)
                            }
                        }
                    }
                }
            } else {
                allCategoriesHolder = db.categories
                categories = categoriesContains(searchingText)
            }
            
        } else {
            if let transfare = transfaringCategories {
              //  self.categories = transfare.categories
                allCategoriesHolder = transfare.categories
                categories = categoriesContains(searchingText)
            } else {
                //ud
                allCategoriesHolder = db.localCategories
                categories = categoriesContains(searchingText)
             //   self.categories = db.localCategories
            }
        }
        
    }
    
    
    
    
    
    let db = DataBase()
    func saveNewCategory(section: Int, category: ScreenCategory) {
        
       // let load = LoadFromDB()
        LoadFromDB.shared.newCategories { loadedData, error in
            var newCategory = category
           // let save = SaveToDB()
            let all = loadedData.sorted{ $0.id > $1.id }
            let newID = (all.first?.id ?? 0) + 1
            
            print("new:", newCategory.category.name)
            print("new id:", newID)
            newCategory.category.id = newID
            SaveToDB.shared.newCategories(newCategory.category) { error in
                self.editingTF = nil

                self.tableData[section].data.insert(newCategory, at: 0)
                self._categories.insert(newCategory.category, at: 0)
                self.tableData[section].newCategory.category.name = ""
              //  self.tableData[section].data.append(newCategory)
                self.selectingIconFor = (nil,nil)
           /*     if CategoriesVC.shared?.showingIcons ?? false {
                    CategoriesVC.shared?.to/ggleIcons(show: false, animated: true, category: nil)
                }*/
                DispatchQueue.main.async {
                    UIImpactFeedbackGenerator().impactOccurred()
          //          self.ai.fastHide { _ in
                        
          //          }
                    
                    
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func addCategoryPerform(section:Int) {
       // DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
            let category = self.tableData[section].newCategory
            if category.category.name != "" {
                self.ai.show(title:"Saving".localize) { _ in
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
            
      //  }
    }
    
    @objc func newCategoryPressed(_ sender: UITapGestureRecognizer) {
        if let double = Double(sender.name ?? "") {
            let section = Int(double) //{
                
                addCategoryPerform(section: section)
        }
        
            
        //}
    }
    
    //editingTfIndex.0 - row
    //editingTfIndex.1 - section
    var editingTfIndex: (Int?,Int?) = (nil,nil)
    
    var endAll = false
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    @objc func pressedToDismiss(_ sender: UITapGestureRecognizer) {
        hideAll()
        
    }
    
    var defaultButtonInset: CGFloat = 0
    var tableContentOf:UIEdgeInsets = UIEdgeInsets.zero
    @objc func keyboardWillHide(_ notification: Notification) {
        editingTfIndex = (nil,nil)
        if !showingIcons {
            selectingIconFor = (nil, nil)
            self.tableView.removeGestureRecognizer(viewTap)
        }
          
        DispatchQueue.main.async {
            if !self.showingIcons {
                self.tableView.contentInset.bottom = 0//self.defaultButtonInset
            }
            self.editingTF = nil
            self.tableView.reloadData()
            
        }
    }
    
    var keyHeight: CGFloat = 0.0
    @objc func keyboardWillShow(_ notification: Notification) {
        self.selectingIconFor = (nil,nil)
        //t//oggleIcons(show: false, animated: true, category: nil)
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
            let height:CGFloat = keyboardHeight - appData.safeArea.1 - self.defaultButtonInset
            let cellEditing = (self.editingTF?.layer.name?.contains("cell") ?? false) || self.selectingIconFor.0 != nil
            self.tableView.contentInset.bottom = height + (cellEditing ? (self.regFooterHeight * (-1)) : 0)

        }
    }
    

    var showingIcons = true
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
                self.iconsContainer.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, show ? 0 : containerHeight + (appData.safeArea.0 + appData.safeArea.1 + 50), 0)
            } completion: { _ in
                if show {
                    IconsVC.shared?.selectedIconName = category?.icon ?? ""
                    IconsVC.shared?.selectedColorName = category?.color ?? ""
                    
                    self.kayboardAppeared(containerHeight)
                    
                  //  DispatchQueue.main.async {
                        IconsVC.shared?.collectionView.reloadData()
                        IconsVC.shared?.scrollToSelected()
               //     }
                    
                }
            }

        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        toHistory = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {

        if fromSettings {
        }
    }

    var appeareDidCall = false
    var unseenIDs:[String] = []
    func containsINUnseen(id:String) -> Bool {
        let all = Array(unseenIDs)
        for i in 0..<all.count {
            if all[i] == "Debts\(id)" {
                return true
            }
        }
        return false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchBar.endEditing(true)
       // DispatchQueue.main.async {
            if let editTF = self.editingTF {
                self.editingTF = nil
                editTF.endEditing(true)
            }
    //    }
        if !self.fromSettings {
            loadData()
        }
        if appeareDidCall {
            if screenType == .categories || screenType == .debts {
                DispatchQueue.init(label: "udLoad", qos: .userInteractive).async {
                    self.loadNotifications { _ in
                       // self.categories = self.categoriesContains(self.searchingText, fromHolder: false)
                        self.loadData(loadFromUD: true)
                    }
                }
            } else {
                DispatchQueue.init(label: "udLoad", qos: .userInteractive).async {
                    self.categories = self.categoriesContains(self.searchingText, fromHolder: false)
                }
            }
        } else {
            appeareDidCall = true
            if screenType == .categories || screenType == .debts {
                DispatchQueue.init(label: "udLoad", qos: .userInteractive).async {
                    self.loadNotifications { _ in
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
        }
        
        if transactionAdded {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        self.tableView.contentInset.bottom = 0
        
    }
    
    func loadNotifications(completion: @escaping (Bool) -> ()) {
        AppDelegate.shared.center.getDeliveredNotifications(completionHandler: { nitof in
            var newIDs:[String] = []
            for i in 0..<nitof.count {
                let requestID = nitof[i].request.identifier
                newIDs.append(requestID)
            }
            newIDs += appData.deliveredNotificationIDs
            self.unseenIDs = newIDs
            completion(true)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !toHistory {

        }

        if !toHistory {
            if fromSettings {
                if !wasEdited {
                    delegate?.categorySelected(category: nil, fromDebts: false, amount: 0)
                } else {
                    delegate?.categorySelected(category: nil, fromDebts: false, amount: 0)
                }
            }
        }
    }
    
    var wasEdited = false
    func updateUI() {
    
        
        
        
        if appData.username != "" && screenType != .localData {
            addRefreshControll()
        }
        
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    
    @objc private func textfieldValueChanged(_ textField: UITextField) {//here
        DispatchQueue.main.async {
            let section = textField.tag// {
               // let section = Int(double)
                    print(textField.text ?? "", "tftftftfttftftftfttftftftft tf")
                    print(self.tableData[section].newCategory.category.name, "tftftftfttftftftfttftftftft name")
                    self.tableData[section].newCategory.category.name = textField.text ?? ""
          //  }
            
            //    self.tableView.reloadData()
            
            
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let section = textField.tag
        addCategoryPerform(section: section)
        return true
    }
    
    func addRefreshControll() {
     //   DispatchQueue.main.async {
        //    self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        //    self.tableView.addSubview(self.refreshControl)
        //}
    }


    @IBOutlet weak var screenAI: UIActivityIndicatorView!
    
    @objc func refresh(sender:AnyObject) {
        DispatchQueue.init(label: "dbLoad", qos: .userInteractive).async {
            self.loadData(showError: true)
        }
        
    }
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func morePressed(_ sender: UIButton) {
        showMoreVC()
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
       // t/oggleIcons(show: false, animated: true, category: nil)
        
        let appData = AppData()
        //get screen data
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
     //   let proResult = appData.proVersion || appData.proTrial
        print(appData.proTrial, "appData.proTrialappData.proTrialappData.proTrialappData.proTrial")
        let moreData = [
            MoreVC.ScreenData(name: "Default".localize, description: "", showAI: true, selected: self.sortOption == .id, action: idAction),
            MoreVC.ScreenData(name: "Name".localize, description: "", showAI: true, selected: self.sortOption == .name, action: nameAction),
            MoreVC.ScreenData(name: "Most used".localize, description: "", showAI: true, selected: self.sortOption == .transactionsCount, pro: appData.proVersion || appData.proTrial, action: countAction),
        ]
        appData.presentMoreVC(currentVC: self, data: moreData, proIndex: 2)
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    

    func deteteCategory(at: IndexPath) {
        let delete = DeleteFromDB()
        delete.CategoriesNew(category: tableData[at.section].data[at.row].category) { _ in
            self.categories = self.db.categories
            self.searchingText = ""
            DispatchQueue.main.async {
                self.searchBar.endEditing(true)
                self.searchBar.text = ""
            }
        }
    }

    

    
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategory: NewCategories?
    func toHistory(index: IndexPath) {
       // let localData = transfaringCategories?.transactions ?? []//or ud local
        historyDataStruct = tableData[index.section].data[index.row].transactions //screenType != .localData ? db.transactions(for: category) : localData
        
        selectedCategory = tableData[index.section].data[index.row].category
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.performSegue(withIdentifier: "toHistory", sender: self)
        }
        
    }

    var _selectingIconFor:(IndexPath?, Int?)
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
    
    var prevSwowingIcons:IndexPath?
    
    var toHistory = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "toHistory":
            toHistory = true
            let vc = segue.destination as! HistoryVC
            vc.historyDataStruct = historyDataStruct
            vc.selectedCategory = selectedCategory
            vc.fromCategories = true
            vc.allowEditing = screenType != .localData ? (selectedCategory?.purpose == .debt ? true : false) : (transfaringCategories == nil ? true : false)
            vc.mainType = screenType != .localData ? .db : transfaringCategories == nil ? .localData : .unsaved

        case "selectIcon":
            let vc = segue.destination as! IconsVC
            vc.delegate = self

        default:
            break
        }
    }


    let footerHeight:CGFloat = 40

    

    @objc func iconTapped(_ sender: UITapGestureRecognizer) {
        if let dob = Double(sender.name ?? "") {
            let section = Int(dob)// {
                selectingIconFor.1 = section
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
          //  }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -60.0 {
            hideAll()
            
        }
        
    }
    
    @IBOutlet weak var iconsContainer: UIView!
    
    let tableCorners:CGFloat = 15
    
    var screenDescription: String = ""
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count + 2 //fromSettings ? 2 : 3//darkAppearence ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return screenDescription == "" ? 0 : 1
        } else {
            if section == 1 {
                return screenType == .localData ? 1 : 0
            } else {
                return tableData[section - sectionsBeforeData].data.count == 0 ? 1 : tableData[section - 2].data.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 || section == 1 {
            return nil
        } else {
            return tableData[section - sectionsBeforeData].title
        }
        
    }
    
    func saveToLocal() {
        if let transfaring = transfaringCategories {
            db.localCategories = transfaring.categories
            db.localTransactions = transfaring.transactions
            transfaringCategories = nil
            screenType = .localData
            loadData()
            
        //    DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
          //  }
        }
        
    }
    let sectionsBeforeData = 2
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return UITableViewCell()//page descriptiion
        } else {
            if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LocalDataActionCell", for: indexPath) as! LocalDataActionCell
                
                cell.load()
                let hideDownload = transfaringCategories == nil ? true : false
                
                if cell.sendPressed.isHidden != !hideDownload {
                    cell.sendPressed.isHidden = !hideDownload
                }
                if cell.deletePressed.isHidden != !hideDownload {
                    cell.deletePressed.isHidden = !hideDownload
                }
                
                if cell.saveLocallyView.isHidden != hideDownload {
                    cell.saveLocallyView.isHidden = hideDownload
                }

                let deleteAction = {
                    needDownloadOnMainAppeare = true
                    self.db.localCategories = []
                    self.db.localTransactions = []
                //    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                  //  }
                }
                let sendAll = {
                    needDownloadOnMainAppeare = true
                    sendSavedData = true
                //    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                  //  }
                }
                
                
                cell.saveAction = saveToLocal
                cell.deleteAction = deleteAction
                cell.sendAction = sendAll
                return cell
            } else {
                
                if tableData[indexPath.section - sectionsBeforeData].data.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoCategoriesCell", for: indexPath) as! NoCategoriesCell
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
                    
                    let index = IndexPath(row: indexPath.row, section: indexPath.section - sectionsBeforeData)
                    cell.lo(index: index, footer: nil)

                    let category = tableData[index.section].data[indexPath.row]

                    let hideUnseenIndicator = containsINUnseen(id: "\(category.category.id)") ? false : true
                    cell.unseenIndicatorView.isHidden = hideUnseenIndicator

                    let hideEditing = category.editing != nil ? false : true
                    let hideQnt = !hideEditing
                    let hideTitle = !hideEditing
                    let hidedueDate = category.category.dueDate == nil
                    
                    if cell.editingStack.isHidden != hideEditing {
                        cell.editingStack.isHidden = hideEditing
                    }
                    if cell.qntLabel.superview?.isHidden ?? false != hideQnt {
                        cell.qntLabel.superview?.isHidden = hideQnt
                    }
                    if cell.categoryNameLabel.isHidden != hideTitle {
                        cell.categoryNameLabel.isHidden = hideTitle
                    }
                    if cell.dueDateStack.isHidden != hidedueDate {
                        cell.dueDateStack.isHidden = hidedueDate
                    }
                    print(selectingIconFor.0)
                    let isEditing = (editingTF == cell.newCategoryTF) || (selectingIconFor.0 == index)
                    cell.footerBackground.backgroundColor = isEditing ? selectionBacground : K.Colors.secondaryBackground

                    cell.newCategoryTF.layer.name = "cell\(index.row)"
                    let dueDate = category.category.dueDate
                   let stringDate = "\(self.makeTwo(n: dueDate?.day ?? 0)).\(self.makeTwo(n: dueDate?.month ?? 0)).\(dueDate?.year ?? 0)"
                    cell.dueDateLabel.text = stringDate
                    let expired = dateExpired(dueDate)
                    cell.dueDateIcon.tintColor = expired ? K.Colors.negative : K.Colors.category
                    cell.dueDateLabel.textColor = expired ? K.Colors.negative : K.Colors.balanceT
                    
                    cell.qntLabel.text = "\(category.transactions.count)"
                    if #available(iOS 13.0, *) {
                        cell.iconimage.image = category.editing == nil ? AppData.iconNamed(category.category.icon) : AppData.iconNamed(category.editing?.icon)
                        cell.iconimage.tintColor = category.editing == nil ? AppData.colorNamed(category.category.color) : AppData.colorNamed(category.editing?.color)
                    }
                    
                    
                    cell.categoryNameLabel.text = category.category.name
                  //  cell.newCategoryTF.backgroundColor = cell.newCategoryTF == editingTF ? K.Colors.primaryBacground : .clear
                    cell.newCategoryTF.text = category.editing?.name ?? category.category.name
                    
                    return cell
                }

            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            return nil
        } else {
        let mainFrame = tableView.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: footerHeight))
        let helperView = UIView(frame: CGRect(x: 10, y: 10, width:mainFrame.width - 20, height: footerHeight - 10))
        helperView.layer.cornerRadius = tableCorners
        helperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        helperView.backgroundColor = K.Colors.secondaryBackground//darkAppearence ? .black : .white
        view.backgroundColor = self.view.backgroundColor
        let label = UILabel(frame: CGRect(x: tableCorners + 10, y: 15, width: mainFrame.width - 40, height: 20))
        label.text = tableData[section - sectionsBeforeData].title
        label.textColor = K.Colors.balanceV
        label.font = .systemFont(ofSize: 14, weight: .medium)
        view.addSubview(helperView)
        view.addSubview(label)

        label.text = tableData[section - sectionsBeforeData].title ?? ""
        return view
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    let regFooterHeight:CGFloat = 50
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0
        } else {
            return screenType != .localData ? regFooterHeight : (tableCorners + 5)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0
        } else {
            return footerHeight
        }
        
    }
    
    var editingTF: UITextField?
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            return nil
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent) as! categoriesVCcell
        /*let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
*/
            let sect = section - sectionsBeforeData
        //show only footer
        let category = tableData[sect].newCategory.category
            cell.footerHelperBottomView.isHidden = false
        cell.lo(index: nil, footer: sect)
        cell.newCategoryTF.text = category.name
            if #available(iOS 13.0, *) {
                cell.iconimage.image = AppData.iconNamed(category.icon)
                cell.iconimage.tintColor = AppData.colorNamed(category.color)
            } else {
                cell.iconimage.isHidden = true
            }
        
            
        cell.editingStack.isHidden = false
        cell.dueDateStack.isHidden = true
        if cell.qntLabel.superview?.isHidden ?? false != true {
            cell.qntLabel.superview?.isHidden = true
        }
            if cell.unseenIndicatorView.isHidden != true {
                cell.unseenIndicatorView.isHidden = true
            }
        cell.cancelButton.isHidden = true
        
       /* print(category.name, "namenamenamenamenamename")
        let hideSave = category.name == "" ? true : false
        if cell.saveButton.isHidden != hideSave {
            cell.saveButton.isHidden = hideSave
        }*/
            cell.buttonsSeparetor.alpha = 0
        cell.categoryNameLabel.isHidden = true
        if screenType != .localData {
            let savePressed = UITapGestureRecognizer(target: self, action: #selector(newCategoryPressed(_:)))
            savePressed.name = "\(sect)"
//commented            cell.saveButton.addGestureRecognizer(savePressed)
            
            let iconPressed = UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:)))
            iconPressed.name = "\(sect)"
            cell.iconimage.addGestureRecognizer(iconPressed)
            cell.newCategoryTF.backgroundColor = cell.newCategoryTF == editingTF ? K.Colors.primaryBacground : .clear
            cell.newCategoryTF.delegate = self
            cell.newCategoryTF.tag = sect
            cell.newCategoryTF.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
        } else {
            cell.iconimage.isHidden = true
            cell.editingStack.isHidden = true
            cell.saveButton.superview?.isHidden = true
        }
        

            cell.newCategoryTF.layer.name = "section\(section - sectionsBeforeData)"
        let view = cell.contentView
        view.isUserInteractionEnabled = true
        //view.layer.cornerRadius = 6
       // view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            let editingtfection = editingTfIndex.0 ?? -1
            print(editingtfection, "editingtfectioneditingtfectioneditingtfectioneditingtfection")
            let isSelected = editingtfection == sect || selectingIconFor.1 == sect
            print(isSelected, "isSelectedisSelectedisSelectedisSelected")
            view.backgroundColor = K.Colors.primaryBacground
        cell.footerBackground.backgroundColor = isSelected ? selectionBacground : K.Colors.secondaryBackground
        cell.footerBackground.layer.cornerRadius = tableCorners
        cell.footerBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localize) {  (contextualAction, view, boolValue) in
            //self.tableActionActivityIndicator.startAnimating()
          //  DispatchQueue.main.async {
            self.ai.show(title: "Deleting".localize) { _ in
                    self.deteteCategory(at: IndexPath(row: indexPath.row, section: indexPath.section - self.sectionsBeforeData))
                }
          //  }
        }
        let localDeleteAction = UIContextualAction(style: .destructive, title: "Delete".localize) {  (contextualAction, view, boolValue) in
            //self.tableActionActivityIndicator.startAnimating()
          //  DispatchQueue.main.async {
            self.ai.show(title: "Deleting".localize) { _ in
                    let id = self.tableData[indexPath.section - self.sectionsBeforeData].data[indexPath.row].category.id
                    self.db.deleteCategory(id: "\(id)", local: true)
                    self.loadData()
                }
          //  }
            
        }
        
        let editAction = UIContextualAction(style: .destructive, title: "Edit".localize) {  (contextualAction, view, boolValue) in
            //self.tableActionActivityIndicator.startAnimating()
            self.tableData[indexPath.section - self.sectionsBeforeData].data[indexPath.row].editing = self.tableData[indexPath.section - self.sectionsBeforeData].data[indexPath.row].category
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .left)
               // self.tableView.reloadData()
            }
        }
        editAction.image = AppData.iconNamed("pencil.yellow")
        deleteAction.image = AppData.iconNamed("trash.red")
        editAction.backgroundColor = K.Colors.primaryBacground
        deleteAction.backgroundColor = K.Colors.primaryBacground
        localDeleteAction.backgroundColor = K.Colors.primaryBacground
        localDeleteAction.image = AppData.iconNamed("trash.red")
        
        if indexPath.section == 0 || indexPath.section == 1 {
            return nil
        } else {
            if screenType == .localData {
                return transfaringCategories == nil ? UISwipeActionsConfiguration(actions: [localDeleteAction]) : nil
            } else {
                let data = self.tableData[indexPath.section - sectionsBeforeData].data
                if data.count != 0 {
                    if data[indexPath.row].editing == nil {
                        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
                    }
                }
                return nil

                
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 || indexPath.section == 1 {
        } else {
            let dataIndex = IndexPath(row: indexPath.row, section: indexPath.section - sectionsBeforeData)
            if tableData[dataIndex.section].data.count == 0 {
                
            } else {
                if let delegate = delegate {
                    delegate.categorySelected(category: tableData[dataIndex.section].data[dataIndex.row].category, fromDebts: tableData[dataIndex.section].data[dataIndex.row].category.purpose == .debt ? true : false, amount: 0)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    if tableData[dataIndex.section].data[dataIndex.row].editing == nil {
                        toHistory(index: dataIndex)
                        //(category: tableData[dataIndex.section].data[dataIndex.row].category)
                    }
                }
            }
            

        }
        
        
        


        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTF = textField
        //t//oggleIcons(show: false, animated: true, category: nil)
     //   selectingIconFor = (nil,nil)
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
                       // let set = IndexSet(integer: section + self.sectionsBeforeData)
                  //      DispatchQueue.main.async {
                          //  self.tableView.reloadSections(set, with: .automatic)
                     //   }
                    }

                    
                }
            }

            
     //commented       self.tableView.reloadData()
        }
    }
}







extension CategoriesVC {
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
    }
}





extension CategoriesVC: IconsVCDelegate {
    func selected(img: String, color: String) {
        
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
                    default:
                        return .expense
                    }
                }

                if img != "" {
                    appData.lastSelected.sett(value: img, setterType: .icon, valueType: valType)
                    tableData[selectingFooter].newCategory.category.icon = img
                }
                if color != "" {
                    appData.lastSelected.sett(value: color, setterType: .color, valueType: valType)
                    tableData[selectingFooter].newCategory.category.color = color
                }
                
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
            
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
      //  if let data = allData {
            categories = allCategoriesHolder
            DispatchQueue.main.async {
                searchBar.endEditing(true)
                self.tableView.reloadData()
            }
       // }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchingText = searchText
        categories = categoriesContains(searchText)
    }
    
    
}

