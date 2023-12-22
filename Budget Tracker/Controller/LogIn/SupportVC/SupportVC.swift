//
//  SupportVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 09.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SupportVC: SuperViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Support message".localize
        textView.delegate = self
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(closeSwipped(_:)))
        let closePress = UISwipeGestureRecognizer(target: self, action: #selector(closePressed(_:)))
        swipe.direction = .down
        
        self.view.addGestureRecognizer(swipe)
        self.view.addGestureRecognizer(closePress)
    }

    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    var message: String = ""
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.message = textView.text
        }
    }
    
    func sendCode(title:String, head:String, body:String, completion: @escaping (Bool) -> ()) {
        let toDataString = "emailTitle=\(title)&emailHead=\(head)&emailBody=\(body)"
        save(dbFileURL: Keys.urlDomen + "budget-tracker-db/sendEmail.php?\(toDataString)", error: { (error) in
            completion(error)
        })
    }
    private func save(dbFileURL: String, error: @escaping (Bool) -> ()) {
        
        let url = NSURL(string: dbFileURL)
        if let RegUrl = url as URL? {
        var request = URLRequest(url: RegUrl)
        request.httpMethod = "POST"
            let dataToSend = Keys.secretKey
                
       // dataToSend = dataToSend + toDataString
        let dataD = dataToSend.data(using: .utf8)
        
        do {

            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, errr in
                
                if errr != nil {
                    error(true)
                    return
                    
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)

                        if returnedData == "1" {
                            error(false)
                        } else {
                            let r = returnedData?.trimmingCharacters(in: .whitespacesAndNewlines)
                            if r == "1" {
                                error(false)
                            } else {
                                error(true)
                            }
                            
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            DispatchQueue.main.async {
                uploadJob.resume()
            }
            
        }
        }
            
    }
    @objc private func textfieldValueChanged(_ textField: UITextView) {
        
    }
    
    @objc func closeSwipped(_ sender: UISwipeGestureRecognizer) {//closeSwipped
        closeKeyboard()
    }
    
    @objc func closePressed(_ sender: UITapGestureRecognizer) {
        closeKeyboard()
    }
    
    func closeKeyboard(){
        DispatchQueue.main.async {
            if self.textView.isFirstResponder {
                self.textView.endEditing(true)
            }
        }
    }

    @IBAction func sendPressed(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            self.textView.endEditing(true)
        }
        
        AppDelegate.shared?.properties?.ai.showLoading {
                let userMessage = self.message + "Username:\(AppDelegate.shared?.properties?.appData.db.username ?? "-")"
                if let mesag = userMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    self.sendCode(title: "btUserSupportRequest", head: "SupportVC", body: mesag) { error in

                        let title =  error ? "Error".localize : "Thank you".localize
                        let description = error ? "Try later".localize : "Your message has been sent".localize
                        DispatchQueue.main.async {
                            self.ai?.showAlertWithOK(title: title, description: description, viewType: error ? .error : .standard)
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                }
            }
   //     }
        
    }

}

extension SupportVC {
    static func configure() -> SupportVC {
        let vc = UIStoryboard(name: "LogIn", bundle: nil).instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
        return vc
        
    }
}
