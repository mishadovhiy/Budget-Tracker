//
//  AppData.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import Foundation


class AppData {
    let db = DataBase()
    var filter:Filter {
        get {
            let dict = db.db["Filter"] as? [String : Any] ?? [:]
            return .init(dict: dict)
        }
        set {
            db.db.updateValue(newValue.dict, forKey: "Filter")
        }
    }
    
    var expenseLabelPressed = true//make only in vc
    var sendSavedData = false
    var needDownloadOnMainAppeare = false
    var needFullReload = false
    static var categoriesHolder:[NewCategories]?
    
    static var linkColor: String {
        set {
            DataBase().db.updateValue(newValue, forKey: "SelectedTintColor")
            let color = colorNamed(newValue)
            DispatchQueue.main.async {
                let window = AppDelegate.shared?.window ?? UIWindow()
                window.tintColor = color
            }
        }
        get {
            return DataBase().db["SelectedTintColor"] as? String ?? "Yellow"
        }
    }
    
    var safeArea: (CGFloat, CGFloat) = (0.0, 0.0)//0-bt  1-top

    var resultSafeArea: (CGFloat, CGFloat) {
        let btn = safeArea.0 + (AppDelegate.shared?.banner.size ?? 0)
        return (btn, safeArea.1)
    }
    
    let lastSelected = LastSelected()

    var forceNotPro: Bool? {
        get{

            return db.db["forcePro"] as? Bool
        }
        set(value){
            db.db.updateValue(value ?? false, forKey: "forcePro")
        }
    }
    
    var proEnabeled:Bool {
        let result = appData.proTrial || appData.proVersion
        return devMode ? !(forceNotPro ?? !result) : result
    }
    
    var proVersion: Bool {
        get{
            let result = !purchasedOnThisDevice ? (db.db["proVersion"] as? Bool ?? false) : purchasedOnThisDevice
            return result
        }
        set(value){
            db.db.updateValue(value, forKey: "proVersion")
        }
    }
    
    var purchasedOnThisDevice: Bool {
        get{
            return db.db["purchasedOnThisDevice"] as? Bool ?? false
        }
        set(value){
            db.db.updateValue(value, forKey: "purchasedOnThisDevice")
        }
    }
    
    var trialDate: String {
        get{
            return db.db["trialDate"] as? String ?? ""
        }
        set(value){
            db.db.updateValue(value, forKey: "trialDate")
        }
    }
    
    var proTrial: Bool {
        get{
            return db.db["proTrial"] as? Bool ?? false
        }
        set(value){
            db.db.updateValue(value, forKey: "proTrial")
        }
    }
    
    
    
    
    
    

    
    
    func emailFromLoadedDataPurch(_ data:[[String]]) -> String? {
        //get user email
        //loadedData.append([name, email, password, registrationDate, pro, trialDate])
        if !appData.purchasedOnThisDevice {
            let currnt = appData.username
            var emailOptional:String?
            for i in 0..<data.count {
                if data[i][0] == currnt {
                    emailOptional = data[i][1]
                }
            }
            if let email = emailOptional {
                var dbPurch = false
                for i in 0..<data.count {
                    if !dbPurch {
                        if data[i][1] == email {
                            if data[i][4] == "1" {
                                dbPurch = true
                                break
                            }
                        }
                    }
                }
                appData.proVersion = dbPurch
                print("dbPurch:", dbPurch)
                return email
            }
            
        }
        return nil
    }
    
    
    var username: String {
        get{
            if let user = db.db["username"] as? String {
                return user
            } else {
                if let oldDB = UserDefaults.standard.value(forKey: "username") as? String {
                    db.db.updateValue(oldDB, forKey: "username")
                    return oldDB
                } else {
                    return ""
                }
            }
        }
        set(value){
            print("new username setted - \(value)")
            db.db.updateValue(value, forKey: "username")
        }
    }
    


    var password: String {
        get{
            if let user = db.db["password"] as? String {
                return user
            } else {
                if let oldDB = UserDefaults.standard.value(forKey: "password") as? String {
                    db.db.updateValue(oldDB, forKey: "password")
                    return oldDB
                } else {
                    return ""
                }
            }
        }
        set(value){
            print("new password setted - \(value)")
            db.db.updateValue(value, forKey: "password")
        }
    }
    
    var userEmailHolder: String {
        get{
            if let user = db.db["userEmailHolder"] as? String {
                return user
            } else {
                if let oldDB = UserDefaults.standard.value(forKey: "userEmailHolder") as? String {
                    db.db.updateValue(oldDB, forKey: "userEmailHolder")
                    return oldDB
                } else {
                    return ""
                }
            }
        }
        set(value){
            print("new password setted - \(value)")
            db.db.updateValue(value, forKey: "userEmailHolder")
        }
    }
    
    var devMode:Bool {
        return userEmailHolder.contains("dovhiy.com")
    }
    


    var unsendedData:[[String: [String:Any]]] {
        //0 - type (delete transaction)
        //1 - toDataString
        get {
            return db.db[ "unsendedData"] as? [[String: [String:Any]]] ?? []
        }
        set(value){
            db.db.updateValue(value, forKey: "unsendedData")
        }
    }

    var fromLoginVCMessage = ""
    
    static func makeTwo(int: Int?) -> String {
        if let n = int {
            return n <= 9 ? "0\(n)" : "\(n)"
        } else {
            return "00"
        }
    }
    


    
    

    


    let categoryColors = [
        "BlueColor", "BlueColor2", "BlueColor3", "GreenColor", "GreenColor-2", "yellowColor2", "OrangeColor", "yellowColor", "OrangeColor-1", "pinkColor2", "PinkColor-1", "PinkColor", "RedColor"
    ]
    
    let screenColors = [
        "BlueColor", "BlueColor2", "BlueColor3", "GreenColor", "GreenColor-2", "yellowColor2", "OrangeColor", "yellowColor", "OrangeColor-1", "pinkColor2", "PinkColor-1", "PinkColor", "RedColor"
    ]
    
    var randomColorName: String {
        return DataBase().db["SelectedTintColor"] as? String ?? "yellowColor"
    }
    
    func stringDate(_ sender: UIDatePicker) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: sender.date)
    }
    
    
    


    
    
    var objects = Objects()
    struct Objects {
        let datePicker = UIDatePicker()
    }

    
    var filterObjects = FilterObjects()
    struct FilterObjects {
        
        let currentDate = UIDatePicker()
        
    }
    
    
    func createFirstData(completion: @escaping () -> ()) {
        let thisMonth = filter.getToday(dateformatter: "01.MM.yyyy")
        let thisYear = filter.getToday(dateformatter: "01.01.yyyy")
        let today = filter.getToday(dateformatter: "dd.MM.yyyy")
        let transactions:[TransactionsStruct] = [
            .init(value: "12500", categoryID: "1", date: thisMonth, comment: ""),
            .init(value: "-2200", categoryID: "4", date: thisMonth, comment: ""),
            .init(value: "-2200", categoryID: "4", date: thisYear, comment: ""),
            .init(value: "-5800", categoryID: "12", date: thisMonth, comment: "Rent"),
            .init(value: "-670", categoryID: "18", date: thisMonth, comment: ""),
            .init(value: "-30", categoryID: "16", date: today, comment: ""),
            .init(value: "-1200", categoryID: "17", date: today, comment: ""),
            .init(value: "-1200", categoryID: "3", date: thisYear, comment: ""),
            .init(value: "10780", categoryID: "1", date: thisYear, comment: "")
        ]
        let categories:[NewCategories] = [
            .init(id: 1, name: "Work", icon: "briefcase.fill", color: "BlueColor", purpose: .income),
            .init(id: 4, name: "TV", icon: "tv.inset.filled", color: "", purpose: .debt, amountToPay: 21000),
            .init(id: 3, name: "Cindy", icon: "peacesign", color: "PinkColor-1", purpose: .debt),
            .init(id: 18, name: "Food", icon: "takeoutbag.and.cup.and.straw.fill", color: "pinkColor2", purpose: .expense),
            .init(id: 12, name: "Bills", icon: "scroll.fill", color: "yellowColor2", purpose: .expense),
            .init(id: 17, name: "Restaurants", icon: "fork.knife", color: "PinkColor-1", purpose: .expense),
            .init(id: 15, name: "Taxi", icon: "car.fill", color: "OrangeColor", purpose: .expense),
            .init(id: 16, name: "Public transport", icon: "bus", color: "BlueColor3", purpose: .expense),
            
        ]
        
        db.categories = categories
        db.transactions = transactions
        completion()
    }
    
    func returnMonth(_ month: Int) -> String {
        let monthes = [
            1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun",
            7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"
        ]
        return monthes[month] ?? "Jan"
    }
    

    


    static func iconSystemNamed(_ name: String?, errorName:String = "photo.fill") -> UIImage {
        let def = errorName
        let namee = name ?? def
        let resultName = namee != "" ? namee : def
        if #available(iOS 13.0, *) {
            if let image = UIImage(systemName: resultName) ?? UIImage(named: resultName) {
                return image
            } else {
                print("Not found image named: ", name ?? "-")
                return UIImage(systemName: def) ?? (UIImage(named: def)!)
            }
        } else {
            return UIImage(named: "warning")!
        } 
        
    }
    
    
    static func iconNamed(_ name: String?) -> UIImage {
        let def = "photo.fill"
        let namee = name ?? def
        let resultName = namee != "" ? namee : def
        if #available(iOS 13.0, *) {
            return UIImage(named: resultName) ?? UIImage(named: def)!
        } else {
            return UIImage(named: "warning")!
        }
        
    }

    static func colorNamed(_ name: String?) -> UIColor {
        let defaultCo = K.Colors.link
        if name ?? "" != "" {
            return UIColor(named: name ?? "") ?? defaultCo
        } else {
            return defaultCo
        }
    }
    
    
    
    static func makeTwo(n: Int?) -> String {
        if let num = n {
            if num < 10 {
                return "0\(num)"
            } else {
                return "\(num)"
            }
        } else {
            return "00"
        }
        
    }
    
}



extension AppData {
    func presentBuyProVC(selectedProduct:Int) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
            let vccc = storyboard.instantiateViewController(withIdentifier: "BuyProVC") as! BuyProVC
          //  vccc.modalPresentationStyle = .formSheet
          //  vccc.navigationController?.setNavigationBarHidden(true, animated: false)
            vccc.selectedProduct = selectedProduct
            self.present(vc: vccc)
        }
    }
    
    
    func present(vc:UIViewController, completion:((Bool)->())? = nil) {
        DispatchQueue.main.async {
            AppDelegate.shared?.present(vc: vc, completion: {
                completion?(true)
            })
        }
    }
    
    
    func presentMoreVC(currentVC: UIViewController, data: [MoreVC.ScreenData], proIndex: Int = 0) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vccc = storyboard.instantiateViewController(withIdentifier: "MoreVC") as! MoreVC
            vccc.modalPresentationStyle = .overFullScreen
            vccc.tableData = data
            vccc.navigationController?.setNavigationBarHidden(true, animated: false)
            let cellHeight = 50
            let contentHeight = (data.count) * cellHeight
            let safeAt = appData.resultSafeArea.1
            let safebt = appData.resultSafeArea.0 + 10
            let window = AppDelegate.shared?.window ?? UIWindow()
            let screenHeight = window.frame.height
            let additionalMargin:CGFloat = safeAt > 0 ? 45 : 40
            let tableInButtom = (screenHeight - (safeAt + safebt + additionalMargin)) - (CGFloat(contentHeight))
            if CGFloat(contentHeight) > currentVC.view.frame.height / 2 {
                vccc.firstCellHeight = currentVC.view.frame.height / 2
            } else {
                vccc.firstCellHeight = tableInButtom
            }
            vccc.selectedProIndex = proIndex
            vccc.cellHeightCust = CGFloat.init(cellHeight)
            currentVC.present(vccc, animated: true)
        }
        
    }
}
