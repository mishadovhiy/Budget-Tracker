//
//  AppIntent.swift
//  BudgetTrackerCalendatWidget
//
//  Created by Misha Dovhiy on 05.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Calendar widget from Budget Tracker.")

    // An example configurable parameter.
    //@Parameter(title: "Favorite Emoji", default: "😃")
   // var favoriteEmoji: String
    //@Parameter(title:"")
}

