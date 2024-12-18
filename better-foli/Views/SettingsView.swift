//
//  SettingsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 18.12.2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    let foliData: FoliDataClass
    
    var body: some View {
        List {
            Button {
                Task {
                    do {
                        let stops = try await foliData.getAllStops()
                        stops.forEach { context.insert($0) }
                        
                        let trips = try await foliData.getAllTrips()
                        trips.forEach { context.insert($0) }
                        
                        let routes = try await foliData.getAllRoutes()
                        routes.forEach { context.insert($0) }
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Label {
                    Text("Refresh all Data")
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

#Preview {
    SettingsView(foliData: FoliDataClass())
}
