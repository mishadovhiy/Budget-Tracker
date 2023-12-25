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
            AppDelegate.properties?.appData.present(vc: activityViewController, completion: completion)
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


extension UIViewController {
    var popupBackgroundColor:UIColor {
        return K.Colors.popupBackground ?? .blue
    }
    
    
    /**
     creates view on window
     */
    func createPopupBackgroundView(_ data:VCpresentedBackgroundData) {
        if let superVC = self as? SuperViewController {
            superVC.backgroundData = data
        }
        let win = UIApplication.shared.keyWindow ?? UIWindow()
        let window = win
       // data.fromWindow ? win : (TabBarController.shared?.view ?? UIView())
        let supWindow = win
        let backColor = popupBackgroundColor
        

        
        let backgroundView = UIView(frame: .init(x: 0, y: -80, width: supWindow.frame.width, height: supWindow.frame.height + 80))
        backgroundView.backgroundColor = backColor
        backgroundView.alpha = 0
        backgroundView.layer.name = data.id
        backgroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundPressed(_:)))
        tap.name = data.id
        backgroundView.addGestureRecognizer(tap)
        window.addSubview(backgroundView)
        UIView.animate(withDuration: 0.3) {
            backgroundView.alpha = data.alpha
        }
    }
    /**
     removes view from the window
     */
    func removePopupBackgroundView(_ data:VCpresentedBackgroundData) {
        self.togglePresentedBackgroundView(.init(show: false, id: data.id, fromWindow: data.fromWindow, completion: {
            $0.0.removeFromSuperview()
            $0.1?.removeFromSuperview()
        }))
    }
    
    func togglePresentedBackgroundView(_ data:VCpresentedBackgroundData) {
        let sup = UIApplication.shared.keyWindow ?? UIWindow()
        guard let background = sup.subviews.first(where: { view in
            return view.layer.name == data.id
        }) else { return }

        UIView.animate(withDuration: 0.3, animations: {
            background.alpha = data.show ? 1 : 0
        }) { _ in
            if let comp = data.completion {
                comp((background, nil))
            }
        
        }
    }
    
    
    struct VCpresentedBackgroundData {
        var isPopupVC = false
        var show:Bool = false
        var id = "VCbackgroundView"
        var fromWindow = false
        /**
         for  createPopupBackgroundView method
         */
        var alpha:CGFloat = 1
        var completion:((_ views:(UIView, UIView?))->())? = nil
    }
    
    @objc private func backgroundPressed(_ sender:UITapGestureRecognizer) {
        self.removePopupBackgroundView(.init(id: sender.name ?? "VCbackgroundView", fromWindow: false))
        self.removePopupBackgroundView(.init(id: sender.name ?? "VCbackgroundView", fromWindow: true))
        self.dismiss(animated: true)
    }
}
