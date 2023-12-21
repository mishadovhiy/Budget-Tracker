//
//  TransactionsManager.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class TransactionsManager {
    var calculation:HomeVC.Calculations?
    var dataTaskCount:(Int, Int)?
    var taskChanged:(((Int, Int)?)->())?
    var filterChanged:Bool = false
    var daysBetween = [""]

    func new(transactions:[TransactionsStruct]) -> [HomeVC.tableStuct] {
        //        return dictToTable(filtered).sorted{
        //            Calendar.current.date(from: $0.date ) ?? Date.distantFuture >
        //                    Calendar.current.date(from: $1.date ) ?? Date.distantFuture
        //        }
        let today = (AppDelegate.shared?.properties?.appData.db.filter.fromDate ?? DateComponents())
        let filtered = transactions.filter({
            $0.dateFromString.toDateComponents().year == today.year && (($0.dateFromString.toDateComponents().month ?? 0) == (today.month ?? -1))
        })
        let result = dataToDict(filtered)
        print(filtered, " grdfsa")
        return dictToTable(result).sorted{
            Calendar.current.date(from: $0.date ) ?? Date.distantFuture >
            Calendar.current.date(from: $1.date ) ?? Date.distantFuture
        }
    }
    
    func total(transactions:[TransactionsStruct]) -> Double {
        var res:Double = 0
        let new = transactions
        let thisMonth = String((AppDelegate.shared?.properties?.appData.db.filter.getToday() ?? "").dropFirst().dropFirst())
        let allForThisMonth = new.filter({
            return $0.date.contains(thisMonth)
        })
        
        allForThisMonth.forEach({
            res += Double($0.value) ?? 0
        })
        return res
    }
    
    func filtered(_ data:[TransactionsStruct]) -> [TransactionsStruct] {
        let today = (AppDelegate.shared?.properties?.appData.db.filter.fromDate ?? DateComponents())
        return data.filter { transaction in
            return (transaction.date.stringToCompIso().year ?? 1) == (today.year ?? 0)
        }
    }
    func dataToDict(_ transactions:[TransactionsStruct]) -> [String:[TransactionsStruct]] {
        var result:[String:[TransactionsStruct]] = [:]
        var i = 0
        let totalCount = transactions.count
        for trans in transactions {
            self.calculation?.balance += (Double(trans.value) ?? 0.0)
            dataTaskCount = (i, totalCount)
            i += 1
            print(i)
            if filterChanged {
                return [:]
            }

           // if trans.category.purpose != .debt {
                if containsDay(curDay: trans.date) {
                    var transForDay = result[trans.date] ?? []
                    transForDay.append(trans)
                    result.updateValue(transForDay, forKey: trans.date)
                    
                }
          //  }
        }
        return result
    }
    
    
    private func containsDay(curDay:String) -> Bool {
        if (AppDelegate.shared?.properties?.appData.db.filter.showAll ?? false) {
            return true
        } else {
            return daysBetween.contains(curDay)

        }
        
    }
    
    func dictToTable(_ dict:[String:[TransactionsStruct]]) -> [HomeVC.tableStuct] {
        return dict.compactMap { (key: String, value: [TransactionsStruct]) in
            let transactions = value.sorted { Double($0.value) ?? 0.0 < Double($1.value) ?? 0.0 }
            let date = key.stringToDateComponent()
            let am = self.amountForTransactions(transactions)
            let amount = Int(am.0)
            let calc = am.1
        
            return .init(date:  date, amount: amount, transactions: transactions)
        }
    }
    
    private func amountForTransactions(_ transactions:[TransactionsStruct]) -> (Double,  HomeVC.Calculations) {
        var result:Double = 0
        var calcs:HomeVC.Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
        for transaction in transactions {
            let amount = (Double(transaction.value) ?? 0.0)
            result += amount
            
            if amount > 0 {
                calcs.income += amount
            } else {
                calcs.expenses += amount
            }
            calcs.perioudBalance += amount
            
        }
        let currentCalcs = calculation ?? .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
      //  calculations = .init(expenses: currentCalcs.expenses + calcs.expenses, income: currentCalcs.income + calcs.income, balance: calculations.balance, perioudBalance: currentCalcs.perioudBalance + calcs.perioudBalance)
       // return result
        let calc:HomeVC.Calculations = .init(expenses: currentCalcs.expenses + calcs.expenses, income: currentCalcs.income + calcs.income, balance: currentCalcs.balance, perioudBalance: currentCalcs.perioudBalance + calcs.perioudBalance)
        self.calculation = calc
        return (result, calc)
        
    }
}
