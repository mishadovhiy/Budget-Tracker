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
    
    func dictionaryToString(_ dictionary:[String:Any], data:PDFProperties, fromCreate:Bool = false) -> ([NSAttributedString], CGFloat) {
        var height:CGFloat = 0
        var text:[NSAttributedString] = []
        if data.defaultHeader {
            let header = documentHeader(data: data, fromCreate: true)
            text.append(header)
            height += (data.needDate ? 145 : 105)
        } else {
            text.append(.init(string: "  \n"))
        }
        var headI = 0
        data.headers.forEach({
            let header = customHeader(data: $0, i: headI, isFooter: false, preview: fromCreate)
            headI += 1
            text.append(header.0)
            text.append(.init(string: "\n"))
            height += (header.1)
        })
        if fromCreate {
            text.append(.init(string: "\n"))
            let button = addButton(type: .addHeader)
            text.append(button.0)
            height += button.1
        }
        text.append(.init(string: "\n\n\n"))
        height += 40
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
        if data.defaultFooter {
            text.append(footer)
            height += 140
        }
        
        var footI = 0
        data.footers.forEach({
            let header = customHeader(data: $0, i: footI, isFooter: true, preview: fromCreate)
            footI += 1
            text.append(header.0)
            text.append(.init(string: "\n"))
            height += (header.1)
        })
        if fromCreate {
            text.append(.init(string: "\n"))
            let button = addButton(type: .addFooter)
            text.append(button.0)
            height += (button.1 + 10)
            text.append(.init(string: "\n"))
        }
        return (text, height)
    }
    
    
    private func addButton(type:PDFEditVC.LinkAttributeType) -> (NSMutableAttributedString, CGFloat) {
        let height:CGFloat = 50
        let text:NSMutableAttributedString = .init(string: "")
        let view = UIView(frame: .init(origin: .zero, size: .init(width: self.manager.pageWidth, height: height)))
        let _ = view.layer.drawSeparetor(color: K.Colors.link, y:height / 2, width: 3)

        let plus = UIImageView(frame: .init(origin: .init(x: manager.pageWidth / 2 - 25, y: height / 2 - 15), size: .init(width: 30, height: 30)))
        plus.shadow()
        plus.image = .init(named: "plusIcon")
        plus.contentMode = .scaleAspectFit
        view.addSubview(plus)
        let attachment = NSTextAttachment()
        attachment.image = view.toImage
        attachment.bounds = view.frame
    
        text.append(.init(attachment: attachment))

        let url = URL(string: "https://editCustom/\(type.rawValue)")!
        text.addAttribute(.init(PDFEditVC.pdfLinkKey), value: url, range: NSRange(0..<text.length))
        //here
        return (text, height)
    }
    
    private func customHeader(data:AdditionalPDFData, i:Int, isFooter:Bool, preview:Bool) -> (NSMutableAttributedString, CGFloat) {
        let text:NSMutableAttributedString = .init(string: "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = data.custom?.textSettins.alighment.textAligment ?? .left
        print("dassfwer ", data.custom?.textSettins)
        
        let font = font(for: data.custom?.textSettins.textSize ?? .small)
        let fontResult = UIFont.systemFont(ofSize: font.0, weight: font.1)
        let color = textColor(for: data.custom?.textSettins.textColor ?? .primary) ?? primaryColor
        var attributes:[NSAttributedString.Key : Any] = [
            .font:fontResult,
            .foregroundColor:color,
            .paragraphStyle:paragraphStyle
        ]
        if preview {
            let linkComp:PDFEditVC.LinkAttributeType = isFooter ? .footer : .header
            attributes.updateValue(URL(string: "https://editCustom/\(linkComp.rawValue)/\(i)")!, forKey: .init(PDFEditVC.pdfLinkKey))
        }
        var dateText:String?
        let replacingType = data.custom?.textSettins.replacingType
        if let date = replacingType, date.date.type != .none {
            dateText = manager.date(for: date)
        }
        
        var attachmentText:NSAttributedString?
        let attachment = data.custom?.textSettins.attachment
        if let attachmentData = attachment, attachmentData.img != nil {
            attachmentText = attachmentView(attachmentData.img, size: attachmentData.displeySize)
        }
        if attachment?.inTextPosition == .left && attachmentText != nil {
            text.append(.init(attributedString: attachmentText!))
        }
        if replacingType?.date.inTextPosition == .left && dateText != nil {
            text.append(.init(string: dateText! + " ", attributes: attributes))
        }
        text.append(.init(string: data.custom?.title ?? "-", attributes: attributes))
        if replacingType?.date.inTextPosition == .right && dateText != nil {
            text.append(.init(string: " " + dateText!, attributes: attributes))
        }

        if attachment?.inTextPosition == .right && attachmentText != nil {
            text.append(.init(attributedString: attachmentText!))
        }
        var height = text.string.calculate(font: fontResult, inWindth: manager.pageWidth).height
        if attachmentText != nil {
            height += (attachment?.size.height ?? 0)
        }
        print(text.string, " gerfeefwrgef ", height)
        return (text, height)
    }
    
    private func documentHeader(data:PDFProperties, fromCreate:Bool = false) -> NSMutableAttributedString {
        let text:NSMutableAttributedString = .init(string: "")
        let attachment = NSTextAttachment()
        attachment.image = .init(named: "icBig")
        attachment.bounds = .init(x: 0, y: -8, width: 40, height: 40)
        let bigFont = font(for: .big)
        let smallFont = font(for: .extraSmall)

        text.append(.init(attachment: attachment))

        let attributes:[NSAttributedString.Key : Any] = [
            .font:UIFont.systemFont(ofSize: bigFont.0, weight: bigFont.1),
            .foregroundColor:self.primaryColor,
        ]
        text.append(.init(string: "  Transactions History ", attributes: attributes))
        text.append(.init(string: "From Budget Tracker\n\n", attributes: [
            .font:UIFont.systemFont(ofSize: smallFont.0, weight: smallFont.1),
            .foregroundColor:secondaryColor
        ]))
    //    text.append(documantDate(data: data, fromCreate: fromCreate))
        return text
    }
    
    private func documantDate(data:PDFProperties, fromCreate:Bool) -> NSMutableAttributedString {
        let smallFont = font(for: .medium)
        let text:NSMutableAttributedString = .init(string: "")
        text.append(.init(string: (data.defaultHeaderData?.type.capitalized ?? "") + " for " + (data.defaultHeaderData?.duration ?? ""), attributes: [
            .font:UIFont.systemFont(ofSize: smallFont.0, weight: smallFont.1),
            .foregroundColor:secondaryColor
        ]))
        text.append(.init(string: "\n"))
        return text
    }
    
    private var footer:NSMutableAttributedString {
        let text:NSMutableAttributedString = .init(string: "")
        let view = UIView(frame:.init(origin: .zero, size: .init(width: manager.pageWidth, height: 90)))
        let imageView:UIImageView = .init(image: Keys.appstoreURL.createQR())
        imageView.frame.size = .init(width: 90, height: 90)
        imageView.layer.cornerRadius = 6
        view.addSubview(imageView)
        let labelFrame:CGRect = .init(origin: .init(x: 100, y: 0), size: .init(width: 400, height: 60))
        let label = UILabel(frame: labelFrame)
        label.text = "Created with"
        label.textColor = K.Colors.link
        let bigFont = font(for: .big)
        let smallFont = font(for: .small)

        label.font = UIFont.systemFont(ofSize: smallFont.0, weight: smallFont.1)
        view.addSubview(label)
        let label2 = UILabel(frame: .init(origin: .init(x: labelFrame.minX, y: labelFrame.minY + 15), size: labelFrame.size))
        label2.text = "Budget Tracker"
        label2.textColor = UIColor(cgColor: primaryColor as! CGColor)
        label2.font = UIFont.systemFont(ofSize: bigFont.0, weight: bigFont.1)
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
        let font = font(for: .big)
        return .init(string: ((value as? [String:Any])?["Name"] as? String ?? "Unknown Category").uppercased(), attributes: [
            .font:UIFont.systemFont(ofSize: font.0, weight: font.1),
            .foregroundColor:self.primaryColor])
    }
    
    var primaryColor:AnyObject {
        return manager.properties.documentProperties.colors.primary
    }
    
    var secondaryColor:AnyObject {
        return manager.properties.documentProperties.colors.secondary
    }
    
    
    private func font(for size:PdfTextProperties.TextSize) -> (CGFloat, UIFont.Weight) {
        let selected = manager.properties.documentProperties.textSizes[size] ?? size.size.size
        print(selected, " rgetrfweregtyb")
        return (CGFloat(selected), size.size.weight)
        
        //UIFont.systemFont(ofSize: CGFloat(selected), weight: .regular)//.systemFont(ofSize: 12, weight: .regular)
    }
    
    private func textColor(for userColor: PdfTextColor) -> CGColor? {
        switch userColor {
        case .primary:return primaryColor as! CGColor
        case .secondary:return secondaryColor as! CGColor
        }
    }
    
    private func row(_ dict:(String, Any)) -> NSAttributedString {
        let res:NSMutableAttributedString = .init(string: "")
        let font = font(for: .small)
        if let newdict = dict.1 as? [String:Any] {
            res.append(.init(string: "\(dict.0)", attributes: [.font:UIFont.systemFont(ofSize: font.0, weight: font.1), .foregroundColor:self.primaryColor]))
            newdict.forEach {
                res.append(self.row(($0.key, $0.value)))
            }
        } else {
            let keys = ["name", "transactions", "category", "value", "Name"]

            if keys.contains(dict.0) {
                res.append(.init(string: "\(dict.0): \(dict.1)\n", attributes: [.font:UIFont.systemFont(ofSize: font.0, weight: font.1), .foregroundColor:self.primaryColor]))
            }
            
        }
        return res
    }
}


private extension UnparcePDF {
    func totalsView(_ value:String) -> UIView {
        let view = UIView()
        let size:CGSize = .init(width: manager.pageWidth - 100, height: 80)
        view.frame.size = size
        let label = UILabel()
        label.frame.size = .init(width: size.width, height: 40)
        let font = font(for: .small)
        let fontSmall = self.font(for: .medium)

        let string:NSMutableAttributedString = .init(string: "Total: ", attributes: [
           // .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .font: UIFont.systemFont(ofSize: font.0, weight: font.1),
            .foregroundColor: UIColor(cgColor: self.primaryColor as! CGColor)
        ])
        string.append(.init(string: value, attributes: [
            //.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .font: UIFont.systemFont(ofSize: fontSmall.0, weight: fontSmall.1),
            .foregroundColor: UIColor(cgColor: self.primaryColor as! CGColor)
        ]))
        label.attributedText = string
        view.addSubview(label)
        return view
    }
    
    
    func attachmentView(_ data:Data?, size:CGSize) -> NSAttributedString? {
        if let data = data {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(data: data)
            attachment.bounds = .init(origin: .zero, size: size)
            return .init(attachment: attachment)
        } else {
            return nil
        }
        
    }
    
    
    func transactionView(_ dict:[String:Any]) -> UIView {
        let transaction = TransactionsStruct.create(dictt: dict)
        let view = UIView()
        let size:CGSize = .init(width: manager.pageWidth - 100, height: 40)
        let exSmallFont = font(for: .extraSmall)
        let smallFont = font(for: .small)
        view.frame.size = size
        let dateLabel = UILabel(frame: .init(origin: .zero, size: size))
        dateLabel.text = transaction?.date ?? ""
        dateLabel.textAlignment = .left
        dateLabel.textColor = UIColor(cgColor: secondaryColor as! CGColor)
        dateLabel.font = .systemFont(ofSize: exSmallFont.0, weight: exSmallFont.1)
        view.addSubview(dateLabel)
        
        if transaction?.comment != "" {
            let commentLabel = UILabel(frame: .init(origin: .init(x: 80, y: 0), size: .init(width: manager.pageWidth / 2, height: size.height)))
            commentLabel.text = transaction?.comment
            commentLabel.textAlignment = .left
            commentLabel.textColor = UIColor(cgColor:secondaryColor as! CGColor)
            commentLabel.font = .systemFont(ofSize: exSmallFont.0, weight: exSmallFont.1)
            view.addSubview(commentLabel)
        }
        
        
        let valueLabel = UILabel(frame: .init(origin: .zero, size: size))
        valueLabel.text = transaction?.value ?? ""
        valueLabel.textAlignment = .right
        valueLabel.textColor = .init(cgColor: primaryColor as! CGColor)
        valueLabel.font = .systemFont(ofSize: smallFont.0, weight: smallFont.1)
        view.addSubview(valueLabel)
        dotts(in: view, size: size)
        return view
    }
    
    private func dotts(in view:UIView, size:CGSize) {
        let separetor = 3
        for i in 0..<(Int(size.width) / separetor) {
            let dotWidth:CGFloat = 3
            let dott = UIView(frame: .init(x: ((CGFloat(separetor) + dotWidth) * CGFloat(i)), y: size.height - 1, width: dotWidth, height: 0.8))
            dott.backgroundColor = UIColor(cgColor: secondaryColor as! CGColor)
            dott.layer.cornerRadius = 0.5
            view.addSubview(dott)
        }
    }
}



