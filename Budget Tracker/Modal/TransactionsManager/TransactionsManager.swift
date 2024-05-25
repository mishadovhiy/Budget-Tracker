//
//  TransactionsManager.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//
#if canImport(UIKit)
import UIKit
#endif
import Foundation

class TransactionsManager {
    var calculation:Calculations?
    var dataTaskCount:(Int, Int)?
    var taskChanged:(((Int, Int)?)->())?
    var filterChanged:Bool = false
    private var balanceTotalHolder:Double = 0
    
    func new(transactions:[TransactionsStruct]) -> [tableStuct] {
        //        return dictToTable(filtered).sorted{
        //            Calendar.current.date(from: $0.date ) ?? Date.distantFuture >
        //                    Calendar.current.date(from: $1.date ) ?? Date.distantFuture
        //        }
        calculation = .init()
        let today = (AppDelegate.properties?.db.filter.fromDate ?? DateComponents())
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
        let thisMonth = String((AppDelegate.properties?.db.filter.getToday() ?? "").dropFirst().dropFirst())
        let allForThisMonth = new.filter({
            return $0.date.contains(thisMonth)
        })
        
        allForThisMonth.forEach({
            res += Double($0.value) ?? 0
        })
        return allForThisMonth.reduce(0) { partialResult, item in
            return partialResult + (Double(item.value) ?? 0)
        }
    }
    
    func filtered(_ data:[TransactionsStruct]) -> [TransactionsStruct] {
        let today = (AppDelegate.properties?.db.filter.fromDate ?? DateComponents())
        self.balanceTotalHolder = data.reduce(0) { partialResult, item in
            return partialResult + (Double(item.value) ?? 0)
        }
        return data.filter { transaction in
            let components = transaction.date.stringToCompIso()
            return (components.year ?? 1) == (today.year ?? 0) && components.month == today.month
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
            if containsDay(curDay: trans.compToIso()) {
                    var transForDay = result[trans.date] ?? []
                    transForDay.append(trans)
                    result.updateValue(transForDay, forKey: trans.date)
                    
                }
          //  }
        }
        return result
    }
    
    
    private func containsDay(curDay:DateComponents?) -> Bool {
        if (AppDelegate.properties?.db.filter.showAll ?? false) {
            return true
        } else {
            let from = AppDelegate.properties?.db.filter.fromDate
            return curDay?.year == from?.year && curDay?.month == from?.month
        }
        
    }
    
    func dictToTable(_ dict:[String:[TransactionsStruct]]) -> [tableStuct] {
        return dict.compactMap { (key: String, value: [TransactionsStruct]) in
            let transactions = value.sorted { Double($0.value) ?? 0.0 < Double($1.value) ?? 0.0 }
            let date = key.stringToDateComponent()
            let am = self.amountForTransactions(transactions)
            let amount = Int(am.0)
            let calc = am.1
        
            return .init(date:  date, amount: amount, transactions: transactions)
        }
    }
    
    private func amountForTransactions(_ transactions:[TransactionsStruct]) -> (Double,  Calculations) {
        var result:Double = 0
        var calcs:Calculations = .init(expenses: 0, income: 0, balance: 0, perioudBalance: 0)
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
        let calc:Calculations = .init(expenses: currentCalcs.expenses + calcs.expenses, income: currentCalcs.income + calcs.income, balance: balanceTotalHolder, perioudBalance: currentCalcs.perioudBalance + calcs.perioudBalance)
        self.calculation = calc
        return (result, calc)
        
    }
}

struct Calculations {
    var expenses:Double
    var income:Double
    var balance:Double
    var perioudBalance:Double
    
    init(expenses: Double = 0, income: Double = 0, balance: Double = 0, perioudBalance: Double = 0) {
        self.expenses = expenses
        self.income = income
        self.balance = balance
        self.perioudBalance = perioudBalance
    }
}

struct tableStuct {
    let date: DateComponents
    let amount: Int
    var transactions: [TransactionsStruct]
}
