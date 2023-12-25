//
//  AIAppearence_Extension.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 25.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import AlertViewLibrary
import UIKit

extension AIAppearence {
    static func create() -> AIAppearence {
        let view = K.Colors.background ?? .red
        let background = UIColor.black
        let separetor = (K.Colors.separetor ?? .red).withAlphaComponent(0.5)
        
        return .with({
            $0.defaultText = .with({
                $0.loading = "Loading".localize
                $0.okButton = "OK".localize
                $0.error = "Error".localize
                $0.success = "Success".localize
                $0.internetError = ("Internet error".localize, "Try again later".localize)
                $0.standart = "Done".localize
                
            })
            $0.additionalLaunchProperties = .with({
                $0.mainCorners = 9
                $0.zPosition = 1001
            })
            $0.colors = .generate({
                $0.loaderBackAlpha = 0.25
                $0.alertBackAlpha = 0.5
                $0.loaderView = view.lighter()
                $0.view = view
                $0.background = background
                $0.separetor = separetor
                $0.texts = .with({
                    $0.title = K.Colors.category ?? .red
                    $0.description = K.Colors.balanceT ?? .red
                })
                $0.buttom = .with({
                    $0.link = K.Colors.link
                    $0.normal = K.Colors.category ?? .red
                })
                
            })
        })
    }
}
