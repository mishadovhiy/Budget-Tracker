//
//  SuperViewController.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import UserNotifications

class SuperViewController: UIViewController, AppDelegateProtocol {
    func resighnActive() {
        self.view.endEditing(true)
    }
    

    lazy var newMessage: MessageView = AppDelegate.shared.newMessage
    lazy var ai: IndicatorView = AppDelegate.shared.ai
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //screen rotation
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    /*
        //DispatchQueue.main.async {
           // self.loadingIndicator.alpha = 1
            let window = UIApplication.shared.keyWindow ?? UIWindow()
           // self.loadingIndicator.alpha = 0
            window.addSubview(self.loadingIndicator)
        //}
 */
    }
    
    var loadedSubviews: Bool = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !loadedSubviews {
            //self.ai = LoadingIndicator.instanceFromNib() as! LoadingIndicator
            loadedSubviews = true

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        AppDelegate.shared.delegate = self
      /*  let window = UIApplication.shared.keyWindow ?? UIWindow()
        let indd = IndicatorView.instanceFromNib() as! IndicatorView
        indd.tag = 23450
        indd.layer.zPosition = 99999
        if !window.superview!.contains(indd) {
            window.superview?.addSubview(indd)
        }
        */
        
        /*DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
           // self.loadingIndicator.alpha = 0
            window.addSubview(self.loadingIndicator)
        }*/
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    
    func makeTwo(n: Int) -> String {
        if n < 10 {
            return "0\(n)"
        } else {
            return "\(n)"
        }
    }
    func getMonthFrom(string: String) -> Int {
        if string != "" {
            if string.count == 10 {
                var monthS = string
                for _ in 0..<3 {
                    monthS.removeFirst()
                }
                for _ in 0..<5 {
                    monthS.removeLast()
                }
                return Int(monthS) ?? 11
            } else {
                return 11
            }
            
        } else {
            return 11
        }
    }
    func getYearFrom(string: String) -> Int {
        if string != "" {
            if string.count == 10 {
                var yearS = string
                for _ in 0..<6 {
                    yearS.removeFirst()
                }
                return Int(yearS) ?? 1996
            } else {
                return 1996
            }
            
            
        } else {
            return 1996
        }
    }
    
    
    
    
    
    func stringToDate(s: String, fullDate: Bool) -> Date {//==false
        let defaultFormat = "dd.MM.yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fullDate ? K.fullDateFormat : defaultFormat
        if let rsult = dateFormatter.date(from: s) {
            return rsult
        } else {
            dateFormatter.dateFormat = defaultFormat
            if let res2 = dateFormatter.date(from: s) {
                return res2
            } else {
                print("ERROR stringToDate: string: \(s); fullDate:\(fullDate)")
                dateFormatter.locale = Locale(identifier: "ua_UA_POSIX")
                dateFormatter.setLocalizedDateFormatFromTemplate(defaultFormat)
                dateFormatter.calendar = .init(identifier: .gregorian)
                
                return dateFormatter.date(from: s) ?? Date()
            }
            
        }

    }
    
    func dateToString(dateFormat:String="dd.MM.yyyy", date: Date = Date()) -> String {
        let formater = DateFormatter()
        formater.dateFormat = dateFormat
        return formater.string(from: date)
    }
    
    func returnMonth(_ month: Int) -> String {
        let monthes = [
            1: "Jan".localize, 2: "Feb".localize, 3: "Mar".localize, 4: "Apr".localize, 5: "May".localize, 6: "Jun".localize, 7: "Jul".localize, 8: "Aug".localize, 9: "Sep".localize, 10: "Oct".localize, 11: "Nov".localize, 12: "Dec".localize
        ]
        return monthes[month] ?? "Jan"
    }
    
    
    func differenceFromNow(startDate: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate, to: Date())
    }
    
    func dateExpired(_ dateComponents: DateComponents?) -> Bool {

        if let comp = dateComponents {
            if let dateDate = NSCalendar.current.date(from: comp) {
                let difference = differenceFromNow(startDate: dateDate)
                print(difference)
                
                let one = (difference.second ?? 0) + (difference.minute ?? 0) + (difference.hour ?? 0)
                let expiredSeconds = one + (difference.day ?? 0) + (difference.month ?? 0) + (difference.year ?? 0)
                
                return expiredSeconds >= 0 ? true : false
            } else {
                return false
            }
        } else {
            return false
        }
        
        
    }
    
    func dateExpired(_ string: String) -> Bool {//      MODIFY TO USE ISO
        let dateDate = stringToDate(s: string, fullDate: true)//remove!
        let difference = differenceFromNow(startDate: dateDate)
        return (difference.year ?? 1 < 0 || difference.month ?? 1 < 0 || difference.day ?? 1 < 0 || difference.hour ?? 1 < 0 || difference.minute ?? 1 < 0 || difference.second ?? 1 < 0) ? false : true
    }
    
    func expiredText(_ diff: DateComponents) -> String {
        let year = diff.year ?? 0 > 0 ? " \(diff.year ?? 0) year" + (diff.year ?? 0 > 1 ? "s": "") : ""
        let month = diff.month ?? 0 > 0 ? " \(diff.month ?? 0) month" + (diff.month ?? 0 > 1 ? "s": "") : ""
        let day = diff.day ?? 0 > 0 ? " \(diff.day ?? 0) day" + (diff.day ?? 0 > 1 ? "s": "") : ""
        let hour = diff.hour ?? 0 > 0 ? " \(diff.hour ?? 0) hour" + (diff.hour ?? 0 > 1 ? "s": "") : ""
        return year + month + day + hour
    }
    
    func dateExpiredCount(startDate: String) -> DateComponents {
        let dateDate = stringToDate(s: startDate, fullDate: true)
        return differenceFromNow(startDate: dateDate)//remove!
    }
    
    struct headerData {
        let title: String
        let description: String?
    }
    

    
    
    func showNotification(notification: UNNotification, completion: @escaping (Any?) -> ()) {
        print("showNotification")
    }
    
    public func notificationReceiver(notification: UNNotification) {
        print("willPresentwillPresent")
        print("received notification:", notification.request.content.body)
      //  notification.request.content.threadIdentifier == "Debts"
        notificationShowed = false
      /*  self.loadingIndicator.completeWithActions(buttonsTitles: ("Cancel", "View"), showCloseButton: false, leftButtonActon: { (_) in
            self.loadingIndicator.fastHide { (_) in
                self.notificationShowed = true
            }
        }, rightButtonActon: { (_) in
            self.loadingIndicator.show { (_) in
                let load = LoadFromDB()
                load.Debts { (loadedDebts, debtsError) in
                    var debtsResult: [DebtsStruct] = []
                    for i in 0..<loadedDebts.count {
                        let name = loadedDebts[i][1]
                        let amountToPay = loadedDebts[i][2]
                        let dueDate = loadedDebts[i][3]
                        debtsResult.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
                    }
                    if debtsError == "" {
                        appData.saveDebts(debtsResult)
                    }
                    var transactions:[TransactionsStruct] = []
                    let allTrans = Array(appData.getTransactions)
                    for i in 0..<allTrans.count{
                        if allTrans[i].category == notification.request.content.title {
                            transactions.append(allTrans[i])
                        }
                    }
                    DispatchQueue.main.async {
                        self.loadingIndicator.fastHide { (_) in
                            self.showHistory(categpry: notification.request.content.title, transactions: transactions)
                        }
                    }
                }
            }
            self.loadingIndicator.fastHide { (_) in
                print("Go to Notif")
                self.notificationShowed = true
                
            }
        }, title: notification.request.content.title, description: notification.request.content.body, error: false)*///PASTAI
    }
    
    var notificationShowed: Bool = true

    
    func showHistory(categpry: String, transactions: [TransactionsStruct]) {
        print("showHistory")
        let db = DataBase()
        if let category = db.category(categpry) {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vccc = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
                vccc.modalPresentationStyle = .formSheet
                vccc.historyDataStruct = transactions
                vccc.selectedCategory = category
                vccc.fromCategories = true
                self.present(vccc, animated: true)
            }
        }
        
        
    }
    
}



extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}
extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}
extension Date {
    var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
}
extension String {
    var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }
    
    func slice(from: String, to: String) -> String? {
        var text:String?
        let _ = (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                text = String(self[substringFrom..<substringTo])
            }
        }
        
        return text
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
}



extension UIViewController{//test
    var previousViewController:UIViewController?{
        if let controllersOnNavStack = self.navigationController?.viewControllers{
            let n = controllersOnNavStack.count
            //if self is still on Navigation stack
            if controllersOnNavStack.last === self, n > 1{
                return controllersOnNavStack[n - 2]
            }else if n > 0{
                return controllersOnNavStack[n - 1]
            }
        }
        return nil
    }
}
