//
//  SuperViewController.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import AlertViewLibrary
import MessageViewLibrary

class SuperViewController: UIViewController {

    var appeareAction:((_ vc:SuperViewController?)->())?
    var disapeareAction:((_ vc:SuperViewController?)->())?
    
    var properties:AppProperties? {
        return AppDelegate.properties
    }
    
    var newMessage:MessageViewLibrary? {
        return AppDelegate.properties?.newMessage
    }
    var ai: AlertManager? {
        return AppDelegate.properties?.ai
    }
    var db:DataBase {
        return AppDelegate.properties?.db ?? DataBase()
    }
    var appData:AppData {
        return AppDelegate.properties?.appData ?? .init()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //screen rotation
    }
    
    func loadLocalData() {
        
    }

    lazy var defaultTableInset = AppDelegate.properties?.banner.size ?? 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        if let back = backgroundData{
            if back.isPopupVC {
                var backD = back
                backD.show = false
                togglePresentedBackgroundView(backD)
                
            } else {
                removePopupBackgroundView(back)
            }
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("ytrgtefrcds")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if waitingToDisapeare {
            waitingToDisapeare = false
            self.viewDidDismiss()
        }
        
        disapeareAction?(self)
        
        if let back = backgroundData, back.isPopupVC {
            removePopupBackgroundView(back)
        }
    }

    var firstAppearCalled = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !firstAppearCalled {
            firstAppearCalled = true
            firstAppeared()
        }
        appeareAction?(self)
    }
    
    func firstAppeared() {
        
    }
    
    func viewDidDismiss() {

    }
 
    private var waitingToDisapeare = false
    func navigationPopVC() {
        waitingToDisapeare = true
    }
    
    
    func getMonthFrom(string: String) -> Int {
        let comp = string.stringToCompIso()
        return comp.month ?? 2022
    }
    func getYearFrom(string: String) -> Int {
        let comp = string.stringToCompIso()
        return comp.year ?? 2022
    }
    
    
    
    func removeKeyboardObthervers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func createCalendar(_ container:UIView, currentSelected:DateComponents?, selected:((_ date:DateComponents)->())? = nil, cellSelected:((_ date:DateComponents, _ cell:CalendarCell)->())? = nil) -> CalendarControlVC? {
        let vc = CalendarControlVC.configure(currentSelected: currentSelected, selected: selected)
        vc.cellSelected = cellSelected
        print(cellSelected, " rtgerfewreg")
        print(currentSelected, " gertgrw")
        addChild(vc)
        guard let childView = vc.view else { return nil }
        container.addSubview(childView)
        childView.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: container)
        vc.didMove(toParent: self)
        return vc
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
    var backgroundData:VCpresentedBackgroundData?
    
    func dateToString(dateFormat:String="dd.MM.yyyy", date: Date = Date()) -> String {
        let formater = DateFormatter()
        formater.dateFormat = dateFormat
        return formater.string(from: date)
    }
    
    func getMonth(_ month: Int) -> String {
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
    
    
    
    func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle? = nil) {
        if #available(iOS 13.0, *) {
            UIImpactFeedbackGenerator(style: style ?? .soft).impactOccurred()
        } else {
            UIImpactFeedbackGenerator(style: style ?? .light).impactOccurred()
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
        var description: String? = nil
    }
    

    

    
    var notificationShowed: Bool = true

    
    func showHistory(categpry: String, transactions: [TransactionsStruct]) {
        print("showHistory")
        let db = AppDelegate.properties?.db
        if let category = db?.category(categpry) {
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

