//
//  MacExtensions.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.05.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


extension ViewController {
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        print(key.characters, "key.characterskey.characters")
        switch key.keyCode {
        case .keyboardN:
            if !AppDelegate.shared!.passcodeLock.presenting {
                toAddTransaction()
            }
           
        default:
            super.pressesBegan(presses, with: event)
        }
        
    }
}
