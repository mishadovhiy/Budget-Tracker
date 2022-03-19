//
//  NavigationItem.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//


import UIKit

@IBDesignable
class NavigationItem:UINavigationItem {
    
    @IBInspectable
    open override var title: String? {
        set {
            super.title = newValue?.localize
        }
        get {
            return super.title
        }
    }
}
