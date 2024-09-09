//
//  ContentView.swift
//  mta-widget
//
//  Created by Pallav Agarwal on 9/8/24.
//

import SwiftUI
import Foundation

// Main Content View
struct ContentView: View {
    @State private var estimate = "Loading..."
    @State private var loading = false

    var body: some View {
        NavigationView {
            VStack {
                Text("MTA Train Arrival Estimate")
                    .font(.title)
                    .padding()

                Spacer()

                Text(estimate)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)

                Spacer()

                Button(action: {
                    Task {
                        estimate = await updateEstimate()
                    }
                }) {
                    Text(loading ? "Loading..." : "Refresh Estimate")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Train Estimate", displayMode: .inline)
            .task {
                estimate = await updateEstimate()
            }
        }
    }
    
    func updateEstimate() async -> String {
        do {
            loading = true
            let estimate = try await callTrainEstimateAPI(.init(station: "Court Sq", routeId: "M", stopId: "F09S"))
            loading = false
            return datesToString(estimate)
        } catch {
            loading = false
            return "Error: \(error)"
        }
    }
}


#Preview {
    ContentView()
}
