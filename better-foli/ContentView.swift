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
                            print("Loading all stops...")
                            let stops = try await foliData.getAllStops()
                            for stop in stops {
                                context.insert(stop)
                            }
                            try context.save()
                        }
                        
                        if (allTrips.isEmpty) {
                            print("Loading all trips...")
                            let trips = try await foliData.getAllTrips()
                            for trip in trips {
                                context.insert(trip)
                            }
                            try context.save()
                        }
                        
                        if (allRoutes.isEmpty) {
                            print("Loading all trips...")
                            let routes = try await foliData.getAllRoutes()
                            for route in routes {
                                context.insert(route)
                            }
                            try context.save()
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
                        Text("Saved Stops and Lines")
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
            }
        }
    }
}

#Preview(traits: .sampleData) {
    ContentView(foliData: FoliDataClass(), locationManager: LocationManagerClass())
}
