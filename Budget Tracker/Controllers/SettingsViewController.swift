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
        SettingsSctruct(title: "Account", description: appData.username == "" ? "Sing In": appData.username, segue: "toSingIn"),
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view != contentView{
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.23) {
                        self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 300, 0)
                    } completion: { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
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
        
        //view.isUserInteractionEnabled = true

        
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
        
        ckeckInternetTimer?.fire()
        appData.internetPresend = nil
        print("reloadAllfromDB")
        let load = LoadFromDB()
        load.Users(mainView: nil) { (loadedData) in
            appData.allUsers = loadedData
            self.ckeckInternetTimer?.invalidate()
        }

    }
    
    
    var toLoginPressed = false
    var ckeckInternetTimer: Timer? {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (a) in
            print("timer")

            if appData.internetPresend == false {
                print("timer: internetPresend == false")
                if self.toLoginPressed {
                    DispatchQueue.main.async {
                        self.message.showMessage(text: "No internet", type: .error)
                    }
                    
                    self.toLoginPressed = false
                }
                a.invalidate()
            } else {
                if appData.internetPresend == true {
                    print("timer: internetPresend == true")
                    if self.toLoginPressed {
                        self.toLoginPressed = false
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: self.tableData[0].segue, sender: self)
                        }
                    }
                    a.invalidate()
                }
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ckeckInternetTimer?.invalidate()
        if segue.identifier == "toSingIn" {
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .logIn
        }
    }

    @IBAction func closePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.23) {
                self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 300, 0)
            } completion: { (_) in
                self.dismiss(animated: true, completion: nil)
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
        
        if indexPath.row != 0 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.tableData[indexPath.row].segue, sender: self)
            }
            
        } else {
            self.toLoginPressed = true
            reloadAllfromDB()
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
