//
//  UITableView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 25.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UITableView {

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        self.contentInset.bottom = AppDelegate.shared?.bannerSize ?? 0
    }
}
