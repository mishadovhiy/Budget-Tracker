//
//  UINavigationController.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UINavigationController {
    enum AppNavigationBacground {
        case regular
        case clear
    }
    
    func setBackground(_ background:AppNavigationBacground) {
        switch background {
        case .clear:
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.backgroundColor = UIColor.clear
            navigationBar.isTranslucent = true
        case .regular:
            self.navigationBar.tintColor = K.Colors.category
            self.navigationBar.barStyle = .black
            if #available(iOS 14.0, *) {
                self.navigationBar.backItem?.backButtonDisplayMode = .minimal
            }
            self.navigationBar.barTintColor = K.Colors.primaryBacground
            self.navigationBar.backgroundColor = K.Colors.primaryBacground
            
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
        }
    }
}

class NavigationController: UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setBackground(.regular)
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        var holder = self.viewControllers
        super.popViewController(animated: animated)
        viewControllers.forEach({ vc in
            holder.removeAll(where: {vc == $0})
        })
        holder.forEach({
            if let vc = $0 as? SuperViewController {
                vc.navigationPopVC()
            }
        })
        return self.topViewController
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        super.popToRootViewController(animated: animated)
        return self.viewControllers
    }
}
