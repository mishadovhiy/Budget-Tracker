//
//  WebViewVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: SuperViewController, UIScrollViewDelegate, WKNavigationDelegate {
    @IBOutlet weak var screenAI: UIActivityIndicatorView!
    
    @IBOutlet weak var webView: WKWebView!
    
    var screenTitle:String = ""
    public var htmlData: HtmlData?
    static var shared = WebViewVC()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.delegate = self
        title = screenTitle
        DispatchQueue.init(label: "loadHtmlData", qos: .userInteractive).async {
            if let htmlData = self.htmlData,
               let html = self.unparseHTML(urlString: htmlData.url, from: "<!--\(htmlData.key)-->", to: "<!--/\(htmlData.key)-->")
            {
                print("loadedHTML:\n", html)
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(html, baseURL: nil)
                    self.webView.isHidden = false
                    self.screenAI.stopAnimating()
                    self.screenAI.isHidden = true
                    self.webView.scrollView.contentInset.bottom = AppDelegate.shared?.banner.size ?? 0
                }
            } else {
                self.errorLoading()
            }
        }
        
        
    }
    
    
    
    
    public func presentScreen(in nav:UINavigationController, data:HtmlData, screenTitle:String) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Reusable", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            vc.htmlData = data
            vc.screenTitle = screenTitle
            nav.pushViewController(vc, animated: true)
        }
    }
    
    
    
    func unparseHTML(urlString:String, from: String, to: String) -> String? {
        let css = "css/style22.css"
        if let url = URL(string: urlString) {
            if let html = try? String(contentsOf: url).replacingOccurrences(of: css, with: "\(urlString)/\(css)").replacingOccurrences(of: "imgs/", with: urlString + "/imgs/") {
                let head = "<!DOCTYPE html><html lang=\"en\"><head>"
                let headContent = (html.slice(from: "<head>", to: "</head>") ?? "")
                let headHtml = head + headContent + "</head><body>" + cssStyles
                let htmlContent = html.slice(from: from, to: to) ?? ""
                let footer = "</body></html>"
                let result = headHtml + htmlContent + footer
                return result
            } else {
                return nil
            }
        } else {
            return nil
        }
        
    }
    
    private func errorLoading() {
        DispatchQueue.main.async {
            AppDelegate.shared?.ai.showAlertWithOK(title: Text.Error.InternetTitle, text: Text.Error.internetDescription, error: true, hidePressed: { _ in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
}

extension WebViewVC {
    struct HtmlData {
        let url:String
        let key:String
    }
}



extension WebViewVC {
    var cssStyles:String {
        return """
<style type="text/css">
@font-face{font-family:'Open Sans', sans-serif;font-display:swap;}
*{box-sizing:border-box;padding:0;margin:0}

body{ background: #000000; padding-left: 10px; padding-right: 10px; }
p, h2, h1, h3, h4, h5, ul, li{ color: #EBE9E9; font-family:'Open Sans',sans-serif; }
p{font-size: 14px;line-height:1.65;}
h2{ margin-top: 35px; margin-bottom: 5px; }
h1{ margin-bottom: 5px; }
ul{ margin-left: 20px; margin-bottom:5px;" }
a{ color: white; }

</style>
"""
    }
}
