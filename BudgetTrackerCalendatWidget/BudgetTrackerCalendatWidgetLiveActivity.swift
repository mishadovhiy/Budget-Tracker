//
//  BudgetTrackerCalendatWidgetLiveActivity.swift
//  BudgetTrackerCalendatWidget
//
//  Created by Misha Dovhiy on 05.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//
#if os(iOS)
import ActivityKit
#endif
import WidgetKit
import SwiftUI

struct BudgetTrackerCalendatWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BudgetTrackerCalendatWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BudgetTrackerCalendatWidgetAttributes.self) { context in
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BudgetTrackerCalendatWidgetAttributes {
    fileprivate static var preview: BudgetTrackerCalendatWidgetAttributes {
        BudgetTrackerCalendatWidgetAttributes(name: "World")
    }
}

extension BudgetTrackerCalendatWidgetAttributes.ContentState {
    fileprivate static var smiley: BudgetTrackerCalendatWidgetAttributes.ContentState {
        BudgetTrackerCalendatWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BudgetTrackerCalendatWidgetAttributes.ContentState {
         BudgetTrackerCalendatWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BudgetTrackerCalendatWidgetAttributes.preview) {
   BudgetTrackerCalendatWidgetLiveActivity()
} contentStates: {
    BudgetTrackerCalendatWidgetAttributes.ContentState.smiley
    BudgetTrackerCalendatWidgetAttributes.ContentState.starEyes
}
