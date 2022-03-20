//
//  LoginSettingsData.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit



class AppSettingsData {
    
    let vc:SettingsVC
    init(vc:SettingsVC) {
        self.vc = vc
    }
    
    func getData() -> [SettingsVC.TableData] {
        let data = [
            SettingsVC.TableData(sectionTitle: "Appearance".localize, cells: appearenceSection()),
            SettingsVC.TableData(sectionTitle: "Security".localize, cells: privacySection()),
            SettingsVC.TableData(sectionTitle: "", cells: otherSection())
        ]
        return data
    }
    
    
     
    
    
    
    func appearenceSection() -> [Any] {
        let colorCell = SettingsVC.StandartCell(title: "Primary color".localize, description: "", colorNamed:  AppData.linkColor, action: {
            DispatchQueue.main.async {
                self.vc.performSegue(withIdentifier: "toColors", sender: self.vc)
            }
        })

        
        let languageCell = SettingsVC.StandartCell(title: "Language".localize, description: AppLocalization.launchedLocalization, action: {
            let langs = ["eng", "ua"]
            let colorSetted: (Int) -> () = { (newValue) in
                AppLocalization.launchedLocalization = langs[newValue]
                AppLocalization.udLocalization = langs[newValue]
                self.vc.loadData()
            }
            
            self.vc.toChooseIn(data: langs, title:"Set".localize + " " + "Language".localize , selectedAction: colorSetted)
        })
        
        

        
        return [colorCell,languageCell]
    }
    
    func privacySection() -> [Any] {
        print("privacySection")
        let passcodeOn = UserSettings.Security.password != ""

        let passcodeCell:SettingsVC.TriggerCell = SettingsVC.TriggerCell(title: "Passcode".localize, isOn: passcodeOn, action: { (newValue) in
            
            self.passcodeSitched(isON: newValue)
        })
        
        if passcodeOn {

            let changePasscodeCell = SettingsVC.StandartCell(title: "Change passcode".localize, action: {
                
                self.getUserPasscode {
                    self.createPassword { newValue in
                        UserSettings.Security.password = newValue
                        self.vc.loadData()
                    }
                }
            })
            
            
            let timeoutText = "Passcode timeout".localize

            let passcodeTimeOut = SettingsVC.StandartCell(title: timeoutText, description: UserSettings.Security.timeOut + " " + "seconds".localize, action: {
                
                let timoutOptions = ["5", "15", "30", "60", "90", "120", "180", "300", "500"]
                let vcTitle = "Set".localize + " " + timeoutText
                
                self.vc.toChooseIn(data: timoutOptions, title: vcTitle) { newValue in
                    
                    UserSettings.Security.timeOut = timoutOptions[newValue]
                    self.vc.loadData()
                }
            })
            
            
            return [passcodeCell, changePasscodeCell, passcodeTimeOut]
        } else {
            return [passcodeCell]
        }
        
    }
    
    
    func otherSection() -> [Any] {
        
        let otherCell = SettingsVC.StandartCell(title: "Access settings".localize, description: "", action: {
            DispatchQueue.main.async {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:]) { _ in
                        
                    }
                }
            }
        })
        
        
        let supportCell = SettingsVC.StandartCell(title: "Support".localize, action: {
            DispatchQueue.main.async {
                self.vc.performSegue(withIdentifier: "toSupport", sender: self.vc)
            }
        })
        
        let devSupport = SettingsVC.StandartCell(title: "App website".localize, action: {
            let urlString = "https://dovhiy.com/#budget"
            if let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:]) { _ in
                        
                    }
                }
            }
        
        })
        
        let pprivacyTitle = "Privacy policy".localize
        let privacy = SettingsVC.StandartCell(title: pprivacyTitle, action: {
            DispatchQueue.main.async {
                if let nav = self.vc.navigationController {
                    WebViewVC.shared.presentScreen(in: nav, data: .init(url: "https://dovhiy.com/apps/previews/budget.html", key: "Privacy"), screenTitle: pprivacyTitle)
                }
            }
        })
        
        return [otherCell, supportCell, devSupport, privacy]
    }
}






extension AppSettingsData {

    func passcodeSitched(isON:Bool) {
        if !isON {
            if UserSettings.Security.password != "" {
                self.getUserPasscode {
                    UserSettings.Security.password = ""
                    self.vc.loadData()
                }
            }
            self.vc.loadData()
            
        } else {
            self.vc.loadData()
            self.createPassword { newValue in
                UserSettings.Security.password = newValue
                self.vc.loadData()
            }
            
        }
    }
    
    func getUserPasscode(completion:@escaping() -> ()) {
        AppDelegate.shared.passcodeLock.present(passcodeEntered: completion)
        AppDelegate.shared.passcodeLock.passcodeLock()
    }
    
    
    func createPassword(completion: @escaping(String) -> ()) {
        
        let nextAction:(String) -> () = { (newValue) in
            let repeateAction:(String) -> () = { (repeatedPascode) in
                if newValue == repeatedPascode {
                    AppDelegate.shared.newMessage.show(title: "Passcode has been setted".localize, type: .succsess)
                    self.vc.toEnterValue(data: nil)
                    completion(newValue)
                } else {
                    AppDelegate.shared.newMessage.show(title: "Passcodes don't match".localize, type: .error)
                }
            }
            let passcodeSecondEntered = EnterValueVC.EnterValueVCScreenData(taskName: "Create".localize + " " + "passcode".localize, title: "Repeat".localize + " " + "passcode".localize, placeHolder: "Password".localize, nextAction: repeateAction, screenType: .code)
            self.vc.toEnterValue(data: passcodeSecondEntered)
            
        }
        
        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: ("Create".localize + " " + "passcode".localize), title: ("Enter".localize + " " + "passcode".localize), placeHolder: "Passcode".localize, nextAction: nextAction, screenType: .code)
        self.vc.toEnterValue(data: screenData)
    }
}
