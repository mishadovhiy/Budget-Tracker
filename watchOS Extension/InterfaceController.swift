//
//  InterfaceController.swift
//  watchOS Extension
//
//  Created by Mikhailo Dovhyi on 08.04.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import WatchKit
import Foundation
import UIKit
//todo:
//load data from db
//if paired and db.username == "" --- load from

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var balanceLabel: WKInterfaceLabel!
    
    @IBOutlet weak var expencesLabel: WKInterfaceLabel!
    
    @IBOutlet weak var incomeLabel: WKInterfaceLabel!
    
    //expences, incomes, balance
    var calculation = (0,0,0)
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        print("Loaded")
    }
    
    func Transactions(completion: @escaping ([[String]], String) -> ()) {
        
        var loadedData: [[String]] = []
        let urlPath = "https://www.dovhiy.com/apps/budget-tracker-db/transactions.php"
        let url: URL = URL(string: urlPath)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                completion([], "Internet Error!")
                return
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    completion([], "Internet Error!")
                    return
                }
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary
                    
               /*     if appData.username != "" {
                        if appData.username == (jsonElement["Nickname"] as? String ?? "") {
                            if let name = jsonElement["Nickname"] as? String,
                               let category = jsonElement["Category"] as? String,
                               let date = jsonElement["Date"] as? String,
                               let value = jsonElement["Value"] as? String,
                               let comment = jsonElement["Comment"] as? String
                            {
                                //calculate
                                loadedData.append([name, category, date, value, comment])
                            }
                        }
                    }*/
                }

                completion(loadedData, "")
            }
        }
        DispatchQueue.main.async {
            task.resume()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        print("Loading")
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}
