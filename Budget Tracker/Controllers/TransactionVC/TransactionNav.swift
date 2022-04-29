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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.shared?.banner.hide(ios13Hide: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppDelegate.shared?.banner.appeare(force: true)
    }

}
