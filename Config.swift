//
//  Config.swift
//  mta-widget
//
//  Created by Pallav Agarwal on 9/9/24.
//

import Foundation

// MARK: 1. Create Routes Here
// Find the stopId using the stops.csv file
let courtSqE = Route(station: "Court Sq (E)", routeId: "E", stopId: "F09S")
let courtSqM = Route(station: "Court Sq (M)", routeId: "M", stopId: "F09S")
let courtSq7 = Route(station: "Court Sq (7)", routeId: "7", stopId: "719S")
let Lex53rdE = Route(station: "Lex 53rd (E)", routeId: "E", stopId: "F11N")
let Lex53rdM = Route(station: "Lex 53rd (M)", routeId: "M", stopId: "F11N")

// MARK: 2. Configure when you want to see what lines
// These will show on the widget
func addRoutes(hour: Int, weekday: Int, routes: inout [Route]) {
    // Weekdays 8 AM to 2 PM, and weekends (show Court Sq E)
    addRoute(startHour: 8, endHour: 14, validWeekdays: [2, 3, 4, 5, 6], hour: hour, weekday: weekday, route: courtSqE, routes: &routes) // Weekdays
    addRoute(startHour: 0, endHour: 24, validWeekdays: [1, 7], hour: hour, weekday: weekday, route: courtSqE, routes: &routes) // Weekends
    
    // Weekdays 8 AM to 2 PM (show Court Sq M)
    addRoute(startHour: 8, endHour: 14, validWeekdays: [2, 3, 4, 5, 6], hour: hour, weekday: weekday, route: courtSqM, routes: &routes)
    
    // Weekdays 8 PM to 11 PM, and weekends (show Court Sq 7)
    addRoute(startHour: 20, endHour: 23, validWeekdays: [2, 3, 4, 5, 6], hour: hour, weekday: weekday, route: courtSq7, routes: &routes) // Weekdays
    addRoute(startHour: 0, endHour: 24, validWeekdays: [1, 7], hour: hour, weekday: weekday, route: courtSq7, routes: &routes) // Weekends
    
    // Weekdays 4 PM to 8 PM (show Lex 53rd E and M)
    addRoute(startHour: 16, endHour: 20, validWeekdays: [2, 3, 4, 5, 6], hour: hour, weekday: weekday, route: Lex53rdE, routes: &routes)
    addRoute(startHour: 16, endHour: 20, validWeekdays: [2, 3, 4, 5, 6], hour: hour, weekday: weekday, route: Lex53rdM, routes: &routes)
}

// MARK: 3. These will show on the app
let allRoutes = [ courtSqE, courtSqM, courtSq7, Lex53rdE, Lex53rdM ]
