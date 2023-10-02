//
//  TransactionsManager.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class TransactionsManager {
    var calculation:ViewController.Calculations?
    var dataTaskCount:(Int, Int)?
    var taskChanged:(((Int, Int)?)->())?
    var filterChanged:Bool = false
    var daysBetween = [""]

    func new(transactions:[TransactionsStruct]) -> [ViewController.tableStuct] {
        let filtered = dataToDict(transactions)
        return dictToTable(filtered).sorted{
            Calendar.current.date(from: $0.date ) ?? Date.distantFuture >
                    Calendar.current.date(from: $1.date ) ?? Date.distantFuture
        }
    }
    
    func total(transactions:[TransactionsStruct]) -> Double {
        var res:Double = 0
        let new = transactions
        let thisMonth = String(appData.filter.getToday().dropFirst().dropFirst())
        let allForThisMonth = new.filter({
            return $0.date.contains(thisMonth)
        })
        
        allForThisMonth.forEach({
            res += Double($0.value) ?? 0
        })
        return res
    }
    
    func filtered(_ data:[TransactionsStruct]) -> [TransactionsStruct] {
        let today = appData.filter.fromDate
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
        if appData.filter.showAll {
            return true
        } else {
            return daysBetween.contains(curDay)

        }
        
    }
    
    func dictToTable(_ dict:[String:[TransactionsStruct]]) -> [ViewController.tableStuct] {
        return dict.compactMap { (key: String, value: [TransactionsStruct]) in
            let co = DateComponents()
            let transactions = value.sorted { Double($0.value) ?? 0.0 < Double($1.value) ?? 0.0 }
            let date = co.stringToDateComponent(s: key)
            let am = amountForTransactions(transactions)
            let amount = Int(am.0)
            let calc = am.1
        
            return .init(date:  date, amount: amount, transactions: transactions)
        }
    }
    
    private func amountForTransactions(_ transactions:[TransactionsStruct]) -> (Double,  ViewController.Calculations) {
        var result:Double = 0
        var calcs:ViewController.Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
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
        let calc:ViewController.Calculations = .init(expenses: currentCalcs.expenses + calcs.expenses, income: currentCalcs.income + calcs.income, balance: currentCalcs.balance, perioudBalance: currentCalcs.perioudBalance + calcs.perioudBalance)
        self.calculation = calc
        return (result, calc)
        
    }
}
