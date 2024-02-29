//
//   UIKeyboardHIDUsage.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

@available(iOS 13.4, *)
extension UIKeyboardHIDUsage {
    var number:Int? {
        switch self {
        case .keyboard0: return 0
        case .keyboard1: return 1
        case .keyboard2: return 2
        case .keyboard3: return 3
        case .keyboard4: return 4
        case .keyboard5: return 5
        case .keyboard6: return 6
        case .keyboard7: return 7
        case .keyboard8: return 8
        case .keyboard9: return 9
        default:
            return nil
        }
    }
}
