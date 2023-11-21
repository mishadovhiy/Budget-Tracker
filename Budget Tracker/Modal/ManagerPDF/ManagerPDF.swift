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
        print(data.from.toShortString(), " ManagerPDF datesss")
        print(data.to.toShortString(), " ManagerPDF datesss")
        print(data.today.toShortString(), " ManagerPDF datesss")

    }
    var properties:PDFProperties = .init(dict: [:])

    lazy var generator:PagePDF = .init()
    var pageWidth:CGFloat = 612
    let normalPageWidth:CGFloat = 612
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
                    }, closed: { presented in
                    //    self.vc.navigationController?.topViewController?.presentShareVC(with: [pdfData], sender: sender)
                        if presented {
                            self.vc.presentShareVC(with: [pdfData], sender:sender) {
                                AppDelegate.shared?.banner.appeare(force: true)
                            }
                        } else {
                            AppDelegate.shared?.banner.hide(ios13Hide: true, completion: {
                                self.vc.presentShareVC(with: [pdfData], sender:sender) {
                                    AppDelegate.shared?.banner.appeare(force: true)
                                }
                            })
                        }
                        
                    })
                    
                } else {
                    let newVC = PDFEditVC.configure(pdf: self)
                    self.vc.navigationController?.pushViewController(newVC, animated: true)
                }
            }
        }
    }

    
    func date(for type:PDFreplacingProperties) -> String {
        //headerData
        switch type.date.type {
        case .transactionDateRange:
            if let first = dateComponent(headerData.from, for: type),
               let second = dateComponent(headerData.to, for: type) {
                return first + " " + type.date.rangeSeparetor + " " + second
            } else {
                return ""
            }
        case .today:
            return dateComponent(headerData.today, for: type) ?? ""
        case .none:
            return ""
        }
    }
    

    private func dateComponent(_ date:DateComponents, for type:PDFreplacingProperties) -> String? {
        return date.toShortString(components: type.date.format.compontns, separetor: type.date.dateSeparetor)
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
    
    
    func previewPDF() -> ([NSAttributedString], CGFloat) {
        properties.defaultHeaderData = headerData
        let data = UnparcePDF(manager: self).dictionaryToString(dict, data: properties, fromCreate: true)
        print(properties, " gterfwe4e5gtr")
        return data
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




