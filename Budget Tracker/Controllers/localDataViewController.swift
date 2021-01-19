//
//  localDataViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 20.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

var fromLocalDataVC = false

class localDataViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var showLocal = true
    //var tableData = appData.transactions.sorted{ $0.dateFromString > $1.dateFromString }
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    lazy var dbData = DBTransactions.sorted{ $0.dateFromString > $1.dateFromString }
    lazy var tableData : [TableDataStruct] = {
        var results:[TableDataStruct]  = []
        let dif = Array(difference)

        for i in 0..<dif.count {
            let new = TableDataStruct(category: dif[i].category, value: dif[i].value, date: dif[i].date, comment: dif[i].comment, uploaded: false)
            results.append(new)
        }
        for i in 0..<dbData.count {
            let new = TableDataStruct(category: dbData[i].category, value: dbData[i].value, date: dbData[i].date, comment: dbData[i].comment, uploaded: true)
            results.append(new)
        }
        print("localDataViewController dif: \(dif.count), dbData: \(dbData.count), results: \(results.count), local: \(appData.transactions.count)")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        return results
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("localDataViewController: DBTransactions: \(DBTransactions.count)")
        print("localDataViewController: appData.transactions: \(appData.transactions.count)")
        message.initMessage()
        
        fromLocalDataVC = true
        
        tableView.delegate = self
        tableView.dataSource = self

    }

    /*func sendToDB() {
        let send = SaveToDB()
        var dif = Array(difference)
        print("sendToDB: difference:", difference.count)
        DispatchQueue.main.async {
            self.message.showMessage(text: "sending", type: .staticError)
        }

        if dif.count > 0 {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { (a) in
                if dif.count > 0 {
                    let toDataString = "&Nickname=\(appData.username)" + "&Category=\(dif.first!.category)"
                        + "&Date=\(dif.first!.date)" + "&Value=\(dif.first!.value)" + "&Comment=\(dif.first!.comment)"
                    send.Transactions(transactionStruct: dif.first!, mainView: nil)
                    dif.removeFirst()
                    print("sendToDB left: \(dif.count)")
                } else {
                    a.invalidate()
                    print("timer coplited")
                    DBTransactions = []
                    self.performSegue(withIdentifier: "homeVC", sender: self)
                    //and cats
                }
            }
            
        } else {
            print("ERROR: nothing to send")
        }
        
    }*/
    
    var canQite = false

    @IBAction func buttonsPressed(_ sender: UIButton) {

        switch sender.tag {
        case 0:
            print("no")
            DBTransactions = []
            DBCategories = []
            appData.saveTransations([])
            appData.fromLoginVCMessage = "Wellcome, \(appData.username)"
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "homeVC", sender: self)
            }
            
        case 1:
            print("yes")
            appData.internetPresend = nil
            fromLocalDataVC = true
            appData.fromLoginVCMessage = "Wellcome, \(appData.username)\nYour data has been send"
            //sendToDB()

        default:
            print("default")
            fromLocalDataVC = true
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "homeVC", sender: self)
            }
        }
    }
    
    var previusSelected: IndexPath? = nil
    var selectedCell: IndexPath? = nil
    
    var balance : Int {
        var bal = 0
        let data = Array(tableData)
        for i in 0..<data.count {
            bal = bal + (Int(data[i].value) ?? 1)
        }
        return bal
    }
    
}

extension localDataViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return tableData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
        let cell = tableView.dequeueReusableCell(withIdentifier: "localDataBalanceCell", for: indexPath) as! localDataBalanceCell
        cell.valueLabel.text = "\(balance)"
        return cell
        case 1:
            let data = tableData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocalVCCell", for: indexPath) as! LocalVCCell
            cell.setupCell(data, i: indexPath.row, tableData: tableData, selectedCell: selectedCell)
            if tableData[indexPath.row].uploaded {
                cell.contentView.backgroundColor = K.Colors.background
            } else {
                cell.contentView.backgroundColor = K.Colors.notOnDBColor
            }
            return cell
        default:
            return UITableViewCell()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            if selectedCell == indexPath {
                selectedCell = nil
            } else {
                previusSelected = selectedCell
                selectedCell = indexPath
            }
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath, self.previusSelected ?? indexPath], with: .automatic)
            }
        }
        
    }
    
}

class LocalVCCell: UITableViewCell {
    
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dailyAmLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    func setupCell(_ data: TableDataStruct, i: Int, tableData: [TableDataStruct], selectedCell: IndexPath?) {
        if (Double(data.value) ?? 0.0) > 0 {
            valueLabel.textColor = K.Colors.category
        } else {
            valueLabel.textColor = K.Colors.negative
        }
        sectionView.layer.cornerRadius = 4
        commentLabel.isHidden = true
        
        let value = String(format:"%.0f", Double(data.value) ?? 0.0)
        commentImage.isHidden = data.comment == "" ? true : false
        
        
        
        valueLabel.text = value
        categoryLabel.text = data.category
        commentLabel.text = data.comment
        if selectedCell != nil {
            if selectedCell!.row == i && commentLabel.text != "" {
                commentLabel.isHidden = false

                commentImage.isHidden = true
            }
        }
        
        if i != 0 {
            if tableData[i - 1].date != data.date {
                sectionView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                dateLabel.text = "\(data.date)"
                dailyAmLabel.text = "\(getDailyTotal(day: data.date, tableData: tableData))"
            } else {
                sectionView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                dateLabel.text = ""
                dailyAmLabel.text = ""
            }
        } else {
            sectionView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            dateLabel.text = "\(data.date)"
            dailyAmLabel.text = "\(self.getDailyTotal(day: data.date, tableData: tableData))"
        }
        
    }
    
    func getDailyTotal(day: String, tableData: [TableDataStruct]) -> String {
        
        var total: Double = 0.0
        for i in 0..<tableData.count {
            if tableData[i].date == day {
                total = total + (Double(tableData[i].value) ?? 0.0)
            }
        }
        
        var amount = ""
        var intTotal = Int(total)
        if total > Double(Int.max) {
            amount = "\(total)"
            intTotal = 1
            return amount
        }
        
        if total > 0 {
            amount = "+\(intTotal)"
        } else {
            amount = "\(intTotal)"
        }
        
        return amount
    }
}

class localDataBalanceCell: UITableViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    
}


struct TableDataStruct {
    let category: String
    let value: String
    let date: String
    let comment: String
    let uploaded: Bool
}
