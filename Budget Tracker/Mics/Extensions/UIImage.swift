//
//  UIImage.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 16.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(_ systemName: String?, errorName:String = "photo.fill") {
        let def = errorName
        let namee = systemName ?? def
        let resultName = namee != "" ? namee : def
        if #available(iOS 13.0, *) {
            if let _ = UIImage(systemName: resultName) {
                self.init(systemName: resultName)
            } else if let _ = UIImage(named: resultName) {
                self.init(named: resultName)
            } else if def != "" {
                print(systemName, " notfoundimg")
                if let _ = UIImage(systemName: def) {
                    self.init(systemName: def)
                } else if let _ = UIImage(named: def) {
                    self.init(named: def)
                } else {
                    print(systemName, " notfoundimg")
                    self.init(named: "warning")
                }
            } else {
                self.init()
            }
        } else {
            self.init(named: "warning")
        }
        
    }
    
}
