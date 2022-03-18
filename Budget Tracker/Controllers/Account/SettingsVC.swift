//
//  SettingsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 10.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit


// перенести сюда суппорт

class SettingsVC: SuperViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableData:[TableData]  = []
    
    func loadData() {
        tableData = [
            TableData(sectionTitle: "Appearance".localize, cells: appearenceSection()),
            TableData(sectionTitle: "Security".localize, cells: privacySection()),
            TableData(sectionTitle: "", cells: otherSection())
        ]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.1
        tableView.layer.shadowOffset = .zero
        tableView.layer.shadowRadius = 12
        tableView.layer.cornerRadius = 9
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        title = "Settings".localize
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toColors":
            let vc = segue.destination as! IconsVC
            vc.delegate = self
            vc.selectedColorName = AppData.linkColor
            vc.screenType = .colorsOnly
        default:
            break
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func toEnterValue(data:EnterValueVC.EnterValueVCScreenData?) {
        if let data = data {
            DispatchQueue.main.async {
                if let nav = self.navigationController {
                    EnterValueVC.shared.presentScreen(in: nav, with: data, defaultValue:nil)
                    
                }
            }
        } else {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController(self, animated: true)
            }
        }
    }
}


extension SettingsVC: IconsVCDelegate {
    func selected(img: String, color: String) {
        AppData.linkColor = color
        self.loadData()
    }
    
    
}




extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let triggerData = tableData[indexPath.section].cells[indexPath.row] as? TriggerCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TriggerSettingsCell", for: indexPath) as! TriggerSettingsCell
            cell.nameLabel.text = triggerData.title
            cell.switchedAction = triggerData.action
            cell.valueSwitcher.isOn = triggerData.isOn
            return cell
        } else {
            if let standartData = tableData[indexPath.section].cells[indexPath.row] as? StandartCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StandartSettingsCell", for: indexPath) as! StandartSettingsCell
                cell.nameLabel.text = standartData.title + (standartData.description == "" ? "" : (": " + standartData.description))
                cell.colorView.isHidden = standartData.colorNamed == "" ? true : false
                if standartData.colorNamed != "" {
                    cell.colorView.backgroundColor = colorNamed(standartData.colorNamed)
                }
                
                return cell
            } else {
                return UITableViewCell()
            }
        }
        

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let standartData = tableData[indexPath.section].cells[indexPath.row] as? StandartCell {
            standartData.action()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension SettingsVC {
    struct TableData {
        let sectionTitle:String
        let cells: [Any]
    }

    struct StandartCell {
        let title: String
        
        var description:String = ""
        var colorNamed:String = ""
        let action: () -> ()
    }
    
    struct TriggerCell {
        let title: String
        let isOn: Bool
        let action: (Bool) -> ()
    }
}








extension SettingsVC {

    func appearenceSection() -> [Any] {
        let colorAction = {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toColors", sender: self)
            }
        }
        
        let languageAction = {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { _ in
                
            }
        }
        
        return [
            StandartCell(title: "Primary color".localize, description: "", colorNamed:  AppData.linkColor, action: colorAction),
            StandartCell(title: "Language".localize, action: languageAction)
        ]
    }
    
    func privacySection() -> [Any] {
        print("privacySection")
        let passcodeOn = UserSettings.Security.password != ""
        let passcodeSwitched:(Bool) -> () = { (newValue) in
            self.passcodeSitched(isON: newValue)
        }
        let passcodeCell:TriggerCell = TriggerCell(title: "Passcode".localize, isOn: passcodeOn, action: passcodeSwitched)
        if passcodeOn {
            let changePasscodeAction:() -> () = {
                self.getUserPasscode {
                    self.createPassword { newValue in
                        UserSettings.Security.password = newValue
                        self.loadData()
                    }
                }
            }
            let changePasscodeCell = StandartCell(title: "Change passcode".localize, action: changePasscodeAction)
            return [passcodeCell, changePasscodeCell]
        } else {
            return [passcodeCell]
        }
        
    }
    
    
    func otherSection() -> [Any] {
        return [
            StandartCell(title: "Support".localize, action: {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toSupport", sender: self)
                }
            })
        ]
    }
}


extension SettingsVC {
    //create password
    
    func passcodeSitched(isON:Bool) {
        if !isON {
            if UserSettings.Security.password != "" {
                self.getUserPasscode {
                    UserSettings.Security.password = ""
                    self.loadData()
                }
            }
            loadData()
            
        } else {
            loadData()
            self.createPassword { newValue in
                UserSettings.Security.password = newValue
                self.loadData()
            }
            
        }
    }
    
    func getUserPasscode(completion:@escaping() -> ()) {
        AppDelegate.shared?.passcodeLock.present(passcodeEntered: completion)
        AppDelegate.shared?.passcodeLock.passcodeLock()
    }
    
    
    func createPassword(completion: @escaping(String) -> ()) {
        
        let nextAction:(String) -> () = { (newValue) in
            let repeateAction:(String) -> () = { (repeatedPascode) in
                if newValue == repeatedPascode {
                    AppDelegate.shared?.newMessage.show(title: "Passcode has been setted".localize, type: .succsess)
                    self.toEnterValue(data: nil)
                    completion(newValue)
                } else {
                    AppDelegate.shared?.newMessage.show(title: "Passcodes don't match".localize, type: .error)
                }
            }
            let passcodeSecondEntered = EnterValueVC.EnterValueVCScreenData(taskName: "Create".localize + " " + "passcode".localize, title: "Repeat".localize + " " + "passcode".localize, placeHolder: "Password".localize, nextAction: repeateAction, screenType: .code)
            self.toEnterValue(data: passcodeSecondEntered)
            
        }
        
        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: "Create".localize + " " + "passcode".localize, title: "Create".localize + " " + "passcode", placeHolder: "Passcode", nextAction: nextAction, screenType: .code)
        toEnterValue(data: screenData)
    }
}






class StandartSettingsCell: UITableViewCell {
    
    @IBOutlet weak var colorView: View!
    @IBOutlet weak var nameLabel: UILabel!
}

class TriggerSettingsCell: UITableViewCell {
    
    var switchedAction:((Bool) -> ())?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBAction func switchChanged(_ sender: UISwitch) {
        if let isON = switchedAction {
            DispatchQueue.main.async {
                isON(sender.isOn)
            }
        }
    }
    @IBOutlet weak var valueSwitcher: UISwitch!
}
