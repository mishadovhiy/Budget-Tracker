//
//  MacExtension.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.05.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


extension TransitionVC {
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        print(key.characters, "key.characterskey.characters")
        if let _ = key.isNum() {
            numberPressed(v: key.characters)
        } else {
            switch key.keyCode {
            case .keyboardDeleteOrBackspace, .keyboardBackslash:
                erace(all: false)
            case .keyboardReturnOrEnter, .keypadEnter:
                donePressedd()
            case .keyboardEscape:
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            default:
                super.pressesBegan(presses, with: event)
            }
        }
        
    }
}
