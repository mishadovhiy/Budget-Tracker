//
//  RemindersVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RemindersVC: SuperViewController {
    typealias TransitionComponents = (albumCoverImageView: UIImageView?, albumNameLabel: UILabel?)
    public var transitionComponents = TransitionComponents(albumCoverImageView: nil, albumNameLabel: nil)
    let transitionAppearenceManager = AnimatedTransitioningManager(duration: 0.28)
    
    var tableData:[ReminderStruct] = []
    @IBOutlet weak var tableView: UITableView!
    weak static var shared:RemindersVC?
    lazy var reminders = ReminderManager()
    var fromAppDelegate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RemindersVC.shared = self
        loadData()
        title = "Payment reminders ".localize
        AppDelegate.properties?.banner.fullScreenDelegates.updateValue(self, forKey: self.restorationIdentifier!)

    }

    override func viewDidDismiss() {
        super.viewDidDismiss()
        AppDelegate.properties?.banner.fullScreenDelegates.removeValue(forKey: self.restorationIdentifier!)
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    private var firstAppeared:Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = nil
        if !firstAppeared {
            firstAppeared = true
            AppDelegate.properties?.banner.bannerCanShow(type: .paymentReminder, completion: {
                self.addTransactionButton.toggleAdView(show: $0)
            })
            
        }
    }
    lazy var today = AppDelegate.properties?.db.filter.getToday() ?? ""
    var editingReminder:Int?
    func performAddReminder() {
        Notifications.requestNotifications()
        let vc = TransitionVC.configure()
        vc.delegate = self
        vc.paymentReminderAdding = true
        if let row = editingReminder {
            editingReminder = nil
            let data = tableData[row]
            vc.reminder_Repeated = data.repeated
            vc.reminder_Time = data.time
            let normalDate = data.transaction.date.stringToCompIso()
            vc.editingDate = normalDate.toShortString() ?? ""
            vc.editingValue = Double(data.transaction.value) ?? 0.0
            vc.editingCategory = data.transaction.categoryID
            vc.editingComment = data.transaction.comment
            vc.idxHolder = row
        }
        navigationController?.delegate = transitionAppearenceManager
        transitionAppearenceManager.beginTransactionPressedView = addTransactionButton
        transitionAppearenceManager.canDivideFrame = false

        self.navigationController?.pushViewController(vc, animated: true)
    }
    private var interstitial: GADFullScreenPresentingAd?
    @IBOutlet weak var addTransactionButton: AdButton!
    @IBAction func addTransactionPressed(_ sender: Any) {
        AppDelegate.properties?.banner.toggleFullScreenAdd(self, type: .paymentReminder, loaded: {
            self.interstitial = $0
            self.interstitial?.fullScreenContentDelegate = self
        }, closed: {presented in 
            self.performAddReminder()
        })
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < -100.0) && fromAppDelegate {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                        
                }
            }
        }
    }
}

extension RemindersVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count == 0 ? 1 : tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableData.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoRemindersCell", for: indexPath) as! NoRemindersCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
            cell.row = indexPath.row
            let data = tableData[indexPath.row]
            cell.amountLabel.text = data.transaction.value
            let date = data.time
            cell.dayNumLabel.text = date?.day?.twoDec
            cell.dateLabel.text = (date?.stringMonth ?? "") + "\n\(date?.year ?? 0)"
            cell.timeLabel.text = date?.timeString
            cell.expiredLabel.isHidden = !(date?.expired ?? false)
            cell.commentLabel.text = data.transaction.comment
            cell.categoryLabel.text = data.transaction.category.name
            cell.actionsView.isHidden = !data.selected
            cell.unseenIndicator.isHidden = !data.higlightUnseen
            cell.repeatedIndicator.isHidden = !(data.repeated ?? false)
            cell.editAction = editReminder(idx:)
            cell.deleteAction = deleteReminder(idx:)
            cell.addTransactionAction = addTransaction(idx:)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableData.count == 0 ? tableView.frame.height : UITableView.automaticDimension
    }
    
  /*  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        cell.select()
    }*/
    
}

extension RemindersVC :TransitionVCProtocol {
    
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime: DateComponents?, repeated: Bool?) {
        let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
        addReminder(wasStringID: nil, transaction: new, reminderTime: reminderTime, repeated: repeated)
    }
    
    func editTransaction(_ transaction: TransactionsStruct, was: TransactionsStruct,reminderTime: DateComponents?, repeated: Bool?, idx:Int?) {
        print("editTransactioneditTransactioneditTransaction")
        addReminder(wasStringID: idx, transaction: transaction, reminderTime: reminderTime, repeated: repeated)
    }
    
    func quiteTransactionVC(reload: Bool) {

    }
    
    func deletePressed() {

    }
    
    
}


extension RemindersVC:GADFullScreenContentDelegate {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        AppDelegate.properties?.banner.adDidPresentFullScreenContent(ad)
    }
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        AppDelegate.properties?.banner.adDidDismissFullScreenContent(ad)
    }
    
}


extension RemindersVC:FullScreenDelegate {
    func toggleAdView(_ show: Bool) {
        addTransactionButton.toggleAdView(show: show)
    }
    
    
}


extension RemindersVC {
    static func showPaymentReminders() {
        DispatchQueue.main.async {
            let strorybpard = UIStoryboard(name: "Main", bundle: nil)
            let vc = strorybpard.instantiateViewController(withIdentifier: "RemindersVC") as! RemindersVC
            vc.fromAppDelegate = true
            let nav = UINavigationController(rootViewController: vc)
            AppDelegate.properties?.appData.present(vc: nav) {
               // AppDelegate.properties?.ai.hide()
            }
            
            nav.setBackground(.regular)
        }
    }
    static func configure() -> RemindersVC {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RemindersVC") as! RemindersVC
        return vc
    }
}



