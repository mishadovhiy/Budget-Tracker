//
//  SelectionStackView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 04.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class SelectionStackView: UIView {
    //@IBOutlet weak var stackView: UIStackView!
    var stackView:UIStackView {
        let view = self.subviews.first(where: {
            $0.layer.name == "backView"
        })
        return view?.subviews.first(where: {$0 is UIStackView}) as! UIStackView
    }
    var data:[SelectionData] = []
    let rowSubviewKey = "rowSubview"

    var showingAt:Int? = nil
    let rowWidth:CGFloat = 120
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        var subViewStack:UIStackView?
        stackView.arrangedSubviews.forEach({
            let listStack = $0.subviews
            let subview = listStack.first(where: {$0.layer.name == rowSubviewKey}) as? UIStackView
            if !(subview?.isHidden ?? true) {
                subViewStack = subview
            }
        })
        if subViewStack != nil {
            print(subViewStack, " gfedwregt")
            if subViewStack?.contains(touches) ?? false {
                subViewStack?.arrangedSubviews.forEach({
                    if $0.contains(touches) {
                        ($0 as? TouchView)?.pressedAction?()
                        print(" egrfedsa")
                    }
                })
                print(" ergfwdas")
            }

        }
    }
    
    func showList(at:Int?) {
        showingAt = at
        print("showListshowList ", at)
        print(stackView.isUserInteractionEnabled, " stackViewisUserInteractionEnabled")
        var selectedStack:UIStackView?
        stackView.arrangedSubviews.forEach {
            let isSelected = $0.layer.name == String(at ?? -1)
          //  let selectedView:UIView? = stackView.arrangedSubviews.first(where: {$0.layer.name == String(at ?? -1)})
            
            let listStack = $0.subviews
            guard let subview = listStack.first(where: {$0.layer.name == rowSubviewKey}) as? UIStackView else { return}
            if isSelected {
                selectedStack = subview
                print(selectedStack, " rgefwd")
            }
            UIView.animate(withDuration: 0.3) {
                subview.isHidden = !isSelected
            }
        }
        UIView.animate(withDuration: 0.2) {
            self.frame.size = .init(width: self.frame.width, height: ((selectedStack?.frame.height ?? 40) + (selectedStack != nil ? 40 : 0)))
        }
        
    }
    
}

extension SelectionStackView {
    struct SelectionData {
        let value:RowValue
        var launchSelectedID:String? = nil
        let subValues:[RowValue]
        let subSelected:(_ subValue:RowValue)->()
        
        var selectedRow:Int? {
            guard let selectedID = launchSelectedID else { return nil }
            var i = 0
            var selected:Int?
            subValues.forEach {
                if $0.id == selectedID {
                    selected = i
                }
                i += 1
            }
            print("hasselected ", selected)
            return selected
        }
    }
    struct RowValue {
        let name:String
        var id:String? = nil
        init(name: String, id: String? = nil) {
            self.name = name
            self.id = (id ?? name).lowercased()
        }
    }
}

extension SelectionStackView {
    static func create(_ superView:UIView, data:[SelectionData], position:CGPoint = .zero) -> SelectionStackView? {
        let view = SelectionStackView.instanceFromNib(frame: .init(origin: position, size: .init(width: superView.frame.size.width, height: 65)))
        view.translatesAutoresizingMaskIntoConstraints = true
        view.createRows(superView, data: data)
        print(view.isUserInteractionEnabled, " viewviewviewisUserInteractionEnabled")
        superView.addSubview(view)
        view.frame = .init(origin: position, size: .init(width: superView.frame.size.width, height: 65))
        return view
    }
    
    class func instanceFromNib(frame:CGRect) -> SelectionStackView {
       // return UINib(nibName: "SelectionStackView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SelectionStackView
        let view = SelectionStackView.init(frame: frame)
        let backView = UIView()
        backView.backgroundColor = K.Colors.separetor?.withAlphaComponent(0.5)
        backView.layer.cornerRadius = 6
        backView.layer.name = "backView"
        view.addSubview(backView)
        backView.addConstaits([.left:0, .top:0], superV: view)

        let stackView = UIStackView()
        backView.addSubview(stackView)
        stackView.addConstaits([.right:0, .top:8, .left:0, .bottom:0], superV: backView)
       // stackView.backgroundColor = K.Colors.separetor?.withAlphaComponent(0.5)
       // stackView.layer.cornerRadius = 6
        return view
    }
}
