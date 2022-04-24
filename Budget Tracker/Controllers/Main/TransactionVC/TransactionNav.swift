//
//  TransactionNav.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class TransactionNav: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.shared?.banner.hide()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppDelegate.shared?.banner.appeare()
    }

}
