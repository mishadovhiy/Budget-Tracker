//
//  UIApplication.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIApplication {
    var sceneKeyWindow:UIWindow? {
        if !Thread.isMainThread {
            print("mainthreaderror")
        }
        let scene = self.connectedScenes.first(where: {
            let window = $0 as? UIWindowScene
            return window?.activationState == .foregroundActive && (window?.windows.contains(where: { $0.isKeyWindow && $0.layer.name == AppDelegate.properties?.selectedID}) ?? false)
        }) as? UIWindowScene
        return scene?.windows.last(where: {$0.isKeyWindow }) ?? ((self.connectedScenes.first as? UIWindowScene)?.windows.first)
    }
}
