//
//  ManagerPDF.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha . All rights reserved.
//

import UIKit
import PDFKit
import GoogleMobileAds

class ManagerPDF {
    private var vc:UIViewController
    private var pageTitle:String
    private var dict:[String:Any]
    init(dict: [String : Any], pageTitle:String, vc:UIViewController, data:PdfData) {
        self.dict = dict
        self.pageTitle = pageTitle
        self.vc = vc
        self.additionalData = data
    }
    var additionalData:PdfData = .init(headers: [], footers: [])
    let pageWidth:CGFloat = 612
    private func showError(title:String, description:String? = nil) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.newMessage.show(title:title, description: description, type: .error)
        
    }
    func exportPDF(sender:UIView, toEdit:Bool = true) {
        
        guard let pdf = self.createPDF(),
              let pdfData = pdf.dataRepresentation() else {
            self.showError(title: "Error creating PDF")
            return
        }
        if !toEdit {
            self.vc.navigationController?.popViewController(animated: true)
            AppDelegate.shared?.banner.toggleFullScreenAdd(self.vc, type: .pdf, loaded: {
                (self.vc as? StatisticVC)?.fullScrAd = $0
                (self.vc as? StatisticVC)?.fullScrAd?.fullScreenContentDelegate = self.vc as! any GADFullScreenContentDelegate
            }, closed: {
            //    self.vc.navigationController?.topViewController?.presentShareVC(with: [pdfData], sender: sender)
                self.vc.presentShareVC(with: [pdfData], sender:sender)
            })
            
        } else {
            let newVC = AttributedStringTestVC.configure(pdf: self)
            self.vc.navigationController?.pushViewController(newVC, animated: true)
        }
        
        
    }

    
    func pdfString(fromCreate:Bool = false) -> (NSAttributedString, CGFloat) {
        let res:NSMutableAttributedString = .init(attributedString: .init(string: ""))
        let data = UnparcePDF(manager: self).dictionaryToString(dict, data: additionalData, fromCreate: fromCreate)
        data.0.forEach({
            res.append($0)
        })
        return (res, data.1)
    }
    
//    func test() -> [NSAttributedString] {
//        return UnparcePDF(manager: self).dictionaryToString(dict, data: additionalData, fromCreate: true).0
//    }

    private func createPDF() -> PDFDocument? {
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
    struct PdfData {
        var defaultHeaderData:AdditionalPDFData.DefaultHeader? = nil
        var defaultHeader:Bool = true
        var headers:[AdditionalPDFData]
        var defaultFooter:Bool = true
        var footers:[AdditionalPDFData]
    }
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


