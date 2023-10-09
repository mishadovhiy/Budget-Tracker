//
//  ExtensionGADBannerViewDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension adBannerView:GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print(#function)
        if adHidden && adNotReceved {
            adNotReceved = false
            appeare(force: true)
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("\(#function): \(error.localizedDescription)")
        
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print(#function)
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print(#function)
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print(#function)
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print(#function)
    }
}
