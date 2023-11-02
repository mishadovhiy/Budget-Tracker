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
    
    func getlocalData(from tableData: [TransactionsStruct]) {
        
        statisticArreyNames = [""]
        statisticData = [:]
        index2 = 0
        maxValue = 0.0
        minValue = 0.0
        
        var index = 0
        for i in 0..<tableData.count {
            if statisticArreyNames[index] != tableData[i].categoryID {
                statisticArreyNames.append(tableData[i].categoryID)
                index += 1
            }
        }
        statisticArreyNames.removeFirst()
        
        for i in 0..<tableData.count {
            if (statisticArreyNames.count - 1) <= index2 {
                if statisticArreyNames[index2] == tableData[i].categoryID {
                    updateGraphValue(i: i, tableData: tableData)
                } else {
                    index2 += 1
                    updateGraphValue(i: i, tableData: tableData)
                }
            }
            
        }
        getMax()
    }
    
    func updateGraphValue(i: Int, tableData: [TransactionsStruct]) {
            
        statisticData.updateValue((Double(tableData[i].value) ?? 0.0) + (statisticData[tableData[i].categoryID] ?? 0.0), forKey: tableData[i].categoryID)
        
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
