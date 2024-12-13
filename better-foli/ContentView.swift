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
    let foliData: FoliDataClass
    let locationManager: LocationManagerClass
    
    @State var mapCameraPosition: MapCameraPosition
    
    @State private var selectedStop: StopData?
    
    @Environment(\.modelContext) private var context
    @Query var allStops: [StopData]
    @Query var allTrips: [TripData]
    
    var body: some View {
        if (allStops.isEmpty || allTrips.isEmpty) {
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
                    } catch {
                        print(error)
                    }
                }
        } else {
            TabView {
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
                    FavouritesView(foliData: foliData)
                } label: {
                    Label {
                        Text("Saved Stops and Lines")
                    } icon: {
                        Image(systemName: "star")
                    }
                }
                
                Tab {
                    Text("Search")
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

#Preview {
    let foliData = FoliDataClass()
    
    ContentView(foliData: foliData, locationManager: LocationManagerClass(), mapCameraPosition: .region(foliData.fallbackLocation))
}
