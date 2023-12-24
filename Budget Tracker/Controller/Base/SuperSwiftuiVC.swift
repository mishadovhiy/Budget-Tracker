//
//  SuperSwiftuiVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit
import SwiftUI

class SuperSwiftuiVC: SuperViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            addSwiftuiView(view: NetworkTestView())
        }
    }
    func addSwiftuiView(view:some View, toView:UIView? = nil) {
        let mainView = toView ?? self.view
        let hostingController = UIHostingController(rootView: view)
        addChild(hostingController)
        hostingController.view.frame = mainView?.bounds ?? .zero
        mainView?.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
