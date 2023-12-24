//
//  buyProVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import StoreKit
import AlertViewLibrary

class BuyProVC: SuperViewController {
    
    func showAlert(title:String,text:String?, error: Bool, goHome: Bool = false) {
        paymentQueueResponded = true
        let show = {
            self.ai?.showAlertWithOK(title: title, description: text, viewType: error ? .error : .standard, okPressed: {
                if goHome {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        if Thread.isMainThread {
            show()
        } else {
            DispatchQueue.main.async {
                show()
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
    

    var bannerWasHidden = false
    var fromSettings = false
    var didappCalled = false
    var requestProd:SKProductsRequest! = SKProductsRequest()
    var proVProduct: SKProduct?
    var restoreRequest:SKReceiptRefreshRequest! = SKReceiptRefreshRequest()


    override func viewDidDismiss() {
        super.viewDidDismiss()
        requestProd = nil
        proVProduct = nil
        BuyProVC.shared = nil
        restoreRequest = nil
    }
    
    weak static var shared: BuyProVC?
    override func viewDidLoad() {
        super.viewDidLoad()
        BuyProVC.shared = self
        
        DispatchQueue.main.async {
            self.tryFree.alpha = 0
            if self.properties!.appData.db.proVersion || self.properties!.appData.db.proTrial || self.properties?.appData.db.trialDate != "" {
                //self.tryFree.alpha = 0
            }
            self.purchasedIndicatorView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        pageChanged(pageControll)
        DispatchQueue(label: "db", qos: .userInitiated).async {
            if let price = AppDelegate.shared?.properties?.db.db["productPrice"] as? String {
                DispatchQueue.main.async {
                    self.priceLabel.text = "\((Double(price)?.string()) ?? "")"
                }
            }
        }

        self.closeButton.alpha = navigationController == nil ? 1 : 0
    }
    
    
    func showPurchasedIndicator() {
        if appData.db.proVersion {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.purchasedIndicatorView.alpha = 1
                } completion: { (_) in
                    UIView.animate(withDuration: 0.3) {
                        //make bigger
                        self.purchasedIndicatorView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    } 

                }

            }
        }
    }
    
    var appeareCalled = false
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        if !appeareCalled {
            appeareCalled = true
            bannerWasHidden = AppDelegate.shared?.properties?.banner.adHidden ?? false
            if !bannerWasHidden {
                AppDelegate.shared?.properties?.banner.hide(ios13Hide: true)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !didappCalled {
            didappCalled = true
            proBackgroundView.alpha = 0.5
            showPurchasedIndicator()
            getProducts()
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
//                self.ai?.show(completion: { _ in
//                    self.checkTransitionState(.purchased, transaction: .init())
//                })
//            })
        }
        
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if !bannerWasHidden {
            AppDelegate.shared?.properties?.banner.appeare(force: true)
        }
       
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
                self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true)
                completion(nil)
            } else {
                let name = self.properties?.appData.db.username
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
        DispatchQueue(label: "local", qos: .userInitiated).async {
            self.db.viewControllers.trial.trialPressed = true
        }
        if !appData.db.proVersion {
            if appData.db.username != "" {
                self.ai?.showLoading {
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

                DispatchQueue.main.async {
                    self.ai?.showAlertWithOK(title: "Sign in required", viewType: .standard, button: .with({
                        $0.title = "Sign in".localize
                        $0.action = {
                            self.performSegue(withIdentifier: "toSingIn", sender: self)

                        }
                        $0.style = .error
                    }), okTitle:"Close".localize)
                }
            }
        }
    }
    
    
    func trialWithoutAcoount() {
        appData.db.proTrial = true
        appData.db.trialDate = appData.db.filter.getToday()
        showAlert(title: AppText.success, text: "Trial has been started successfully".localize, error: false, goHome: true)
    }
    
    func performTrial(loadedData:(String, String, String, String)) {
        let today = appData.db.filter.getToday()
        let toDataStringMian = "&Nickname=\(appData.db.username)" + "&Email=\(loadedData.0)" + "&Password=\(loadedData.1)" + "&Registration_Date=\(loadedData.2)"
        
        let dataStringSave = toDataStringMian + "&ProVersion=0" + "&trialDate=\(today)"
        print(dataStringSave)
        let delete = DeleteFromDB()
        delete.User(toDataString: toDataStringMian) { (errorr) in
            if errorr {
                self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true)
            } else {
                SaveToDB.shared.Users(toDataString: dataStringSave ) { (error) in
                if error {
                    self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true)
                } else {
                    DispatchQueue.main.async {
                        self.properties?.appData.db.proTrial = true
                        self.properties?.appData.db.trialDate = today
                        self.showAlert(title: AppText.success, text: "Trial has been started successfully".localize, error: false, goHome: true)

                    }
                }
                
            }
            }
            
        }
        
    }
    

    
    var userData = ("","","","")
    @IBAction func buyPressed(_ sender: UIButton) {
        paymentQueueResponded = false
        let nick = appData.db.username
        if !appData.db.proVersion {
            if appData.db.username == "" {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toSingIn", sender: self)
                }
            } else {

                self.ai?.showLoading {
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
                self.newMessage?.show(title: "You have already purchased pro version".localize, type: .error)
            }
        }
        
        
    }
    
    @IBAction func restorePressed(_ sender: UIButton) {
        print("restorePressed")
        paymentQueueResponded = false
        if SKPaymentQueue.canMakePayments() {
            self.restoreRequest.delegate = self
            self.ai?.showLoading {
                SKPaymentQueue.default().restoreCompletedTransactions()
                SKPaymentQueue.default().add(self)
                self.restoreRequest.start()
            }
            
        } else {
            print("go to restrictions")
            self.showAlert(title: "Error".localize, text: "Permission denied".localize, error: true)
        }
    }
    
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
            DispatchQueue(label: "db", qos: .userInitiated).async {
                AppDelegate.shared?.properties?.db.db.updateValue("\(product.price.doubleValue)", forKey: "productPrice")
                print(product.price, " rgfergtbhgref")
                DispatchQueue.main.async {
                    self.priceLabel.text = "\(product.price.doubleValue.string())"
                }
            }
        }
    }
}

extension BuyProVC: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("restoreCompletedTransactionsFailedWithError")
        self.showAlert(title: "Payment not found".localize, text: nil, error: true)
    }

    func toDataString(save:Bool, user:[String]) -> String {
        let toDataStringMian = "&Nickname=\(user[0])" + "&Email=\(user[1])" + "&Password=\(user[2])" + "&Registration_Date=\(user[3])"
        return toDataStringMian + "&ProVersion=\(!save ? user[4] : "1")" + "&trialDate=\(user[5])"
    }
    
    func dbSavePurchase() {

        getUser { loadedUser in
            if let user = loadedUser {
            
                let delete = DeleteFromDB()
                delete.User(toDataString: self.toDataString(save: false, user: user)) { (errorr) in
                    if errorr {
                        self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true)
                    } else {
                        SaveToDB.shared.Users(toDataString: self.toDataString(save: true, user: user)) { (error) in
                            if error {
                                self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true)
                            } else {
                                self.scsPurchaseShow()
                            }
                            
                        }
                    }
                }
            } else {
                
                self.showAlert(title: "Purchase restored".localize, text: "", error: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.ai?.showAlertWithOK(title: "Error saving purchase to your Budget Tracker account", description: "Please, log in to your account and Restore Purchase Again", viewType: .error)
                })
            }
        }
        
        
    }
    
    
    func scsPurchaseShow() {
        DispatchQueue.main.async {
            self.showPurchasedIndicator()
            self.showAlert(title: AppText.success, text: "Pro version available across all your devices".localize, error: false, goHome: true)
          //  UIApplication().endBackgroundTask()
        }
    }
    

    func checkTransitionState(_ state:SKPaymentTransactionState? = nil, transaction:SKPaymentTransaction) {
        let test = state != nil
        switch state ?? transaction.transactionState {
        case .purchased, .restored:
            print("paymentQueue pur succss")
            if !paymentQueueResponded {
                paymentQueueResponded = true
                if !test {
                    print("fsdfassrgetr")
                    SKPaymentQueue.default().finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                }
                
                DispatchQueue.init(label: "DB").async {
                    self.properties?.appData.db.proVersion = true
                    self.properties?.appData.db.purchasedOnThisDevice = true
                    self.dbSavePurchase()
                }
            }
            
            break
        case .failed:
            print("paymentQueue pur ERROR")
            if !test {
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            }
            DispatchQueue.main.async {
                self.showAlert(title: "Payment failed".localize, text: nil, error: true)
            }
            break
        default:
            break
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            checkTransitionState(transaction: $0)
        }
    }
}



extension BuyProVC {
    static func presentBuyProVC(selectedProduct:Int) {
        let vc = BuyProVC.configure()
        vc.selectedProduct = selectedProduct
        AppDelegate.shared?.properties?.appData.present(vc: vc)
    }
    static func configure() -> BuyProVC {
        return UIStoryboard(name: "LogIn", bundle: nil).instantiateViewController(withIdentifier: "BuyProVC") as! BuyProVC
    }
}
