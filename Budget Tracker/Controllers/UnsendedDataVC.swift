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
        
        DispatchQueue.main.async {
            self.mainTitleLabel.text = "Unsended Data"
        }
        
        if messageText != "" {
            DispatchQueue.main.async {
                self.message.showMessage(text: self.messageText, type: .error)
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
