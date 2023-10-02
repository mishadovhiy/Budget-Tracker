//
//  ManagerPDF.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit
import PDFKit

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
        let text = UnparcePDF().dictionaryToString(dict)
        guard let page = generator.createPDFPage(fromAttributes: .init(attributedString: text))
        else {
            showError(title: "Error converting to pdf image")
            return nil
        }
        pdfDocument.insert(page, at: pdfDocument.pageCount)
        return pdfDocument
    }
    
    let generator:PagePDF = .init()
}

