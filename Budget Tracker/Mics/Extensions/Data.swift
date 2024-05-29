//
//  Data.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 16.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

extension Data {
    static func create(from dict:[String:Any]) -> Data? {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false) {
            print(data.count, " gewsassd")
            return data

        } else {
            return nil
        }
    }
    var toDict:[String:Any]? {
        if let dictionary = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(self) as? [String: Any] {
                return dictionary
            } else {
                return nil
            }
    }
}
