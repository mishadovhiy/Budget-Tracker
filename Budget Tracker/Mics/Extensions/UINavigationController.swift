//
//  UINavigationController.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationBar.tintColor = K.Colors.category
        self.navigationBar.barStyle = .black
        if #available(iOS 14.0, *) {
            self.navigationBar.backItem?.backButtonDisplayMode = .minimal
        }
        self.navigationBar.barTintColor = K.Colors.primaryBacground
        self.navigationBar.backgroundColor = K.Colors.primaryBacground

        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
       // self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
       
    }
}
