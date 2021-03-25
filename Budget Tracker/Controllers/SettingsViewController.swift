//
//  SettingsViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
var categoriesDebtsCount = (0,0)

protocol SettingsViewControllerProtocol {
    func closeSettings(sendSavedData:Bool, needFiltering: Bool)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var delegate: SettingsViewControllerProtocol?
    
    var tableData: [SettingsSctruct] = [
        SettingsSctruct(title: "Account", description: appData.username == "" ? "Sing In": appData.username, segue: "toSavedData"),
        SettingsSctruct(title: "Categories", description: "\(categoriesDebtsCount.0)", segue: "settingsToCategories"),
        SettingsSctruct(title: "Debts", description: "\(categoriesDebtsCount.1)", segue: "toDebts")
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
        if UserDefaults.standard.value(forKey: "firstLaunchSettings") as? Bool ?? false == false {
            if appData.username == "" {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Create account to use app across all your devices", type: .succsess, windowHeight: 80, autoHide: false, bottomAppearence: true)
                }
            } else {
                UserDefaults.standard.setValue(true, forKey: "firstLaunchSettings")
            }
        }
        
        getdata()
    }
    

    
    func getdata() {
        categoriesDebtsCount = (0,0)
        let allCategories = Array(appData.getCategories())
        var debts:[CategoriesStruct] = []
        var categpries:[CategoriesStruct] = []
        for i in 0..<allCategories.count {
            if allCategories[i].debt {
                debts.append(allCategories[i])
            } else {
                categpries.append(allCategories[i])
            }
        }
        categoriesDebtsCount = (categpries.count, debts.count)
        let unsavedCat = (UserDefaults.standard.value(forKey: "savedCategories") as? [[String]] ?? []).count
        let unsavedTrans = (UserDefaults.standard.value(forKey: "savedTransactions") as? [[String]] ?? []).count
        let data = [
            SettingsSctruct(title: "Account", description: appData.username == "" ? "Sing In": appData.username, segue: (unsavedCat + unsavedTrans) > 0 ? "toSavedData" : "toSingIn"),
            SettingsSctruct(title: "Categories", description: "\(categoriesDebtsCount.0)", segue: "settingsToCategories"),
            SettingsSctruct(title: "Debts", description: "\(categoriesDebtsCount.1)", segue: "toDebts")
        ]
        tableData = data
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("setting touches")
        if let touch = touches.first {
            if touch.view != contentView{
                closeWithAnimation()
            }
        }
    }

    var sendLocalDataPressed = false
    
    override func viewWillDisappear(_ animated: Bool) {
        if !toSegue {
            print("transactionAddedtransactionAddedtransactionAdded", transactionAdded)
            delegate?.closeSettings(sendSavedData: sendLocalDataPressed, needFiltering: transactionAdded)
            transactionAdded = false
        }
        DispatchQueue.main.async {
            self.message.hideMessage()
        }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let wasBack = self.view.backgroundColor
        DispatchQueue.main.async {
            self.view.backgroundColor = .clear
            self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -self.contentView.frame.maxY, 0)

            UIView.animate(withDuration: 0.27) {
                self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                self.view.backgroundColor = wasBack
            } completion: { (_) in
                /*UIView.animate(withDuration: 0.15) {
                    self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { (_) in
                    self.tableView.reloadData()
                }*/
                self.tableView.reloadData()
            }
        }
    }

    
    var toSegue = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        toSegue = true
        let messageText = "Save or delete data bellow"
        
        switch segue.identifier {
        case "toSingIn":
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .singIn
        case "toSavedData":
            let vc = segue.destination as! UnsendedDataVC
            vc.delegate = self
            vc.messageText = messageText
        case "settingsToCategories":
            let nav = segue.destination as! NavigationController
            let vc = nav.topViewController as! CategoriesVC
            vc.delegate = self
            vc.fromSettings = true
        case "toDebts":
            print("")
            let nav = segue.destination as! NavigationController
            let vc = nav.topViewController as! DebtsVC
            vc.delegate = self
            vc.fromSettings = true
        default:
            print("default")
        }
        

    }

    @IBAction func closePressed(_ sender: UIButton) {
        closeWithAnimation()
    }
    
    func closeWithAnimation(vcanimation: Bool = true) {
        DispatchQueue.main.async {
            self.message.hideMessage()
            
            
            UIView.animate(withDuration: 0.25) {
                self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -self.contentView.frame.maxY, 0)
                self.view.backgroundColor = .clear
            } completion: { (_) in
                self.toSegue = false
                self.dismiss(animated: false, completion: nil)
            }
           /* if !vcanimation {
                
                
            } else {
                UIView.animate(withDuration: 0.23) {
                    self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -self.contentView.frame.maxY, 0)
                } completion: { (_) in
                    self.toSegue = false
                    self.dismiss(animated: vcanimation, completion: nil)
                }
            }*/
        }
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
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.tableData[indexPath.row].segue, sender: self)
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

extension SettingsViewController: UnsendedDataVCProtocol {
    func quiteUnsendedData(deletePressed: Bool, sendPressed: Bool) {
        if !deletePressed && !sendPressed {
            delegate?.closeSettings(sendSavedData: false, needFiltering: false)
        } else {
            if deletePressed {
                print("seletePressed")
                appData.saveTransations([], key: "savedTransactions")
                appData.saveCategories([], key: "savedCategories")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.performSegue(withIdentifier: "toSingIn", sender: self)
                }
            } else {
                if sendPressed {
                    toSegue = false
                    sendLocalDataPressed = true
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}

extension SettingsViewController: CategoriesVCProtocol {
    func categorySelected(category: String, purpose: Int, fromDebts: Bool, amount: Int) {
        getdata()
    }
}

extension SettingsViewController: DebtsVCProtocol {
    func catDebtSelected(name: String, amount: Int) {
        getdata()
    }
}
