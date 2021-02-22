//
//  UnsendedDataVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 22.01.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

protocol UnsendedDataVCProtocol {
    func deletePressed()
    func sendPressed()
}

class UnsendedDataVC: UIViewController {

    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var transactions: [TransactionsStruct] = []
    var categories: [CategoriesStruct] = []
    var delegate:UnsendedDataVCProtocol?
    @IBOutlet var cornerButtons: [UIButton]!
    
    @IBOutlet weak var editingModeButtonsStack: UIStackView!
    @IBOutlet weak var mainButtonsStack: UIStackView!
    @IBOutlet weak var deleteSelectedButton: UIButton!
    
    
    var messageText = ""
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactions = transactions.sorted{ $0.dateFromString < $1.dateFromString }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let editGesture = UILongPressGestureRecognizer(target: self, action: #selector(editeTableGesture(_:)))
        tableView.addGestureRecognizer(editGesture)
        getData()
        
        for button in cornerButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 4
        }
        
        DispatchQueue.main.async {
            self.editingModeButtonsStack.isHidden = true
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
    
    func getData() {
        
        categories = appData.getCategories(key: "savedCategories")
        transactions = appData.savedTransactions
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.sendPressed()
        }
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.deletePressed()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    var editingMode = false
    @objc func editeTableGesture(_ sender: UILongPressGestureRecognizer) {
        if !editingMode {
            editingMode = true
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.mainButtonsStack.alpha = 0
                } completion: { (_) in
                    self.tableView.reloadData()
                    self.mainButtonsStack.isHidden = true
                    self.editingModeButtonsStack.isHidden = false
                    UIView.animate(withDuration: 0.2) {
                        self.editingModeButtonsStack.alpha = 1
                    }

                }
            }
        }
    }
    
    var indexSesHolder: [IndexPath] = []
    @IBAction func deleteSelectedPressed(_ sender: UIButton) {
        indexSesHolder = selectedIndexses
        removeFirstInList()
    }
    
    func removeFirstInList() {
        selectedIndexses = selectedIndexses.sorted(by: { $1.row > $0.row})
        print(selectedIndexses, "selectedIndexsesselectedIndexses")
        if let first = selectedIndexses.first {
            print(first, "firstfirstfirst")
            if first.section == 0 {
                transactions.remove(at: first.row)
                appData.saveTransations(transactions, key: "savedTransactions")
                selectedIndexses.removeFirst()
                for i in 0..<selectedIndexses.count {
                    if selectedIndexses[i].section == 0 {
                        selectedIndexses[i].row = selectedIndexses[i].row-1
                    }
                }
                
                removeFirstInList()
            } else {
                if first.section == 1 {
                    categories.remove(at: first.row)
                    selectedIndexses.removeFirst()
                    appData.saveCategories(categories, key: "savedCategories")
                    for i in 0..<selectedIndexses.count {
                        if selectedIndexses[i].section == 1 {
                            selectedIndexses[i].row = selectedIndexses[i].row-1
                        }
                    }
                    removeFirstInList()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: self.indexSesHolder, with: .left)
                self.deleteSelectedButton.setTitle("Delete (\(self.selectedIndexses.count))", for: .normal)
            }
        }
    }
    
    
    
    @IBAction func turnOffEditingModePressed(_ sender: UIButton) {
        editingMode = false
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.editingModeButtonsStack.alpha = 0
            } completion: { (_) in
                self.tableView.reloadData()
                self.editingModeButtonsStack.isHidden = true
                self.mainButtonsStack.isHidden = false
                UIView.animate(withDuration: 0.2) {
                    self.mainButtonsStack.alpha = 1
                }

            }
        }
    }
    
    var selectedIndexses: [IndexPath] = []
    
    
    
    
}


extension UnsendedDataVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return transactions.count
        case 1: return categories.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Transactions"
        case 1: return "Categories"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedTransactionsCell", for: indexPath) as! unsendedTransactionsCell
            let data = transactions[indexPath.row]
            cell.categoryLabel.text = data.category
            cell.commentLabel.text = data.comment
            cell.dateLabel.text = data.date
            cell.valueLabel.text = String(format:"%.0f", Double(data.value) ?? 0.0)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedCategoriesCell") as! unsendedCategoriesCell
            let data = categories[indexPath.row]
            cell.nameLabel.text = data.name
            cell.perposeLabel.text = data.purpose
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if editingMode {
            cell.accessoryType = .checkmark
            var inList = false
            for selected in selectedIndexses {
                if selected == indexPath {
                    inList = true
                }
            }
            cell.tintColor = inList ? K.Colors.negative : K.Colors.pink
        } else {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            switch indexPath.section {
            case 0: self.transactions.remove(at: indexPath.row)
                appData.saveTransations(self.transactions, key: "savedTransactions")
            case 1: self.categories.remove(at: indexPath.row)
                appData.saveCategories(self.categories, key: "savedCategories")
            default:
                print("default")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainFrame = self.view.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: 25))
        let labels = UILabel(frame: CGRect(x: mainTitleLabel.superview?.frame.minX ?? 0.0, y: 0, width: mainFrame.width - 20, height: 25))
        labels.text = section == 0 ? "Transactions" : "Categories"
        view.backgroundColor = UIColor(named: "darkTableColor")
        view.addSubview(labels)
        labels.font = .systemFont(ofSize: 14, weight: .medium)
        labels.textColor = .white
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var removeSelectedAt: Int?
        for i in 0..<selectedIndexses.count {
            if selectedIndexses[i] == indexPath {
                removeSelectedAt = i
            }
        }
        if let newSelection = removeSelectedAt {
            selectedIndexses.remove(at: newSelection)
            
        } else {
            selectedIndexses.append(IndexPath(row: indexPath.row, section: indexPath.section))
        }
        print(selectedIndexses)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.deleteSelectedButton.setTitle("Delete (\(self.selectedIndexses.count))", for: .normal)
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
