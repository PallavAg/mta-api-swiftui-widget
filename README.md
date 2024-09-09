# MTA API SwiftUI Widget
![Swift](https://img.shields.io/badge/Swift-5-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-17%2B-blue?logo=apple)
![WidgetKit](https://img.shields.io/badge/WidgetKit-enabled-green?logo=apple)

## Overview
**MTA API Widget** is a simple iOS application and widget that uses the public MTA API to fetch real-time train arrival information. The app decodes the API response, which is in GTFS (General Transit Feed Specification) format, using Protocol Buffers (protobuf). It then displays the arrival times for specified subway routes directly in a widget or within the app. 

The widget updates regularly to show arrival times based on the current time and day, ensuring that only relevant routes are displayed when appropriate.

## Features
- Real-time MTA train arrival information
- Configurable routes and times for when to display each line
- Widget support using WidgetKit for quick glanceable updates
- iOS 17+ App Intent to support manually reloading the widget

## Widget Preview
![image](https://github.com/user-attachments/assets/6175dc45-40ec-430a-933e-7e83ec0436dd)


## Requirements
- **iOS 17+**
- **Swift**
- **WidgetKit**

## Running Instructions

### Step 1: Modify the Configuration for Your Own Routes
The `Config.swift` file contains the routes and configuration logic. You can customize the routes and times for when each route should be displayed by following these steps:

#### 1. Define Your Routes in `Config.swift`
In `Config.swift`, you can create `Route` instances that represent the train lines and stops you want to monitor. The `Route` struct has three components:
- `station`: The name for the station that will be displayed
- `routeId`: The ID of the route (e.g., "E" for the E line).
- `stopId`: The specific stop ID from the MTA GTFS data - find your `stopId` using the `stops.csv` file in the project.
  - Once you find the stopId (eg. `"719"` for the Court Sq stop), add `S` or `N` for the northbound / southbound train

```swift
// Example Routes
let courtSq7 = Route(station: "Court Sq (7)", routeId: "7", stopId: "719S")
let courtSqE = Route(station: "Court Sq (E)", routeId: "E", stopId: "F09S")
```

### Step 2: Use your own Apple Developer Account
1. Open the project in Xcode.
2. Navigate to the project settings by clicking on the project file in the Project Navigator.
3. Go to the **Signing & Capabilities** section for each target.
4. Assign your Apple Developer account under the **Team** dropdown.
5. You may also need to change the bundle identifier to a unique one
