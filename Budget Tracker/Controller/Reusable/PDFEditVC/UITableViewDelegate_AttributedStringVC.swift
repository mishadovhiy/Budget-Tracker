//
//  UITableViewDelegate_AttributedStringVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension PDFEditVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttributedPreviewCell", for: indexPath) as! AttributedPreviewCell
        cell.selectedLineView.isHidden = !(selectedRow == indexPath.row)
        cell.set(tableData[indexPath.row].0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if settingsNav?.viewControllers.count == 1 {
            if tableData[indexPath.row].1, let url = link(indexPath, reorder: false)
            {
                selectedRow = indexPath.row
                linkPressed(url)
                tableView.reloadData()
            }
        } else {
            vibrate(style: .heavy)
        }
        
        
    }
    
    private func link(_ index:IndexPath, reorder:Bool = true) -> URL? {
        let text = tableData[index.row].0
        let range = NSRange(0..<(text.length))
        if let url = url(text) {
            return url
        } else if text.containsAttachments(in: range), !reorder {
            let textNew = NSMutableAttributedString(attributedString: text)
            textNew.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, textNew.length), options: []) { value, range, stop in
                if let _ = value as? NSTextAttachment {
                    textNew.replaceCharacters(in: range, with: "")
                    stop.pointee = true
                }
                
            }
            return url(textNew)
            
        } else {
            return nil
        }
    }
    
    private func url(_ text:NSAttributedString) -> URL? {
        if let atr = text.attribute(.init(PDFEditVC.pdfLinkKey), at: NSMakeRange(0, text.length).location, effectiveRange: nil),
           let url = atr as? URL {
            return url
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableData[indexPath.row].1, let urlLink = link(indexPath, reorder: false),
           let component = urlLink.components.first(where: {
               return LinkAttributeType.init(rawValue: $0) != nil
           }),
           let url = LinkAttributeType(rawValue: component),
           url.canReorder,
           let dataRow = url.dataIndex(components: urlLink.components),
           settingsNav?.viewControllers.count == 1
        {
            
            let edit:UIContextualAction = .init(style: .normal, title: "Edit") { a, v, act in
                let holder = self.selectedRow
                self.selectedRow = indexPath.row
                
                self.linkPressed(urlLink)
                var raws = [indexPath]
                if let holder = holder {
                    raws.append(.init(row: holder, section: 0))
                }
                tableView.reloadRows(at: raws, with: .automatic)
            }
            let delete:UIContextualAction = .init(style: .normal, title: "Delete") { a, v, act in
                self.deletePressed(at: dataRow, isFooter: url == .footer)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.endUpdates()
                self.updateDB()
            }
            edit.editType()
            delete.deleteType()
            return .init(actions: [edit, delete])
        } else {
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if tableData[indexPath.row].1, let urlLink = link(indexPath, reorder: false),
           let component = urlLink.components.first(where: {
               return LinkAttributeType.init(rawValue: $0) != nil
           }),
           let url = LinkAttributeType(rawValue: component)
        {
            return url.canReorder
        } else {
            return false
        }
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if tableData[sourceIndexPath.row].1, tableData[destinationIndexPath.row].1, let urlLink = link(sourceIndexPath),
           let component = urlLink.components.first(where: {
               return LinkAttributeType.init(rawValue: $0) != nil
           }),
           let url = LinkAttributeType(rawValue: component),
           url.canReorder,
           let dataIndex = url.dataIndex(components: urlLink.components)
        {
            let data = (url == .footer ? (self.pdfData?.properties.footers ?? []) : (self.pdfData?.properties.headers ?? []))[dataIndex]
            let toLink = link(destinationIndexPath)
            let toLinkurl = LinkAttributeType(rawValue: component)
            let toIndex = toLinkurl?.dataIndex(components: toLink?.components ?? [])
            self.removeCustom(isFooter: url == .footer, at: dataIndex)
            self.enteringValuePropHolder = data.custom?.textSettins ?? .init(dict: [:])
            self.addCustom(isFooter: toLinkurl == .footer, str: data.custom?.title ?? "-", insertAt: toIndex)
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableData[indexPath.row].1, let urlLink = link(indexPath, reorder: false),
           let component = urlLink.components.first(where: {
               return LinkAttributeType.init(rawValue: $0) != nil
           }),
           let url = LinkAttributeType(rawValue: component),
           url.canReorder,
           let _ = url.dataIndex(components: urlLink.components)
        {
            return true
        } else {
            return false
        }
    }
}
