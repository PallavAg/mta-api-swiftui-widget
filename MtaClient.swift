//
//  MtaClient.swift
//  mta-widget
//
//  Created by Pallav Agarwal on 9/8/24.
//

import Foundation
import SwiftUI

// Helpers
let mtaColors: [String: Color] = [
    "1": .red,
    "2": .red,
    "3": .red,
    "4": .green,
    "5": .green,
    "6": .green,
    "7": .purple,
    "A": .blue,
    "C": .blue,
    "E": .blue,
    "B": .orange,
    "D": .orange,
    "F": .orange,
    "M": .orange,
    "G": .green,
    "J": .brown,
    "Z": .brown,
    "L": .gray,
    "N": .yellow,
    "Q": .yellow,
    "R": .yellow,
    "W": .yellow,
    "S": .gray // Shuttle
]

struct Route {
    let station: String
    let routeId: String
    let stopId: String
}

func populateRoutes() -> [Route] {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.hour, .minute, .weekday], from: now)
    
    guard let hour = components.hour, let weekday = components.weekday else {
        return []
    }
    
    var routes: [Route] = []
    
    // Call the function that populates the routes array based on conditions
    addRoutes(hour: hour, weekday: weekday, routes: &routes)
    
    return routes
}

func addRoute(startHour: Int, endHour: Int, validWeekdays: [Int], hour: Int, weekday: Int, route: Route, routes: inout [Route]) {
    if hour >= startHour && hour < endHour && validWeekdays.contains(weekday) {
        routes.append(route)
    }
}


func callTrainEstimateAPI(_ route: Route) async throws -> [Date] {
    // The URL of the MTA GTFS feed for the A, C, E lines
    var apiUrl = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-ace"
    if route.routeId == "M" {
        apiUrl = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-bdfm"
    }
    if route.routeId == "7" {
        apiUrl = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"
    }
    
    guard let url = URL(string: apiUrl) else {
        throw URLError(.badURL)
    }
    
    // Make the GET request
    let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
    
    // Check if the response is valid
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    // Decode the protobuf data into the GTFSRealtime_FeedMessage model
    
    let feed = try TransitRealtime_FeedMessage(serializedBytes: data)
    
    // The specific route and stop ID we're interested in
    //    let targetRouteId = "E"
    //    let targetStopId = "F09S"
    let targetRouteId = route.routeId
    let targetStopId = route.stopId
    
    // Find and output the arrival times for Route 'E' and Stop 'F09N'
    var arrivalTimes: [Date] = []
    
    var stops = Set<String>()
    var routeIds = Set<String>()
    
    for entity in feed.entity {
        let tripUpdate = entity.tripUpdate
        routeIds.insert(entity.tripUpdate.trip.routeID)
        if entity.tripUpdate.trip.routeID == targetRouteId {
            for stopTimeUpdate in tripUpdate.stopTimeUpdate {
                if stopTimeUpdate.stopID == targetStopId {
                    let arrivalTime = stopTimeUpdate.arrival.time
                    let arrivalDate = Date(timeIntervalSince1970: TimeInterval(arrivalTime))
                    arrivalTimes.append(arrivalDate)
                }
                stops.insert("\(stopTimeUpdate.stopID)")
            }
        }
    }
    
    // print(routeIds)
    // print(stops)
    
    var estimates = [Date]()
    
    // Output the arrival times
    if arrivalTimes.isEmpty {
        print("No upcoming arrivals found for Route \(targetRouteId) at Stop \(targetStopId).")
        throw URLError(.badServerResponse)
    } else {
        // print("Upcoming arrivals for Route \(targetRouteId) at Stop \(targetStopId):")
        for (_, arrivalTime) in arrivalTimes.sorted().enumerated() {
            estimates.append(arrivalTime)
            if estimates.count == 2 {
                return estimates
            }
        }
    }
    
    throw URLError(.badServerResponse)
}

func dateToString(_ date: Date) -> String {
    return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
}

func datesToString(_ dates: [Date]) -> String {
    return dates.map { dateToString($0) }.joined(separator: "\n")
}
