//
//  ExtensionIndicatorView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension IndicatorView {
    func showAlertWithOK(title:String? = nil,text:String? = nil, error: Bool, okTitle:String = "OK", hidePressed:((Bool)->())? = nil) {
        let alertTitle = title ?? (error ? "Error".localize : Text.success)
        DispatchQueue.main.async {
            self.showAlertWithOK(title: alertTitle, text: text, error: error, okTitle: okTitle, hidePressed: hidePressed)
        }
    }
    
    func prebuild_closeButton(title:String = "OK", style:ButtonType = .regular) -> button {
        return .init(title: title, style: style, close: true) { _ in }
    }
    
}

extension IndicatorView {
    
    enum Image:String {
        case error = "warning"
        case succsess = "success"
        case message = "vxc"
    
    }

    enum ViewType {
        /**
         - higligting background
         */
        case error
        /**
         - higligting background
         */
        case internetError
        case succsess
        case standard
        /**
         - error type without higlight
         */
        case standardError
        case ai
    }
    
    
    
    struct button {
        let title: String
        var style: ButtonType
        var close: Bool = true
        let action: ((Bool) -> ())?
    }
    enum ButtonType {
        case error
        case regular
        case link
    }
}
