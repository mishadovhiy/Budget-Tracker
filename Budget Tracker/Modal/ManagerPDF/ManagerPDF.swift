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
    private var headerData:PDFProperties.DefaultHeaderData
    
    init(dict: [String : Any], pageTitle:String, vc:UIViewController, data:PDFProperties.DefaultHeaderData) {
        self.dict = dict
        self.pageTitle = pageTitle
        self.vc = vc
        self.headerData = data
    }
    var properties:PDFProperties = .init(dict: [:])

    lazy var generator:PagePDF = .init()
    let pageWidth:CGFloat = 612
    
    private func showError(title:String, description:String? = nil) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.newMessage.show(title:title, description: description, type: .error)
        
    }
    func exportPDF(sender:UIView, toEdit:Bool = true) {
        DispatchQueue(label: "dbPdf", qos: .userInitiated).async {
            let db = AppDelegate.shared?.db.viewControllers.pdfProperties ?? .init(dict: [:])
            self.properties = db
            print(db, " yhrtgerfwd")
            DispatchQueue.main.async {
                guard let pdf = self.createPDF(),
                      let pdfData = pdf.dataRepresentation() else {
                    self.showError(title: "Error creating PDF")
                    return
                }
                if !toEdit {
                    self.vc.navigationController?.popViewController(animated: true)
                    AppDelegate.shared?.banner.toggleFullScreenAdd(self.vc, type: .pdf, loaded: {
                        (self.vc as? StatisticVC)?.fullScrAd = $0
                        (self.vc as? StatisticVC)?.fullScrAd?.fullScreenContentDelegate = self.vc as? GADFullScreenContentDelegate
                    }, closed: {
                    //    self.vc.navigationController?.topViewController?.presentShareVC(with: [pdfData], sender: sender)
                        self.vc.presentShareVC(with: [pdfData], sender:sender)
                    })
                    
                } else {
                    let newVC = AttributedStringTestVC.configure(pdf: self)
                    self.vc.navigationController?.pushViewController(newVC, animated: true)
                }
            }
        }
    }

    
    func pdfString(fromCreate:Bool = false) -> (NSAttributedString, CGFloat) {
        let res:NSMutableAttributedString = .init(attributedString: .init(string: ""))
        properties.defaultHeaderData = headerData
        let data = UnparcePDF(manager: self).dictionaryToString(dict, data: properties, fromCreate: fromCreate)
        print(properties, " gterfwe4e5gtr")
        data.0.forEach({
            res.append($0)
        })
        return (res, data.1)
    }
    

    
    private func createPDF() -> PDFDocument? {
        let pdfDocument = PDFDocument()
        let text = pdfString()

        guard let page = generator.createPDFPage(fromAttributes: .init(attributedString: text.0), textHeight: text.1, pageWidth: pageWidth, background: properties.documentProperties.colors.background)
        else {
            showError(title: "Error converting to pdf image")
            return nil
        }
        pdfDocument.insert(page, at: pdfDocument.pageCount)
        return pdfDocument
    }
    
}




