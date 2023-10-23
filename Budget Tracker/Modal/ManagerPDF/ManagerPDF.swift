//
//  ManagerPDF.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha . All rights reserved.
//

import UIKit
import PDFKit

struct ManagerPDF {
    private var vc:UIViewController
    private var pageTitle:String
    private var dict:[String:Any]
    init(dict: [String : Any], pageTitle:String, vc:UIViewController, data:[AdditionalPDFData]) {
        self.dict = dict
        self.pageTitle = pageTitle
        self.vc = vc
        self.additionalData = data
    }
    var additionalData:[AdditionalPDFData]
    
    let pageWidth:CGFloat = 612
    private func showError(title:String, description:String? = nil) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.newMessage.show(title:title, description: description, type: .error)
        
    }
    mutating func exportPDF(sender:UIView) {
        guard let pdf = createPDF(),
              let pdfData = pdf.dataRepresentation() else {
            showError(title: "Error creating PDF")
            return
        }
        vc.navigationController?.pushViewController(AttributedStringTestVC.configure(pdf: self), animated: true)
       // vc.presentShareVC(with: [pdfData], sender:sender)
    }
    
    func pdfString(fromCreate:Bool = false) -> (NSAttributedString, CGFloat) {
        let res:NSMutableAttributedString = .init(attributedString: .init(string: ""))
        let data = UnparcePDF(manager: self).dictionaryToString(dict, data: additionalData, fromCreate: fromCreate)
        data.0.forEach({
            res.append($0)
        })
        return (res, data.1)
    }
    
    func test() -> [NSAttributedString] {
        return UnparcePDF(manager: self).dictionaryToString(dict, data: additionalData, fromCreate: true).0
    }

    private mutating func createPDF() -> PDFDocument? {
        let pdfDocument = PDFDocument()
        let text = pdfString()
        guard let page = generator.createPDFPage(fromAttributes: .init(attributedString: text.0), textHeight: text.1, pageWidth: pageWidth)
        else {
            showError(title: "Error converting to pdf image")
            return nil
        }
        pdfDocument.insert(page, at: pdfDocument.pageCount)
        return pdfDocument
    }
    
    lazy var generator:PagePDF = .init()

}



extension ManagerPDF {
    struct AdditionalPDFData {
        var custom:Custom?
        var defaultHeader:DefaultHeader?
        var height:CGFloat? = nil
        struct Custom {
            var image:Data? = nil
            var title:String? = nil
            var description:String? = nil
        }

        struct DefaultHeader {
            let duration:String
            /**
             - expenses, income, etc
             */
            let type:String
        }
    }
}
