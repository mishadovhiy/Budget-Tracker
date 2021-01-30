//
//  FirstLaunchViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 16.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class FirstLaunchViewController: UIViewController {

    
    @IBOutlet var cornerButtons: [UIButton]!
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        appData.internetPresend = nil
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 9
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius = 10
        contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 600, 0)
        for i in 0..<cornerButtons.count {
            cornerButtons[i].layer.masksToBounds = true
            cornerButtons[i].layer.cornerRadius = 6
        }
        
        //downloadFromDB()
        
        createFirstData()
        appData.defaults.set(false, forKey: "firstLaunch")
        
    }
    
    func createFirstData() {
        
        let transactions = [
            TransactionsStruct(value: "5000", category: "Freelance", date: "\(appData.filter.getToday(appData.filter.filterObjects.currentDate))", comment: ""),
            TransactionsStruct(value: "-350", category: "Food", date: "\(appData.filter.getToday(appData.filter.filterObjects.currentDate))", comment: "")
        ]
        let categories = [
            CategoriesStruct(name: "Food", purpose: K.expense),
            CategoriesStruct(name: "Work", purpose: K.income)
        ]
        appData.saveTransations(transactions)
        appData.saveCategories(categories)

        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.6) {
            self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLogIN" {
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .createAccount
        }
        if segue.identifier == "toCreate" {
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .singIn
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CreateAccPressed(_ sender: UIButton) {
        if (appData.internetPresend ?? false) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toSingIn", sender: self)
            }
        }
    }
    
    @IBAction func singInPressed(_ sender: UIButton) {
        if (appData.internetPresend ?? false) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toLogIn", sender: self)
            }
        }
        
    }
}
