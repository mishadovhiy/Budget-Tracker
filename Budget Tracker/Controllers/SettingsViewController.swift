//
//  SettingsViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

protocol SettingsViewControllerProtocol {
    func closeSettings(sendSavedData:Bool)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var delegate: SettingsViewControllerProtocol?
    
    var tableData = [
        SettingsSctruct(title: "Account", description: appData.username == "" ? "Sing In": appData.username, segue: (appData.savedTransactions.count + appData.getCategories(key: "savedCategories").count) > 0 ? "toSavedData" : "toSingIn"),
        SettingsSctruct(title: "Categories", description: "All Categories (\(appData.getCategories().count))", segue: "settingsToCategories"),
    ]
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        
        if UserDefaults.standard.value(forKey: "firstLaunchSettings") as? Bool ?? false == false {
            if appData.username == "" {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Create account to use app across all your devices", type: .succsess, windowHeight: 80, autoHide: false, bottomAppearence: true)
                }
            } else {
                UserDefaults.standard.setValue(true, forKey: "firstLaunchSettings")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view != contentView{
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.23) {
                        self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -self.contentView.frame.maxY, 0)
                    } completion: { (_) in
                        self.toSegue = false
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

    var sendLocalDataPressed = false
    
    override func viewWillDisappear(_ animated: Bool) {
        if !toSegue {
            delegate?.closeSettings(sendSavedData: sendLocalDataPressed)
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
        
        
        //view.isUserInteractionEnabled = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -self.contentView.frame.maxY, 0)
            UIView.animate(withDuration: 0.23) {
                self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
            self.tableView.reloadData()
        }
    }
    
    

    var toSegue = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        toSegue = true
        let messageText = "Save or Delete data bellow"
        if segue.identifier == "toSingIn" {
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .createAccount
        } else {
            if segue.identifier == "toSavedData" {
                let vc = segue.destination as! UnsendedDataVC
                vc.delegate = self
                vc.messageText = messageText
            }
        }
        
        switch segue.identifier {
        case "toSingIn":
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .createAccount
        case "toSavedData":
            let vc = segue.destination as! UnsendedDataVC
            vc.delegate = self
            vc.messageText = messageText
        case "settingsToCategories":
            let vc = segue.destination as! CategoriesVC
            vc.delegate = self
            vc.fromSettings = true
        default:
            print("default")
        }
    }

    @IBAction func closePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.23) {
                self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -self.contentView.frame.maxY, 0)
            } completion: { (_) in
                self.toSegue = false
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
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
    func deletePressed() {
        appData.saveTransations([], key: "savedTransactions")
        appData.saveCategories([], key: "savedCategories")
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.performSegue(withIdentifier: "toSingIn", sender: self)
        }
    }
    
    func sendPressed() {
        toSegue = false
        sendLocalDataPressed = true
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

extension SettingsViewController: CategoriesVCProtocol {
    func categorySelected(category: String, purpose: Int) {
        print("called")
        tableData = [
            SettingsSctruct(title: "Account", description: appData.username == "" ? "Sing In": appData.username, segue: (appData.savedTransactions.count + appData.getCategories(key: "savedCategories").count) > 0 ? "toSavedData" : "toSingIn"),
            SettingsSctruct(title: "Categories", description: "All Categories (\(appData.getCategories().count))", segue: "settingsToCategories"),
        ]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
