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
        SettingsSctruct(title: "Sing Out", description: appData.username, segue: appData.username == "" ? "toSingIn" : "toDontGo"),
        SettingsSctruct(title: "Categories", description: "All Categories (\(appData.getCategories().count))", segue: "settingsToCategories"),
        SettingsSctruct(title: "Filter", description: selectedPeroud, segue: "settingsToFilter")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        
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
        performSegue(withIdentifier: tableData[indexPath.row].segue, sender: self)
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
