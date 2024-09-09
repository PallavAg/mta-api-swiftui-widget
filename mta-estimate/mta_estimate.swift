//
//  mta_estimate.swift
//  mta-estimate
//
//  Created by Pallav Agarwal on 9/8/24.
//

import WidgetKit
import SwiftUI
import Foundation

// Helper functions to convert dates to strings
func datesToString(_ dates: [Date], currentDate: Date) -> String {
    return dates.map { dateWithMinutesRemaining($0, currentDate: currentDate) }.joined(separator: "\n")
}

func dateWithMinutesRemaining(_ date: Date, currentDate: Date) -> String {
    let timeString = dateToString(date)
    let secondsRemaining = Int(date.timeIntervalSince(currentDate))
    
    if secondsRemaining < 0 {
        return "Arriving"
    } else if secondsRemaining < 60 {
        return "\(timeString) (\(secondsRemaining)s)"
    } else {
        let minutesRemaining = secondsRemaining / 60
        return "\(timeString) (\(minutesRemaining)m)"
    }
}

func formattedTime(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return formatter.string(from: date)
}

// Provider is responsible for creating the widget timeline and fetching the data to display.
struct Provider: AppIntentTimelineProvider {

    // Provides a placeholder widget that appears while the actual data is being loaded.
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), estimates: [], routes: [])
    }
    
    // Provides a snapshot of the widget with static data for quick previews.
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let (estimates, routes) = await fetchEstimate()
        return SimpleEntry(date: Date(), estimates: estimates, routes: routes)
    }
    
    // Builds a timeline of widget entries. This is called by the system to display and refresh the widget.
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Fetch the latest MTA arrival estimates and determine which routes to show based on time
        let (estimates, routes) = await fetchEstimate()

        // Create a timeline entry with the current date and fetched estimates.
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, estimates: estimates, routes: routes)
        entries.append(entry)

        // Refresh the widget every 3 minutes by scheduling a new timeline.
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 3, to: currentDate)!
        return Timeline(entries: entries, policy: .after(refreshDate))
    }
    
    // Determine the appropriate routes and fetch estimates
    func fetchEstimate() async -> ([String], [Route]) {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute, .weekday], from: now)
        
        guard let hour = components.hour, let weekday = components.weekday else {
            return (["Error fetching time"], [])
        }
        
        let routes: [Route] = populateRoutes()

        // Fetch estimates for the determined routes
        var estimates: [String] = []
        for route in routes {
            do {
                let arrivalTimes = try await callTrainEstimateAPI(route)
                let estimateString = datesToString(arrivalTimes, currentDate: now)
                estimates.append(estimateString) // Store individual estimates for each route
            } catch {
                estimates.append("Not Running")
            }
        }

        return (estimates, routes)
    }
}

// SimpleEntry is the data model used for each timeline entry, representing a point in time.
// Each route has its corresponding estimate.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let estimates: [String]
    let routes: [Route]
}

// MARK: Widget Layout
struct mta_estimateEntryView: View {
    var entry: Provider.Entry

    // Environment variable to check the current widget size
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Use HStack for medium/large widgets, VStack for small
            ForEach(Array(zip(entry.routes, entry.estimates)), id: \.0.station) { route, estimate in
                if widgetFamily == .systemSmall {
                    // Vertical layout for small widgets
                    VStack(alignment: .leading) {
                        Text("\(route.station)")
                            .font(.system(size: 12))
                            .bold()
                            .foregroundStyle(mtaColors[route.routeId] ?? .primary)

                        Text(estimate)
                            .font(.system(size: 10))
                            .monospaced()
                            .lineLimit(3)
                            .fixedSize()
                    }
                    .padding(.bottom, 1)
                    .padding(.top, 4)
                } else {
                    // Horizontal layout for medium and larger widgets
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(route.station)")
                            .font(.system(size: 14))
                            .bold()
                            .padding(.top, 3)
                            .foregroundStyle(mtaColors[route.routeId] ?? .primary)

                        Text(estimate)
                            .font(.caption)
                            .lineLimit(3)
                            .monospaced()
                            .minimumScaleFactor(0.5)
                            .fixedSize()
                    }
                    .padding(.bottom, 4)
                }
            }
            
            if entry.routes.isEmpty {
                Text("Nothing to show here.")
            }
            
            Spacer()

            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("as of " + formattedTime(from: entry.date))
                        .font(.system(size: 9))
                }

                // Small refresh button that triggers a widget reload
                Button(intent: ReloadIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption2)
                }
            }
        }
        .padding(5)  // Reduced padding for space efficiency
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

// Preview structure for quick testing and visualization in Xcode.
#Preview(as: .systemSmall) {
    mta_estimate()
} timeline: {
    SimpleEntry(date: .now, estimates: ["10:19:30 AM (2m)\n10:19:30 AM (2m)", "10:30:30 AM (13m)\n10:19:30 AM (2m)"], routes: [Route(station: "Court Sq (E)", routeId: "E", stopId: "F09S"), Route(station: "Court Sq (M)", routeId: "M", stopId: "F09S")])
    SimpleEntry(date: .now, estimates: ["No upcoming arrivals."], routes: [])
}
