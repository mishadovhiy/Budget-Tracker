//
//  Extensions_SelectionStackView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 04.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension SelectionStackView:UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let id = pickerView.layer.name ?? ""
        let data = self.data.first(where: {$0.value.id == id})
        return data?.subValues.count ?? 0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView()
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        view.addSubview(label)
        label.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: view)
        let id = pickerView.layer.name ?? ""
        let data = self.data.first(where: {$0.value.id == id})
        let rowData = data?.subValues[row]
        label.text = rowData?.name ?? "-"
        label.textAlignment = .center
        return view
    }
    /*func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let id = pickerView.layer.name ?? ""
        let data = self.data.first(where: {$0.value.id == id})
        let rowData = data?.subValues[row]
        return .init(.init(string: rowData?.name ?? "-", attributes: [
            .font:UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor:UIColor.white
        ]))
    }*/
    

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let id = pickerView.layer.name ?? ""
        let data = self.data.first(where: {$0.value.id == id})
        if let rowData = data?.subValues[row] {
            data?.subSelected(rowData)

        }
    }
}

extension SelectionStackView {
    func createRows(_ superView:UIView, data:[SelectionData]) {
       // superView.addSubview(self)
        
     //   self.addConstaits([.top:0,.right:0, .left:0, .height:40], superV: superView)
      //  self.frame = .init(origin: .zero, size: .init(width: superView.frame.width, height: 40))
        print(data.count, " SelectionStackView")
        self.data = data
        for i in 0..<data.count {
            let _ = self.createRow(data[i], at: i)
        }
    }
    
    private func createPicker(_ value:SelectionData, at:Int) {
        let stack = UIStackView()
        let label = UILabel()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.layer.name = value.value.id
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(pickerView)
        pickerView.addConstaits([.width:rowWidth], superV: stack)
        stack.spacing = -3
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = K.Colors.balanceT
        label.text = value.value.name
        label.addConstaits([.height:11], superV: stack)
        stackView.addArrangedSubview(stack)
        stack.addConstaits([.width:rowWidth, .height:self.frame.height], superV: stackView)
    }
    
    private func createRow(_ value:SelectionData, at:Int) {
        createPicker(value, at: at)
        /*let superView = createRowView(value.value, toStack: stackView, selected: {subValue in
            self.showList(at: at == self.showingAt ? nil : at)
        })
        superView.layer.name = "\(at)"
        let subStack = UIStackView()
        subStack.isUserInteractionEnabled = true
        subStack.distribution = .fillEqually
        subStack.axis = .vertical
        subStack.layer.name = rowSubviewKey
        subStack.isHidden = true
        superView.addSubview(subStack)
        subStack.addConstaits([.top:40,.right:0, .left:0], superV: superView)
        subStack.backgroundColor = .orange
        value.subValues.forEach({
            let _ = createRowView($0, toStack: subStack, selected: value.subSelected)
        })*/
    }
    
    private func createRowView(_ value:RowValue, toStack:UIStackView, selected:@escaping(_ subValue:RowValue)->()) -> TouchView {
        let isSub = toStack != stackView
        let view:TouchView = .init()
        view.layer.cornerRadius = 4
        view.backgroundColor = isSub ? .white.withAlphaComponent(0.4) : .white
        let label = UILabel()
        label.text = value.name
        label.font = .systemFont(ofSize: 12, weight: isSub ? .regular : .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        toStack.addArrangedSubview(view)
        view.addConstaits([.height:self.frame.height, .width:70], superV: toStack)
        view.addSubview(label)
        label.isUserInteractionEnabled = false
        label.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: view)
        view.isUserInteractionEnabled = true

        view.pressedAction = {
           // fatalError()
            selected(value)
        }
        return view
    }

}
