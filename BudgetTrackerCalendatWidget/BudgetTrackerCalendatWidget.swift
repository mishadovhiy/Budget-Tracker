//
//  BudgetTrackerCalendatWidget.swift
//  BudgetTrackerCalendatWidget
//
//  Created by Misha Dovhiy on 05.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import WidgetKit
import SwiftUI

struct BudgetTrackerCalendatWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    private var unparced:UnparceProvider {.init(provider: entry, date: today) }
    private var params:WidgetProportions { .init(kind: widgetFamily) }
    
    var body: some View {
        let data = self.unparced
        let collectionData = data.colectionItems
        if params.mainHorizontal {
            let space:CGFloat = widgetFamily == .systemExtraLarge ? 25 : 10
            HStack(spacing:space) {
                gridView(collectionData)
                if params.needTotals {
                    VStack(alignment: .leading, spacing: space) {
                        if params.needBalance {
                            balancesV(collectionData, canScal: true)
                        }
                        totalsV(collectionData, space: space)
                    }
                }
            }
        } else {
            VStack(spacing:10) {
                if params.needTotals {
                    HStack(spacing: 35) {
                        if params.needBalance {
                            balancesV(collectionData, canScal: false)
                        }
                        totalsH(collectionData)
                    }
                }
                gridView(collectionData)
            }
        }
        
    }
    
    private func totalsV(_ data:BudgetTrackerCalendatWidgetEntryView.UnparceProvider.CollectionResult, space:CGFloat = 10) -> some View {
        VStack(alignment:.leading, spacing: space) {
            VStack(alignment:.leading) {
                Text("Income")
                    .frame(alignment:.leading)
                    .font(.system(size: params.balanceTitleFontSize))
                    .foregroundColor(Color(params.colors.balancesTitleLabel))
                    .minimumScaleFactor(0.3)
                Text("\(Int(data.income))")
                    .minimumScaleFactor(0.3)
                    .foregroundColor(Color(params.colors.balancesValueLabel))
                    .font(.system(size: params.balanceValueFontSize, weight: .semibold))
            }
            VStack(alignment:.leading) {
                Text("Expences")
                    .frame(alignment:.leading)
                    .font(.system(size: params.balanceTitleFontSize))
                    .foregroundColor(Color(params.colors.balancesTitleLabel))
                    .minimumScaleFactor(0.3)
                Text("\(Int(data.expenses))")
                    .minimumScaleFactor(0.3)
                    .foregroundColor(Color(params.colors.balancesValueLabel))
                    .font(.system(size: params.balanceValueFontSize, weight: .semibold))
                
            }
        }
    }
    
    private func totalsH(_ data:BudgetTrackerCalendatWidgetEntryView.UnparceProvider.CollectionResult) -> some View {
        HStack(spacing:35) {
            VStack(alignment:.leading) {
                Text("Income")
                    .frame(alignment:.leading)
                    .font(.system(size: params.balanceTitleFontSize))
                    .foregroundColor(Color(params.colors.balancesTitleLabel))
                Text("\(Int(data.income))")
                    .foregroundColor(Color(params.colors.balancesValueLabel))
                    .font(.system(size: params.balanceValueFontSize, weight: .semibold))
            }
            VStack(alignment:.leading) {
                Text("Expences")
                    .frame(alignment:.leading)
                    .font(.system(size: params.balanceTitleFontSize))
                    .foregroundColor(Color(params.colors.balancesTitleLabel))
                Text("\(Int(data.expenses))")
                    .foregroundColor(Color(params.colors.balancesValueLabel))
                    .font(.system(size: params.balanceValueFontSize, weight: .semibold))
            }
        }
    }
    
    private func balancesV(_ data:BudgetTrackerCalendatWidgetEntryView.UnparceProvider.CollectionResult, canScal:Bool = false) -> some View {
        VStack(alignment:.leading) {
            Text("Balance")
                .frame(alignment:.leading)
                .font(.system(size: params.balanceTitleFontSize))
                .foregroundColor(Color(params.colors.balancesTitleLabel))
                .minimumScaleFactor(canScal ? 0.3 : 1)
            Text("\(Int(data.balance))")
                .minimumScaleFactor(canScal ? 0.3 : 1)
                .foregroundColor(Color(params.colors.balancesValueLabel))
                .font(.system(size: params.balanceValueFontSize, weight: .semibold))
            
        }
    }
    
    private func gridView(_ data:BudgetTrackerCalendatWidgetEntryView.UnparceProvider.CollectionResult) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(params.gridSize.width), spacing: params.spacing), count: 7),
                  spacing: params.spacing) {
            ForEach(data.transactions, id: \.self.day) { item in
                let empty = item.isEmpty
                VStack(alignment:.center) {
                    Text(!empty ? item.day : "")
                        .foregroundColor(Int(item.day) == (today.day ?? -1) ? .red : Color(params.colors.titleLabel))
                        .frame(width: params.gridSize.width - 2, height: (params.gridSize.height / 3) - 2, alignment:.leading)
                    Text(!empty ? item.amount : "")
                        .font(.system(size: params.greyFontSize))
                        .foregroundColor(Color(params.colors.descriptionLabel))
                        .background(Color(params.colors.gridBackground.withAlphaComponent(0.2)))
                        .cornerRadius(5)
                        .frame(width: params.gridSize.width, alignment:.leading)
                }
                
                .frame(width: params.gridSize.width, height: params.gridSize.height)
                .background(!empty ? Color(params.colors.gridBackground.withAlphaComponent(0.2)) : .clear)
                .cornerRadius(params.spacing == 0 ? 1 : 6)
                .font(.system(size: params.titleSize, weight: .semibold))
                .minimumScaleFactor(0.3)
            }
        }
    }
    
    var today: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day], from: Date())
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(transactions: [], date: Date(), configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    let dbDict = UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.value(forKey: "transactionsDataNew") as? [[String:Any]] ?? []
                    let results = SimpleEntry(transactions: dbDict, isLoaded:true, date: Date(), configuration: configuration)
                    DispatchQueue.main.async {
                        continuation.resume(returning: results)
                    }
                }
            }
            return result
        } catch {
            return .init(transactions: [], date: .now, configuration: .smiley)
        }
        
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        //let currentDate = Date()
        for _ in 0 ..< 5 {
            //   let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = await snapshot(for: configuration, in: context)
            entries.append(entry)
        }
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    var transactions:[[String:Any]]
    var isLoaded = false
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct BudgetTrackerCalendatWidget: Widget {
    let kind: String = "BudgetTrackerCalendatWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BudgetTrackerCalendatWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        // intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        // intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    BudgetTrackerCalendatWidget()
} timeline: {
    SimpleEntry(transactions: [], date: .now, configuration: .smiley)
    SimpleEntry(transactions: [], date: .now, configuration: .starEyes)
}





extension BudgetTrackerCalendatWidgetEntryView.UnparceProvider {
    struct Transaction {
        let day:String
        var amount:String = ""
        var isEmpty:Bool = false
    }
    
    struct DaysCompletion {
        let days:[Int]
        let weekStart:Int
    }
}

extension BudgetTrackerCalendatWidgetEntryView {
    struct UnparceProvider {
        private let provider:Provider.Entry
        private let date:DateComponents
        
        init(provider: Provider.Entry, date:DateComponents) {
            self.provider = provider
            self.date = date
        }
        
        private var transactions:[[String:Any]] {
            provider.transactions
        }
        
        private var month:Int {
            date.month ?? 0
        }
        
        private var year:Int {
            date.year ?? 0
        }
        
        private func transactionsByDay(days:[Int]) -> [String:[String]] {
            var dict:[String:[String]] = [:]
            days.forEach({ dayInt in
                var transaction:[String] = []
                let dayString = "\(twoDecs(dayInt)).\(twoDecs(month)).\(year)"
                transactions.forEach({
                    if let day = $0["Date"] as? String,
                       day == dayString,
                       let amount = $0["Amount"] as? String
                    {
                        transaction.append(amount)
                    }
                })
                dict.updateValue(transaction, forKey: "\(dayInt)")
            })
            return dict
        }
        
        private func twoDecs(_ n:Int) -> String {
            if n <= 9 {
                return "0\(n)"
            } else {
                return "\(n)"
            }
        }
        
        private var getDays: DaysCompletion {
            let dateComponents = DateComponents(year: year, month: month)
            let calendar = Calendar.current
            let date = calendar.date(from: dateComponents)!
            
            let range = calendar.range(of: .day, in: .month, for: date)!
            let numDays = range.count
            var resultDays:[Int] = []
            let formatter  = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let strDate = "\(year)-\(twoDecs(month))-01"
            let datee = formatter.date(from: strDate)
            let calendarr = Calendar(identifier: .gregorian)
            let weekNumber = calendarr.component(.weekday, from: datee ?? Date()) - 3
            
            let weekRes = weekNumber < 0 ? 7 + weekNumber : weekNumber
            /* for _ in 0..<weekRes{
             resultDays.append(0)
             }*/
            for i in 0..<numDays {
                resultDays.append(i+1)
            }
            return .init(days: resultDays, weekStart: weekRes + 1)
        }
        
        struct CollectionResult {
            let transactions:[Transaction]
            let balance:CGFloat
            let expenses:CGFloat
            let income:CGFloat
        }
        
        var colectionItems:CollectionResult {
            var data:[Transaction] = []
            let get = getDays
            var days = get.days.compactMap({
                return ($0 != 0 ? "\($0)" : "--")
            })
            for i in 0..<get.weekStart {
                days.insert("--\(i)", at: 0)
            }
            let dict = transactionsByDay(days: get.days)
            var balance:CGFloat = 0
            var expoenses:CGFloat = 0
            var income:CGFloat = 0
            days.forEach({
                let transactions = dict["\($0)"] ?? []
                var amount:CGFloat = 0
                transactions.forEach({
                    let new = Double($0) ?? 0
                    amount += new
                    
                })
                if $0.contains("--") {
                    data.append(.init(day: "", isEmpty: true))
                } else if let transacs = dict["\($0)"], transacs.count != 0 {
                    data.append(.init(day: $0, amount: "\(Int(amount))"))
                    balance += amount
                    if amount >= 0 {
                        income += amount
                    } else {
                        expoenses += amount
                    }
                } else {
                    data.append(.init(day: $0))
                }
            })
            return .init(transactions: data, balance: balance, expenses: expoenses, income: income)
        }
    }
    
}

extension BudgetTrackerCalendatWidgetEntryView {
    struct WidgetProportions {
        let kind:WidgetFamily
        init(kind: WidgetFamily) {
            self.kind = kind
        }
        
        var titleSize:CGFloat {
            switch kind {
            case .systemMedium:
                return 9
            case .systemLarge:
                return 12
            case .systemExtraLarge:
                return 13
            default:
                return 8
            }
            
        }
        
        var greyFontSize:CGFloat {
            switch kind {
            case .systemMedium:
                return 9
            case .systemLarge:
                return 11
            case .systemExtraLarge:
                return 13
            default:
                return 8
            }
        }
        
        var balanceTitleFontSize:CGFloat {
            switch kind {
            case .systemExtraLarge:
                return 13
            default:
                return 11
            }
        }
        var balanceValueFontSize:CGFloat {
            switch kind {
            case .systemExtraLarge:
                return 20
            default:
                return 17
            }
        }
        
        var spacing:CGFloat {
            switch kind {
            case .systemMedium:
                return 2
            case .systemLarge:
                return 3
            case .systemExtraLarge:
                return 7
            default:
                return 0
            }
        }
        
        var gridSize:CGSize {
            switch kind {
            case .systemMedium:
                return .init(width: 30, height: 24)
            case .systemLarge:
                return .init(width: 42, height: 45)
            case .systemExtraLarge:
                return .init(width: 60, height: 45)
            default:
                return .init(width: 22, height: 24)
            }
        }
        
        var needWeeks:Bool {
            switch kind {
            case .systemSmall, .systemMedium:
                return false
            case .systemLarge, .systemExtraLarge:
                return true
            default:
                return false
            }
        }
        
        var needBalance:Bool {
            switch kind {
            case .systemExtraLarge, .systemLarge, .systemMedium:
                return true
            default:
                return false
            }
        }
        
        var needTotals:Bool {
            switch kind {
            case .systemExtraLarge, .systemLarge, .systemMedium:
                return true
            default:
                return false
            }
        }
        
        var padding:CGFloat {
            switch kind {
            case .systemLarge:return -10
            default:return 0
            }
        }
        
        var mainHorizontal:Bool {
            switch kind {
            case .systemMedium, .systemExtraLarge:return true
            default:return false
            }
        }
        
        let colors:Colors = .init()
        
        struct Colors {
            var titleLabel:UIColor {
                .init(named: "balanceTitleColor") ?? .red
            }
            var descriptionLabel:UIColor {
                .init(named: "WhiteColor") ?? .red
            }
            
            var balancesTitleLabel:UIColor {
                .init(named: "balanceTitleColor") ?? .red
            }
            var balancesValueLabel:UIColor {
                .init(named: "WhiteColor") ?? .red
            }
            var gridBackground:UIColor {
                .init(named: "CategoryColor1") ?? .red
            }
            
        }
    }
}
