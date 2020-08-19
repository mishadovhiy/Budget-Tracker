//
//  SettingsViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!

    let tableData = [
        SettingsSctruct(title: appData.username == "" ? "Sing in" : "Sing out", description: appData.username, segue: appData.username == "" ? "toSingIn" : "toDontGo"),
        SettingsSctruct(title: "Categories", description: "All Categories (\(appData.getCategories().count))", segue: "settingsToCategories"),
        SettingsSctruct(title: "Filter", description: selectedPeroud, segue: "settingsToFilter")
    ]
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadAllfromDB()
    }
    
    func updateUI() {
        tableView.delegate = self
        tableView.dataSource = self
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 9
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius = 10
        contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 300, 0)
        
        view.isUserInteractionEnabled = true
        let hideOnSwipe = UISwipeGestureRecognizer(target: self, action: #selector(closeSwipe))
        hideOnSwipe.direction = .down
        view.addGestureRecognizer(hideOnSwipe)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 300, 0)
        }
    }
    
    func reloadAllfromDB() {
        
        print("reloadAllfromDB")
        let load = LoadFromDB()
        load.Users(mainView: self) { (loadedData) in
            if loadedData.count > 0 {
                appData.allUsers = loadedData
                appData.internetPresend = true
            } else {
                print("users: appData.internetPresend = false")
                appData.internetPresend = false
                return
            }
        }
        
        load.Transactions(mainView: self) { (loadedData) in
            print("loaded \(loadedData.count) transactions from DB")
            var dataStruct: [TransactionsStruct] = []
            for i in 0..<loadedData.count {
                    
                let value = loadedData[i][3]
                let category = loadedData[i][1]
                let date = loadedData[i][2]
                let comment = loadedData[i][4]
                dataStruct.append(TransactionsStruct(value: value, category: category, date: date, comment: comment))
            }
                
            if loadedData.count > 0 {
                appData.saveTransations(dataStruct)
                appData.internetPresend = true

            }
        }

        
        load.Categories(mainView: self) { (loadedData) in
            print("loaded \(loadedData.count) Categories from DB")
            var dataStruct: [CategoriesStruct] = []
            for i in 0..<loadedData.count {
                    
                let name = loadedData[i][1]
                let purpose = loadedData[i][2]
                dataStruct.append(CategoriesStruct(name: name, purpose: purpose))
            }
                
            if loadedData.count > 0 {
                appData.saveCategories(dataStruct)
                appData.internetPresend = true
                refreshDataComlition = true
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSingIn" {
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .logIn
        }
    }
    
    
    
//close
    
    @objc func closeSwipe(_ gesture: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//table view

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsVCCell", for: indexPath) as! SettingsVCCell
        
        cell.titleLbel.text = tableData[indexPath.row].title
        cell.descriptionLabel.text = tableData[indexPath.row].description
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != 0 {
            performSegue(withIdentifier: tableData[indexPath.row].segue, sender: self)
        } else {
            if appData.internetPresend ?? false {
                self.performSegue(withIdentifier: self.tableData[indexPath.row].segue, sender: self)
                
            } else {
                DispatchQueue.init(label: "loaddata").async {
                //    let _ = AppData.DB(username: appData.username, mainView: self)
                }
                self.message.showMessage(text: "No internet", type: .error)
                
            }
            
        }
        
        
        
        
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
    }
    
}


// struct

struct SettingsSctruct {
    let title: String
    let description: String
    let segue: String
}


// cell

class SettingsVCCell: UITableViewCell {
    
    @IBOutlet weak var titleLbel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}
