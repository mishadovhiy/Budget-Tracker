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
        print(indexPath.row, " rgter")
        cell.set(tableData[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if settingsNav?.viewControllers.count == 1 {
            if let url = link(indexPath) {
                linkPressed(url)
            }
        } else {
            vibrate(style: .heavy)
        }
        
        
    }
    
    private func link(_ index:IndexPath) -> URL? {
        let text = tableData[index.row]
        let range = NSRange(0..<(text.length))
        if let atr = text.attribute(.init(PDFEditVC.pdfLinkKey), at: range.location, effectiveRange: nil),
            let url = atr as? URL {
            
            return url
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let urlLink = link(indexPath),
           let component = urlLink.components.first(where: {
               return LinkAttributeType.init(rawValue: $0) != nil
           }),
           let url = LinkAttributeType(rawValue: component),
           url.canReorder,
           let dataRow = url.dataIndex(components: urlLink.components)
        {
            return .init(actions: [
                .init(style: .normal, title: "Reorder") { a, v, act in
                    self.stopEditingButton.fadeTransition(0.3)
                    self.stopEditingButton.isHidden = false
                    tableView.reloadData()
                    tableView.setEditing(true, animated: true)
                    print(tableView.isEditing, " gterfwds")
                },
                .init(style: .normal, title: "Edit") { a, v, act in
                    self.linkPressed(urlLink)
                },
                .init(style: .normal, title: "Delete") { a, v, act in
                    self.deletePressed(at: dataRow, isFooter: url == .footer)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .left)
                    tableView.endUpdates()
                    self.updateDB()
                }
            ])
        } else {
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let urlLink = link(indexPath),
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
        if let urlLink = link(sourceIndexPath),
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
    
}
