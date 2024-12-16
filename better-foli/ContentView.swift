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
    
    func loadStops() async throws {
        print("Loading all stops...")
        
        let stops = try await foliData.getAllStops()
        for stop in stops {
            context.insert(stop)
        }
    }
    
    func loadTrips() async throws {
        print("Loading all trips...")

        let trips = try await foliData.getAllTrips()
        for trip in trips {
            context.insert(trip)
        }
    }
    
    func loadRoutes() async throws {
        print("Loading all routes...")
        
        let routes = try await foliData.getAllRoutes()
        for route in routes {
            context.insert(route)
        }
    }
    
    var body: some View {
        if (allStops.isEmpty || allTrips.isEmpty || allRoutes.isEmpty) {
            ProgressView("Loading data...")
                .task {
                    do {
                        if (allStops.isEmpty) {
                            try await loadStops()
                        }
                        
                        if (allTrips.isEmpty) {
                            try await loadTrips()
                        }
                        
                        if (allRoutes.isEmpty) {
                            try await loadRoutes()
                        }
                    } catch {
                        print(error)
                    }
                }
        } else {
            TabView {
                Tab {
                    FavouritesView(foliData: foliData)
                } label: {
                    Label {
                        Text("Favourites")
                    } icon: {
                        Image(systemName: "star")
                    }
                }
                
                Tab {
                    OverviewMapView(foliData: foliData, locationManager: locationManager)
                } label: {
                    Label {
                        Text("Stop Map")
                    } icon: {
                        Image(systemName: "map")
                    }
                }
                
                Tab {
                    SearchView(foliData: foliData)
                } label: {
                    Label {
                        Text("Search")
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
                Tab {
                    List {
                        Button {
                            Task {
                                do {
                                    try await loadStops()
                                    try await loadTrips()
                                    try await loadRoutes()
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
