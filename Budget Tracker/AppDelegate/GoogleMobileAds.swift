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
    func addBannerViewToView(_ bannerView: GADBannerView) {
        let windoww = window ?? UIWindow()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        windoww.addSubview(bannerView)

        windoww.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: windoww.safeAreaLayoutGuide,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: windoww,
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
