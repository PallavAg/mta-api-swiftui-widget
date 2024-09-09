//
//  mta_estimateLiveActivity.swift
//  mta-estimate
//
//  Created by Pallav Agarwal on 9/8/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct mta_estimateAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct mta_estimateLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: mta_estimateAttributes.self) { context in
            // Lock screen/banner UI goes here
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

extension mta_estimateAttributes {
    fileprivate static var preview: mta_estimateAttributes {
        mta_estimateAttributes(name: "World")
    }
}

extension mta_estimateAttributes.ContentState {
    fileprivate static var smiley: mta_estimateAttributes.ContentState {
        mta_estimateAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: mta_estimateAttributes.ContentState {
         mta_estimateAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: mta_estimateAttributes.preview) {
   mta_estimateLiveActivity()
} contentStates: {
    mta_estimateAttributes.ContentState.smiley
    mta_estimateAttributes.ContentState.starEyes
}
