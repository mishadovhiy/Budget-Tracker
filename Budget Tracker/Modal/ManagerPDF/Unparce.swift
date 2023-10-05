//
//  Unparce.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation
import UIKit

extension ManagerPDF {
    struct UnparcePDF {
        private func transactions(_ value:Any?) -> NSAttributedString {
            let array = value as? [[String:Any]] ?? []
            let text:NSMutableAttributedString = .init(string: "")
            array.forEach({
                let date = $0["Date"] as? String ?? "Unknown date"
                let amount = $0["Amount"] as? String ?? "-"
                let comment = (($0["Comment"] as? String) ?? "") != "" ? "\($0["Comment"] ?? "")" : ""
                text.append(.init(string: "\(amount)", attributes: [.foregroundColor:self.color,
                    .font:UIFont.systemFont(ofSize: 12, weight: .light
                                           )]))
                text.append(.init(string: " (\(date)) \(comment)\n", attributes: [
                    .font: UIFont.systemFont(ofSize: 9, weight: .light),
                    .foregroundColor:K.Colors.balanceT!.cgColor
                                           
                ]))
                
            })
            return text
        }
        
        private func category(_ value:Any?) -> NSAttributedString {
            return .init(string: ((value as? [String:Any])?["Name"] as? String ?? "Unknown Category").uppercased(), attributes: [.font:UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor:self.color])
        }
        
        func dictionaryToString(_ dictionary:[String:Any]) -> NSAttributedString {
            let text:NSMutableAttributedString = .init(string: "Transaction History\n", attributes: [.font:UIFont.systemFont(ofSize: 28, weight: .bold), .foregroundColor:self.color])
                /*    text.append(.init(string: "From", attributes: [
                .font:UIFont.systemFont(ofSize: 14, weight: .light), .foregroundColor:self.color
            ]))*/
            text.append(.init(string: "From Budget Tracker App\n\n\n", attributes: [
                .font:UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor:self.color
            ]))
            dictionary.forEach({
                if let val = $0.value as? [String:Any] {
                    val.forEach({
                        text.append(self.row(($0.key, $0.value)))
                    })
                } else if let val = $0.value as? [[String:Any]] {
                    val.forEach({
                        let cat = self.category($0["category"])
                        let val = $0["value"]
                        let trans = self.transactions($0["transactions"])
                        text.append(cat)
                        text.append(.init(string: "\n"))
                        text.append(trans)
                        text.append(.init(string: "Total: \(val ?? "")\n\n\n", attributes: [
                            .font:UIFont.systemFont(ofSize: 9, weight: .light), .foregroundColor:self.color]))
                    })
                } else {
                    text.append(self.row(($0.key, $0.value)))
                }
            })
            text.append(.init(string: "\n"))
            let attach = NSTextAttachment()
            attach.image = .init(named: "icBig")
            attach.bounds = .init(x: 50, y: 50, width: 40, height: 40)
        
            let str = NSAttributedString(attachment: attach)
            text.append(str)
            
            return text
        }
        
        var color:AnyObject {
            return (K.Colors.category ?? .white).cgColor
        }
        
        private func row(_ dict:(String, Any)) -> NSAttributedString {
            let res:NSMutableAttributedString = .init(string: "")
            if let newdict = dict.1 as? [String:Any] {
                res.append(.init(string: "\(dict.0)", attributes: [.font:UIFont.systemFont(ofSize: 9, weight: .light), .foregroundColor:self.color]))
                newdict.forEach {
                    res.append(self.row(($0.key, $0.value)))
                }
            } else {
                let keys = ["name", "transactions", "category", "value", "Name"]
                if keys.contains(dict.0) {
                    res.append(.init(string: "\(dict.0): \(dict.1)\n", attributes: [.font:UIFont.systemFont(ofSize: 9, weight: .light), .foregroundColor:self.color]))
                }
                
            }
            return res
        }
    }
}
