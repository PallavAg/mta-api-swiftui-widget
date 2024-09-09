//
//  AppIntent.swift
//  mta-estimate
//
//  Created by Pallav Agarwal on 9/8/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}

struct ReloadIntent: AppIntent {
    static var title: LocalizedStringResource = "Repeat Last Coffee"

    init(){}
    
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
