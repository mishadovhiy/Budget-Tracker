//
//  CategoriesVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData


///TODO:
//no data cell
var _categoriesHolder: [CategoriesStruct] = []

protocol CategoriesVCProtocol {
    func categorySelected(category: NewCategories?, fromDebts: Bool, amount: Int)
}

class CategoriesVC: SuperViewController, UITextFieldDelegate {
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
    
    


    //(categories[i].name, categories[i].count, categories[i].debt)
  //  var expenses: [(String, Int)] = []
  //  var incomes: [(String, Int)] = []
    
    
    
    lazy var viewTap:UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(pressedToDismiss(_:)))
    }()
    
    enum ScreenType {
        
        case categories
        case debts
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

            print("newValue::", newValue.count)
            for i in 0..<newValue.count {
                let purpose = newValue[i].purpose
                let strPurpose = purposeToString(purpose)
                var data = resultDict[strPurpose] ?? []
                data.append(ScreenCategory(category: newValue[i]))
                resultDict.updateValue(data, forKey: strPurpose)
                
            }

            
            switch self.screenType {
            case .categories:
                self.tableData = [
                    ScreenDataStruct(title: K.expense, data: resultDict[purposeToString(.expense)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .expense))),
                    ScreenDataStruct(title: K.income, data: resultDict[purposeToString(.income)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .income)))
                ]
            case .debts:
                self.tableData = [
                    ScreenDataStruct(title: K.expense, data: resultDict[purposeToString(.debt)] ?? [], newCategory: ScreenCategory(category: NewCategories(id: -1, name: "", icon: "", color: "", purpose: .debt))),
                ]
            }
            
            
        }
    }

    
    func loadData(showError:Bool = false) {

        let load = LoadFromDB()
        load.newCategories { loadedData, error in

            print(loadedData.count, "loadedDataloadedDataloadedData")
            self.categories = loadedData
            if error != .none {
                if showError {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: error == .internet ? "No Interner" : "Error", type: .internetError)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CategoriesVC.shared = self
        updateUI()
        loadData()
        
       /* if _categoriesHolder.count == 0 {
            if appData.username != "" {
                let load = LoadFromDB()
                load.newCategories { data, error in
                    if error == "" {
                        
                    }
                    self.getDataFromLocal()
                }
            } else {
                getDataFromLocal()
            }
        } else {
            
            self.getDataFromLocal()
        }
*/
        
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
                //CategoriesVC.shared?.loadData()
                //CategoriesVC.shared?.categories = self.db.categories
                self.tableData[section].newCategory.category.name = ""
                self.tableData[section].data.append(newCategory)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    @objc func newCategoryPressed(_ sender: UITapGestureRecognizer) {
        if let section = Int(sender.name ?? "") {
            let category = tableData[section].newCategory
            saveNewCategory(section: section, category: category)
        }
    }
    
    
    
    func saveEditingCategory(_ category: ScreenCategory, index: IndexPath) {
        if let editingValue = category.editing {
            let delete = DeleteFromDB()
            delete.CategoriesNew(category: category.category) { error in
                let save = SaveToDB()
                save.newCategories(editingValue) { error in
                    //CategoriesVC.shared?.categories = self.db.categories
                    CategoriesVC.shared?.tableData[index.section].data[index.row].category = editingValue
                    CategoriesVC.shared?.tableData[index.section].data[index.row].editing = nil
                }
            }
            
        }
    }
    
    var endAll = false
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    @objc func pressedToDismiss(_ sender: UITapGestureRecognizer) {
     /*   if self.newCategoryTextField.isFirstResponder {
            DispatchQueue.main.async {
                self.newCategoryTextField.endEditing(true)
                
            }
        }*/
    }
    
    var tableContentOf:UIEdgeInsets = UIEdgeInsets.zero
    @objc func keyboardWillHide(_ notification: Notification) {
          self.view.removeGestureRecognizer(viewTap)
        DispatchQueue.main.async {
            self.tableView.contentInset = self.tableContentOf
            self.editingValue = nil
            self.tableView.reloadData()
            
        }
    }
    
    var keyHeight: CGFloat = 0.0
    @objc func keyboardWillShow(_ notification: Notification) {
        self.view.addGestureRecognizer(viewTap)
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if keyboardHeight > 1.0 {
                DispatchQueue.main.async {
                    self.tableView.contentInset.bottom = keyboardHeight - appData.safeArea.1//self.safeAreaButton
                   // self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y - keyboardHeight)
                }

            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        toHistory = false

        navigationController?.setNavigationBarHidden(false, animated: true)
       /* //if iphone
        DispatchQueue.main.async {
            let mainFrame = self.view.frame
            if self.safeAreaButton > 0 {
                let window = UIApplication.shared.keyWindow ?? UIWindow()
            }

        }*/
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {

        if fromSettings {
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        print("didApp")
        //getDataFromLocal()
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.tableContentOf = self.tableView.contentInset
            self.tableView.reloadData()
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
     //   newCategoryTextField.delegate = self
        if appData.username != "" {
            addRefreshControll()
        }
        whenNoCategories()
        let hiseCatsSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(hideCats(_:)))
        hiseCatsSwipe.direction = .left
        view.addGestureRecognizer(hiseCatsSwipe);
        

        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        DispatchQueue.main.async {
            self.title = "Categories"
           // self.tableView.translatesAutoresizingMaskIntoConstraints = true
         /*   self.newCategoryTextField.returnKeyType = .done
            self.newCategoryTextField.font = .systemFont(ofSize: 17, weight: .semibold)
            self.newCategoryTextField.clearButtonMode = .always*/
        }
    }
    

   /* func getDataFromLocal() {

        expenses = []
        incomes = []
        let categories = Array(appData.getCategories())
        for i in 0..<categories.count {
            if categories[i].purpose == K.expense {
                expenses.append((categories[i].name, categories[i].count))
            } else {
                incomes.append((categories[i].name, categories[i].count))
            }
        }
        whenNoCategories()
        expenses = expenses.sorted { $0.1 > $1.1 }
        incomes = incomes.sorted { $0.1 > $1.1 }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            if self.newCategoryTextField.isFirstResponder {
                self.newCategoryTextField.endEditing(true)
            } else {
                self.tableView.reloadData()
            }
        }
        
        
    }*/
    
    @objc private func textfieldValueChanged(_ textField: UITextField) {//here
        DispatchQueue.main.async {
            self.tableData[textField.tag].newCategory.category.name = textField.text ?? ""
        }
    }
    
    @objc func hideCats(_ gesture: UISwipeGestureRecognizer) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
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
        /*if appData.username != "" {
            let load = LoadFromDB()
            load.Categories{ (loadedData, error) in
                if error == "" {
                    print("loaded \(loadedData.count) Categories from DB")
                    var dataStruct: [CategoriesStruct] = []
                    for i in 0..<loadedData.count {
                        
                        let name = loadedData[i][1]
                        let purpose = loadedData[i][2]
                       // let isDebt = loadedData[i][3] == "0" ? false : true
                        dataStruct.append(CategoriesStruct(name: name, purpose: purpose, count: 0))
                    }
                    appData.saveCategories(dataStruct)
                    self.getDataFromLocal()
                    
                } else {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: error, type: .internetError)
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        } else {
            getDataFromLocal()
        }*/
    }
    
    func whenNoCategories() {
      /*  if expenses.count == 0 && incomes.count == 0 {

        } else {

        }*/
    }

    
    func sendToDBCategory(title: String, purpose: String) {
        wasEdited = true
        transactionAdded = true
        let save = SaveToDB()
      //  save.newCategories(<#T##category: NewCategories##NewCategories#>, completion: <#T##(Bool) -> ()#>)
       /* let Nickname = appData.username
        if Nickname != "" {
            let toDataString = "&Nickname=\(Nickname)" + "&Title=\(title)" + "&Purpose=\(purpose)" + "&ExpectingPayment=0"
            let save = SaveToDB()
            save.Categories(toDataString: toDataString) { (error) in
                var categories = Array(appData.getCategories())
                categories.append(CategoriesStruct(name: title, purpose: purpose, count: 0))
                appData.saveCategories(categories)
                self.getDataFromLocal()
                if error {
                    appData.unsendedData.append(["category": toDataString])
                }
            }
        }*/
    }
    
    func deteteCategory(at: IndexPath) {
        let delete = DeleteFromDB()
        delete.CategoriesNew(category: tableData[at.section].data[at.row].category) { _ in
            self.categories = self.db.categories
        }
    }

    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategoryName = ""
    func toHistory(category: NewCategories) {
        historyDataStruct = []
        /*let trans =  UserDefaults.standard.value(forKey: "transactionsData") as? [[String]] ?? []
        var totValue = 0.0
        for i in 0..<trans.count {
            if trans[i][2] == category {
                
                totValue = (Double(trans[i][1]) ?? 0.0) + totValue
                historyDataStruct.append(TransactionsStruct(value: trans[i][1], categoryID: trans[i][2], date: trans[i][3], comment: trans[i][4]))
            }
        }
*/
        historyDataStruct = db.transactions(for: category)
        
        selectedCategoryName = category.name
        if historyDataStruct.count > 0 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toHistory", sender: self)
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }

    var _selectingIconFor:(IndexPath?, Int?)
    var selectingIconFor:(IndexPath?, Int?) {
        get {
            return _selectingIconFor
        }
        set {
            _selectingIconFor = newValue
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "selectIcon", sender: self)
            }
        }
    }
    
    var toHistory = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "toHistory":
            toHistory = true
            let vc = segue.destination as! HistoryVC
            vc.historyDataStruct = historyDataStruct
            vc.selectedCategoryName = selectedCategoryName
            vc.fromCategories = true
            vc.allowEditing = false
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
    
    let darkSectionBackground = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    
    var editingValue: editingType?
    enum editingType {
        case expenses
        case income
    }
    
    var editingString: String?
    
    @objc func addPressed(_ sender: UITapGestureRecognizer) {
        
     /*   if let section = Int(sender.name ?? "") {
            self.showAnimatonOnSwitch = true
            self.newCategoryTextField.removeFromSuperview()
            switch section {
            case 0:
                editingValue = .expenses
            case 1:
                editingValue = .income
            default:
                return
            }
            
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
                //self.tableView.reloadData()
                //self.tableView.scrollToRow(at: IndexPath(row: self.editingValue! == .expenses ? self.expenses.count-1 : self.incomes.count-1, section: section), at: .bottom, animated: true)
                self.newCategoryTextField.text = ""
                self.tableView.reloadData()
            }
        }*/
    }
    
    let footerHeight:CGFloat = 40
    
  //  let newCategoryTextField = UITextField(frame: .zero)
    var showAnimatonOnSwitch = true
    //keyboardWillShoe and willHide - remove textfield
    

    @objc func iconTapped(_ sender: UITapGestureRecognizer) {
        if let section = Int(sender.name ?? "") {
            selectingIconFor.1 = section
        }
        
    }

    
}


//MARK: - Table View

extension CategoriesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count //fromSettings ? 2 : 3//darkAppearence ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].data.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
        cell.lo(index: indexPath, footer: nil)

        if endAll {
            cell.newCategoryTF.endEditing(true)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      //  let lightBackground = K.Colors.balanceT //UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1)
     //   view.backgroundColor = self.view.backgroundColor == K.Colors.background ? lightBackground : darkSectionBackground
        let mainFrame = tableView.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: footerHeight))
        let helperView = UIView(frame: CGRect(x: 0, y: 10, width:mainFrame.width, height: footerHeight - 10))
        helperView.layer.cornerRadius = 6
        helperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        helperView.backgroundColor = K.Colors.secondaryBackground//darkAppearence ? .black : .white
        view.backgroundColor = self.view.backgroundColor
        let label = UILabel(frame: CGRect(x: 10, y: 15, width: mainFrame.width - 40, height: 20))
        label.text = tableData[section].title
        label.textColor = K.Colors.balanceV
        label.font = .systemFont(ofSize: 14, weight: .medium)
        view.addSubview(helperView)
        view.addSubview(label)

        label.text = tableData[section].title ?? ""
        return view
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return footerHeight// + (safeAreaButton > 0 ? 10 : 0)
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return footerHeight + 15// + (safeAreaButton > 0 ? 10 : 0)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent) as! categoriesVCcell
            /*cell.categoryTextField.placeholder = "New " + (section == 0 ? "expence" : "income")
            cell.categoryTextField.delegate = self
            cell.categoryTextField.tag = section
            cell.iconImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:))))
            //cell.iconPressedFunc = iconPressed*/
            cell.lo(index: nil, footer: section)
            let savePressed = UITapGestureRecognizer(target: self, action: #selector(newCategoryPressed(_:)))
            savePressed.name = "\(section)"
            cell.saveButton.addGestureRecognizer(savePressed)
            
            let iconPressed = UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:)))
            iconPressed.name = "\(section)"
            cell.iconimage.addGestureRecognizer(iconPressed)
            cell.newCategoryTF.delegate = self
            cell.newCategoryTF.tag = section
            cell.newCategoryTF.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
            if endAll {
                cell.newCategoryTF.endEditing(true)
            }
            let view = cell.contentView
            view.isUserInteractionEnabled = true
            view.layer.cornerRadius = 6
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            view.backgroundColor = K.Colors.secondaryBackground
            return view

        } else {
            return nil
        }
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section != 2 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                //self.tableActionActivityIndicator.startAnimating()
                self.deteteCategory(at: indexPath)
            }
            deleteAction.backgroundColor = K.Colors.negative
            
            let editAction = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
                //self.tableActionActivityIndicator.startAnimating()
                self.tableData[indexPath.section].data[indexPath.row].editing = self.tableData[indexPath.section].data[indexPath.row].category
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            editAction.backgroundColor = K.Colors.yellow
            
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let editingValue = editingValue {
            /*DispatchQueue.main.async {
                 self.newCategoryTextField.endEditing(true)
             }*/
            endAll = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.endAll = false
            }
        } else {
            if !fromSettings {
                delegate?.categorySelected(category: tableData[indexPath.section].data[indexPath.row].category, fromDebts: false, amount: 0)
                navigationController?.popToRootViewController(animated: true)
            } else {
                switch indexPath.section {
                case 0:
                    toHistory(category: tableData[indexPath.section].data[indexPath.row].category)
                case 1:
                    toHistory(category: tableData[indexPath.section].data[indexPath.row].category)
                default:
                    self.dismiss(animated: true)
                }
            }
        }
        
       /* if editingValue == nil {
            if indexPath.section == 2 {
                if appData.proVersion || appData.proTrial {
                    historyDataStruct = []
                    selectedCategoryName = ""
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toDebts", sender: self)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
                
            } else {
                if !fromSettings {
                    delegate?.categorySelected(category: indexPath.section == 0 ? expenses[indexPath.row].0 : incomes[indexPath.row].0, purpose: indexPath.section, fromDebts: false, amount: 0)
                    navigationController?.popToRootViewController(animated: true)
                } else {
                    switch indexPath.section {
                    case 0:
                        toHistory(category: expenses[indexPath.row].0)
                    case 1:
                        toHistory(category: incomes[indexPath.row].0)
                    default:
                        self.dismiss(animated: true)
                    }
                }
            }
        } else {
           /* DispatchQueue.main.async {
                self.newCategoryTextField.endEditing(true)
            }*/
        }*/
        
    }
    
}





extension CategoriesVC: DebtsVCProtocol {
    func catDebtSelected(name: String, amount: Int) {
  //      delegate?.categorySelected(category: name, purpose: 1, fromDebts: true, amount: amount)
    //    navigationController?.popToRootViewController(animated: true)
    }
    
    
}
/*
extension CategoriesVC: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("clear")
        DispatchQueue.main.async {
            
            self.newCategoryTextField.endEditing(true)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("")//+
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let newCategory = textField.text ?? ""
        if newCategory != "" {
            let purpose = textField.tag == 0 ? K.expense : K.income
            if appData.username != "" {
                self.whenNoCategories()
                self.sendToDBCategory(title: newCategory, purpose: purpose)
            } else {
                var categories = Array(appData.getCategories())
                categories.append(CategoriesStruct(name: newCategory, purpose: purpose, count: 0))
                appData.saveCategories(categories)
             //   self.getDataFromLocal()
            }
        }
        DispatchQueue.main.async {
            textField.endEditing(true)
        }
        
        return true

    }
    
}

*/

class newCategoryCell: UITableViewCell {
    
    @IBOutlet weak var iconImage: UIButton!
    var iconPressedFunc:(() -> ())?
    
    @IBAction func iconPressed(_ sender: UIButton) {
        if let fucn = iconPressedFunc {
            fucn()
        }
    }
    
    @IBOutlet weak var categoryTextField: UITextField!
    
}



extension CategoriesVC {
    struct ScreenDataStruct {
        let title: String?
        var data: [ScreenCategory]
        var newCategory: ScreenCategory
    }
    
    
    struct ScreenCategory {
        var category:NewCategories
        var proLocked: Bool = false
        var showDisclosure:Bool = true
        var editing:NewCategories? = nil
    }
}





extension categoriesVCcell:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("")
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
            
    }
    
    
    
}


class categoriesVCcell: UITableViewCell {
    
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
        
        
        var category:CategoriesVC.ScreenCategory {
            let defaultCategory = CategoriesVC.ScreenCategory(category: NewCategories(id: -2, name: "-", icon: "", color: "", purpose: .expense))
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
        
        let hideEditing = (category.editing != nil || footer != nil) ? false : true
        let hideQnt = !hideEditing
        let hideTitle = !hideEditing
        
        DispatchQueue.main.async {
            if self.editingStack.isHidden != hideEditing {
                self.editingStack.isHidden = hideEditing
            }
            if self.qntLabel.superview?.isHidden ?? false != hideQnt {
                self.qntLabel.superview?.isHidden = hideQnt
            }
            if self.categoryNameLabel.isHidden != hideTitle {
                self.categoryNameLabel.isHidden = hideTitle
            }
            
            self.iconimage.image = category.editing == nil ? iconNamed(category.category.icon) : iconNamed(category.editing?.icon)
            
            self.iconimage.tintColor = category.editing == nil ? colorNamed(category.category.color) : colorNamed(category.editing?.color)
            
            
            self.categoryNameLabel.text = category.category.name
            
            self.accessoryType = category.editing != nil ? .none : .disclosureIndicator
            
            
            let iconPressed = UITapGestureRecognizer(target: self, action: #selector(self.iconPressed(_:)))
            self.iconimage.addGestureRecognizer(iconPressed)
            
            if let section = footer {
                self.newCategoryTF.text = CategoriesVC.shared?.tableData[section].newCategory.category.name
            } else {
                self.newCategoryTF.delegate = self
                self.newCategoryTF.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
                
                self.newCategoryTF.text = category.editing?.name ?? category.category.name
            }
            
        }
    }

    
    @objc func iconPressed(_ sender: UITapGestureRecognizer) {
        if let indexPath = indexPath {
           // CategoriesVC.shared?.iconPressed()
            CategoriesVC.shared?.selectingIconFor.0 = indexPath
        }
        
        
    }
    
    
    private func animateEditing() {
        
    }
    
    
    @objc private func textfieldValueChanged(_ textField: UITextField) {
        if let footerSection = footerSection {
            //adding new
            DispatchQueue.main.async {
                CategoriesVC.shared?.tableData[footerSection].newCategory.category.name = textField.text ?? ""
            }
        } else {
            if let indexPath = indexPath {
                DispatchQueue.main.async {
                    CategoriesVC.shared?.tableData[indexPath.section].data[indexPath.row].editing?.name = textField.text ?? ""
                }
            }
        }
        
        
        
    }
    
    
    var currentCategory: CategoriesVC.ScreenCategory?
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        if let index = indexPath {
            CategoriesVC.shared?.tableData[index.section].data[index.row].editing = nil
            lo(index: index, footer: nil)
        }
        
        
    }
    
    let db = DataBase()
    
    
    
    
    
    private func saveCategory(_ category: CategoriesVC.ScreenCategory) {
        
        
        if category.editing != nil {
            if let index = indexPath {
                CategoriesVC.shared?.saveEditingCategory(category, index: index)
            }
        }
        
         else {
            
            //
            
            
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {

        DispatchQueue.main.async {
            CategoriesVC.shared?.ai.show(completion: { _ in
                if let currentCategory = self.currentCategory {
                    self.saveCategory(currentCategory)
                }
                
            })
        }
        
    }
    
}
