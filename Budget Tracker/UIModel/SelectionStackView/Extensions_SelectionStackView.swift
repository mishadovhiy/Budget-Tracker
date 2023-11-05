//
//  Extensions_SelectionStackView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 04.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit
 
extension SelectionStackView {
    func createRows(_ data:[SelectionData]) {
        for i in 0..<data.count {
            let _ = createRow(data[i], at: i)
        }

    }
    private func createRow(_ value:SelectionData, at:Int) {
        let superView = createRowView(value.value, toStack: stack, selected: {subValue in
            self.showList(at: at)
        })
        superView.layer.name = "\(at)"
        let subStack = UIStackView()
        subStack.layer.name = rowSubviewKey
        superView.addSubview(subStack)
        subStack.addConstaits([.top:40,.right:0, .left:0], superV: superView)
        value.subValues.forEach({
            let _ = createRowView($0, toStack: subStack, selected: value.subSelected)
        })
    }
    
    private func createRowView(_ value:RowValue, toStack:UIStackView, selected:@escaping(_ subValue:RowValue)->()) -> TouchView {
        let isSub = toStack != stack
        let view:TouchView = .init()
        view.layer.cornerRadius = 4
        view.backgroundColor = .white
        let label = UILabel()
        label.text = value.name
        label.font = .systemFont(ofSize: 12, weight: isSub ? .regular : .semibold)
        label.adjustsFontSizeToFitWidth = true
        toStack.addSubview(view)
        view.addConstaits([.height:40, .width:70], superV: toStack)
        view.addSubview(label)
        label.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: toStack)
        view.pressedAction = {
            selected(value)
        }
        return view
    }
}
