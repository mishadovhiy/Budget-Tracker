//
//  SelectionStackView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 04.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class SelectionStackView: UIView {

    var data:[SelectionData] = []
    var stack:UIStackView!
    let rowSubviewKey = "rowSubview"

    func showList(at:Int?) {
        let selectedView:UIView? = stack.arrangedSubviews.first(where: {$0.layer.name == String(at ?? -1)})
        let listStack = selectedView?.subviews
    }
    
}

extension SelectionStackView {
    struct SelectionData {
        let value:RowValue
        let subValues:[RowValue]
        let subSelected:(_ subValue:RowValue)->()
    }
    struct RowValue {
        let name:String
    }
}

extension SelectionStackView {
    static func create(_ superView:UIView, data:[SelectionData]) -> SelectionStackView? {
        let view = SelectionStackView.instanceFromNib()
        superView.addSubview(view)
        view.addConstaits([.top:0,.right:0, .left:0], superV: superView)
        view.createRows(data)
        return view
    }
    
    class func instanceFromNib() -> SelectionStackView {
        return UINib(nibName: "SelectionStackView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SelectionStackView
    }
}
