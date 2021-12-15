//
//  CategoriesVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation

///TODO:
//no data cell
var _categoriesHolder: [CategoriesStruct] = []

protocol CategoriesVCProtocol {
    func categorySelected(category: NewCategories?, fromDebts: Bool, amount: Int)
}

class CategoriesVC: SuperViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var catData = appData.categoryVC
    var refreshControl = UIRefreshControl()
    var hideTitle = false
    var fromSettings = false
    var delegate: CategoriesVCProtocol?

    static var shared:CategoriesVC?
    var _tableData:[ScreenDataStruct] = []
    var tableData:[ScreenDataStruct] {
        get {
            return _tableData
        }
        set {
            _tableData = newValue
            DispatchQueue.main.async {
               // self.tableView.reloadData()
               /* if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                if self.ai.isShowing {
                    self.ai.fastHide { _ in
                        
                    }
                }*/
                
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
            

            
            for i in 0..<newValue.count {
                let purpose = newValue[i].purpose
                let strPurpose = purposeToString(purpose)
                var data = resultDict[strPurpose] ?? []
                //set transactions and dont set in
                

                var transactions:[TransactionsStruct] {
                    if self.screenType != .localData {
                        return db.transactions(for: newValue[i])
                    } else {
                        var all: [TransactionsStruct] {
                            if let transfaring = transfaringCategories  {
                                return transfaring.transactions
                            } else {
                                return db.localTransactions
                            }
                        }
                        var transResult:[TransactionsStruct] = []
                        for t in 0..<all.count {
                            if "\(newValue[i].id)" == all[t].categoryID {
                                transResult.append(all[t])
                            }
                        }
                        return transResult
                        
                        
                    }
                     //?  : (transfaringCategories != nil ? (transfaringCategories?.transactions ?? []) : )
                }
                
                data.append(ScreenCategory(category: newValue[i], transactions: transactions))
                resultDict.updateValue(data, forKey: strPurpose)
                
            }

            
            
            
            switch self.screenType {
            case .categories:
                self.tableData = [
                    ScreenDataStruct(title: K.expense, data: resultDict[purposeToString(.expense)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .expense), transactions: [])),
                    ScreenDataStruct(title: K.income, data: resultDict[purposeToString(.income)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .income), transactions: []))
                ]
            case .debts:
                self.tableData = [
                    ScreenDataStruct(title: "", data: resultDict[purposeToString(.debt)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .debt), transactions: [])),
                ]
            case .localData:
                self.tableData = [
                    ScreenDataStruct(title: K.expense, data: resultDict[purposeToString(.expense)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .expense), transactions: [])),
                    ScreenDataStruct(title: K.expense, data: resultDict[purposeToString(.income)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .income), transactions: [])),
                    ScreenDataStruct(title: purposeToString(.debt), data: resultDict[purposeToString(.debt)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .debt), transactions: []))
                ]
            }
            DispatchQueue.main.async {
                self.editingTF = nil
                self.toggleIcons(show: false, animated: true)
                self.editingTF?.endEditing(true)
                self.tableView.reloadData()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                if self.ai.isShowing {
                    self.ai.fastHide { _ in
                        
                    }
                }
            }
            
        }
    }

    var transfaringCategories: LoginViewController.TransferingData?
    func loadData(showError:Bool = false) {

        if screenType != .localData {
            let load = LoadFromDB()
            load.newCategories { loadedData, error in
                self.categories = loadedData
                if error != .none {
                    if showError {
                        DispatchQueue.main.async {
                            self.message.showMessage(text: error == .internet ? "No Interner" : "Error", type: .internetError)
                        }
                    }
                }
            }
        } else {
            if let transfare = transfaringCategories {
                self.categories = transfare.categories
            } else {
                //ud
                self.categories = db.localCategories
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleIcons(show: false, animated: false)
        
        var strTitle:String {
            switch screenType {
            case .localData:
                return "Local data"
            case .categories:
                return "Categories"
            case .debts:
                return "Debts"
            }
        }
        title = strTitle
        CategoriesVC.shared = self
        updateUI()
        loadData()
        
        
    }
    
    
    let db = DataBase()
    func saveNewCategory(section: Int, category: ScreenCategory) {
        
        let load = LoadFromDB()
        load.newCategories { loadedData, error in
            var newCategory = category
            let save = SaveToDB()
            let all = loadedData.sorted{ $0.id > $1.id }
            let newID = (all.first?.id ?? 0) + 1
            
            print("new:", newCategory.category.name)
            print("new id:", newID)
            newCategory.category.id = newID
            save.newCategories(newCategory.category) { error in
                self.editingTF = nil
                self.tableData[section].newCategory.category.name = ""
                self.tableData[section].data.append(newCategory)
                if CategoriesVC.shared?.showingIcons ?? false {
                    CategoriesVC.shared?.toggleIcons(show: false, animated: true)
                }
                DispatchQueue.main.async {
                    self.ai.fastHide { _ in
                        UIImpactFeedbackGenerator().impactOccurred()
                    }
                    
                    
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    @objc func newCategoryPressed(_ sender: UITapGestureRecognizer) {
        if let section = Int(sender.name ?? "") {
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
                
                self.ai.show { _ in
                    self.editingTF?.endEditing(true)
                    self.editingTF = nil
                    let category = self.tableData[section].newCategory
                    self.saveNewCategory(section: section, category: category)
                }
            }
            
        }
    }
    

    
    var endAll = false
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    @objc func pressedToDismiss(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            if let editing = self.editingTF {
                editing.endEditing(true)
            }
            
        }
       /* if showingIcons {
            toggleIcons(show: false, animated: true)
        }*/
    }
    
    var defaultButtonInset: CGFloat = 0
    var tableContentOf:UIEdgeInsets = UIEdgeInsets.zero
    @objc func keyboardWillHide(_ notification: Notification) {
          self.view.removeGestureRecognizer(viewTap)
        DispatchQueue.main.async {
            if !self.showingIcons {
                self.tableView.contentInset.bottom = self.defaultButtonInset
            }
            self.editingTF = nil
            self.tableView.reloadData()
            
        }
    }
    
    var keyHeight: CGFloat = 0.0
    @objc func keyboardWillShow(_ notification: Notification) {
        toggleIcons(show: false, animated: true)
        self.view.addGestureRecognizer(viewTap)
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
            self.tableView.contentInset.bottom = keyboardHeight - appData.safeArea.1 - self.defaultButtonInset

        }
    }
    

    var showingIcons = false
    func toggleIcons(show:Bool, animated: Bool) {
        showingIcons = show
        
        DispatchQueue.main.async {
            let containerHeight = self.iconsContainer.layer.frame.height
            if show  {
              //  self.view.addGestureRecognizer(self.viewTap)
                self.editingTF?.endEditing(true)
                self.kayboardAppeared(containerHeight)
            } else {
                if self.editingTF == nil {
             //       self.view.removeGestureRecognizer(self.viewTap)
                    self.tableView.contentInset.bottom = self.defaultButtonInset
                }
            }
            UIView.animate(withDuration: animated ? 0.3 : 0) {
                self.iconsContainer.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, show ? 0 : containerHeight + (appData.safeArea.0 + appData.safeArea.1 + 50), 0)
            } completion: { _ in
                
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if appeareDidCall {
            categories = _categories
        } else {
            appeareDidCall = true
        }
        
        if transactionAdded {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
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
    
        tableView.delegate = self
        tableView.dataSource = self

        if appData.username != "" {
            addRefreshControll()
        }
        
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    
    @objc private func textfieldValueChanged(_ textField: UITextField) {//here
        DispatchQueue.main.async {
            if let section = Int(textField.layer.name ?? "") {
                print(textField.text ?? "", "tftftftfttftftftfttftftftft tf")
                print(self.tableData[section].newCategory.category.name, "tftftftfttftftftfttftftftft name")
                self.tableData[section].newCategory.category.name = textField.text ?? ""
                self.tableView.reloadData()
            }
            
        }
    }

    
    func addRefreshControll() {
        DispatchQueue.main.async {
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            self.tableView.addSubview(self.refreshControl)
        }
    }


    
    @objc func refresh(sender:AnyObject) {
        loadData(showError: true)
    }
    



    func deteteCategory(at: IndexPath) {
        let delete = DeleteFromDB()
        delete.CategoriesNew(category: tableData[at.section].data[at.row].category) { _ in
            self.categories = self.db.categories
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
            toggleIcons(show: true, animated: true)
        }
    }
    
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
        case "toDebts":
            if segue.identifier == "toDebts" {
                let vc = segue.destination as! DebtsVC
      //          vc.debts = debts
                if !fromSettings {
                    vc.delegate = self
                 //   vc.darkAppearence = self.darkAppearence
                    vc.safeAreaButton = appData.safeArea.1//safeAreaButton
                }
            }
        case "selectIcon":
            let vc = segue.destination as! IconsVC
            vc.delegate = self
        default:
            break
        }
    }


    let footerHeight:CGFloat = 40

    

    @objc func iconTapped(_ sender: UITapGestureRecognizer) {
        if let section = Int(sender.name ?? "") {
            selectingIconFor.1 = section
        }
        
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -60.0 {
            if let editing = editingTF {
                editingTF = nil
                toggleIcons(show: false, animated: true)
                DispatchQueue.main.async {
                    editing.endEditing(true)
                    
                }
            }
            
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
                return tableData[section - 2].data.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 || section == 1 {
            return nil
        } else {
            return tableData[section - 2].title
        }
        
    }
    
    func saveToLocal() {
        if let transfaring = transfaringCategories {
            db.localCategories = transfaring.categories
            db.localTransactions = transfaring.transactions
            transfaringCategories = nil
            screenType = .localData
            loadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return UITableViewCell()
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
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                let sendAll = {
                    needDownloadOnMainAppeare = true
                    sendSavedData = true
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
                
                cell.saveAction = saveToLocal
                cell.deleteAction = deleteAction
                cell.sendAction = sendAll
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
                
                let index = IndexPath(row: indexPath.row, section: indexPath.section - 2)
                cell.lo(index: index, footer: nil)
                let selected = UIView(frame: .zero)
                selected.backgroundColor = K.Colors.primaryBacground
                cell.selectedBackgroundView = selected
                let category = tableData[index.section].data[indexPath.row]

                cell.accessoryType = category.editing != nil ? .none : .disclosureIndicator
                let hideEditing = category.editing != nil ? false : true
                let hideQnt = !hideEditing
                let hideTitle = !hideEditing

                if cell.editingStack.isHidden != hideEditing {
                    cell.editingStack.isHidden = hideEditing
                }
                if cell.qntLabel.superview?.isHidden ?? false != hideQnt {
                    cell.qntLabel.superview?.isHidden = hideQnt
                }
                if cell.categoryNameLabel.isHidden != hideTitle {
                    cell.categoryNameLabel.isHidden = hideTitle
                }
                cell.qntLabel.text = "\(category.transactions.count)"
                cell.iconimage.image = category.editing == nil ? iconNamed(category.category.icon) : iconNamed(category.editing?.icon)
                cell.iconimage.tintColor = category.editing == nil ? colorNamed(category.category.color) : colorNamed(category.editing?.color)
                cell.categoryNameLabel.text = category.category.name
                cell.newCategoryTF.backgroundColor = cell.newCategoryTF == editingTF ? K.Colors.primaryBacground : .clear
                cell.newCategoryTF.text = category.editing?.name ?? category.category.name
                //
                cell.lo(index: index, footer: nil)
                /*if endAll {
                    cell.newCategoryTF.endEditing(true)
                }*/
                return cell
            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            return nil
        } else {
        let mainFrame = tableView.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: footerHeight))
        let helperView = UIView(frame: CGRect(x: 0, y: 10, width:mainFrame.width, height: footerHeight - 10))
        helperView.layer.cornerRadius = tableCorners
        helperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        helperView.backgroundColor = K.Colors.secondaryBackground//darkAppearence ? .black : .white
        view.backgroundColor = self.view.backgroundColor
        let label = UILabel(frame: CGRect(x: 10, y: tableCorners, width: mainFrame.width - 40, height: 20))
        label.text = tableData[section - 2].title
        label.textColor = K.Colors.balanceV
        label.font = .systemFont(ofSize: 14, weight: .medium)
        view.addSubview(helperView)
        view.addSubview(label)

        label.text = tableData[section - 2].title ?? ""
        return view
        }
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0
        } else {
            return screenType != .localData ? 60 : 20
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
            let sect = section - 2
        //show only footer
        let category = tableData[sect].newCategory.category
        cell.lo(index: nil, footer: sect)
        cell.newCategoryTF.text = category.name
        cell.iconimage.image = iconNamed(category.icon)
        cell.iconimage.tintColor = colorNamed(category.color)
        cell.editingStack.isHidden = false
        cell.dueDateStack.isHidden = true
        if cell.qntLabel.superview?.isHidden ?? false != true {
            cell.qntLabel.superview?.isHidden = true
        }
        cell.cancelButton.isHidden = true
        
       /* print(category.name, "namenamenamenamenamename")
        let hideSave = category.name == "" ? true : false
        if cell.saveButton.isHidden != hideSave {
            cell.saveButton.isHidden = hideSave
        }*/
        cell.categoryNameLabel.isHidden = true
        if screenType != .localData {
            let savePressed = UITapGestureRecognizer(target: self, action: #selector(newCategoryPressed(_:)))
            savePressed.name = "\(sect)"
            cell.saveButton.addGestureRecognizer(savePressed)
            
            let iconPressed = UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:)))
            iconPressed.name = "\(sect)"
            cell.iconimage.addGestureRecognizer(iconPressed)
            cell.newCategoryTF.backgroundColor = cell.newCategoryTF == editingTF ? K.Colors.primaryBacground : .clear
            cell.newCategoryTF.delegate = self
            cell.newCategoryTF.layer.name = "\(sect)"
            cell.newCategoryTF.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
        } else {
            cell.iconimage.isHidden = true
            cell.editingStack.isHidden = true
            cell.saveButton.superview?.isHidden = true
        }
        

        let view = cell.contentView
        view.isUserInteractionEnabled = true
        //view.layer.cornerRadius = 6
       // view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.backgroundColor = K.Colors.primaryBacground// K.Colors.secondaryBackground
        cell.footerBackground.backgroundColor = K.Colors.secondaryBackground
        cell.footerBackground.layer.cornerRadius = tableCorners
        cell.footerBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            //self.tableActionActivityIndicator.startAnimating()
            self.deteteCategory(at: IndexPath(row: indexPath.row, section: indexPath.section - 2))
        }
        deleteAction.backgroundColor = K.Colors.negative
        
        let editAction = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
            //self.tableActionActivityIndicator.startAnimating()
            self.tableData[indexPath.section - 2].data[indexPath.row].editing = self.tableData[indexPath.section - 2].data[indexPath.row].category
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        editAction.backgroundColor = K.Colors.yellow
        
        
        
        if indexPath.section == 0 || indexPath.section == 1 {
            return nil
        } else {
            if screenType == .localData {
                //delete cate from local
                //
                return transfaringCategories == nil ? UISwipeActionsConfiguration(actions: [deleteAction, editAction]) : nil
            } else {
                return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 || indexPath.section == 1 {
        } else {
            let dataIndex = IndexPath(row: indexPath.row, section: indexPath.section - 2)
            
            if let delegate = delegate {
                delegate.categorySelected(category: tableData[dataIndex.section].data[dataIndex.row].category, fromDebts: false, amount: 0)
                self.navigationController?.popViewController(animated: true)
            } else {
                if tableData[dataIndex.section].data[dataIndex.row].editing == nil {
                    toHistory(index: dataIndex)
                    //(category: tableData[dataIndex.section].data[dataIndex.row].category)
                }
            }
            
            /*if screenType == .localData {
                
            } else {
                if let editing = editingTF {
                    editingTF = nil
                    toggleIcons(show: false, animated: true)
                    editing.endEditing(true)
                } else {
                    
                    if !fromSettings {
                        delegate?.categorySelected(category: tableData[dataIndex.section].data[dataIndex.row].category, fromDebts: false, amount: 0)
                        self.navigationController?.popViewController(animated: true)
                    //    navigationController?.popToRootViewController(animated: true)//to prev vc indeed!!!
                    } else {
                        if tableData[indexPath.section].data[indexPath.row].editing == nil {
                            toHistory(category: tableData[dataIndex.section].data[dataIndex.row].category)
                        }
                        
                    }
                    
                }
            }*/
        }
        
        
        


        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTF = textField
        toggleIcons(show: false, animated: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}






extension CategoriesVC: DebtsVCProtocol {
    func catDebtSelected(name: String, amount: Int) {

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


extension categoriesVCcell:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        CategoriesVC.shared?.editingTF = textField
       /* DispatchQueue.main.async {
            CategoriesVC.shared?.tableView.reloadData()
        }*/
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}


extension CategoriesVC: IconsVCDelegate {
    func selected(img: String, color: String) {
        if let selectingIndex = selectingIconFor.0 {
            if img != "" {
                tableData[selectingIndex.section].data[selectingIndex.row].editing?.icon = img
            }
            if color != "" {
                tableData[selectingIndex.section].data[selectingIndex.row].editing?.color = color
            }
            
        } else {
            if let selectingFooter = selectingIconFor.1 {
                if img != "" {
                    tableData[selectingFooter].newCategory.category.icon = img
                }
                if color != "" {
                    tableData[selectingFooter].newCategory.category.color = color
                }
                
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
            
    }
    
    
    
}








class categoriesVCcell: UITableViewCell {
    
    @IBOutlet weak var footerBackground: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var qntLabel: UILabel!
    @IBOutlet weak var proView: UIView!
    @IBOutlet weak var iconimage: UIImageView!
    
    
    
    @IBOutlet private weak var dueDateIcon: UIImageView! //1only set color when expired
    @IBOutlet private weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDateStack: UIStackView!
    @IBOutlet weak var payAmountLabel: UILabel!
    
    
    @IBOutlet weak var editingStack: UIStackView!
    @IBOutlet weak var newCategoryTF: UITextField!
    
    //here
    
    var indexPath:IndexPath?
    var footerSection: Int?
    

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    func lo(index:IndexPath?, footer: Int?) {
        indexPath = index
        footerSection = footer
        
        DispatchQueue.main.async {
            self.newCategoryTF.layer.cornerRadius = 6
        }
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
            let iconPressed = UITapGestureRecognizer(target: self, action: #selector(self.iconPressed(_:)))//
            self.iconimage.addGestureRecognizer(iconPressed)//
        }
        
    }
    
    @objc func iconPressed(_ sender: UITapGestureRecognizer) {
        if let indexPath = indexPath {
            if let category = currentCategory {
                if category.editing != nil {
                    CategoriesVC.shared?.selectingIconFor.0 = indexPath
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
    
    
    var currentCategory: CategoriesVC.ScreenCategory?
    
    @IBAction private func cancelPressed(_ sender: UIButton) {
        cancelEditing()
    }
    
    private func cancelEditing() {
        if let index = indexPath {
            CategoriesVC.shared?.tableData[index.section].data[index.row].editing = nil
            DispatchQueue.main.async {
                CategoriesVC.shared?.toggleIcons(show: false, animated: true)
                CategoriesVC.shared?.editingTF?.endEditing(true)
                CategoriesVC.shared?.editingTF = nil
                CategoriesVC.shared?.tableView.reloadData()
                CategoriesVC.shared?.ai.fastHide { _ in
                    
                }
            }
        }
    }
    
    
    let db = DataBase()
    
    
    
    
    
    private func saveCategory(_ category: CategoriesVC.ScreenCategory) {

        if category.editing != nil {
            if let index = indexPath {
                if let editingValue = category.editing {
                    let delete = DeleteFromDB()
                    delete.CategoriesNew(category: category.category) { error in
                        let save = SaveToDB()
                        save.newCategories(editingValue) { error in
                            //CategoriesVC.shared?.categories = self.db.categories
                            CategoriesVC.shared?.tableData[index.section].data[index.row].category = editingValue
                            CategoriesVC.shared?.tableData[index.section].data[index.row].editing = nil
                            DispatchQueue.main.async {
                                CategoriesVC.shared?.toggleIcons(show: false, animated: true)
                                CategoriesVC.shared?.editingTF?.endEditing(true)
                                CategoriesVC.shared?.editingTF = nil
                                CategoriesVC.shared?.tableView.reloadData()
                                CategoriesVC.shared?.ai.fastHide(completionn: { _ in
                                    UIImpactFeedbackGenerator().impactOccurred()
                                })
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        UIImpactFeedbackGenerator().impactOccurred()
        CategoriesVC.shared?.ai.show { _ in
            if let currentCategory = self.currentCategory {
                if currentCategory.editing?.name != "" {
                    self.saveCategory(currentCategory)
                } else {
                    self.cancelEditing()
                }
            }
        }
        
        if CategoriesVC.shared?.showingIcons ?? false {
            CategoriesVC.shared?.toggleIcons(show: false, animated: true)
        }

    }
    
}





class LocalDataActionCell: UITableViewCell {
    
    @IBOutlet weak var deletePressed: UIView!
    @IBOutlet weak var sendPressed: UIView!
    @IBOutlet weak var saveLocallyView: UIView!
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    var saveAction:(() -> ())?
    var sendAction:(() -> ())?
    var deleteAction:(() -> ())?
    
    func load() {
        let savePressed = UITapGestureRecognizer(target: self, action: #selector(saveLocallyPress(_:)))
        self.saveLocallyView.addGestureRecognizer(savePressed)
        
        let sendGesture = UITapGestureRecognizer(target: self, action: #selector(sendPress(_:)))
        self.sendPressed.addGestureRecognizer(sendGesture)
        
        let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(deletePress(_:)))
        self.deletePressed.addGestureRecognizer(deleteGesture)
    }
    
    override func draw(_ rect: CGRect) {
        self.saveLocallyView.layer.cornerRadius = 6
        self.sendPressed.layer.cornerRadius = 6
        self.deletePressed.layer.cornerRadius = 6
    }
    
    @objc func saveLocallyPress(_ sender: UITapGestureRecognizer) {
        if let action = saveAction {
            action()
        }
    }
    @objc func sendPress(_ sender: UITapGestureRecognizer) {
        if let action = sendAction {
            action()
        }
    }
    @objc func deletePress(_ sender: UITapGestureRecognizer) {
        if let action = deleteAction {
            action()
        }
    }
    
}
