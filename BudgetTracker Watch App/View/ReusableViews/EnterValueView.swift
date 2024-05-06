//
//  EnterValueView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 04.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI

struct EnterValueView: View {
    
    @State var enteringValue:EnteringValue = .init(type: .string({_ in}))
    
    var body: some View {
        ScrollView {
            if enteringValue.type.type == .numbers {
                calculatorView
            } else {
                TextField("", text: $enteringValue.value)
                    .disabled(enteringValue.type.type == .numbers)
            }
        }
        .navigationTitle(enteringValue.value)
    }
    
    // MARK: IBAction
    private func calculatorPressed(_ key:CalculationValue.Right) {
        switch key {
        case .removeLast: enteringValue.value.removeLast()
        case .removeAll: enteringValue.value.removeAll()
        }
    }
    
    private func calculatorPressed(_ key:CalculationValue.Top) {
        
    }
    
}

fileprivate extension EnterValueView {
    private var calculatorView:some View {
        VStack {
//            HStack {
//                ForEach(CalculationValue.Top.allCases, id: \.rawValue) { key in
//                    Button("\(key.title)") {
//                        self.calculatorPressed(key)
//                    }
//                }
//            }
//            
            HStack {
                numbersView
                VStack {
                    ForEach(CalculationValue.Right.allCases, id: \.rawValue) { key in
                        Button("\(key.title)") {
                            self.calculatorPressed(key)
                        }
                    }
                    Spacer()
                }
                .frame(width: 30)
            }
        }
    }
    
    private var numbersView: some View {
        VStack {
            ForEach(0..<3) {section in
                HStack {
                    ForEach(0..<3) {index in
                        numberButtonView((index + 1) + (3 * section))
                    }
                }
            }
            HStack() {
                numberButtonView(0)
            }
        }
    }
    
    private func numberButtonView(_ i:Int) -> some View {
        Button("\(i)") {
            if enteringValue.value.count <= 9 {
                enteringValue.value += "\(i)"
            }
        }
    }
}

extension EnterValueView {
    enum CalculationValue {
        enum Top:String, CaseIterable {
            case plus, minus, divide, multiply
            var title:String {
                switch self {
                case .plus:
                    return "+"
                case .minus:
                    return "-"
                case .divide:
                    return "/"
                case .multiply:
                    return "*"
                }
            }
        }
        enum Right:String, CaseIterable {
            case removeLast, removeAll
            var title:String {
                switch self {
                case .removeLast:
                    return "<"
                case .removeAll:
                    return "C"
                }
            }
        }
    }
}

extension EnterValueView {
    struct EnteringValue {
        let type:ValueType
        var screenTitle:String = ""
            
        var value:String = "" {
            didSet {
                let value = self.value
                switch type {
                case .numbers(let action):
                    action(Int(value) ?? 0)
                case .string(let action):
                    action(value)
                }
            }
        }
        
        enum ValueType {
            case numbers((_ newValue:Int)->())
            case string((_ newValue:String)->())
            
            var type: `Type` {
                switch self {
                case .numbers(_): return .numbers
                case .string(_): return .string
                }
            }
            
            enum `Type` {
                case numbers, string
            }
        }
    }

}

#Preview {
    EnterValueView()
}
