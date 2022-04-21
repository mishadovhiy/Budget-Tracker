//
//  buyProVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import StoreKit

class BuyProVC: SuperViewController {
    
    func showAlert(title:String,text:String?, error: Bool, goHome: Bool = false) {
        paymentQueueResponded = true
        DispatchQueue.main.async {
            self.ai.showAlertWithOK(title: title, text: text, error: error) { _ in
                if goHome {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "homeVC", sender: self)
                    }
                }
            }
        }

    }
    var paymentQueueResponded = false
    @IBOutlet weak var proBackgroundView: UIImageView!
    @IBOutlet weak var tryFree: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pageControll: UIPageControl!
    var selectedProduct = 0
    @IBOutlet weak var buyProutton: UIButton!
    @IBOutlet weak var buyProView: UIView!
    @IBOutlet weak var purchasedIndicatorView: UIView!
    

    
    var requestProd = SKProductsRequest()
    var proVProduct: SKProduct?
    

    static var shared: BuyProVC?
    override func viewDidLoad() {
        super.viewDidLoad()
        BuyProVC.shared = self
        DispatchQueue.main.async {
            if appData.proVersion || appData.proTrial || appData.trialDate != "" {
                self.tryFree.alpha = 0
            }
            self.purchasedIndicatorView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        pageChanged(pageControll)
        if let price = UserDefaults.standard.value(forKey: "productPrice") {
            DispatchQueue.main.async {
                self.priceLabel.text = "\(price)"
            }
        }

        self.closeButton.alpha = navigationController == nil ? 1 : 0
    }


    
    func showPurchasedIndicator() {
        if appData.proVersion {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.purchasedIndicatorView.alpha = 1
                } completion: { (_) in
                    UIView.animate(withDuration: 0.3) {
                        //make bigger
                        self.purchasedIndicatorView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    } completion: { (_) in
                        
                    }

                }

            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        AppDelegate.shared?.hideAdd()
    }
    
    var fromSettings = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        proBackgroundView.alpha = 0.5
        showPurchasedIndicator()
        getProducts()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        AppDelegate.shared?.bannerAppeare()
    }
    
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        print(#function, sender.currentPage, "ghjcnhxuik")
    }
    
    
    func getProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(["BudgetTrackerPro"]))
        self.requestProd = request
        request.delegate = self
        request.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSingIn" {
            if let vc = segue.destination as? LoginViewController {
                vc.messagesFromOtherScreen = "Sign in to use pro version across all your devices".localize
                vc.fromPro = true
            }
            
        }
    }
    
    func getUser(completion:@escaping([String]?) -> ()) {
        LoadFromDB.shared.Users { (loadedData, error) in
            if error {
                self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true)
                completion(nil)
            } else {
                let name = appData.username
                for i in 0..<loadedData.count {
                    if loadedData[i][0] == name {
                        completion(loadedData[i])
                        return
                    }
                }
                completion(nil)
            }
        }
    }
    
    @IBAction func tryFreePressed(_ sender: UIButton) {
        UserDefaults.standard.setValue(true, forKey: "trialPressed")
        if !appData.proVersion {
            if appData.username != "" {
                self.ai.show { (_) in
                    self.getUser { loadedData in
                        if let data = loadedData {
                            if data[5] != "" {
                                self.showAlert(title: "Access denied".localize, text: "You have already tried trial version".localize, error: true)
                                return
                            } else {
                                if data[4] != "1" {
                                    let new = (data[1], data[2], data[3], data[5])
                                    self.userData = new
                                    self.performTrial(loadedData: new)
                                } else {
                                    self.showAlert(title: "You already have PRO version".localize, text: nil, error: false)
                                }
                                
                                
                            }
                        }
                        
                    }
                }
                
            } else {
                let firstButton = self.ai.prebuild_closeButton(title: "Close".localize, style: .error)
                let secondButton = IndicatorView.button(title: "Sign in".localize, style: .regular, close: true) { _ in
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toSingIn", sender: self)
                    }
                }
                
                DispatchQueue.main.async {
                    self.ai.showAlert(buttons: (firstButton, secondButton), title: "Sign in required".localize, type: .standard)
                }
            }
        }
    }
    
    
    func trialWithoutAcoount() {
        appData.proTrial = true
        appData.trialDate = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        showAlert(title: Text.success, text: "Trial has been started successfully".localize, error: false, goHome: true)
    }
    
    func performTrial(loadedData:(String, String, String, String)) {
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let toDataStringMian = "&Nickname=\(appData.username)" + "&Email=\(loadedData.0)" + "&Password=\(loadedData.1)" + "&Registration_Date=\(loadedData.2)"
        
        let dataStringSave = toDataStringMian + "&ProVersion=0" + "&trialDate=\(today)"
        print(dataStringSave)
        let delete = DeleteFromDB()
        delete.User(toDataString: toDataStringMian) { (errorr) in
            if errorr {
                self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true)
            } else {
                SaveToDB.shared.Users(toDataString: dataStringSave ) { (error) in
                if error {
                    self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true)
                } else {
                    DispatchQueue.main.async {
                        appData.proTrial = true
                        appData.trialDate = today
                        self.showAlert(title: Text.success, text: "Trial has been started successfully".localize, error: false, goHome: true)

                    }
                }
                
            }
            }
            
        }
        
    }
    

    
    var userData = ("","","","")
    @IBAction func buyPressed(_ sender: UIButton) {
        paymentQueueResponded = false
        let nick = appData.username
        if !appData.proVersion {
            if appData.username == "" {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toSingIn", sender: self)
                }
            } else {

                self.ai.show { (_) in
                    guard let myProduct = self.proVProduct else {
                        self.showAlert(title: "Error".localize, text: "Permission denied".localize, error: true)
                        return
                    }
                    if SKPaymentQueue.canMakePayments() {
                        print("can make true")
                        let payment = SKPayment(product: myProduct)
                        SKPaymentQueue.default().add(self)
                        SKPaymentQueue.default().add(payment)
                    } else {
                        print("go to restrictions")
                        self.showAlert(title: "Error".localize, text: "Permission denied".localize, error: true)
                    }
                }
                
                
                
                
            }
        } else {
            DispatchQueue.main.async {
                self.newMessage.show(title: "You have already purchased pro version".localize, type: .error)
            }
        }
        
        
    }
    
    let restoreRequest = SKReceiptRefreshRequest()
    @IBAction func restorePressed(_ sender: UIButton) {
        print("restorePressed")
        paymentQueueResponded = false
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
            SKPaymentQueue.default().add(self)

            self.ai.show { (_) in
                self.restoreRequest.delegate = self
                self.restoreRequest.start()
            }
            
        } else {
            print("go to restrictions")
            self.showAlert(title: "Error".localize, text: "Permission denied".localize, error: true)
        }
    }
    
    
    @IBAction func closePressed(_ sender: Any) {
        print("prrrr")
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    

    
}

extension BuyProVC: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response, "productsRequest didReceive")
        print(response.invalidProductIdentifiers, "invalidProductIdentifiers")
        print(response.products.count, "count")
        if let product = response.products.first {
            print(product, "productproductproduct")
            proVProduct = product
            UserDefaults.standard.setValue(product.price, forKey: "productPrice")
            DispatchQueue.main.async {
                self.priceLabel.text = "\(product.price)"
            }
        }
    }
}

extension BuyProVC: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("restoreCompletedTransactionsFailedWithError")
        self.showAlert(title: "Payment not found".localize, text: nil, error: true)
    }

    func dbSavePurchase() {

        getUser { loadedUser in
            if let user = loadedUser {
                let toDataStringMian = "&Nickname=\(user[0])" + "&Email=\(user[1])" + "&Password=\(user[2])" + "&Registration_Date=\(user[3])"
                let dataStringSave = toDataStringMian + "&ProVersion=1" + "&trialDate=\(user[5])"
                let delete = DeleteFromDB()
                let dataStringDelete = toDataStringMian

                delete.User(toDataString: dataStringDelete) { (errorr) in
                    if errorr {
                        self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true)
                    } else {
                        SaveToDB.shared.Users(toDataString: dataStringSave ) { (error) in
                            if error {
                                self.showAlert(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true)
                            } else {
                                self.scsPurchaseShow()
                            }
                            
                        }
                    }
                }
            } else {
                self.showAlert(title: "Error saving purchase".localize, text: "", error: true)
            }
        }
        
        
    }
    
    
    func scsPurchaseShow() {
        DispatchQueue.main.async {
            self.showPurchasedIndicator()
            self.showAlert(title: Text.success, text: "Pro version available across all your devices".localize, error: false, goHome: true)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break

            case .purchased, .restored:
                print("paymentQueue pur succss")
                if !paymentQueueResponded {
                    paymentQueueResponded = true
                    SKPaymentQueue.default().finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                    appData.proVersion = true
                    appData.purchasedOnThisDevice = true
                    DispatchQueue.init(label: "DB").async {
                        self.dbSavePurchase()
                    }
                }
                
                break
            case .failed, .deferred:
                print("paymentQueue pur ERROR")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                DispatchQueue.main.async {
                    self.showAlert(title: "Payment failed".localize, text: nil, error: true)
                }
                break
            default:
                DispatchQueue.main.async {
                    self.ai.fastHide() { (_) in
                        SKPaymentQueue.default().finishTransaction(transaction)
                        SKPaymentQueue.default().remove(self)
                    }
                }
            }
        }
    }
}

