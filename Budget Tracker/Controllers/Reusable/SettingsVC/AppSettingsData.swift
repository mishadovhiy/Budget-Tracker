//
//  LoginSettingsData.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit



class AppSettingsData {
    
    private var specialData:[SettingsVC.TableData]? = nil
    let vc:SettingsVC
    init(vc:SettingsVC, data:[SettingsVC.TableData]? = nil) {
        self.vc = vc
        self.specialData = data
    }
    
    func getData() -> [SettingsVC.TableData] {
        if let data = specialData {
            return data
        } else {
            let data = [
                SettingsVC.TableData(sectionTitle: "Appearance".localize, cells: appearenceSection()),
                SettingsVC.TableData(sectionTitle: "Security".localize, cells: privacySection()),
                SettingsVC.TableData(sectionTitle: "", cells: otherSection()),
                SettingsVC.TableData(sectionTitle: "", cells: urlSection())
            ]
            return data
        }
        
    }
    
    
     
    
    
    
    func appearenceSection() -> [Any] {
        let colorCell = SettingsVC.StandartCell(title: "Primary color".localize, description: "", colorNamed:  AppData.linkColor, pro: nil, action: {//!appData.proEnabeled ? 3 : nil
            DispatchQueue.main.async {
                self.vc.performSegue(withIdentifier: "toColors", sender: self.vc)
            }
        })

        
        let languageCell = SettingsVC.StandartCell(title: "Language".localize, description: AppLocalization.launchedLocalization, action: {
            let langs = ["eng", "ua"]
            let colorSetted: (Int) -> () = { (newValue) in
                AppLocalization.launchedLocalization = langs[newValue]
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    AppLocalization.udLocalization = langs[newValue]
                    DispatchQueue.main.async {
                        self.vc.loadData()
                    }
                }
            }
            
            self.vc.toChooseIn(data: langs, title:"Language".localize , selectedAction: colorSetted)
        })
        
        

        
        return [colorCell,languageCell]
    }
    
    func privacySection() -> [Any] {
        print("privacySection")
        let passcodeOn = UserSettings.Security.password != ""

        let passcodeCell:SettingsVC.TriggerCell = SettingsVC.TriggerCell(title: "Passcode".localize, isOn: passcodeOn, pro: nil, action: { (newValue) in//!appData.proEnabeled ? 2 : nil
            
            self.passcodeSitched(isON: newValue)
        })
        
        if passcodeOn {

            let changePasscodeCell = SettingsVC.StandartCell(title: "Change passcode".localize, showIndicator: false, action: {
                
                self.getUserPasscode {
                    self.createPassword { newValue in
                        DispatchQueue(label: "db", qos: .userInitiated).async {
                            UserSettings.Security.password = newValue
                            DispatchQueue.main.async {
                                self.vc.loadData()
                            }
                        }
                    }
                }
            })
            
            
            let timeoutText = "Passcode timeout".localize

            let passcodeTimeOut = SettingsVC.StandartCell(title: timeoutText, description: UserSettings.Security.timeOut + " " + "seconds".localize, action: {
                
                let timoutOptions = ["15", "30", "60", "90", "120", "180", "300", "500"]
                let vcTitle = timeoutText
                
                self.vc.toChooseIn(data: timoutOptions, title: vcTitle) { newValue in
                    DispatchQueue(label: "db", qos: .userInitiated).async {
                        UserSettings.Security.timeOut = timoutOptions[newValue]
                        DispatchQueue.main.async {
                            self.vc.loadData()
                        }
                    }
                }
            })
            
            
            return [passcodeCell, changePasscodeCell, passcodeTimeOut]
        } else {
            return [passcodeCell]
        }
        
    }
    
    
    func urlSection() -> [Any] {
        let supportCell = SettingsVC.StandartCell(title: "Write to App Support".localize, action: {
            DispatchQueue.main.async {
                self.vc.performSegue(withIdentifier: "toSupport", sender: self.vc)
            }
        })
        
        let devSupport = SettingsVC.StandartCell(title: "App website".localize, action: {
            let urlString = "https://mishadovhiy.com/#budget"
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
                    WebViewVC.shared.presentScreen(in: nav, data: .init(url: "https://mishadovhiy.com/apps/previews/budget.html", key: "Privacy".localize), screenTitle: pprivacyTitle)
                }
            }
            
        })
        let appUrl:SettingsVC.StandartCell = .init(title: "App store", action: {
            guard let url:URL = .init(string: Keys.appstoreURL) else { return}
            UIApplication.shared.open(url)
        
        })
        return [supportCell, privacy, devSupport, appUrl]
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
        
        
        
        
        
        let appShortcodes = SettingsVC.StandartCell(title: "Application ShortCode Actions", action: {
            let ignoring = DataBase().viewControllers.ignoredActionTypes
            let cells:[SettingsVC.TriggerCell] = AppDelegate.ShortCodeItem.allCases.compactMap({ item in
                return .init(title: item.item.title, isOn: !ignoring.contains(item.rawValue), action: { isOn in
                    DispatchQueue(label: "db", qos: .userInitiated).async {
                        if isOn {
                            DataBase().viewControllers.ignoredActionTypes.removeAll(where: {$0.contains(item.rawValue)})
                        } else {
                            DataBase().viewControllers.ignoredActionTypes.append(item.rawValue)
                        }
                        DispatchQueue.main.async {
                            AppDelegate.shared?.setQuickActions()
                        }
                    }
                })
            })
            
            self.vc.navigationController!.pushViewController(SettingsVC.configure(additionalData: [.init(sectionTitle: "Quick homescreen actions", cells: cells)]), animated: true)
            
        })
        
        
        
        
        let testPro:SettingsVC.TriggerCell = SettingsVC.TriggerCell(title: "forceNotPro", isOn: AppDelegate.shared?.appData.forceNotPro ?? false, pro: nil, action: { (newValue) in
            AppDelegate.shared?.appData.forceNotPro = newValue ? true : nil
        })

        
        var cells = [otherCell, appShortcodes]
        if AppDelegate.shared?.appData.devMode ?? false {
            //cells.append
        }
        return cells

    }
}






extension AppSettingsData {

    func passcodeSitched(isON:Bool) {
        if !isON {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                if UserSettings.Security.password != "" {
                    DispatchQueue.main.async {
                        self.getUserPasscode {
                            DispatchQueue(label: "db", qos: .userInitiated).async {
                                UserSettings.Security.password = ""
                                DispatchQueue.main.async {
                                    self.vc.loadData()
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.vc.loadData()
                }
            }
            
            
        } else {
            self.vc.loadData()
            self.createPassword { newValue in
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    UserSettings.Security.password = newValue
                    DispatchQueue.main.async {
                        self.vc.loadData()
                    }
                }
            }
            
        }
    }
    
    func getUserPasscode(completion:@escaping() -> ()) {

        AppDelegate.shared!.presentLock(passcode: true, passcodeVerified: completion)
    }
    
    
    func createPassword(completion: @escaping(String) -> ()) {
        
        let nextAction:(String) -> () = { (newValue) in
            let repeateAction:(String) -> () = { (repeatedPascode) in
                if newValue == repeatedPascode {
                    AppDelegate.shared!.newMessage.show(title: "Passcode has been setted".localize, type: .succsess)
                    self.vc.toEnterValue(data: nil)
                    completion(newValue)
                } else {
                    AppDelegate.shared!.newMessage.show(title: "Passcodes don't match".localize, type: .error)
                }
            }
            let passcodeSecondEntered = EnterValueVC.EnterValueVCScreenData(taskName: "Create".localize + " " + "passcode".localize, title: "Repeat".localize + " " + "passcode".localize, placeHolder: "Password".localize, nextAction: repeateAction, screenType: .code)
            self.vc.toEnterValue(data: passcodeSecondEntered)
            
        }
        
        let screenData = EnterValueVC.EnterValueVCScreenData(taskName: ("Create".localize + " " + "passcode".localize), title: ("Enter".localize + " " + "passcode".localize), placeHolder: "Passcode".localize, nextAction: nextAction, screenType: .code)
        self.vc.toEnterValue(data: screenData)
    }
}

