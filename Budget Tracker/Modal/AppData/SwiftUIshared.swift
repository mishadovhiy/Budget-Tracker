//
//  SwiftUIshared.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 06.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
struct MyUIKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        // Create and return your UIKit view here
        let uiView = UIView()
        let label = UILabel()
        uiView.addSubview(label)
        label.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: uiView)
        label.text = "\(AppData().db.transactions.count)"
        // Customize your UIKit view if needed
        return uiView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the UIKit view when SwiftUI properties change
        // You can configure and update the view here
    }
    

}
