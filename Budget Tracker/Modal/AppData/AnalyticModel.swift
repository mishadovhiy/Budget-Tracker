//
//  Analytics.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 16.05.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

struct AnalyticModel {
    static var shared = AnalyticModel()
    
    var analiticStorage:[Analitic] {
        get {
            let all = UserDefaults.standard.value(forKey: "analiticStorage") as? [[String:Any]] ?? []
            var result:[Analitic] = []
            for element in all {
                result.append(.init(dict: element))
            }
            return result
        }
        set {
            var result:[[String:Any]] = []
            for element in newValue {
                result.append(element.dict)
            }
            UserDefaults.standard.setValue(result, forKey: "analiticStorage")
        }
    }

    func checkData() {
        let all = UserDefaults.standard.value(forKey: "analiticStorage") as? [[String:Any]] ?? []
        let first = UserDefaults.standard.value(forKey: "firstAnalyticSent") as? Bool ?? false
        if (all.count > (appData.devMode ? 20 : 50)) || !first {
            if !first {
                UserDefaults.standard.setValue(true, forKey: "firstAnalyticSent")
            }
            sendData(all)
        }
    }
    
    
    private func createData(_ dataOt:[[String:Any]]?) -> String {
        var all = dataOt ?? (UserDefaults.standard.value(forKey: "analiticStorage") as? [[String:Any]] ?? [])
        all.append([
            "id":(UIDevice.current.identifierForVendor?.description ?? "unknown"),
            "deviceType":(AppDelegate.shared?.deviceType.rawValue ?? "unknown"),
            "authorized":(appData.username == "" ? "1" : "0")
        ])
        guard let data = try? JSONSerialization.data(withJSONObject: all, options: []) else {
            return ""
        }
        return ((String(data: data, encoding: .utf8) ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
    
    private func sendData(_ dataOt:[[String:Any]]?) {
        let analyticsData = createData(dataOt)
        if analyticsData != "" {
            SaveToDB.shared.sendAnalytics(data: analyticsData) { error in
                if error {
                    print("ERRor sending data")
                } else {
                    UserDefaults.standard.setValue([], forKey: "analiticStorage")
                }
            }
        }
        
    }
    
    
    class Analitic {
        let key:String
        let action:String
        let time:String
        let dict:[String:Any]
        
        init(dict:[String:Any]) {
           
            if let timee = dict["time"] as? String {
                self.time = timee
                self.dict = dict
            } else {
                let time = Date().iso8601withFractionalSeconds
                var resultDict = dict
                resultDict.updateValue(time, forKey: "time")
                self.time =  time
                self.dict = resultDict
            }
            
            self.key = dict["key"] as? String ?? ""
            self.action = dict["vc"] as? String ?? ""
            
        }
        init(key:String, action:String) {
            let time = Date().iso8601withFractionalSeconds
            let dict = ["key":key, "vc":action, "time": time]
            
            self.dict = dict
            self.time = time
            self.key = dict["key"] ?? ""
            self.action = dict["vc"] ?? ""
            print("newAnalitic: ", dict)
        }

    }
}
