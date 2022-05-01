//
//  QRcodeVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.05.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class QRcodeVC: UIViewController {

    @IBOutlet weak var qrCodeImage: UIImageView!

    let urlStr = "https://apps.apple.com/app/budget-traker/id1511515117"
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = self.generateQRCode(from: urlStr)
        self.qrCodeImage.image = image
    }

    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    @IBAction func close(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    @IBAction func openPressed(_ sender: Any) {
        if let url = URL(string: urlStr) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    
                }
            }
        }
    }

    
    
    
}



extension UIKey {
    func isNum() -> Int? {
        if let num = Int(self.characters) {
            return num
        }
        
        return nil
    }
}
