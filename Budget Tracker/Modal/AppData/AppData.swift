//
//  AppData.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import Foundation


class AppData {
    var db:DataBase {
        return AppDelegate.shared?.properties?.db ?? .init()
    }
    
    var sendSavedData = false
    var needDownloadOnMainAppeare = false
    var needFullReload = false
    lazy var screenColors = categoryColors
    var fromLoginVCMessage = ""
    var backgroundEnterDate:Date?
    var becameActive = false
    
    var resultSafeArea: (CGFloat, CGFloat) {
        let safe = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        let btn = safe.top + (AppDelegate.shared?.properties?.banner.size ?? 0)
        return (btn, safe.bottom)
    }
    
    static func toDeviceSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:]) { _ in
                
            }
        }
    }

    let categoryColors = [
        "BlueColor", "BlueColor2", "BlueColor3", "GreenColor", "GreenColor-2", "yellowColor2", "OrangeColor", "yellowColor", "OrangeColor-1", "pinkColor2", "PinkColor-1", "PinkColor", "RedColor", "Brown"
    ]
    
    public lazy var deviceType:DeviceType = {
        if #available(iOS 13.0, *) {
#if !os(iOS)
            return .mac
#endif
            return .primary
        } else {
            return .underIos13
        }
    }()
    
    public lazy var symbolsAllowed:Bool = {
        return deviceType != .primary ? false : true
    }()
    
    
    
}



extension AppData {
    func present(vc:UIViewController, presentingVC:UIViewController? = nil, completion:(()->())? = nil) {
        let window = UIApplication.shared.keyWindow
        if let presentingVC = presentingVC {
            presentingVC.present(vc, animated: true, completion: completion)
        } else if let presenting = window?.rootViewController?.presentedViewController {
            presenting.dismiss(animated: true, completion: {
                self.present(vc: vc, completion: completion)
            })
        } else {
             window?.rootViewController?.present(vc, animated: true, completion: completion)
        }
    }

}


extension AppData {
    func presentBuyProVC(selectedProduct:Int) {
        BuyProVC.presentBuyProVC(selectedProduct: selectedProduct)
    }
}



extension AppData {
    enum DeviceType:String {
        case primary = "primary"
        case underIos13 = "underIos13"
        case mac = "mac"
    }
}
