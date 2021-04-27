//
//  buyProVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 27.03.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import StoreKit

class BuyProVC: UIViewController {
    
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
    lazy var ai : LoadingIndicator = {
        return LoadingIndicator(superView: self.view)
    }()
    
    override func viewDidLoad() {
        DispatchQueue.main.async {
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
        
        
        

            /* if #available(iOS 13.0, *) {
        } else {
            closeButton.alpha = 1
        }*/
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        //did lo - transform - small
        showPurchasedIndicator()
        getProducts()
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
                vc.messagesFromOtherScreen = "Log in or create an account before purchasing"
                vc.fromPro = true
            }
            
        }
    }
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    var userData = ("","","","")
    @IBAction func buyPressed(_ sender: UIButton) {

        let nick = appData.username
        if !appData.proVersion {
            if appData.username == "" {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toSingIn", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    self.ai = LoadingIndicator(superView: self.view)
                    self.ai.showIndicator()
                }
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
                        DispatchQueue.main.async {
                            self.ai.completeWithDone(title: "Internet Error") { (_) in
                            }
                        }
                    }
                    
                }
                
                
            }
        } else {
            DispatchQueue.main.async {
                self.message.showMessage(text: "You have already purchased Pro version", type: .succsess, windowHeight: 65)
            }
        }
        
        
    }
    
    let restoreRequest = SKReceiptRefreshRequest()
    @IBAction func restorePressed(_ sender: UIButton) {
        print("restorePressed")
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
            SKPaymentQueue.default().add(self)
            DispatchQueue.main.async {
                self.ai = LoadingIndicator(superView: self.view)
                self.ai.showIndicator()
            }
            restoreRequest.delegate = self
            restoreRequest.start()
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
        DispatchQueue.main.async {
            self.ai.completeWithDone(title: "Payment not found", error: true) { (_) in
                //if not logged in - show log in button
            }
        }
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
                                self.ai.completeWithDone(title: "Success!", description: "Pro features available across all your devices") { (_) in
                                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
                                        self.performSegue(withIdentifier: "homeVC", sender: self)
                                    }
                                }
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
                    self.ai.completeWithDone(title: "Payment Error", error: true) { (_) in
                        
                    }
                }
                break
            default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                DispatchQueue.main.async {
                    self.ai.fastHideIndicator { (_) in
                        
                    }
                }
            }
        }
    }
}

