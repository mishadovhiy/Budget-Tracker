//
//  SettingsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 10.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit


// перенести сюда суппорт

class SettingsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var ai: IndicatorView = {
        let newView = AppDelegate.shared?.ai ?? IndicatorView.instanceFromNib() as! IndicatorView
        return newView
    }()
    
    var tableData:[TableData] {
        
        
        return [
            TableData(sectionTitle: "Appearence", cells: appearenceSection()),
            TableData(sectionTitle: "Privacy", cells: privacySection()),
            TableData(sectionTitle: "", cells: otherSection())
        ]
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


        title = "Settings"
        tableView.delegate = self
        tableView.dataSource = self
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
}


extension SettingsVC: IconsVCDelegate {
    func selected(img: String, color: String) {
        AppData.linkColor = color
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
            StandartCell(title: "Primary color", description: AppData.linkColor, action: colorAction),
            StandartCell(title: "Language", action: languageAction)
        ]
    }
    
    func privacySection() -> [Any] {
        print("privacySection")
        let passcodeOn = UserDefaults.standard.value(forKey: "PasscodeON") as? Bool ?? false
        
        return [
            TriggerCell(title: "Passcode", isOn: passcodeOn, action: { isON in
                //if on - go to create passcode vc
                //reapre passcode
                //if settend - set switch on else - -asscode on = off and reload data
                print("passcode isON:", isON)
                UserDefaults.standard.setValue(isON, forKey: "PasscodeON")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        ]
    }
    
    
    func otherSection() -> [Any] {
        return [
            StandartCell(title: "Support", action: {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toSupport", sender: self)
                }
            })
        ]
    }
}






class StandartSettingsCell: UITableViewCell {
    
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
