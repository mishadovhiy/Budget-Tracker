//
//  adBannerView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import GoogleMobileAds

class adBannerView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet private weak var adStack: UIStackView!
    
    var size:CGFloat {
        get {
            return adHidden ? 0 : _size
        }
        set {
            _size = newValue
        }
    }
    var _size:CGFloat = 0
    var adHidden = true
    var adNotReceved = true
    

    public func createBanner() {
        GADMobileAds.sharedInstance().start { status in
            
            DispatchQueue.main.async {
                let height = self.backgroundView.frame.height
                print(status.description, " GADMobileAdsGADMobileAds status  / height:", height)
                let adSize = GADAdSizeFromCGSize(CGSize(width: 320, height: height))
                self.size = height
                let bannerView = GADBannerView(adSize: adSize)
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
                bannerView.rootViewController = AppDelegate.shared?.window?.rootViewController
                bannerView.load(GADRequest())
                bannerView.delegate = self
                self.adStack.addArrangedSubview(bannerView)
                let window = AppDelegate.shared?.window ?? UIWindow()
                window.addSubview(self)
                self.frame = window.frame
                DispatchQueue.main.async {
                    self.frame = self.backgroundView.frame
                    self.translatesAutoresizingMaskIntoConstraints = true
                }
               
                self.adStack.layer.cornerRadius = 4
                self.adStack.layer.masksToBounds = true
            }
        }
    }

    
    public func appeare(force:Bool = false) {
        
        var go:Bool {
            if #available(iOS 13.0, *) {
                return force && !appData.proEnabeled
            } else {
                return !appData.proEnabeled
            }
        }
        if go {
            adHidden = false
            DispatchQueue.main.async {
                self.alpha = 0
                UIView.animate(withDuration: 0.4) {
                    self.alpha = 1
                }
            }
        }

    }
    
    public func hide(remove:Bool = false, ios13Hide:Bool = false) {
        var go:Bool {
            if #available(iOS 13.0, *) {
                return (remove || appData.proEnabeled || ios13Hide) && !adHidden
            } else {
                return true
            }
        }
        if !adNotReceved && go {
            adHidden = true
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 0
                } completion: { _ in
                    if remove {
                        self.removeAd()
                    }
                    
                }
            }
        }

        
    }
    
    private func removeAd() {
        self.size = 0
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    @IBAction private func closePressed(_ sender: UIButton) {
        appData.presentBuyProVC(selectedProduct: 2)
    }
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "adBannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override init(frame: CGRect) {
        print("BannerInit")
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}



