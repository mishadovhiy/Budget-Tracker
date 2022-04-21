//
//  GoogleMobileAds.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 15.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import GoogleMobileAds


extension AppDelegate:GADBannerViewDelegate {
    //ads
    func implementAdd() {
        GADMobileAds.sharedInstance().start { status in
            print(status.description, " GADMobileAdsGADMobileAds status")
            let banSize = GADAdSizeBanner
            self.bannerSize = banSize.size.height
            DispatchQueue.main.async {
                let bannerView = GADBannerView(adSize: banSize)
                self.addBannerViewToView(bannerView)
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
                bannerView.rootViewController = self.window?.rootViewController
                bannerView.load(GADRequest())
                bannerView.delegate = self
            }
        }
    }
    
    
    @objc func closeBannerPressed() {
        appData.presentBuyProVC(selectedProduct: 2)
    }
    
    
    func hideAdd(remove:Bool = false, pro:Bool? = nil) {
        bannerHidden = true
        DispatchQueue.main.async {
            if let bannerSuperView = self.bannerSuperView {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .allowAnimatedContent) {
                bannerSuperView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, bannerSuperView.frame.height + ((self.window?.safeAreaInsets.bottom ?? 50) + 50), 0)
            } completion: { _ in
                if remove {
                    self.removeAdd(pro: pro)
                }
            }
            }
        }
    }
    func bannerAppeare() {
        bannerHidden = false
        DispatchQueue.main.async {
            if let bannerSuperView = self.bannerSuperView {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .allowAnimatedContent) {
                    self.bannerSuperView?.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                } completion: { _ in
                }
            }
            
        }
    }
    
    private func removeAdd(pro:Bool?) {
        let isPro = pro ?? appData.proEnabeled
        if isPro {
            self.bannerSize = 0
            DispatchQueue.main.async {
                self.bannerBacgroundView?.removeFromSuperview()
            }
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        let windoww = window ?? UIWindow()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        let backgroundV = UIView()
        bannerBacgroundView = backgroundV
        backgroundV.translatesAutoresizingMaskIntoConstraints = false
        
        windoww.addSubview(backgroundV)
        backgroundV.addSubview(bannerView)
        backgroundV.alpha = 0
        
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(K.Colors.category ?? .white, for: .normal)
        closeButton.target(forAction: #selector(closeBannerPressed), withSender: self)
        closeButton.addTarget(self, action: #selector(closeBannerPressed), for: .touchUpInside)
        backgroundV.addSubview(closeButton)
        
        
        windoww.addConstraints(
          [NSLayoutConstraint(item: closeButton,
                              attribute: .left,
                              relatedBy: .equal,
                              toItem: backgroundV.safeAreaLayoutGuide,
                              attribute: .left,
                              multiplier: 1,
                              constant: 10),
           NSLayoutConstraint(item: closeButton,
                              attribute: .centerY,
                              relatedBy: .equal,
                              toItem: backgroundV,
                              attribute: .centerY,
                              multiplier: 1,
                              constant: 0)
          ,
         ])
        windoww.addConstraints(
          [NSLayoutConstraint(item: backgroundV,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: windoww.safeAreaLayoutGuide,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: backgroundV,
                              attribute: .right,
                              relatedBy: .equal,
                              toItem: windoww.safeAreaLayoutGuide,
                              attribute: .right,
                              multiplier: 1,
                              constant: 0)
          ,
          NSLayoutConstraint(item: backgroundV,
                             attribute: .left,
                             relatedBy: .equal,
                             toItem: windoww.safeAreaLayoutGuide,
                             attribute: .left,
                             multiplier: 1,
                             constant: 0)
         ]
        )
       
        windoww.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: backgroundV.safeAreaLayoutGuide,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .top,
                              relatedBy: .equal,
                              toItem: backgroundV.safeAreaLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: backgroundV,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
        
        
        backgroundV.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, backgroundV.frame.height + (windoww.safeAreaInsets.bottom + 50), 0)
        backgroundV.alpha = 1
        self.bannerSuperView = backgroundV

       }
    
    
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
        bannerAppeare()
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
    
}
