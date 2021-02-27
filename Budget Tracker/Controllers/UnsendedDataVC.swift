//
//  UnsendedDataVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 22.01.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

protocol UnsendedDataVCProtocol {
    func quiteUnsendedData(deletePressed: Bool, sendPressed: Bool)
}

class UnsendedDataVC: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var cornerButtons: [UIButton]!
    @IBOutlet weak var deleteSelectedButton: UIButton!
    @IBOutlet weak var saveAllButton: UIButton!
    var _tablTrans: [UnsendedTransactions] = []
    var categoruesTableData: [UnsendedCategories] = []
    var tableDataTransactions: [UnsendedTransactions] {
        get{
            return _tablTrans
        }
        set {
            _tablTrans = newValue
            print("table data new value setted")
            DispatchQueue.main.async {
                
                self.deleteSelectedButton.setTitle("Delete (\(self.selectedCount))", for: .normal)
                self.tableView.reloadData()
                if newValue.count == 0 && self.categoruesTableData.count == 0 {
                    self.deletePress = true
                    self.dismiss(animated: true) {
                        self.delegate?.quiteUnsendedData(deletePressed: true, sendPressed: false)
                    }
                }
                UIView.animate(withDuration: 0.23) {
                    self.saveAllButton.alpha = self.selectedCount == 0 ? 1 : 0.2
                } completion: { (_) in
                    
                }

                
            }
        }
    }
    
    @IBOutlet weak var deleteAllButton: UIButton!
    var transactions: [TransactionsStruct] = []
    var categories: [CategoriesStruct] = []
    var delegate:UnsendedDataVCProtocol?
    
    struct UnsendedTransactions {
        let value: String
        let category: String
        let date: String
        let comment: String
        var selected: Bool
    }
    struct UnsendedCategories {
        let name: String
        let purpose: String
        var selected: Bool
    }
    
    var messageText = ""
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    var didapp = false
    let activity = UIActivityIndicatorView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        for button in cornerButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 4
        }
        didapp = true
        DispatchQueue.main.async {
            let titleFrame = self.mainTitleLabel.frame
            //self.activity.frame = CGRect(x: titleFrame.maxX, y: titleFrame.minY + (self.mainTitleLabel.superview?.superview?.frame.minY ?? 0) + 6, width: 15, height: 15)
            self.activity.frame = CGRect(x: titleFrame.maxX + 17, y: 8 + (self.mainTitleLabel.superview?.frame.minY ?? 0) + (self.mainTitleLabel.superview?.superview?.frame.minY ?? 0), width: 15, height: 15)
            self.view.addSubview(self.activity)
            self.activity.style = .gray
            self.activity.startAnimating()
            self.deleteSelectedButton.superview?.alpha = 0
            self.deleteAllButton.alpha = 0
        }
        
        
    }
    @objc func refresh(sender:AnyObject) {
        print("refreshing")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if messageText != "" {
            DispatchQueue.main.async {
                self.message.showMessage(text: self.messageText, type: .error, windowHeight: 65, bottomAppearence: true)
                self.messageText = ""
            }
        } else {
            if UserDefaults.standard.value(forKey: "firstLaunchUnsendedDataVC") as? Bool ?? true {
                UserDefaults.standard.setValue(false, forKey: "firstLaunchUnsendedDataVC")
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Long press anywhere to turn on editing mode", type: .succsess, windowHeight: 65)
                }
            }
        }
        if didapp {
            self.getData()
        }
        
    }
    
    var foundInAListCount = 0
    func getData() {
        didapp = false
        categories = appData.getCategories(key: "savedCategories")
        transactions = appData.savedTransactions.sorted{ $0.dateFromString < $1.dateFromString }
        foundInAListCount = 0
        selectedCount = 0
        
        var holder:[UnsendedTransactions] = []
        defaultsTransactions = appData.transactions
        for transaction in transactions {
            foundInAListCount = contains(transaction) ? foundInAListCount + 1 : foundInAListCount
            let new = UnsendedTransactions(value: transaction.value, category: transaction.category, date: transaction.date, comment: transaction.comment, selected: false)
            holder.append(new)
        }
        var catHolder: [UnsendedCategories] = []
        defaultsCategories = appData.getCategories()
        for category in categories {
            foundInAListCount = contains(category) ? foundInAListCount + 1 : foundInAListCount
            let new = UnsendedCategories(name: category.name, purpose: category.purpose, selected: false)
            catHolder.append(new)
            
        }
        categoruesTableData = catHolder
        tableDataTransactions = holder
        DispatchQueue.main.async {
            if self.activity.isAnimating {
                self.activity.stopAnimating()
            }
            UIView.animate(withDuration: 0.4) {
                self.deleteSelectedButton.superview?.alpha = 1
                self.deleteAllButton.alpha = 1
            } completion: { (_) in
            }
        }
    }

    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    var sendPres = false
    @IBAction func sendPressed(_ sender: UIButton) {
        print(self.selectedCount, "self.selectedCountself.selectedCountself.selectedCountself.selectedCount")
        if self.selectedCount == 0 {
            sendPres = true
            self.dismiss(animated: true) {
                self.delegate?.quiteUnsendedData(deletePressed: false, sendPressed: true)
            }
        }
    }
    var deletePress = false
    @IBAction func deletePressed(_ sender: UIButton) {
        deletePress = true
        self.dismiss(animated: true) {
            self.delegate?.quiteUnsendedData(deletePressed: true, sendPressed: false)
        }
    }
    
    
    var defaultsTransactions:[TransactionsStruct] = []
    func contains(_ value: TransactionsStruct) -> Bool {
        var found: Bool?
        let dbData = Array(defaultsTransactions)
        
        for i in 0..<dbData.count {
            if value.comment == dbData[i].comment &&
                value.category == dbData[i].category &&
                value.date == dbData[i].date &&
                value.value == dbData[i].value {
                
                found = true
                return true
            }
        }
        if found == nil {
            return false
        } else {
            return found!
        }
    }
    
    var defaultsCategories: [CategoriesStruct] = []
    func contains(_ value: CategoriesStruct) -> Bool {
        var found: Bool?
        let dbData = Array(defaultsCategories)
        
        for i in 0..<dbData.count {
            if value.name == dbData[i].name &&
                value.purpose == dbData[i].purpose
            {
                found = true
                return true
            }
        }
        if found == nil {
            return false
        } else {
            return found!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !sendPres && !deletePress {
            self.delegate?.quiteUnsendedData(deletePressed: false, sendPressed: false)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    



    

    @IBAction func deleteSelectedPressed(_ sender: UIButton) {
        if selectedCount != 0 {
            var result: [TransactionsStruct] = []
            result.removeAll()
            var newTable: [UnsendedTransactions] = []
            newTable.removeAll()
            foundInAListCount = 0
            selectedCount = 0
            defaultsTransactions = appData.transactions
            for trans in tableDataTransactions {
                if !trans.selected {
                    let new = TransactionsStruct(value: trans.value, category: trans.category, date: trans.date, comment: trans.comment)
                    foundInAListCount = contains(new) ? foundInAListCount + 1 : foundInAListCount
                    result.append(new)
                    newTable.append(trans)
                }
            }
            appData.saveTransations(result, key: "savedTransactions")
            
            var newCategories: [UnsendedCategories] = []
            var defaultsCatsResult: [CategoriesStruct] = []
            newCategories.removeAll()
            defaultsCatsResult.removeAll()
            for cat in categoruesTableData {
                if !cat.selected {
                    let new = CategoriesStruct(name: cat.name, purpose: cat.purpose, count: 0)
                    foundInAListCount = contains(new) ? foundInAListCount + 1 : foundInAListCount
                    newCategories.append(cat)
                    defaultsCatsResult.append(new)
                    
                }
            }
            defaultsCategories = appData.getCategories()
            appData.saveCategories(defaultsCatsResult, key: "savedCategories")
            categoruesTableData = newCategories
            tableDataTransactions = newTable
        }
    }

    

    @objc func selectRepeatedPressed(_ sender: UIButton){
        defaultsTransactions = appData.transactions
        selectedCount = 0
        foundInAListCount = 0
        var all = Array(self.tableDataTransactions)
        for i in 0..<all.count {
            if all[i].selected {
                self.selectedCount += 1
            } else {
                if contains(TransactionsStruct(value: all[i].value, category: all[i].category, date: all[i].date, comment: all[i].comment)) {
                    self.selectedCount += 1
                    all[i].selected = true
                }
            }
            
        }
        
        var allCats = Array(self.categoruesTableData)
        for i in 0..<allCats.count {
            if allCats[i].selected {
                self.selectedCount += 1
            } else {
                if contains(CategoriesStruct(name: allCats[i].name, purpose: allCats[i].purpose, count: 0)) {
                    self.selectedCount += 1
                    allCats[i].selected = true
                }
            }
        }
        categoruesTableData = allCats
        tableDataTransactions = all
        
    }
    
    
    @objc func selectAllInSectionPressed(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if let name = sender.name {
            if let section = Int(name) {
                var holder = tableDataTransactions
                selectedCount = 0
                if section == 1 {
                    for i in 0..<holder.count {
                        selectedCount += 1
                        holder[i].selected = true
                    }
                    let catHolder = categoruesTableData
                    for i in 0..<catHolder.count {
                        if catHolder[i].selected {
                            selectedCount += 1
                        }
                    }
                    self.tableDataTransactions = holder
                } else {
                    if section == 2 {
                        print("categories")
                        var catHolder = categoruesTableData
                        for i in 0..<catHolder.count {
                            selectedCount += 1
                            catHolder[i].selected = true
                        }
                        for i in 0..<holder.count {
                            if holder[i].selected {
                                selectedCount += 1
                            }
                        }
                        self.categoruesTableData = catHolder
                        self.tableDataTransactions = holder
                    }
                }
            }
        }
    }
    var selectedCount = 0
    
    let lightTrash = UIImage(named: "lightTrash") ?? UIImage()
    let redTrash = UIImage(named: "redTrash") ?? UIImage()
    let redPlusImage = UIImage(named: "ovalPlus") ?? UIImage()
    
}


extension UnsendedDataVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return foundInAListCount > 0 ? 1 : 0
        case 1: return tableDataTransactions.count
        case 2: return categoruesTableData.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Transactions"
        case 2: return "Categories"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "repeatedDataCell") as! repeatedDataCell
            
            cell.selectButton.setTitle("Select (\(self.foundInAListCount))", for: .normal)
            cell.selectButton.addTarget(self, action: #selector(self.selectRepeatedPressed(_:)), for: .touchUpInside)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedTransactionsCell", for: indexPath) as! unsendedTransactionsCell
            let data = tableDataTransactions[indexPath.row]
            cell.categoryLabel.text = data.category
            cell.commentLabel.text = data.comment
            cell.dateLabel.text = data.date
            cell.valueLabel.text = String(format:"%.0f", Double(data.value) ?? 0.0)
            cell.treshImage.image = data.selected ? redTrash : lightTrash
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedCategoriesCell") as! unsendedCategoriesCell
            let data = categoruesTableData[indexPath.row]
            cell.nameLabel.text = data.name
            cell.perposeLabel.text = data.purpose
            cell.trashImage.image = data.selected ? redTrash : lightTrash
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        case 1: return tableDataTransactions.count == 0 ? 0 : 25
        case 2: return categoruesTableData.count == 0 ? 0 : 25
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let mainFrame = self.view.frame
            let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: 25))
            let labels = UILabel()
            let heplerView = UIView(frame: CGRect(x: (mainTitleLabel.superview?.superview?.frame.minX ?? 0.0), y: 4, width: (mainFrame.width - 20) / 2, height: 25))
            view.addSubview(heplerView)
            let stackview = UIStackView()
            stackview.spacing = 5
            stackview.alignment = .fill
            stackview.distribution = .equalSpacing
            stackview.axis = .horizontal
            heplerView.addSubview(stackview)
            let title = section == 1 ? "Transactions" : "Categories"
            labels.text = title
            view.backgroundColor = UIColor(named: "darkTableColor")
            labels.font = .systemFont(ofSize: 14, weight: .medium)
            labels.textColor = UIColor(named: "CategoryColor") ?? .red
            let plusIcon = UIImageView()
            plusIcon.image = redPlusImage
            let gestur = UITapGestureRecognizer(target: self, action: #selector(selectAllInSectionPressed(_:)))
            gestur.name = "\(section)"
            heplerView.isUserInteractionEnabled = true
            heplerView.addGestureRecognizer(gestur)
            labels.translatesAutoresizingMaskIntoConstraints = false
            plusIcon.translatesAutoresizingMaskIntoConstraints = false
            stackview.addArrangedSubview(labels)
            stackview.addArrangedSubview(plusIcon)
            labels.adjustsFontSizeToFitWidth = true
            stackview.translatesAutoresizingMaskIntoConstraints = false
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            
            if indexPath.section == 1 {
                tableDataTransactions[indexPath.row].selected = tableDataTransactions[indexPath.row].selected ? false : true
            } else {
                if indexPath.section == 2 {
                    categoruesTableData[indexPath.row].selected = categoruesTableData[indexPath.row].selected ? false : true
                }
            }
            selectedCount = 0
            for cat in categoruesTableData {
                if cat.selected {
                    selectedCount += 1
                }
            }
            for trans in tableDataTransactions {
                if trans.selected {
                    selectedCount += 1
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.deleteSelectedButton.setTitle("Delete (\(self.selectedCount))", for: .normal)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section != 0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                switch indexPath.section {
                case 1:
                    self.transactions.remove(at: indexPath.row)
                    appData.saveTransations(self.transactions, key: "savedTransactions")
                    self.getData()
                case 2:
                    self.categories.remove(at: indexPath.row)
                    appData.saveCategories(self.categories, key: "savedCategories")
                    self.getData()
                default:
                    print("default")
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            return UISwipeActionsConfiguration(actions: selectedCount == 0 ? [deleteAction] : [])
        } else {
            return nil
        }
    }

}

class unsendedTransactionsCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var treshImage: UIImageView!
}
class unsendedCategoriesCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var perposeLabel: UILabel!
    @IBOutlet weak var trashImage: UIImageView!
    
}

class repeatedDataCell: UITableViewCell {
    @IBOutlet weak var selectButton: UIButton!
    
}
