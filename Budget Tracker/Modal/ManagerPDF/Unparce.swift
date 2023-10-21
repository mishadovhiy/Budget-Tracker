//
//  Unparce.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation
import UIKit


struct UnparcePDF {
    let manager:ManagerPDF
    func dictionaryToString(_ dictionary:[String:Any], data:[ManagerPDF.AdditionalPDFData], fromCreate:Bool = false) -> (NSAttributedString, CGFloat) {
        var height:CGFloat = 0
        let text:NSMutableAttributedString = .init(attributedString: .init(string: ""))
        data.forEach({
            let header = documentHeader(data: $0)
            text.append(header)
            height += 170
        })
        dictionary.forEach({
            if let val = $0.value as? [String:Any] {
                val.forEach({
                    text.append(self.row(($0.key, $0.value)))
                })
            } else if let val = $0.value as? [[String:Any]] {
                val.forEach({
                    let transactions = self.transactions($0["transactions"])
                    height += transactions.1
                    height += 105
                    text.append(self.category($0["category"]))
                    text.append(.init(string: "\n"))
                    text.append(transactions.0)
                    text.append(self.total("\($0["value"] as? Double ?? 0)"))
                    text.append(.init(string: "\n"))
                })
            } else {
                text.append(self.row(($0.key, $0.value)))
            }
        })
        text.append(footer)
        height += 140
        return (text, height)
    }
    
    private func documentHeader(data:ManagerPDF.AdditionalPDFData) -> NSMutableAttributedString {
        let text:NSMutableAttributedString = .init(string: "")
        let attachment = NSTextAttachment()
        attachment.image = .init(named: "icBig")
        attachment.bounds = .init(x: 0, y: -8, width: 40, height: 40)
        text.append(.init(attachment: attachment))

        text.append(.init(string: "  Transactions History ", attributes: [
            .font:UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor:self.color,
            .link: URL(string: "https://mishadovhiy.com")!
        ]))
        text.append(.init(string: "From Budget Tracker\n\n", attributes: [
            .font:UIFont.systemFont(ofSize: 12, weight: .bold),
            .foregroundColor:(K.Colors.balanceT ?? .red).cgColor
        ]))
        text.append(.init(string: (data.defaultHeader?.type.capitalized ?? "") + " for " + (data.defaultHeader?.duration ?? ""), attributes: [
            .font:UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor:K.Colors.balanceT?.cgColor
        ]))

        text.append(.init(string: "\n\n\n\n\n"))

        return text
    }
    
    private var footer:NSMutableAttributedString {
        let text:NSMutableAttributedString = .init(string: "")
        let view = UIView(frame:.init(origin: .zero, size: .init(width: ManagerPDF.pageWidth, height: 90)))
        let imageView:UIImageView = .init(image: Keys.appstoreURL.createQR())
        imageView.frame.size = .init(width: 90, height: 90)
        imageView.layer.cornerRadius = 6
        view.addSubview(imageView)
        let labelFrame:CGRect = .init(origin: .init(x: 100, y: 0), size: .init(width: 400, height: 60))
        let label = UILabel(frame: labelFrame)
        label.text = "Created with"
        label.textColor = K.Colors.link
        label.font = .systemFont(ofSize: 12, weight: .medium)
        view.addSubview(label)
        let label2 = UILabel(frame: .init(origin: .init(x: labelFrame.minX, y: labelFrame.minY + 15), size: labelFrame.size))
        label2.text = "Budget Tracker"
        label2.textColor = UIColor(cgColor: color as! CGColor)
        label2.font = .systemFont(ofSize: 30, weight: .black)
        view.addSubview(label2)
        let attachment = NSTextAttachment()
        attachment.image = view.toImage
        text.append(.init(attachment: attachment))
        return text
        
    }
    
    private func transactions(_ value:Any?) -> (NSMutableAttributedString, CGFloat) {
        let array = value as? [[String:Any]] ?? []
        let text:NSMutableAttributedString = .init(string: "")
        var count:CGFloat = 0
        array.forEach({
            count += 45
            let attachment = NSTextAttachment()
            attachment.image = transactionView($0).toImage
            text.append(.init(attachment: attachment))
        })
        return (text, count)
    }
    
    private func total(_ value:String?) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = totalsView(value ?? "-").toImage
        return .init(attachment: attachment)
    }
    
    private func category(_ value:Any?) -> NSAttributedString {
        return .init(string: ((value as? [String:Any])?["Name"] as? String ?? "Unknown Category").uppercased(), attributes: [.font:UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor:self.color])
    }
    
    let color:AnyObject = (K.Colors.category ?? .white).cgColor
    
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


private extension UnparcePDF {
    func totalsView(_ value:String) -> UIView {
        let view = UIView()
        let size:CGSize = .init(width: ManagerPDF.pageWidth - 100, height: 80)
        view.frame.size = size
        let label = UILabel()
        label.frame.size = .init(width: size.width, height: 40)
        let string:NSMutableAttributedString = .init(string: "Total: ", attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: self.color
        ])
        string.append(.init(string: value, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: self.color
        ]))
        label.attributedText = string
        view.addSubview(label)
        return view
    }
    
    func transactionView(_ dict:[String:Any]) -> UIView {
        let transaction = TransactionsStruct.create(dictt: dict)
        let view = UIView()
        let size:CGSize = .init(width: ManagerPDF.pageWidth - 100, height: 40)
        view.frame.size = size
        let dateLabel = UILabel(frame: .init(origin: .zero, size: size))
        dateLabel.text = transaction?.date ?? ""
        dateLabel.textAlignment = .left
        dateLabel.textColor = K.Colors.balanceT
        dateLabel.font = .systemFont(ofSize: 9, weight: .regular)
        view.addSubview(dateLabel)
        
        if transaction?.comment != "" {
            let commentLabel = UILabel(frame: .init(origin: .init(x: 80, y: 0), size: .init(width: ManagerPDF.pageWidth / 2, height: size.height)))
            commentLabel.text = transaction?.comment
            commentLabel.textAlignment = .left
            commentLabel.textColor = K.Colors.balanceT
            commentLabel.font = .systemFont(ofSize: 9, weight: .regular)
            view.addSubview(commentLabel)
        }
        
        
        let valueLabel = UILabel(frame: .init(origin: .zero, size: size))
        valueLabel.text = transaction?.value ?? ""
        valueLabel.textAlignment = .right
        valueLabel.textColor = .init(cgColor: color as! CGColor)
        valueLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        view.addSubview(valueLabel)
        dotts(in: view, size: size)
        return view
    }
    
    private func dotts(in view:UIView, size:CGSize) {
        let separetor = 3
        for i in 0..<(Int(size.width) / separetor) {
            let dotWidth:CGFloat = 3
            let dott = UIView(frame: .init(x: ((CGFloat(separetor) + dotWidth) * CGFloat(i)), y: size.height - 1, width: dotWidth, height: 0.8))
            dott.backgroundColor = K.Colors.balanceT
            dott.layer.cornerRadius = 0.5
            view.addSubview(dott)
        }
    }
}


