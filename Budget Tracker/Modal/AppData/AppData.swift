//
//  AppData.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//
#if canImport(UIKit)
import UIKit
#endif
import Foundation


class AppData {
    fileprivate var db:DataBase {
        return AppDelegate.properties?.db ?? .init()
    }
    
    var sendSavedData = false
    var needDownloadOnMainAppeare = false
    var needFullReload = false
    lazy var screenColors = categoryColors
    var fromLoginVCMessage = ""
    var backgroundEnterDate:Date?
    var becameActive = false
    
    var resultSafeArea: (CGFloat, CGFloat) {
#if os(iOS)
        let safe = UIApplication.shared.sceneKeyWindow?.safeAreaInsets ?? .zero
        let btn = safe.top + (AppDelegate.properties?.banner.size ?? 0)
        return (btn, safe.bottom)
        #else
        return (0, 0)
        #endif
        
    }
    
    static func toDeviceSettings() {
#if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:]) { _ in
                
            }
        }
        #endif
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
#if os(iOS)
    func present(vc:UIViewController, presentingVC:UIViewController? = nil, completion:(()->())? = nil) {
        let window = UIApplication.shared.sceneKeyWindow!
        if let presentingVC = presentingVC {
            if let presentVC = presentingVC.presentedViewController {
                self.present(vc: vc, presentingVC: presentVC, completion: completion)
            } else {
                presentingVC.present(vc, animated: true, completion: completion)
            }
        } else if let presenting = window.rootViewController?.presentedViewController {
        //    presenting.dismiss(animated: true, completion: {
            self.present(vc: vc, presentingVC: presenting, completion: completion)
               // self.present(vc: vc, completion: completion)
         //   })
        } else {
            window.rootViewController?.present(vc, animated: true, completion: completion)
        }
    }
    #endif
    func threadCheck(shouldMainThread:Bool = true, showError:Bool = true) {
        let error = shouldMainThread != Thread.isMainThread
        if error {
            print("!!!!!!!!!!!errororor api")
#if os(iOS)
            if (AppDelegate.properties?.db.devMode ?? false) && showError {
                if !Thread.isMainThread {
                    DispatchQueue.main.async {
                        AppDelegate.properties?.newMessage.show(title:"fatal error, from main", type: .error)

                    }
                } else if showError {
                    AppDelegate.properties?.newMessage.show(title:"fatal error, from main", type: .error)

                }
            }
            #endif
        }
    }

}


extension AppData {
    func presentBuyProVC(selectedProduct:Int) {
        #if os(iOS)
        BuyProVC.presentBuyProVC(selectedProduct: selectedProduct)
        #endif
    }
}



extension AppData {
    enum DeviceType:String {
        case primary = "primary"
        case underIos13 = "underIos13"
        case mac = "mac"
    }
}
