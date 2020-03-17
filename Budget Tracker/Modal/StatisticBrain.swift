//
//  StatisticBrain.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.03.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class StatisticBrain {
    
    var statisticData: [String: Double] = [:]
    var statisticArreyNames: [String] = [""]
    var index2 = 0
    var maxValue = 0.0
    var minValue = 0.0
    var maxIncomeName = ""
    var maxExpenceName = ""
    
    func getData(from tableData: [Transactions]) {
        
        statisticArreyNames = [""]
        statisticData = [:]
        index2 = 0
        maxValue = 0.0
        minValue = 0.0
        
        var index = 0
        for i in 0..<tableData.count {
            if statisticArreyNames[index] != tableData[i].category ?? "" {
                statisticArreyNames.append(tableData[i].category ?? "")
                index += 1
            }
        }
        statisticArreyNames.removeFirst()
        
        for i in 0..<tableData.count {
            if statisticArreyNames[index2] == tableData[i].category ?? "" {
                updateGraphValue(i: i, tableData: tableData)
            } else {
                index2 += 1
                updateGraphValue(i: i, tableData: tableData)
            }
        }
        getMax()
    }
    
    func updateGraphValue(i: Int, tableData: [Transactions]) {
            
        statisticData.updateValue(tableData[i].value + (statisticData[tableData[i].category ?? ""] ?? 0.0), forKey: tableData[i].category ?? "")
        
    }
    

    func getMax() {
        
        maxValue = statisticData.values.max() ?? 0.0
        minValue = statisticData.values.min() ?? 0.0
        maxExpenceName = ""
        maxIncomeName = ""
        
        for (key, value) in statisticData {
            if statisticData[key] == minValue {
                maxExpenceName = key
            }
            if statisticData[key] == maxValue {
                maxIncomeName = key
            }
        }
    }
    
}
