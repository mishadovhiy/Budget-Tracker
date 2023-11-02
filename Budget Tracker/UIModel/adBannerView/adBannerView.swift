//
//  adBannerView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Combine
protocol FullScreenDelegate {
    func toggleAdView(_ show:Bool)
}
class adBannerView: UIView {
    var fullScreenDelegates:[String:FullScreenDelegate] = [:]
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet private weak var adStack: UIStackView!
    let videoShowDelay:Double = 20
    var _size:CGFloat = 0
    var adHidden = true
    var adNotReceved = true
    
    private var id:String {
        (AppDelegate.shared?.appData.devMode ?? false) ? "ca-app-pub-3940256099942544/2934735716" : "ca-app-pub-5463058852615321/8457751935"
    }
    
    public func createBanner() {
        GADMobileAds.sharedInstance().start { status in
            print(Thread.isMainThread, " createBannercreateBanner")
            let window = AppDelegate.shared?.window ?? UIWindow()
            let height = self.backgroundView.frame.height
            let screenWidth:CGFloat = window.frame.width > 330 ? 320 : 300
            let adSize = GADAdSizeFromCGSize(CGSize(width: screenWidth, height: height))
            self.size = height
            let bannerView = GADBannerView(adSize: adSize)
            bannerView.adUnitID = self.id
            bannerView.rootViewController =  AppDelegate.shared?.window?.rootViewController
            
            bannerView.delegate = self
            self.adStack.addArrangedSubview(bannerView)
            self.addConstants(window)
            self.adStack.layer.cornerRadius = 4
            self.adStack.layer.masksToBounds = true
            self.layer.zPosition = 999
            self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height, 0)
            bannerView.load(GADRequest())
        }
    }
    
    func toggleFullScreenAdd(_ vc:UIViewController, type:FullScreenBanner, loaded:@escaping(GADFullScreenPresentingAd?)->(), completion:@escaping()->()) {
        bannerCanShow(type: type) { show in
            if show {
                self.bannerShowCompletion = completion
                self.presentingFullType = type
                self.presentFullScreen(vc, loaded: loaded)
            } else {
                completion()
            }
        }
        
    }

    
    
    public func appeare(force:Bool = false) {
        
        var go:Bool {
            if #available(iOS 13.0, *) {
                return force && !(AppDelegate.shared?.appData.proEnabeled ?? false)
            } else {
                return !(AppDelegate.shared?.appData.proEnabeled ?? false)
            }
        }
        DispatchQueue(label: "db", qos: .userInitiated).async {
            if go {
                self.adHidden = false
                DispatchQueue.main.async {
                    self.isHidden = false
                    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .allowAnimatedContent) {
                        //self.alpha = 1
                        self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                    }
                }
            }
        }
    }
    
    public func hide(remove:Bool = false, ios13Hide:Bool = false) {
        
        var go:Bool {
            if #available(iOS 13.0, *) {
                return (remove || (AppDelegate.shared?.appData.proEnabeled ?? false) || ios13Hide) && !adHidden
            } else {
                return true
            }
        }
        if !adNotReceved && go {
            adHidden = true
            DispatchQueue.main.async {
                let window = AppDelegate.shared?.window ?? UIWindow()
                UIView.animate(withDuration: 0.3) {
                    // self.alpha = 0
                    self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, window.frame.height, 0)
                } completion: { _ in
                    self.isHidden = true
                    if remove {
                        self.removeAd()
                    }
                }
            }
        }
    }
    
    var clearBackground = true
    func setBackground(clear:Bool) {
        clearBackground = clear
        UIView.animate(withDuration: 0.3) {
            AppDelegate.shared?.banner.backgroundView.backgroundColor = clear ? .clear : K.Colors.primaryBacground
        }
    }
    
    

    

    var size:CGFloat {
        get {
            return adHidden ? 0 : _size
        }
        set {
            _size = newValue
            if #available(iOS 13.0, *) {
                BannerPublisher.valuePublisher.send(newValue)
            } else {
                ViewController.shared?.bannerUpdated(newValue)
            }
        }
    }
    
    
    
    private func removeAd() {
        self.size = 0
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    
    private var showedBanner:[FullScreenBanner:Date] = [:]
    
    private func presentFullScreen(_ vc:UIViewController, loaded:@escaping(GADFullScreenPresentingAd?)->()) {
        //here
        rootVC = vc
        let id = (AppDelegate.shared?.appData.devMode ?? false) ? "ca-app-pub-3940256099942544/4411468910" : "ca-app-pub-5463058852615321/8167495597"
        GADInterstitialAd.load(withAdUnitID: id, request: GADRequest()) { ad, error in
            loaded(ad)
            if error != nil {
                print(error ?? "-", "bannerror")
            }
            ad?.present(fromRootViewController: vc)
        }
    }
    
    private var bannerShowCompletion:(()->())?
    func bannerCanShow(type:FullScreenBanner, completion:@escaping(_ show:Bool)->()) {
        DispatchQueue(label: "db",  qos: .userInitiated).async {
            if !(AppDelegate.shared?.appData.proEnabeled ?? false) {
                if let from = self.showedBanner[type] {
                    let now = Date()
                    let dif = now.timeIntervalSince(from)
                    if dif >= self.videoShowDelay {
                        DispatchQueue.main.async {
                            completion(true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        
        
    }
    
    
    @IBAction private func closePressed(_ sender: UIButton) {
        AppDelegate.shared?.appData.presentBuyProVC(selectedProduct: 2)
    }
    
    
    
    private func addConstants(_ window:UIWindow) {
        window.addSubview(self)
        window.addConstraints([
            .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: window.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
            .init(item: self, attribute: .centerXWithinMargins, relatedBy: .equal, toItem: window.safeAreaLayoutGuide, attribute: .centerXWithinMargins, multiplier: 1, constant: 0),
            .init(item: self, attribute: .trailing, relatedBy: .equal, toItem: window.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0),
            .init(item: self, attribute: .leading, relatedBy: .equal, toItem: window.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0)
        ])
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "adBannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    private var presentingFullType:FullScreenBanner?
    private weak var rootVC:UIViewController?
    private var showedBannerTime:Data?
    private func adWatched() -> Bool {
        //10
        return true
    }
}



extension adBannerView {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        showedBannerTime = Data()
        AppDelegate.shared?.ai.fastHide()
    }
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidDismissFullScreenContent")
        bannerShowCompletion?()
        bannerShowCompletion = nil
        if let type = presentingFullType {
            self.showedBanner.updateValue(Date(), forKey: type)
            if self.adWatched() {
                self.fullScreenDelegates.forEach({
                    $0.value.toggleAdView(false)
                })
                Timer.scheduledTimer(withTimeInterval: videoShowDelay, repeats: false, block: { _ in
                    self.fullScreenDelegates.forEach({
                        $0.value.toggleAdView(true)
                    })
                })
            }
            presentingFullType = nil
//here
        }

    }
}







@available(iOS 13.0, *)
struct BannerPublisher {
    static var valuePublisher = PassthroughSubject<CGFloat, Never>()
    static var cancellableHolder = Set<AnyCancellable>()
}


enum FullScreenBanner {
    case pdf
    case paymentReminder
    var alertMessage:MessageContent {
        switch self {
        case .pdf:
            return .init(title: "Watch Ad needed", description: "to create PDF you have to watch 10 seconds ad")
        case .paymentReminder:
            return .init(title: "Watch Ad needed", description: "to add new Payment Reminder you have to watch 10 seconds ad")

        }
    }
}


