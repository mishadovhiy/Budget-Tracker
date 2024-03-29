//
//  SceneDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = BaseWindow.init(windowScene: windowScene)
        window?.layer.name = UUID().uuidString
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationController")
        AppDelegate.properties?.selectedID = window?.layer.name ?? ""
        window?.makeKeyAndVisible()
    }


    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
        print("uyefrdwsx fred")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        AppDelegate.properties?.becomeActive()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        AppDelegate.properties?.receinActive()
    }
    
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        AppDelegate.shared.application(UIApplication.shared, performActionFor: shortcutItem, completionHandler: completionHandler)
    }
}

class BaseWindow:UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        AppDelegate.properties?.selectedID = layer.name ?? ""
        return super.hitTest(point, with: event)
    }
}
