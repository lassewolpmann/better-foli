//
//  ContentView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query var allStops: [StopData]
    @Query var allTrips: [TripData]
    @Query var allRoutes: [RouteData]
    
    let foliData: FoliDataClass
    let locationManager: LocationManagerClass

    var body: some View {
        if (allStops.isEmpty || allTrips.isEmpty || allRoutes.isEmpty) {
            ProgressView("Loading data...")
                .task {
                    do {
                        if (allStops.isEmpty) {
                            let stops = try await foliData.getAllStops()
                            stops.forEach { context.insert($0) }
                        }
                        
                        if (allTrips.isEmpty) {
                            let trips = try await foliData.getAllTrips()
                            trips.forEach { context.insert($0) }
                        }
                        
                        if (allRoutes.isEmpty) {
                            let routes = try await foliData.getAllRoutes()
                            routes.forEach { context.insert($0) }
                        }
                    } catch {
                        print(error)
                    }
                }
        } else {
            TabView {
                Tab {
                    FavouritesView(foliData: foliData, locationManager: locationManager)
                } label: {
                    Label {
                        Text("Favourites")
                    } icon: {
                        Image(systemName: "star")
                    }
                }
                
                Tab {
                    AllStopsView(foliData: foliData, locationManager: locationManager)
                } label: {
                    Label {
                        Text("All Stops")
                    } icon: {
                        Image(systemName: "map")
                    }
                }
                
                Tab {
                    SearchView(foliData: foliData, locationManager: locationManager)
                } label: {
                    Label {
                        Text("Search")
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
                Tab {
                    SettingsView(foliData: foliData)
                } label: {
                    Label {
                        Text("Settings")
                    } icon: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    ContentView(foliData: FoliDataClass(), locationManager: LocationManagerClass())
}
