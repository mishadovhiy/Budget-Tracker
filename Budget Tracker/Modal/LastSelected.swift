//
//  LastSelected.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 21.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class LastSelected {

    private var dict: [String:String] {
        return UserDefaults.standard.value(forKey: "lastSelected") as? [String:String] ?? [:]
    }
    private let mainKey = "lastSelected"

    func sett(value: String, setterType: SettingTypeEnum = .SelectedTypeEnum, valueType: SelectedTypeEnum) {
        let key = settingTypeToString(setterType) + typeToString(valueType)
        var all = dict
        all.updateValue(value, forKey: key)
        UserDefaults.standard.setValue(all, forKey: mainKey)
    }
    
    func gett(setterType: SettingTypeEnum = .SelectedTypeEnum, valueType: SelectedTypeEnum) -> String? {
        let key = settingTypeToString(setterType) + typeToString(valueType)
        let value = dict[key]
        return value
    }
    
    
    enum SelectedTypeEnum {
        case expense
        case income
        case debt
    }
    private func typeToString(_ type: SelectedTypeEnum) -> String {
        switch type {
        case .expense:
            return K.expense
        case .income:
            return K.income
        case .debt:
            return "debt"
        }
    }
    
    enum SettingTypeEnum {
        case icon
        case color
        case SelectedTypeEnum
    }
    private func settingTypeToString(_ type: SettingTypeEnum) -> String {
        switch type {
        case .icon:
            return "Icon"
        case .color:
            return "Color"
        case .SelectedTypeEnum:
            return ""
        }
    }

    private func resetAll() {
        UserDefaults.standard.setValue(nil, forKey: mainKey)
    }
    

}
