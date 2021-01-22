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
    var keyPrefix = "unsaved"
    var delegate:UnsendedDataVCProtocol?
    @IBOutlet var cornerButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(keyPrefix, "keyyy")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getData()
        if keyPrefix == "unsaved" {
            DispatchQueue.main.async {
                self.cornerButtons[0].isHidden = true
            }
        }
        
        for button in cornerButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 4
        }
        
        DispatchQueue.main.async {
            self.mainTitleLabel.text = self.keyPrefix.capitalized + " Data"
        }
    }
    
    func getData() {
        
        categories = appData.getCategories(key: "\(keyPrefix)Categories")
        transactions = keyPrefix == "unsaved" ? appData.unsavedTransactions : appData.savedTransactions
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        delegate?.sendPressed()
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        
        delegate?.deletePressed()
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
            cell.valueLabel.text = data.value
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
