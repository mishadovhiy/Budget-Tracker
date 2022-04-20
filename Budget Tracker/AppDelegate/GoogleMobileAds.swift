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
            DispatchQueue.main.async {
                let banSize = GADAdSizeBanner
                self.bannerSize = banSize.size.height
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
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        let windoww = window ?? UIWindow()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        let backgroundV = UIView()
        bannerBacgroundView = backgroundV
        backgroundV.translatesAutoresizingMaskIntoConstraints = false
        
        windoww.addSubview(backgroundV)
        backgroundV.addSubview(bannerView)
        
        
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
       }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
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
