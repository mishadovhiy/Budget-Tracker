//
//  SuperViewController.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SuperViewController: UIViewController {

    lazy var loadingIndicator: IndicatorView = {
        let newView = IndicatorView.instanceFromNib() as! IndicatorView
        return newView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow ?? UIWindow()
            self.loadingIndicator.alpha = 0
            window.addSubview(self.loadingIndicator)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.loadingIndicator.alpha = 1
        }
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        DispatchQueue.main.async {
            self.loadingIndicator.removeFromSuperview()
        }
    }
    
}
