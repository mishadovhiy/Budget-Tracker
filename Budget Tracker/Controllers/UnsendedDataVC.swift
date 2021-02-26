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
    var _tablTrans: [UnsendedTransactions] = []
    var tableDataTransactions: [UnsendedTransactions] {
        get{
            return _tablTrans
        }
        set {
            _tablTrans = newValue
            print("table data new value setted")
            DispatchQueue.main.async {
                if self.selectedCount == 0 {
                    self.activityIdicator.removeFromSuperview()
                }
                self.deleteSelectedButton.setTitle("Delete (\(self.selectedCount))", for: .normal)
                self.tableView.reloadData()
            }
        }
    }
    
    var activityIdicator = UIActivityIndicatorView(frame: .zero)
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
    
    var messageText = ""
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getData()
        
        for button in cornerButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 4
        }
        
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if messageText != "" {
            DispatchQueue.main.async {
                self.message.showMessage(text: self.messageText, type: .error, windowHeight: 65)
            }
        } else {
            if UserDefaults.standard.value(forKey: "firstLaunchUnsendedDataVC") as? Bool ?? true {
                UserDefaults.standard.setValue(false, forKey: "firstLaunchUnsendedDataVC")
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Long press anywhere to turn on editing mode", type: .succsess, windowHeight: 65)
                }
            }
        }
    }
    
    var foundInAListCount = 0
    func getData() {
        
        categories = appData.getCategories(key: "savedCategories")
        transactions = appData.savedTransactions.sorted{ $0.dateFromString < $1.dateFromString }
        foundInAListCount = 0
        tableDataTransactions.removeAll()
        for transaction in transactions {
            foundInAListCount = contains(transaction) ? foundInAListCount + 1 : foundInAListCount
            let new = UnsendedTransactions(value: transaction.value, category: transaction.category, date: transaction.date, comment: transaction.comment, selected: false)
            tableDataTransactions.append(new)
        }
        DispatchQueue.main.async {
            self.activityIdicator.stopAnimating()
            self.activityIdicator.removeFromSuperview()
            self.tableView.reloadData()
        }
    }

    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    var sendPres = false
    @IBAction func sendPressed(_ sender: UIButton) {
        sendPres = true
        self.dismiss(animated: true) {
            self.delegate?.quiteUnsendedData(deletePressed: false, sendPressed: true)
        }
    }
    var deletePress = false
    @IBAction func deletePressed(_ sender: UIButton) {
        deletePress = true
        self.dismiss(animated: true) {
            self.delegate?.quiteUnsendedData(deletePressed: true, sendPressed: false)
        }
    }

    
    func getFoundInAList(in localData: [Any], select: Bool = false) -> [UnsendedTransactions] {
        
        var newData = localData as! [UnsendedTransactions]
        for i in 0..<newData.count {
            if contains(TransactionsStruct(value: tableDataTransactions[i].value, category: tableDataTransactions[i].category, date: tableDataTransactions[i].date, comment: tableDataTransactions[i].comment)) {
                newData[i].selected = true
                if select {
                    tableDataTransactions[i].selected = true
                }
                
            }
        }
        
        return newData //emse conteins in cats
    }
    
  func contains(_ value: TransactionsStruct) -> Bool {
      var found: Bool?
    let dbData = Array(appData.transactions)
      
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
    
    override func viewWillDisappear(_ animated: Bool) {
        if !sendPres && !deletePress {
            self.delegate?.quiteUnsendedData(deletePressed: false, sendPressed: false)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    



    

    @IBAction func deleteSelectedPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.activityIdicator.frame = CGRect(x: 0, y: 0, width: sender.layer.frame.width, height: sender.layer.frame.height)
            self.activityIdicator.startAnimating()
            sender.addSubview(self.activityIdicator)
        }
        
        var result: [TransactionsStruct] = []
        result.removeAll()
        var newTable: [UnsendedTransactions] = []
        newTable.removeAll()
        foundInAListCount = 0
        selectedCount = 0
        for trans in tableDataTransactions {
            if !trans.selected {
                let new = TransactionsStruct(value: trans.value, category: trans.category, date: trans.date, comment: trans.comment)
                foundInAListCount = contains(new) ? foundInAListCount + 1 : foundInAListCount
                result.append(new)
                newTable.append(trans)
            }
        }
        appData.saveTransations(result, key: "savedTransactions")
        tableDataTransactions = newTable
        
    }

    

    
    var selectingRepeatedData = false
    @objc func selectRepeatedPressed(_ sender: UITapGestureRecognizer){
        selectedCount = 0
        foundInAListCount = 0
        selectingRepeatedData = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        for i in 0..<tableDataTransactions.count {
            if contains(TransactionsStruct(value: tableDataTransactions[i].value, category: tableDataTransactions[i].category, date: tableDataTransactions[i].date, comment: tableDataTransactions[i].comment)) {
                selectedCount += 1
                tableDataTransactions[i].selected = true
                if i == tableDataTransactions.count - 1 {
                    selectingRepeatedData = false
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    var selectingAllData = false
    @objc func selectAllInSectionPressed(_ sender: UITapGestureRecognizer) {
        selectingAllData = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIdicator.frame = CGRect(x: 0, y: 0, width: self.deleteSelectedButton.layer.frame.width, height: self.deleteSelectedButton.layer.frame.height)
            self.activityIdicator.startAnimating()
            self.deleteSelectedButton.addSubview(self.activityIdicator)
        }

        if let name = sender.name {
            if let section = Int(name) {
                selectedCount = 0
                if section == 1 {
                    for i in 0..<tableDataTransactions.count {
                        selectedCount += 1
                        tableDataTransactions[i].selected = true
                        if tableDataTransactions.count-1 == i {
                            print("last complited")
                            selectingAllData = false
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.activityIdicator.removeFromSuperview()
                            }
                        }
                    }
                } else {
                    if section == 2 {
                        print("categories")
                    }
                }
            }
        }
    }
    var selectedCount = 0
    
    
}


extension UnsendedDataVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return foundInAListCount > 0 ? 1 : 0
        case 1: return tableDataTransactions.count
        case 2: return categories.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3//categories.count > 0 ? 3 : 2
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "repeatedDataCell", for: indexPath) as! repeatedDataCell
            
            cell.selectButton.setTitle("Select (\(foundInAListCount))", for: .normal)
            let ai = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 15, height: 15))
            if selectingRepeatedData {
                ai.startAnimating()
                cell.selectButton.addSubview(ai)
            } else {
                ai.removeFromSuperview()
            }
            cell.selectButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectRepeatedPressed(_:))))
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedTransactionsCell", for: indexPath) as! unsendedTransactionsCell
            let data = tableDataTransactions[indexPath.row]
            cell.categoryLabel.text = data.category
            cell.commentLabel.text = data.comment
            cell.dateLabel.text = data.date
            cell.valueLabel.text = String(format:"%.0f", Double(data.value) ?? 0.0)
            
            cell.tintColor = tableDataTransactions[indexPath.row].selected ? K.Colors.negative : K.Colors.pink
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedCategoriesCell") as! unsendedCategoriesCell
            let data = categories[indexPath.row]
            cell.nameLabel.text = data.name
            cell.perposeLabel.text = data.purpose
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 25
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let mainFrame = self.view.frame
            let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: 25))
            let labels = UILabel(frame: CGRect(x: mainTitleLabel.superview?.frame.minX ?? 0.0, y: 0, width: (mainFrame.width - 20) / 2, height: 25))
            let title = section == 1 ? "Transactions" : "Categories"
            labels.text = title
            view.backgroundColor = UIColor(named: "darkTableColor")
            view.addSubview(labels)
            labels.font = .systemFont(ofSize: 14, weight: .medium)
            labels.textColor = UIColor(named: "CategoryColor") ?? .red
            let selectAll = UILabel(frame: CGRect(x: labels.frame.maxX, y: 0, width: labels.frame.width, height: labels.frame.height))
            selectAll.text = selectingAllData ? "Selecting \(title)" : "Select all \(title)"
            selectAll.textColor = UIColor(named: "CategoryColor") ?? .red
            selectAll.font = .systemFont(ofSize: 12, weight: .semibold)
            selectAll.textAlignment = .right
            selectAll.isUserInteractionEnabled = true
            let gestur = UITapGestureRecognizer(target: self, action: #selector(selectAllInSectionPressed(_:)))
            gestur.name = "\(section)"
            selectAll.addGestureRecognizer(gestur)
            view.addSubview(selectAll)
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            if indexPath.section == 1 {
                tableDataTransactions[indexPath.row].selected = tableDataTransactions[indexPath.row].selected ? false : true
                selectedCount = 0
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
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section != 0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                switch indexPath.section {
                case 1:
                    self.transactions.remove(at: indexPath.row)
                    appData.saveTransations(self.transactions, key: "savedTransactions")
                    self.activityIdicator.startAnimating()
                    view.addSubview(self.activityIdicator)
                    self.activityIdicator.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                    self.getData()
                case 2:
                    self.categories.remove(at: indexPath.row)
                    self.activityIdicator.startAnimating()
                    view.addSubview(self.activityIdicator)
                    self.activityIdicator.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
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
    
}
class unsendedCategoriesCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var perposeLabel: UILabel!
    
}

class repeatedDataCell: UITableViewCell {
    @IBOutlet weak var selectButton: UIButton!
    
}
