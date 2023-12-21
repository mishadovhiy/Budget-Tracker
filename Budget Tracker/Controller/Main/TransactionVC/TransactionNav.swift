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
        AppDelegate.shared?.properties?.banner.hide(ios13Hide: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppDelegate.shared?.properties?.banner.appeare(force: true)
    }

}

extension TransactionNav {
    static func configure(_ root:UIViewController) -> TransactionNav {
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "transactionsVCNav") as! TransactionNav
        return vc*/
        let nav = TransactionNav(rootViewController: root)
        return nav
    }
}
