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
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emo ji", default: "😃")
    var favoriteEmoji: String
}

