//
//  UIViewController.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
extension UIActivityIndicatorView {
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        self.hidesWhenStopped = true
    }
}
extension UIViewController {
    
    func presentShareVC(vcc:UIViewController? = nil, with items:[Any], completion:(()->())? = nil, sender:UIView, dismissed:(()->())? = nil) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.popoverPresentationController?.sourceRect = .init(origin: .zero, size: self.view.frame.size)
        activityViewController.excludedActivityTypes = [ .airDrop, .postToFacebook, .copyToPasteboard, .mail, .message, .addToReadingList, .markupAsPDF, .openInIBooks, .postToFlickr, .postToTencentWeibo, .postToVimeo, .print, .saveToCameraRoll]
        if #available(iOS 16.4, *) {
            activityViewController.excludedActivityTypes?.append(.addToHomeScreen)
            activityViewController.excludedActivityTypes?.append(.sharePlay)
            
        }
        
        
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            dismissed?()
        }
        if let vc = vcc {
            vc.present(activityViewController, animated: true, completion: completion)
        } else {
            AppDelegate.shared?.present(vc: activityViewController, completion: completion)
        }
        
    }
    
    var previousViewController:UIViewController?{
        if let controllersOnNavStack = self.navigationController?.viewControllers{
            let n = controllersOnNavStack.count
            //if self is still on Navigation stack
            if controllersOnNavStack.last === self, n > 1{
                return controllersOnNavStack[n - 2]
            }else if n > 0{
                return controllersOnNavStack[n - 1]
            }
        }
        return nil
    }
    
    
    static var panIndicatorLayerName:String = "PanIndicatorViewPrimary"
    
    func createPanIndicator() {
        if !self.view.subviews.contains(where: {$0.layer.name == UIViewController.panIndicatorLayerName}) {
            let view = UIView()
            view.isUserInteractionEnabled = false
            view.backgroundColor = .white.withAlphaComponent(0.4)
            view.layer.cornerRadius = 2
            view.layer.name = UIViewController.panIndicatorLayerName
            view.alpha = 0.1
            self.view.addSubview(view)
            // let topMinus = self.navigationController?.navigationBar.frame.height ?? 0
            view.addConstaits([.top: view.safeAreaInsets.top + 10, .centerX:0, .width:45, .height:4], superV: self.view)
        }
        
    }
}
