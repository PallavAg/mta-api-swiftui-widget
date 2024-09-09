//
//  mta_estimate.swift
//  mta-estimate
//
//  Created by Pallav Agarwal on 9/8/24.
//

import WidgetKit
import SwiftUI
import Foundation

// Provider is responsible for creating the widget timeline and fetching the data to display.
struct Provider: AppIntentTimelineProvider {
    
    // Provides a placeholder widget that appears while the actual data is being loaded.
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), estimate: "Loading...")
    }
    
    // Provides a snapshot of the widget with static data for quick previews.
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let estimate = await fetchEstimate()
        return SimpleEntry(date: Date(), estimate: estimate)
    }
    
    // Builds a timeline of widget entries. This is called by the system to display and refresh the widget.
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        // Fetch the latest MTA arrival estimate.
        let estimate = await fetchEstimate()
        
        // Create a timeline entry with the current date and fetched estimate.
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, estimate: estimate)
        entries.append(entry)
        
        // Refresh the widget every 3 minutes by scheduling a new timeline.
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 3, to: currentDate)!
        return Timeline(entries: entries, policy: .after(refreshDate))
    }
    
    // Asynchronously fetch the latest MTA arrival estimate by calling the API.
    func fetchEstimate() async -> String {
        do {
            // Try to call the MTA API and return the fetched estimate.
            let estimates = try await callTrainEstimateAPI(Route(station: "Court Sq", routeId: "E", stopId: "F09S"))
            return datesToString(estimates)
        } catch {
            // Handle any errors by returning an error message.
            return "Error fetching estimate."
        }
    }
}

// SimpleEntry is the data model used for each timeline entry, representing a point in time.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let estimate: String
}

// MARK: Widget Layout
struct mta_estimateEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Court Sq. E")
                    
                Text(entry.estimate)  // Display the MTA estimate
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .monospaced()
                    .bold()
                
                Spacer()
                
                Text("Last updated")  // Last update time
                    .font(.footnote)
                    .bold()
                
                Text(entry.date, style: .time)
                    .font(.footnote)
            }
            .multilineTextAlignment(.center)
            .padding(1)
            Spacer()
        }
    }
}

// mta_estimate is the widget configuration and entry point.
struct mta_estimate: Widget {
    let kind: String = "mta_estimate"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            mta_estimateEntryView(entry: entry)
                .containerBackground(.fill.quinary, for: .widget)  // Set background style
        }
    }
}

// Intent for customizing the widget with different emoji (optional in this case).
extension ConfigurationAppIntent {
}

// Preview structure for quick testing and visualization in Xcode.
#Preview(as: .systemSmall) {
    mta_estimate()
} timeline: {
    // Previewing with mock data
    SimpleEntry(date: .now, estimate: "10:19:00 AM\n10:24:00 AM\n10:56:00 AM")
    SimpleEntry(date: .now, estimate: "No upcoming arrivals.")
}
