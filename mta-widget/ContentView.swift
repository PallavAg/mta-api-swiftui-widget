//
//  ContentView.swift
//  mta-widget
//
//  Created by Pallav Agarwal on 9/8/24.
//

import SwiftUI
import Foundation

// Helper functions to convert dates to strings
func datesToString(_ dates: [Date], currentDate: Date = Date()) -> String {
    return dates.map { dateWithMinutesRemaining($0, currentDate: currentDate) }.joined(separator: "\n")
}

func dateWithMinutesRemaining(_ date: Date, currentDate: Date) -> String {
    let timeString = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
    let minutesRemaining = Int(date.timeIntervalSince(currentDate) / 60)
    return "\(timeString) (\(minutesRemaining)m)"
}

// Main Content View
struct ContentView: View {
    @State private var estimates: [String] = ["Loading..."]
    @State private var loading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Display each route and its estimates
                ScrollView {
                    ForEach(estimates, id: \.self) { estimate in
                        HStack {
                            Text(LocalizedStringKey(estimate))
                                .font(.title3)
                                .padding()
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        estimates = await updateEstimates()
                    }
                }) {
                    Text(loading ? "Loading..." : "Refresh Estimates")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Train Estimates", displayMode: .large)
            .task {
                estimates = await updateEstimates()
            }
        }
    }
    
    // Function to fetch and update estimates for all routes
    func updateEstimates() async -> [String] {
        loading = true
        
        let now = Date()
        var allEstimates: [String] = []
        
        // List of routes to fetch estimates for
        let routes = [
            Route(station: "Court Sq (E)", routeId: "E", stopId: "F09S"),
            Route(station: "Court Sq (M)", routeId: "M", stopId: "F09S"),
            Route(station: "Court Sq (7)", routeId: "7", stopId: "719S"),
            Route(station: "Lex 53rd (E)", routeId: "E", stopId: "F11N"),
            Route(station: "Lex 53rd (M)", routeId: "M", stopId: "F11N")
        ]
        
        // Fetch estimates for each route
        for route in routes {
            do {
                let arrivalTimes = try await callTrainEstimateAPI(route)
                let estimateString = datesToString(arrivalTimes, currentDate: now)
                let routeEstimate = "**\(route.station):**\n\(estimateString)"
                allEstimates.append(routeEstimate)
            } catch {
                allEstimates.append("**\(route.station):** Not running")
            }
        }
        
        loading = false
        return allEstimates
    }
}


#Preview {
    ContentView()
}
