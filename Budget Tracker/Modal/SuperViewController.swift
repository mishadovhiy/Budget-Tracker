//
//  SuperViewController.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import UserNotifications

class SuperViewController: UIViewController {

    let center = UNUserNotificationCenter.current()
    lazy var loadingIndicator: IndicatorView = {
        let newView = IndicatorView.instanceFromNib() as! IndicatorView
        return newView
        //return (UIApplication.shared.keyWindow ?? UIWindow()).viewWithTag(23450) as? IndicatorView ?? IndicatorView(frame: .zero)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(center.delegate, "center.descriptioncenter.description")
      /*  let window = UIApplication.shared.keyWindow ?? UIWindow()
        let indd = IndicatorView.instanceFromNib() as! IndicatorView
        indd.tag = 23450
        indd.layer.zPosition = 99999
        if !window.superview!.contains(indd) {
            window.superview?.addSubview(indd)
        }
        */
        DispatchQueue.main.async {
           // self.loadingIndicator.alpha = 1
            let window = UIApplication.shared.keyWindow ?? UIWindow()
           // self.loadingIndicator.alpha = 0
            window.addSubview(self.loadingIndicator)
        }
        /*DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
           // self.loadingIndicator.alpha = 0
            window.addSubview(self.loadingIndicator)
        }*/
        
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
      //  center.delegate = nil
        
        DispatchQueue.main.async {
            self.loadingIndicator.removeFromSuperview()
        }
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
    
    func stringToDateComponent(s: String, dateFormat:String="dd.MM.yyyy") -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: s)
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? Date())
    }
    
    func stringToDate(s: String, dateFormat:String="dd.MM.yyyy") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: s) ?? Date()
    }
    
    func dateToString(dateFormat:String="dd.MM.yyyy", date: Date = Date()) -> String {
        let formater = DateFormatter()
        formater.dateFormat = dateFormat
        return formater.string(from: date)
    }
    
    func returnMonth(_ month: Int) -> String {
        let monthes = [
            1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun",
            7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"
        ]
        return monthes[month] ?? "Jan"
    }
    
    
    func differenceFromNow(startDate: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate, to: Date())
    }
    
    func dateExpired(_ string: String) -> Bool {
        let dateDate = stringToDate(s: string, dateFormat: K.fullDateFormat)
        let difference = differenceFromNow(startDate: dateDate)
        return (difference.year ?? 0 < 0 || difference.month ?? 0 < 0 || difference.day ?? 0 < 0 || difference.hour ?? 0 < 0 || difference.minute ?? 0 < 0 || difference.second ?? 0 < 0) ? false : true
    }
    
    struct headerData {
        let title: String
        let description: String?
    }
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    
    public func notificationReceiver(notification: UNNotification) {
        print("willPresentwillPresent")
        print("received notification:", notification.request.content.body)
      //  notification.request.content.threadIdentifier == "Debts"
        notificationShowed = false
        self.loadingIndicator.completeWithActions(buttonsTitles: ("Cancel", "View"), showCloseButton: false, leftButtonActon: { (_) in
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
        }, title: notification.request.content.title, description: notification.request.content.body, error: false)
    }
    
    var notificationShowed: Bool = true

    
    func showHistory(categpry: String, transactions: [TransactionsStruct]) {
        print("showHistory")
        
        
       // self.presentedViewController?.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vccc = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
        vccc.modalPresentationStyle = .formSheet
        vccc.historyDataStruct = transactions
        vccc.selectedCategoryName = categpry
        vccc.fromCategories = true
        self.present(vccc, animated: true)
        
    }
    
}



