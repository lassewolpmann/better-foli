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
    @State private var showFavourites: Bool = false
    
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
            ZStack {
                Map(position: $mapCameraPosition, bounds: .init(maximumDistance: 10000), selection: $selectedStop) {
                    // Always show user location
                    UserAnnotation()
                    
                    ForEach(foliData.allStops, id: \.code) { stop in
                        Marker(stop.name, systemImage: stop.isFavourite ? "star.fill" : "bus", coordinate: stop.coords)
                            .tint(.orange)
                            .tag(stop)
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: true))
                .mapControls {
                    MapCompass()
                }
            }
            .task {
                locationManager.requestAuthorization()
                foliData.allStops = allStops
                foliData.allTrips = allTrips
            }
            .onChange(of: mapCameraPosition, {
                foliData.searchFilter = ""
            })
            .safeAreaInset(edge: .bottom, content: {
                OverviewMapButtonsView(foliData: foliData, mapCameraPosition: $mapCameraPosition, showFavourites: $showFavourites, selectedStop: $selectedStop)
            })
            .sheet(item: $selectedStop) { stop in
                StopView(foliData: foliData, stop: stop)
            }
            .sheet(isPresented: $showFavourites) {
                FavouritesView(foliData: foliData)
            }
        }
    }
}

#Preview {
    let foliData = FoliDataClass()
    
    ContentView(foliData: foliData, locationManager: LocationManagerClass(), mapCameraPosition: .region(foliData.fallbackLocation))
}
