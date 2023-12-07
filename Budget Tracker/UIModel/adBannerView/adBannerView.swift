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
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet private weak var adStack: UIStackView!
    
    private var presentingFullType:FullScreenBanner?
    private weak var rootVC:UIViewController?
    private var showedBannerTime:Data?
    var bannerWatchedFull:Bool = false
    var smallAddHideHolder:Bool = true
    var fullScreenDelegates:[String:FullScreenDelegate] = [:]
    
    let videoShowDelay:Double = 3 * 60
    var _size:CGFloat = 0
    var adHidden = true
    var adNotReceved = true
    //private var showedBanner:[FullScreenBanner:Date] = [:]
    private var showedBanner:Date?
    private var bannerShowCompletion:((_ presented:Bool)->())?
    var clearBackground = true
    
    
    private func remove() {
        rootVC = nil
        presentingFullType = nil
        showedBannerTime = nil
        showedBanner = nil
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        if firstMovedSuperview {
            remove()
        }
    }
    
    
    private var firstMovedSuperview = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !firstMovedSuperview {
            firstMovedSuperview = true
        }
    }
    private var id:String {
        (AppDelegate.shared?.appData.devMode ?? false) ? "ca-app-pub-3940256099942544/2934735716" : "ca-app-pub-5463058852615321/8457751935"
    }
    
    deinit {
        remove()
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
    
    func toggleFullScreenAdd(_ vc:UIViewController, type:FullScreenBanner, loaded:@escaping(GADFullScreenPresentingAd?)->(), closed:@escaping(_ presented:Bool)->()) {
        bannerCanShow(type: type) { show in
            if show {
                self.bannerShowCompletion = closed
                self.presentingFullType = type
                if !self.adHidden {
                    self.smallAddHideHolder = self.adHidden
                    self.hide(ios13Hide: true, completion: {
                        self.presentFullScreen(vc, loaded: loaded)
                    })
                } else {
                    self.smallAddHideHolder = self.adHidden
                    self.presentFullScreen(vc, loaded: loaded)

                }
                
            } else {
                closed(false)
            }
        }
        
    }

    
    
    public func appeare(force:Bool = false, completion:(()->())? = nil) {
        
        var go:Bool {
            if #available(iOS 13.0, *) {
                return force && !(AppDelegate.shared?.appData.proEnabeled ?? false)
            } else {
                return !(AppDelegate.shared?.appData.proEnabeled ?? false)
            }
        }
     //   DispatchQueue(label: "db", qos: .userInitiated).async {
            if go {
                self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.toHide, 0)
                self.isHidden = false

                self.adHidden = false
             //   DispatchQueue.main.async {
                UIView.animate(withDuration: 0.6, delay: 0.01, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
                        //self.alpha = 1
                        self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                    }, completion: {
                        if !$0 {
                            return
                        }
                        completion?()
                    })
              //  }
            } else {
                completion?()
            }
      //  }
    }
    
    public func hide(remove:Bool = false, ios13Hide:Bool = false, completion:(()->())? = nil) {
        
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
                UIView.animate(withDuration: 0.3) {
                    // self.alpha = 0
                    self.backgroundView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.toHide, 0)
                } completion: { 
                    if !$0 {
                        return
                    }
                    self.isHidden = true
                    if remove {
                        self.removeAd()
                    }
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    private var toHide:CGFloat {
        let window = AppDelegate.shared?.window ?? UIWindow()
        return window.frame.height
    }
    
    
    func setBackground(clear:Bool) {
        clearBackground = clear
        UIView.animate(withDuration: 0.3) {
            AppDelegate.shared?.banner.backgroundView.backgroundColor = clear ? .clear : K.Colors.primaryBacground
        }
    }
    
    
    func changeBannerPosition(top:Bool) {
        let wind = AppDelegate.shared?.window ?? UIWindow()
        let safeAreas = wind.safeAreaInsets.top + size + wind.safeAreaInsets.bottom + (HomeVC.shared?.navigationController?.navigationBar.frame.height ?? 0)
        let topPosition = (wind.frame.height - (safeAreas + 5)) * -1
        
        guard let constant = wind.constraints.first(where: {$0.firstAttribute == .bottom}) else {
            return
        }
     //   wind.fadeTransition(0.3)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            
            constant.constant = top ? topPosition : 0
            wind.layoutIfNeeded()
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
                HomeVC.shared?.bannerUpdated(newValue)
            }
        }
    }
    
    
    
    private func removeAd() {
        self.size = 0
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    

    
    
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
    
    func bannerCanShow(type:FullScreenBanner, completion:@escaping(_ show:Bool)->()) {
        DispatchQueue(label: "db",  qos: .userInitiated).async {
            if !(AppDelegate.shared?.appData.proEnabeled ?? false) {
                if let from = self.showedBanner {
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
    

}



extension adBannerView {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        bannerWatchedFull = false
        showedBannerTime = Data()
        AppDelegate.shared?.ai.fastHide()
        let shape = AppDelegate.shared?.window?.layer.drawSeparetor(color: K.Colors.link, y: AppDelegate.shared?.window?.safeAreaInsets.top, width: 3)
        shape?.name = "adFullBanerLine"
        shape?.performAnimation(key: .stokeEnd, to: CGFloat(1), code: .general, duration: 10, completion: {
            self.bannerWatchedFull = true
            UIView.animate(withDuration: 0.3) {
                shape?.strokeColor = UIColor.green.cgColor
            }
         //   shape?.performAnimation(key: .background, to: UIColor.green.cgColor, duration: 0.4)
        })
    }
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidDismissFullScreenContent")
        let holderCompletion = bannerShowCompletion
        bannerShowCompletion = nil
        let layer = AppDelegate.shared?.window?.layer.sublayers?.first(where: {$0.name == "adFullBanerLine"})
        
        if let _ = presentingFullType {
            //self.showedBanner.updateValue(Date(), forKey: type)
            if self.bannerWatchedFull {
                self.showedBanner = Date()
                self.fullScreenDelegates.forEach({
                    $0.value.toggleAdView(false)
                })
                Timer.scheduledTimer(withTimeInterval: videoShowDelay, repeats: false, block: { _ in
                    self.fullScreenDelegates.forEach({
                        $0.value.toggleAdView(true)
                    })
                })
                if !smallAddHideHolder && presentingFullType != .pdf {
                    self.appeare(force: true) {
                        holderCompletion?(true)

                    }
                } else {
                    holderCompletion?(true)
                }
            } else {
                AppDelegate.shared?.newMessage.show(title:"Ad not watched till the end", type: .error)

                self.appeare(force: true)
            }
            presentingFullType = nil
        }
        UIView.animate(withDuration: 0.6, animations: {
            layer?.opacity = 0
        }, completion: { 
            if !$0 {
                return
            }
            layer?.removeAllAnimations()
            layer?.removeFromSuperlayer()
        })

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
    case categoryLimit
    
    var alertMessage:MessageContent {
        switch self {
        case .pdf:
            return .init(title: "Watch Ad needed", description: "to create PDF you have to watch 10 seconds ad")
        case .paymentReminder:
            return .init(title: "Watch Ad needed", description: "to add new Payment Reminder you have to watch 10 seconds ad")

        case .categoryLimit:
            return .init(title: "Watch Ad needed", description: "")
        }
    }
}


