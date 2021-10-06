//
//  splitVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 05.10.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit


class SplitVC: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let w:CGFloat = 50.0
        maximumPrimaryColumnWidth = w + 10;
        minimumPrimaryColumnWidth = w;
        preferredPrimaryColumnWidthFraction = 60
        preferredDisplayMode = .allVisible
        maximumPrimaryColumnWidth = 60
        if #available(iOS 14.0, *) {
            preferredPrimaryColumnWidth = 50.0
        }
        
    }
}
