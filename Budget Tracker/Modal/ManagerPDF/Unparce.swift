//
//  Unparce.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation
import UIKit

class UnparcePDF {
    var manager:ManagerPDF!
    init(manager: ManagerPDF!) {
        self.manager = manager
    }
    deinit {
        manager = nil
        print("UnparcePDFUnparcePDF deinit")
    }
    
    func dictionaryToString(_ dictionary:[String:Any], data:PDFProperties, fromCreate:Bool = false) -> ([(NSAttributedString, Bool)], CGFloat) {
        var height:CGFloat = 0
        var text:[(NSAttributedString, Bool)] = []

        let defaultHeaders:[AdditionalPDFData] = !data.defaultHeader ? [] : data.editableDefaultHeader(img: UIImage(named: "icBig")?.pngData())
        var dHeaderI = 0
        defaultHeaders.forEach {
            let header = customHeader(data: $0, i: dHeaderI, isFooter: false, preview: false)
            dHeaderI += 1
            text.append((header.0, false))
            text.append((.init(string: "\n"), false))
            height += (header.1)
        }
        var headI = 0
        //[AdditionalPDFData]
        data.headers.forEach({
            let header = customHeader(data: $0, i: headI, isFooter: false, preview: fromCreate)
            headI += 1
            text.append((header.0, true))
            text.append((.init(string: "\n"), false))
            height += (header.1)
        })
        if fromCreate {
            text.append((.init(string: "\n"), false))
            let button = addButton(type: .addHeader)
            text.append((button.0, true))
            height += button.1
        }
        text.append((.init(string: "\n\n\n"), false))
        height += 40
        dictionary.forEach({
            if let val = $0.value as? [String:Any] {
                val.forEach({
                    text.append((self.row(($0.key, $0.value)), false))
                })
            } else if let val = $0.value as? [[String:Any]] {
                let tableData = transactionsTable(categorized: val, data: data)
                height += CGFloat(tableData.0)
                tableData.1.forEach {
                    text.append($0)
                }
            } else {
                text.append((self.row(($0.key, $0.value)), false))
            }
        })
        if data.defaultFooter {
            text.append((footer, false))
            text.append((.init(string: "\n\n"), false))
            height += 150
        }
        
        var footI = 0
        data.footers.forEach({
            let header = customHeader(data: $0, i: footI, isFooter: true, preview: fromCreate)
            footI += 1
            text.append((header.0, true))
            text.append((.init(string: "\n"), false))
            height += (header.1)
        })
        if fromCreate {
            text.append((.init(string: "\n"), false))
            let button = addButton(type: .addFooter)
            text.append((button.0, true))
            height += (button.1 + 10)
            text.append((.init(string: "\n"), false))
        }
        return (text, height)
    }
    
    
    private func transactionsTable(categorized:[[String:Any]], data:PDFProperties) -> (Int, [(NSAttributedString, Bool)]) {
        var transactions:[[String:Any]] = []
        var height:Int = 0
        var text:[(NSAttributedString, Bool)] = []
        var total:Double = 0
        categorized.forEach({
            if data.documentProperties.tableStyle.categorySepareted {
                let transactions = self.transactions($0["transactions"], data: data)
                height += Int(transactions.1)
                height += 105
                text.append((self.category($0["category"]), false))
                text.append((.init(string: "\n"), false))
                text.append((transactions.0, false))
                text.append((self.total("\($0["value"] as? Double ?? 0)"), false))
                text.append((.init(string: "\n"), false))
            } else {
                let transactionsDict = $0["transactions"] as? [[String:Any]] ?? []
                total += $0["value"] as? Double ?? 0
                transactionsDict.forEach {
                    let transaction = TransactionsStruct.create(dictt: $0)
                    transactions.append(transaction?.dict ?? [:])
                }
            }
          })
        
        if !data.documentProperties.tableStyle.categorySepareted {
            let header = self.transactions([], data: data)
            text.append((header.0, false))

            let transactionsData = self.transactions(transactions, data: data)
            height += Int(transactionsData.1 + header.1)
            
            height += 40
            text.append((transactionsData.0, false))
            text.append((self.total("\(total)"), false))
        }
        
        return (height, text)
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
       // let paragraphStyle = NSMutableParagraphStyle()
        if data.custom?.textSettins.attachment.img == nil {
            paragraphStyle.lineSpacing = 4
        }
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
        let paragraphStyle2 = NSMutableParagraphStyle()

        paragraphStyle2.lineSpacing = 10
        print(text.string, " gerfedaefre")
        
        var height = text.string.count >= 30 ? fontResult.calculate(inWindth:manager.pageWidth, attributes: [.paragraphStyle:paragraphStyle2], string: text.string).height : 40
        if attachmentText != nil {
            height += (attachment?.displeySize.height ?? 0)
        }

        
        return (text, height)
    }
    
    private func spaceView(h:CGFloat = 20) -> NSAttributedString {
        let view = UIView()
        view.backgroundColor = .clear
        view.frame = .init(origin: .zero, size: .init(width: manager.pageWidth, height: h))
        let attachment = NSTextAttachment()
        attachment.image = view.toImage
        attachment.bounds = view.bounds
        return .init(attachment: attachment)
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
       
        let imageView:UIImageView = .init(image: .init(QRcode: Keys.appstoreURL))
        imageView.frame = .init(origin: .zero, size: .init(width: 90, height: 90))
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
    
    private func transactions(_ value:Any?, data:PDFProperties) -> (NSMutableAttributedString, CGFloat) {
        let array = (value as? [[String:Any]] ?? []).sorted(by: {
            
            var sort = data.documentProperties.tableStyle.sort
            if data.documentProperties.tableStyle.categorySepareted && sort == .category {
                sort = .amount
            }
            let lt = TransactionsStruct.create(dictt: $0)
            let rt = TransactionsStruct.create(dictt: $1)
            switch sort {
            case .date:
                let left = lt?.dateFromString ?? Date()
                let right = rt?.dateFromString ?? Date()
                return left >= right
            case .category:
                let left = lt?.category.name ?? ""
                let right = rt?.category.name ?? ""
                return left >= right
            case .amount:
                let left = Double(lt?.value ?? "") ?? 0
                let right = Double(rt?.value ?? "") ?? 0
                return left >= right
            }
            
        })
        let text:NSMutableAttributedString = .init(string: "")
        var count:CGFloat = 0
        let height:CGFloat = 45
        array.forEach({
            count += height
            let attachment = NSTextAttachment()
            attachment.image = transactionView($0, data: data, isLast: array.count == Int(count / height)).toImage
            text.append(.init(attachment: attachment))
        })
        if array.isEmpty {
            count += height
            let attachment = NSTextAttachment()
            attachment.image = transactionView([:], data: data).toImage
            text.append(.init(attachment: attachment))
        }
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
    
    
    func transactionView(_ dict:[String:Any], data:PDFProperties, isLast:Bool = false) -> UIView {
        if data.documentProperties.tableStyle.categorySepareted {
            return transactionViewRegular(dict, data: data, isLast: isLast)
        } else {
            return transactionViewRegular(dict, data: data, isLast: isLast)
        }
    }
    
    private func transactionViewRegular(_ dict:[String:Any], data:PDFProperties, isLast:Bool) -> UIView {
        return transactionViewCategorithed(dict, data: data, isLast: isLast)
    }
    
    private func transactionViewCategorithed(_ dict:[String:Any], data:PDFProperties, isLast:Bool) -> UIView {
        let transaction = TransactionsStruct.create(dictt: dict)
        let view = UIView()
        let color2 = dict.isEmpty ? primaryColor as! CGColor : secondaryColor as! CGColor
        let color1 = primaryColor as! CGColor
        let size:CGSize = .init(width: manager.pageWidth - 100, height: 40)
        let exSmallFont = font(for: .extraSmall)
        let smallFont = font(for: .small)
        view.frame.size = size
        let dateLabel = UILabel(frame: .init(origin: .zero, size: size))
        dateLabel.text = transaction?.date ?? "Date"
        dateLabel.textAlignment = .left
        dateLabel.textColor = UIColor(cgColor: color2)
        dateLabel.font = .systemFont(ofSize: exSmallFont.0, weight: exSmallFont.1)
        view.addSubview(dateLabel)
        
        if transaction?.comment != "" || !data.documentProperties.tableStyle.categorySepareted {
            let commentLabel = UILabel(frame: .init(origin: .init(x: 80, y: 0), size: .init(width: manager.pageWidth / 2, height: size.height)))
            commentLabel.text = !data.documentProperties.tableStyle.categorySepareted ? transaction?.category.name ?? "Category" : transaction?.comment ?? "Comment"
            commentLabel.textAlignment = .left
            commentLabel.textColor = UIColor(cgColor:color2)
            commentLabel.layer.name = "commentLabel"
            commentLabel.font = .systemFont(ofSize: exSmallFont.0, weight: exSmallFont.1)
            view.addSubview(commentLabel)
        }
        
        
        let valueLabel = UILabel(frame: .init(origin: .zero, size: size))
        valueLabel.text = transaction?.value ?? "Amount"
        valueLabel.textAlignment = .right
        valueLabel.textColor = .init(cgColor: color1)
        valueLabel.font = dict.isEmpty ? .systemFont(ofSize: smallFont.0, weight: smallFont.1) : .systemFont(ofSize: smallFont.0, weight: smallFont.1)
        view.addSubview(valueLabel)
        if !data.documentProperties.tableStyle.categorySepareted && !dict.isEmpty {
            let _ = view.layer.drawLine([
                .init(x: 0, y: 0),
                .init(x: size.width, y: 0)
            ], color: UIColor(cgColor:color2), width: 0.5, opacity: 1)
            let _ = view.layer.drawLine([
                .init(x: 0, y: 5),
                .init(x: 0, y: size.height - (isLast ? 5 : 0))
            ], color: UIColor(cgColor:secondaryColor as! CGColor), width: 0.5, opacity: 1)
            let _ = view.layer.drawLine([
                .init(x: size.width, y: 5),
                .init(x: size.width, y: size.height - (isLast ? 5 : 0))
            ], color: UIColor(cgColor:color2), width: 0.5, opacity: 1)
            if isLast {
                let _ = view.layer.drawLine([
                    .init(x: 0, y: size.height),
                    .init(x: size.width, y: size.height)
                ], color: UIColor(cgColor:color2), width: 0.5, opacity: 1)
            }
            let _ = view.subviews.first(where: {$0.layer.name == "commentLabel"})?.layer.drawLine([
                        .init(x: 0, y: 5),
                        .init(x: 0, y: dateLabel.frame.height  - (isLast ? 5 : 0))
                    ], color: UIColor(cgColor:color2), width: 0.5, opacity: 1)

        } else if !dict.isEmpty {
            dotts(in: view, size: size, data: data)
        }
        return view
    }
    
    private func dotts(in view:UIView, size:CGSize, data:PDFProperties) {
        let dotsSeparetor = data.documentProperties.tableStyle.dotsSeparetor
        let separetor = dotsSeparetor ? 3 : 1
        for i in 0..<(Int(size.width) / separetor) {
            let dotWidth:CGFloat = dotsSeparetor ? 3 : size.width
            let dott = UIView(frame: .init(x: ((CGFloat(separetor) + dotWidth) * CGFloat(i)), y: size.height - 1, width: dotWidth, height: dotsSeparetor ? 0.8 : 0.4))
            dott.backgroundColor = UIColor(cgColor: secondaryColor as! CGColor)
            dott.layer.cornerRadius = 0.5
            view.addSubview(dott)
        }
    }
}



