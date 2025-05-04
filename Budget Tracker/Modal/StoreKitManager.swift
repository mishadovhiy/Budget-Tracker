//
//  StoreKitManager.swift
//  Budget Tracker
//
//  Created by Mykhailo Dovhyi on 04.05.2025.
//  Copyright © 2025 Misha Dovhiy. All rights reserved.
//

import StoreKit

struct StorekitModel {
    func requestReview() {
        #if os(watchOS)
        #else
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        {
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: windowScene)
            } else {
                SKStoreReviewController.requestReview()
            }
        }
        #endif
    }
}
