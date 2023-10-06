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
    var entry: Provider.Entry
    @State private var data: String = "Loading..."
    
    var body: some View {
        
        
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Favrite Emoji:")
        
            Text("count: \(entry.transactions.count)\nloaded:\(entry.isLoaded.description)\n\(data)")
            
        }
    }

    
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(transactions: [], date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let dbDict = UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")?.value(forKey: "transactionsDataNew") as? [[String:Any]] ?? []
        print(dbDict.count, " trgeegr")
        return SimpleEntry(transactions: dbDict, isLoaded:true, date: Date(), configuration: configuration)
        
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = await snapshot(for: configuration, in: context)
            entries.append(entry)
        }

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
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    BudgetTrackerCalendatWidget()
} timeline: {
    SimpleEntry(transactions: [], date: .now, configuration: .smiley)
    SimpleEntry(transactions: [], date: .now, configuration: .starEyes)
}
