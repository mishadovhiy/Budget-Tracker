//
//  buyProVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import StoreKit

class BuyProVC: SuperViewController {//ЗАПИСЫВАТЬ ДЕЛЕГАТЫ ИЛИ ВЫЗЫВАТЬ ИЗ ЕП ДЕЛЕГАТА
    
    func showAlert(title:String,text:String?, error: Bool, goHome: Bool = false) {
        
        let okButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in
            if goHome {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "homeVC", sender: self)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.ai.completeWithActions(buttons: (okButton, nil), title: title, descriptionText: text, type: error ? .error : .standard)
        }

    }
    
    @IBOutlet weak var tryFree: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pageControll: UIPageControl!
    var selectedProduct = 0
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var buyProutton: UIButton!
    @IBOutlet weak var buyProView: UIView!
    @IBOutlet weak var purchasedIndicatorView: UIView!
    
    //title, description, imageName
    let allProducts:[(String, String, String)] = [
        ("Debts", "Track how much people own you", "purchaseDebts"),
        ("Transfer data", "Transfer data from previous account", "purchaseTransferData")
    ]
    
    var requestProd = SKProductsRequest()
    var proVProduct: SKProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            if appData.proVersion || appData.proTrial || appData.trialDate != "" {
                self.tryFree.alpha = 0
            }
            self.purchasedIndicatorView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.purchasedIndicatorView.layer.cornerRadius = 4
        }
        pageControll.numberOfPages = allProducts.count
        pageChanged(pageControll)
        if let price = UserDefaults.standard.value(forKey: "productPrice") {
            DispatchQueue.main.async {
                self.priceLabel.text = "\(price)"
            }
        }
        
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.productSwipped(_:)))
        leftSwipe.direction = .left
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.productSwipped(_:)))
        rightSwipe.direction = .right
        self.productTitleLabel.superview?.superview?.superview?.superview?.addGestureRecognizer(leftSwipe)
        self.productTitleLabel.superview?.superview?.superview?.superview?.addGestureRecognizer(rightSwipe)
        
        DispatchQueue.main.async {
            self.buyProView.layer.cornerRadius = 10
            self.buyProutton.layer.cornerRadius = 10
            
        }

        

        self.closeButton.alpha = navigationController == nil ? 1 : 0
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    @objc func productSwipped(_ sender: UISwipeGestureRecognizer) {

        let leftSwipe = selectedProduct == (allProducts.count - 1) ? (allProducts.count - 1) : selectedProduct + 1
        let rightSwipe = selectedProduct == 0 ? 0 : selectedProduct - 1
        selectedProduct = sender.direction == .left ? leftSwipe : rightSwipe
        DispatchQueue.main.async {
            self.pageChanged(self.pageControll)
        }
        
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
    }
    
    var fromSettings = false
    override func viewDidAppear(_ animated: Bool) {
        //did lo - transform - small
        super.viewDidAppear(true)
        showPurchasedIndicator()
        getProducts()
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        if fromSettings {

        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        //selectedProduct = sender.currentPage
        sender.currentPage = selectedProduct
        DispatchQueue.main.async {
            self.productTitleLabel.text = self.allProducts[sender.currentPage].0
            self.productDescriptionLabel.text = self.allProducts[sender.currentPage].1
            self.productImage.image = UIImage(named: self.allProducts[sender.currentPage].2)
        }
    }
    
    
    func getProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(["BudgetTrackerPro"]))
        self.requestProd = request
        request.delegate = self
        request.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSingIn" {
            //messagesFromOtherScreen
            if let vc = segue.destination as? LoginViewController {
                vc.messagesFromOtherScreen = "Sign in to use pro version across all your devices"
                vc.fromPro = true
            }
            
        }
    }
    
    @IBAction func tryFreePressed(_ sender: UIButton) {
        if !appData.proVersion {
            if appData.username != "" {

                self.ai.show { (_) in
                    let load = LoadFromDB()
                    load.Users { (loadedData, error) in
                        if error {

                            self.showAlert(title: "Internet error", text: "Try again later", error: true)
                        } else {
                            let nik = appData.username
                            for i in 0..<loadedData.count {
                                if loadedData[i][0] == nik {
                                    if loadedData[i][5] != "" {

                                        self.showAlert(title: "Access denied", text: "You have already tried trial version", error: true)
                                        return
                                    } else {
                                        self.userData = (loadedData[i][1], loadedData[i][2], loadedData[i][3], loadedData[i][5])
                                        self.performTrial()
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
                
            } else {
        /*        DispatchQueue.main.async {
                    
                    self.loadingIndicator.completeWithActions(buttonsTitles: ("No", "Sing in"), leftButtonActon: { (_) in
                        self.trialWithoutAcoount()
                    }, rightButtonActon: { (_) in
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toSingIn", sender: self)
                        }
                        
                    }, title: "Would you like to sign in?", description: "Sign in to try trial across all your devices")

                }*/
                let firstButton = IndicatorView.button(title: "No", style: .standart, close: true) { _ in
                    self.trialWithoutAcoount()
                }
                let secondButton = IndicatorView.button(title: "Sing in", style: .standart, close: true) { _ in
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toSingIn", sender: self)
                    }
                }
                
                DispatchQueue.main.async {
                    self.ai.completeWithActions(buttons: (firstButton, secondButton), title: "Would you like to sign in?", descriptionText: "Sign in to try trial across all your devices", type: .standard)
                }
            }
        }
    }
    
    
    func trialWithoutAcoount() {
        appData.proTrial = true
        appData.trialDate = appData.filter.getToday(appData.filter.filterObjects.currentDate)

        showAlert(title: "Success", text: "Trial has been started successfully", error: false, goHome: true)
     /*   self.loadingIndicator.completeWithActions(buttonsTitles: (nil, "Start"), rightButtonActon: { (_) in
            self.loadingIndicator.hideIndicator(fast: true) { (co) in
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
                    self.performSegue(withIdentifier: "homeVC", sender: self)
                }
            }
        }, title: "Success", description: "Trial has been started successfully")*/
        
    }
    
    func performTrial() {
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let save = SaveToDB()
        let toDataStringMian = "&Nickname=\(appData.username)" + "&Email=\(self.userData.0)" + "&Password=\(self.userData.1)" + "&Registration_Date=\(self.userData.2)"
        
        let dataStringSave = toDataStringMian + "&ProVersion=0" + "&trialDate=\(today)"
        print(dataStringSave)
        save.Users(toDataString: dataStringSave ) { (error) in
            if error {
                appData.unsendedData.append(["saveUser": dataStringSave])
            }
            let delete = DeleteFromDB()
            let dataStringDelete = toDataStringMian + "&ProVersion=0" + "&trialDate="
            print(dataStringDelete)
            delete.User(toDataString: dataStringDelete) { (errorr) in
                if errorr {
                    appData.unsendedData.append(["deleteUser": dataStringDelete])
                }
                DispatchQueue.main.async {
                    appData.proTrial = true
                    appData.trialDate = today
                    self.showAlert(title: "Success", text: "Trial has been started successfully", error: false, goHome: true)

                }
            }
        }
    }
    

    
    var userData = ("","","","")
    @IBAction func buyPressed(_ sender: UIButton) {

        let nick = appData.username
        if !appData.proVersion {
            if appData.username == "" {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toSingIn", sender: self)
                }
            } else {
                /*DispatchQueue.main.async {
                    self.loadingIndicator.show()
                }*/
                self.ai.show { (_) in
                    let load = LoadFromDB()
                    load.Users { (loadedData, error) in
                        if !error {
                            for i in 0..<loadedData.count {
                                if loadedData[i][0] == nick {
                                    self.userData = (loadedData[i][1], loadedData[i][2], loadedData[i][3], loadedData[i][5])
                                    break
                                }
                            }
                            print("buyPressed")
                            guard let myProduct = self.proVProduct else {
                                return
                            }
                            if SKPaymentQueue.canMakePayments() {
                                print("can make true")
                                let payment = SKPayment(product: myProduct)
                                SKPaymentQueue.default().add(self)
                                SKPaymentQueue.default().add(payment)
                            } else {
                                print("go to restrictions")
                            }
                        } else {

                            self.showAlert(title: "Internet error", text: "Try again later", error: true)
                        }
                        
                    }
                }
                
                
                
                
            }
        } else {
            DispatchQueue.main.async {
                self.message.showMessage(text: "You have already purchased pro version", type: .succsess, windowHeight: 65)
            }
        }
        
        
    }
    
    let restoreRequest = SKReceiptRefreshRequest()
    @IBAction func restorePressed(_ sender: UIButton) {
        print("restorePressed")
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
            SKPaymentQueue.default().add(self)

            self.ai.show { (_) in
                self.restoreRequest.delegate = self
                self.restoreRequest.start()
            }
            
        } else {
            print("go to restrictions")
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
      /*  DispatchQueue.main.async {
            self.loadingIndicator.completeWithActions(buttonsTitles: (nil, "OK"), rightButtonActon: { (_) in
                self.loadingIndicator.hideIndicator(fast: true) { (co) in
                    
                }
            }, title: "Payment not found", error: true)
        }*/
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break

            case .purchased, .restored:
                print("paymentQueue pur succss")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                appData.proVersion = true
                appData.purchasedOnThisDevice = true

                DispatchQueue.init(label: "DB").async {
                    let save = SaveToDB()
                    let toDataStringMian = "&Nickname=\(appData.username)" + "&Email=\(self.userData.0)" + "&Password=\(self.userData.1)" + "&Registration_Date=\(self.userData.2)"
                    
                    let dataStringSave = toDataStringMian + "&ProVersion=1" + "&trialDate=\(self.userData.3)"
                    print(dataStringSave)
                    save.Users(toDataString: dataStringSave ) { (error) in
                        if error {
                            appData.unsendedData.append(["saveUser": dataStringSave])
                        }
                        let delete = DeleteFromDB()
                        let dataStringDelete = toDataStringMian + "&ProVersion=0" + "&trialDate=\(self.userData.3)"
                        print(dataStringDelete)
                        delete.User(toDataString: dataStringDelete) { (errorr) in
                            if errorr {
                                appData.unsendedData.append(["deleteUser": dataStringDelete])
                            }
                            DispatchQueue.main.async {
                                self.showPurchasedIndicator()
                                self.showAlert(title: "Success", text: "Pro features available across all your devices", error: false, goHome: true)
                          /*      self.loadingIndicator.completeWithActions(buttonsTitles: (nil, "Start"), rightButtonActon: { (_) in
                                    self.loadingIndicator.hideIndicator(fast: true) { (co) in
                                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
                                            self.performSegue(withIdentifier: "homeVC", sender: self)
                                        }
                                    }
                                }, title: "Success", description: "Pro features available across all your devices")*/
                            }
                        }
                    }
                    
                }
                
                break
            case .failed, .deferred:
                print("paymentQueue pur ERROR")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                DispatchQueue.main.async {

                    self.showAlert(title: "Payment failed", text: nil, error: true)
                }
                break
            default:
                DispatchQueue.main.async {
                    self.ai.hideIndicator(fast: true) { (_) in
                        SKPaymentQueue.default().finishTransaction(transaction)
                        SKPaymentQueue.default().remove(self)
                    }
                }
            }
        }
    }
}

