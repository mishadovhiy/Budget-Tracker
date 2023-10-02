//
//  PagePDF.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit
import PDFKit
import CoreGraphics

struct PagePDF {
    
    func createPDFPage(fromText text: String) -> PDFPage? {
        let textFont = UIFont.systemFont(ofSize: 12.0)
        let textSizeCalc = text.calculate(font: textFont, inWindth: 512)
        let textHeight = textSizeCalc.height >= 692 ? textSizeCalc.height : 692
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: textHeight + 100)
        let textAttributes: [NSAttributedString.Key: Any] = [.font: textFont]
        let atr = NSAttributedString(string: text, attributes: textAttributes)
        let nsStr = NSAttributedString(attributedString: atr)
        let mut = NSMutableAttributedString(attributedString: nsStr)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, [:])
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        
        
        let textRect = CGRect(x: 50, y: 50, width: 512, height: textHeight)
        mut.draw(in: textRect)
        UIGraphicsEndPDFContext()
        if pdfData.length > 0 {
            return PDFDocument(data: pdfData as Data)?.page(at: 0)
        } else {
            print("PDF data is empty")
            return nil
        }
        
    }
    
    func createPDFPage(fromAttributes text: NSMutableAttributedString) -> PDFPage? {
        let textFont = UIFont.systemFont(ofSize: 13.0)
        let textSizeCalc = text.string.calculate(font: textFont, inWindth: 512)
        let textHeight = (textSizeCalc.height) >= 692 ? (textSizeCalc.height) : 692
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: textHeight + 100)
    
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, [:])
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor((K.Colors.background ?? .red).cgColor)
            context?.fill(pageRect)
        
        let textRect = CGRect(x: 50, y: 50, width: 512, height: textHeight)
        text.draw(in: textRect)
        UIGraphicsEndPDFContext()
        if pdfData.length > 0 {
            return PDFDocument(data: pdfData as Data)?.page(at: 0)
        } else {
            print("PDF data is empty")
            return nil
        }
        
    }
}
