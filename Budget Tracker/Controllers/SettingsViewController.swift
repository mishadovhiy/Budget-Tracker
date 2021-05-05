//
//  SettingsViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
var categoriesDebtsCount = (0,0)
var safeArTopHeight: CGFloat = 0.0
protocol SettingsViewControllerProtocol {
    func closeSettings(sendSavedData:Bool, needFiltering: Bool)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var delegate: SettingsViewControllerProtocol?
    var tableData: [SettingsSctruct] = [
        SettingsSctruct(title: "Account", description: appData.username == "" ? "Sing In": appData.username, segue: ((UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String]] ?? []).count + (UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String]] ?? []).count + (UserDefaults.standard.value(forKey: K.Keys.localDebts) as? [[String]] ?? []).count) > 0 ? "toSavedData" : "toSingIn"),
        SettingsSctruct(title: "Categories", description: "\(categoriesDebtsCount.0)", segue: "settingsToCategories"),
        SettingsSctruct(title: "Debts", description: "\(categoriesDebtsCount.1)", segue: (appData.proVersion || appData.proTrial) ? "toDebts" : "toProVC")
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
        
        toSegue = false
        if UserDefaults.standard.value(forKey: "firstLaunchSettings") as? Bool ?? false == false {
            if appData.username == "" {
                DispatchQueue.main.async {
                    self.message.showMessage(text: "Create account to use app across all your devices", type: .succsess, windowHeight: 80, autoHide: false, bottomAppearence: false)
                }
            } else {
                UserDefaults.standard.setValue(true, forKey: "firstLaunchSettings")
            }
        }
        
        getdata()
        
       /* DispatchQueue.main.async {
            //self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
           // let window = UIApplication.shared.keyWindow ?? UIWindow()
           // window.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
           // window.alpha = 0.2
            
        }*/

    }
    
    
    

    
    func getdata() {
        categoriesDebtsCount = (0,0)
        let allCategories = UserDefaults.standard.value(forKey: "categoriesData") as? [[String]] ?? []//Array(appData.getCategories())
        /*      var debts:[CategoriesStruct] = []
        var categpries:[CategoriesStruct] = []
        for i in 0..<allCategories.count {
            if allCategories[i].debt {
                debts.append(allCategories[i])
            } else {
                categpries.append(allCategories[i])
            }
        }*/
        let allDebts = UserDefaults.standard.value(forKey: "allDebts") as? [[String]] ?? [] //Array(appData.getDebts())
        categoriesDebtsCount = (allCategories.count, allDebts.count)//debts.count)
        let unsavedCat = (UserDefaults.standard.value(forKey: K.Keys.localCategories) as? [[String]] ?? []).count
        let unsavedTrans = (UserDefaults.standard.value(forKey: K.Keys.localTrancations) as? [[String]] ?? []).count
        let unsavedDebts = (UserDefaults.standard.value(forKey: K.Keys.localDebts) as? [[String]] ?? []).count
        let data = [
            SettingsSctruct(title: "Account", description: appData.username == "" ? "Sing In": appData.username, segue: (unsavedCat + unsavedTrans + unsavedDebts) > 0 ? "toSavedData" : "toSingIn"),
            SettingsSctruct(title: "Categories", description: "\(categoriesDebtsCount.0)", segue: "settingsToCategories"),
            SettingsSctruct(title: "Debts", description: "\(categoriesDebtsCount.1)", segue: (appData.proVersion || appData.proTrial) ? "toDebts" : "toProVC")
        ]
        tableData = data
        if appData.proTrial {
            let trial = 7 - (UserDefaults.standard.value(forKey: "trialToExpireDays") as? Int ?? 0)
            tableData.append(SettingsSctruct(title: "Trial expires in \(trial) day\(trial == 1 ? "" : "s")", description: "", segue: "toProVC", textInCenter: true))
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("setting touches")
        if let touch = touches.first {
            if touch.view != contentView {
                closeWithAnimation()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(tableView.contentOffset, "settingsVC contentOffset")
        if appData.proVersion {
            if tableView.contentOffset.y < -40.0 {
                self.getdata()
                self.tableData.append(SettingsSctruct(title: "Pro Version", description: "Purchased", segue: "toProVC"))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
    }

    var sendLocalDataPressed = false
    
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            //self.helperNavView.removeFromSuperview()


        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        //navigationController?.setNavigationBarHidden(false, animated: true)
       /* DispatchQueue.main.async {
            safeArTopHeight = self.view.safeAreaInsets.top
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            self.helperNavView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: safeArTopHeight)//self.navigationController?.navigationBar.frame.height ?? 1)
            window.addSubview(self.helperNavView)
            /*UIView.animate(withDuration: 0.3) {
                self.helperNavView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: height)
            }*/
 
        }*/
        if !toSegue {
            //fatalError()
            print("transactionAddedtransactionAddedtransactionAdded", transactionAdded)
            let needFiltering = transactionAdded
            delegate?.closeSettings(sendSavedData: sendLocalDataPressed, needFiltering: needFiltering)
            transactionAdded = false
        } else {
            
        }
        DispatchQueue.main.async {
            self.message.hideMessage()
        }
    }
    
    func updateUI() {
        tableView.delegate = self
        tableView.dataSource = self
       // contentView.layer.masksToBounds = true
        DispatchQueue.main.async {
           // self.view.backgroundColor = .red
            self.contentView.layer.cornerRadius = 9
            self.contentView.layer.shadowColor = UIColor.black.cgColor
            self.contentView.layer.shadowOpacity = 1
            self.contentView.layer.shadowOffset = .zero
            self.contentView.layer.shadowRadius = 10
        }
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
       /* let wasBack = self.view.backgroundColor
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
        }*/
    }

    
    var toSegue = false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        //navigationController?.setNavigationBarHidden(false, animated: true)
        toSegue = true
        let messageText = "Check data from previous account before logging out"
        
        switch segue.identifier {
        case "toProVC":
            let vc = segue.destination as! BuyProVC
            vc.fromSettings = true
        case "toSingIn":
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .singIn
            vc.fromSettings = true
        case "toSavedData":
            let vc = segue.destination as! UnsendedDataVC
            vc.delegate = self
            vc.messageText = messageText
        case "settingsToCategories":
            let vc = segue.destination as! CategoriesVC
          //  let vc = nav.topViewController as! CategoriesVC
          //  vc.delegate = self
            vc.fromSettings = true
        case "toDebts":
            print("")
            let vc = segue.destination as! DebtsVC
          //  let vc = nav.topViewController as! DebtsVC
      //      vc.delegate = self
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
            self.dismiss(animated: true, completion: nil)
        }
        
      /*animate in top  DispatchQueue.main.async {
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
        }*/
    }
    
    
    
}


//table view

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsVCCell", for: indexPath) as! SettingsVCCell
        cell.proView.alpha = 0
        cell.titleLbel.text = tableData[indexPath.row].title
        cell.descriptionLabel.text = tableData[indexPath.row].description
        cell.proView.layer.cornerRadius = 4
        if indexPath.row == 2 {
            cell.proView.alpha = (appData.proVersion || appData.proTrial) ? 0 : 1
        }

        cell.accessoryType = tableData[indexPath.row].textInCenter ? .none : .disclosureIndicator
        cell.titleLbel.textAlignment = tableData[indexPath.row].textInCenter ? .center : .left
        cell.titleLbel.textColor = tableData[indexPath.row].textInCenter ? K.Colors.balanceT : UIColor(named: "darkTableColor")
        //med 17
        cell.titleLbel.font = .systemFont(ofSize: tableData[indexPath.row].textInCenter ? 13 : 17, weight: .medium)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.tableData[indexPath.row].segue != "" {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.tableData[indexPath.row].segue, sender: self)
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
    var textInCenter: Bool = false
}


// cell

class SettingsVCCell: UITableViewCell {
    
    @IBOutlet weak var titleLbel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var proView: UIView!
}

extension SettingsViewController: UnsendedDataVCProtocol {
    func quiteUnsendedData(deletePressed: Bool, sendPressed: Bool) {
        if !deletePressed && !sendPressed {
            delegate?.closeSettings(sendSavedData: false, needFiltering: false)
        } else {
            if deletePressed {
                print("seletePressed")
                appData.saveTransations([], key: K.Keys.localTrancations)
                appData.saveCategories([], key: K.Keys.localCategories)
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

/*extension SettingsViewController: CategoriesVCProtocol {
    func categorySelected(category: String, purpose: Int, fromDebts: Bool, amount: Int) {
        getdata()
    }
}

extension SettingsViewController: DebtsVCProtocol {
    func catDebtSelected(name: String, amount: Int) {
        getdata()
    }
}*/

