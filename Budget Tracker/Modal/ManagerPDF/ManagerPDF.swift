//
//  ManagerPDF.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit
import PDFKit
import CoreGraphics

struct ManagerPDF {
    private var vc:UIViewController
    private var pageTitle:String
    private var dict:[String:Any]
    init(dict: [String : Any], pageTitle:String, vc:UIViewController) {
        self.dict = dict
        self.pageTitle = pageTitle
        self.vc = vc
    }
    private func showError(title:String, description:String? = nil) {
        AppDelegate.shared?.newMessage.show(title:title, description: description, type: .error)
        
    }
    func exportPDF() {
        guard let pdf = createPDF(),
              let pdfData = pdf.dataRepresentation() else {
            showError(title: "Error creating PDF")
            return
        }
        vc.presentShareVC(with: [pdfData])
    }
    
    private func createPDF() -> PDFDocument? {
        let pdfDocument = PDFDocument()
        let text = dictionaryToString(dict)
        guard let page = generator.createPDFPage(fromText: text)
        else {
            showError(title: "Error converting to pdf image")
            return nil
        }
        pdfDocument.insert(page, at: pdfDocument.pageCount)
        return pdfDocument
    }
    
    private func dictionaryToString(_ dictionary: [String: Any]) -> String {
        var text = ""
        print(dictionary, " bjkljkgrrfedmn")
        dictionary.forEach({
            if let val = $0.value as? [String:Any] {
                val.forEach({
                    text += self.row(($0.key, $0.value))
                })
            } else if let val = $0.value as? [[String:Any]] {
                val.forEach({
                    $0.forEach({
                        text += self.row(($0.key, $0.value))
                    })
                })
            } else {
                text += self.row(($0.key, $0.value))
            }
        })
        
        return text
    }
    
    private func row(_ dict:(String, Any)) -> String {
        var res:String = ""
        if let newdict = dict.1 as? [String:Any] {
            res += "\(dict.0)"
            newdict.forEach {
                res += self.row(($0.key, $0.value))
            }
        } else { /*else if let newArr = dict.1 as? [[String:Any]] {
            res += "\(dict.0)"
            newArr.forEach({
                $0.forEach({
                    res += self.row(($0.key, $0.value))
                })
            })
        } else {*/
            let keys = ["name", "transactions"]
            if keys.contains(dict.0) {
                res = "\(dict.0): \(dict.1)\n"
            }
            
        }
        return res
    }
    
    let generator:PagePDF = .init()
}


struct PagePDF {
    
    func createPDFPage(fromText text: String) -> PDFPage? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, [:])
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        
        let textFont = UIFont.systemFont(ofSize: 12.0)
        let textAttributes: [NSAttributedString.Key: Any] = [.font: textFont]
        
        let textRect = CGRect(x: 50, y: 50, width: 512, height: 692)
        text.draw(in: textRect, withAttributes: textAttributes)
        UIGraphicsEndPDFContext()
        if pdfData.length > 0 {
            return PDFDocument(data: pdfData as Data)?.page(at: 0)
        } else {
            print("PDF data is empty")
            return nil
        }
        
    }
}
