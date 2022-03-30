//
//  ExtensionIndicatorView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension IndicatorView {
    func showAlert(title:String? = nil,text:String? = nil, error: Bool) {
        
        let resultTitle = title == nil ? (error ? "Error".localize : "Success".localize) : title!
        
        let okButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in
        }
        
        DispatchQueue.main.async {
            self.completeWithActions(buttons: (okButton, nil), title: resultTitle, descriptionText: text, type: error ? .error : .standard)
        }

    }
}
