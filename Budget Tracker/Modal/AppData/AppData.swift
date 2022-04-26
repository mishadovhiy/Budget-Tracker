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
    var expenseLabelPressed = true//make only in vc
    var sendSavedData = false
    var needDownloadOnMainAppeare = false
    
    static var categoriesHolder:[NewCategories]?
    
    static var linkColor: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "SelectedTintColor")
            let color = colorNamed(newValue)
            DispatchQueue.main.async {
                let window = AppDelegate.shared?.window ?? UIWindow()
                window.tintColor = color
            }
        }
        get {
            return UserDefaults.standard.value(forKey: "SelectedTintColor") as? String ?? "Yellow"
        }
    }
    
    let defaults = UserDefaults.standard
    var safeArea: (CGFloat, CGFloat) = (0.0, 0.0)//0-bt  1-top

    var resultSafeArea: (CGFloat, CGFloat) {
        let btn = safeArea.0 + (AppDelegate.shared?.banner.size ?? 0)
        return (btn, safeArea.1)
    }
    
    let lastSelected = LastSelected()

    var forceNotPro: Bool? {
        get{

            return defaults.value(forKey: "forcePro") as? Bool
        }
        set(value){
            defaults.set(value, forKey: "forcePro")
        }
    }
    
    var proEnabeled:Bool {
        let result = appData.proTrial || appData.proVersion
        return devMode ? !(forceNotPro ?? !result) : result
    }
    
    var proVersion: Bool {
        get{
            let result = !purchasedOnThisDevice ? (defaults.value(forKey: "proVersion") as? Bool ?? false) : purchasedOnThisDevice
            return result
        }
        set(value){
            defaults.set(value, forKey: "proVersion")
        }
    }
    
    var purchasedOnThisDevice: Bool {
        get{
            return defaults.value(forKey: "purchasedOnThisDevice") as? Bool ?? false
        }
        set(value){
            defaults.set(value, forKey: "purchasedOnThisDevice")
        }
    }
    
    var trialDate: String {
        get{
            return defaults.value(forKey: "trialDate") as? String ?? ""
        }
        set(value){
            defaults.set(value, forKey: "trialDate")
        }
    }
    
    var proTrial: Bool {
        get{
            return defaults.value(forKey: "proTrial") as? Bool ?? false
        }
        set(value){
            defaults.set(value, forKey: "proTrial")
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
            return defaults.value(forKey: "username") as? String ?? ""
        }
        set(value){
            print("new username setted - \(value)")
            defaults.set(value, forKey: "username")
        }
    }
    


    var password: String {
        get{
            return defaults.value(forKey: "password") as? String ?? ""
        }
        set(value){
            print("new password setted - \(value)")
            defaults.set(value, forKey: "password")
        }
    }
    
    var userEmailHolder: String {
        get{
            return defaults.value(forKey: "userEmailHolder") as? String ?? ""
        }
        set(value){
            print("new password setted - \(value)")
            defaults.set(value, forKey: "userEmailHolder")
        }
    }
    
    var devMode:Bool {
        return userEmailHolder.contains("dovhiy.com")
    }
    


    var unsendedData:[[String: [String:Any]]] {
        //0 - type (delete transaction)
        //1 - toDataString
        get {
            return defaults.value(forKey: "unsendedData") as? [[String: [String:Any]]] ?? []
        }
        set(value){
            defaults.set(value, forKey: "unsendedData")
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
        return UserDefaults.standard.value(forKey: "SelectedTintColor") as? String ?? "yellowColor"
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
    
    
    
    var filter = Filter()
    struct Filter {
        
        var showAll:Bool {
            get {
                UserDefaults.standard.value(forKey: "showAll") as? Bool ?? false
            }
            set {
                UserDefaults.standard.setValue(newValue, forKey: "showAll")
            }
        }
        var from: String {
            get {
                UserDefaults.standard.value(forKey: "SortFrom") as? String ?? ""
            }
            set {
                UserDefaults.standard.setValue(newValue, forKey: "SortFrom")
            }
        }
        var to: String {
            get {
                UserDefaults.standard.value(forKey: "SortTo") as? String ?? ""
            }
            set {
                UserDefaults.standard.setValue(newValue, forKey: "SortTo")
            }
        }
        var selectedPeroud:String {
            get {
                UserDefaults.standard.value(forKey: "SortSelectedPeroud") as? String ?? ""
            }
            set {
                UserDefaults.standard.setValue(newValue, forKey: "SortSelectedPeroud")
            }
        }
        
        func getLastDayOf(month: Int, year: Int) -> Int {
            
            let dateComponents = DateComponents(year: year, month: month)
            let calendar = Calendar.current
            let date = calendar.date(from: dateComponents)!

            let range = calendar.range(of: .day, in: .month, for: date)!
            return range.count
        
        }
        
        func getLastDayOf(fullDate: String) -> Int {
            
            if fullDate != "" {
                let month = getMonthFromString(s: fullDate)
                let year = getMonthFromString(s: fullDate)
                
                let dateComponents = DateComponents(year: year, month: month)
                let calendar = Calendar.current
                let date = calendar.date(from: dateComponents)!

                let range = calendar.range(of: .day, in: .month, for: date)!
                return range.count
            } else {
                return 28
            }
        
        }
        
        
        
        func getToday(dateformatter: String = "dd.MM.yyyy") -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateformatter
            let results = dateFormatter.string(from: Date())
            return results
        }
        
        func makeTwo(n: Int) -> String {
            if n < 10 {
                return "0\(n)"
            } else {
                return "\(n)"
            }
        }
        
        func getDayFromString(s: String) -> Int {
            
            if s != "" {
                var day = s
                for _ in 0..<8 {
                    day.removeLast()
                }
                return Int(day) ?? 23
            } else {
                return 11
            }
            
        }
        
        
        func getMonthFromString(s: String) -> Int {
            
            if s != "" {
                var month = s
                for _ in 0..<3 {
                    month.removeFirst()
                }
                for _ in 0..<5 {
                    month.removeLast()
                }
                return Int(month) ?? 11
            } else {
                return 11
            }
        }
        
        func getYearFromString(s: String) -> Int {
            
            if s != "" {
                var year = s
                for _ in 0..<6 {
                    year.removeFirst()
                }
                return Int(year) ?? 1996
                
            } else {
                return 1996
            }

        }
        
        
        var filterObjects = FilterObjects()
        struct FilterObjects {
            
            let currentDate = UIDatePicker()
            
        }
    }
    
    
    
    func createFirstData(completion: @escaping () -> ()) {
        
    /*    let transactions = [
            TransactionsStruct(value: "5000", categoryID: "Freelance", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.MM.yyyy"))", comment: ""),
            TransactionsStruct(value: "10000", categoryID: "Work", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.01.yyyy"))", comment: ""),
            TransactionsStruct(value: "-100", categoryID: "Food", date: "\(filter.getToday(filter.filterObjects.currentDate, dateformatter: "01.MM.yyyy"))", comment: ""),
            TransactionsStruct(value: "-400", categoryID: "Food", date: "\(filter.getToday(filter.filterObjects.currentDate))", comment: ""),
            TransactionsStruct(value: "-1000", categoryID: "Bills", date: "\(filter.getToday(filter.filterObjects.currentDate))", comment: ""),
        ]
        let categories = [
            NewCategories(id: <#T##Int#>, name: <#T##String#>, icon: <#T##String#>, color: <#T##String#>, purpose: <#T##CategoryPurpose#>)
            CategoriesStruct(name: "Food", purpose: K.expense, count: 0),
            CategoriesStruct(name: "Taxi", purpose: K.expense, count: 0),
            CategoriesStruct(name: "Public Transport", purpose: K.expense, count: 0),
            CategoriesStruct(name: "Bills", purpose: K.expense, count: 0),
            CategoriesStruct(name: "Work", purpose: K.income, count: 0),
            CategoriesStruct(name: "Freelance", purpose: K.income, count: 0)
        ]
        saveTransations(transactions)
        saveCategories(categories)*/
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
            let window = AppDelegate.shared?.window ?? UIWindow()
            if let rootVC = window.rootViewController {
                let presentt = {
                  //  rootVC.presentedViewController
                    rootVC.present(vc, animated: true, completion: {
                        if let completion = completion {
                            completion(true)
                        }
                    })
                }
                if let presenting = rootVC.presentedViewController {
                    presenting.dismiss(animated: true, completion: presentt)
                } else {
                    presentt()
                }
                
                
            } else {
                AppDelegate.shared?.ai.showAlertWithOK(title: "Error", text: Text.Error.internetDescription, error: true, hidePressed: completion)
            }
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
