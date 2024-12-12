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
    @State private var cameraRegion: MKCoordinateRegion?
    @State private var selectedStop: StopData?
    @State private var searchFilter: String = ""
    @State private var showFavourites: Bool = false
    
    @Environment(\.modelContext) private var context
    @Query var allStops: [StopData]
    @Query var allTrips: [TripData]
    
    var filteredStops: [StopData] {
        guard let cameraRegion else { return [] }
        let spanBuffer = 0.001
        
        return allStops.filter { stop in
            let lat = cameraRegion.center.latitude
            let latMin = (lat - cameraRegion.span.latitudeDelta / 2) - spanBuffer
            let latMax = (lat + cameraRegion.span.latitudeDelta / 2) + spanBuffer
            
            let lon = cameraRegion.center.longitude
            let lonMin = (lon - cameraRegion.span.longitudeDelta / 2) - spanBuffer
            let lonMax = (lon + cameraRegion.span.longitudeDelta / 2) + spanBuffer
            
            // Return true if stop is in camera region and distance
            if (stop.latitude >= latMin && stop.latitude <= latMax && stop.longitude >= lonMin && stop.longitude <= lonMax) { return true }
            
            // Default return false
            return false
        }
    }
    
    var body: some View {
        ZStack {
            Map(position: $mapCameraPosition, selection: $selectedStop) {
                // Always show user location
                UserAnnotation()
                
                ForEach(filteredStops, id: \.code) { stop in
                    Marker(stop.name, systemImage: stop.isFavourite ? "star.fill" : "bus", coordinate: stop.coords)
                        .tint(.orange)
                        .tag(stop)
                }
            }
            
            .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: true))
            .onMapCameraChange(frequency: .onEnd, { context in
                cameraRegion = context.region
            })
            .mapControls {
                MapCompass()
            }
            
            if (!searchFilter.isEmpty) {
                BusStopSearchView(searchFilter: searchFilter, mapCameraPosition: $mapCameraPosition)
            }
        }
        .onChange(of: mapCameraPosition, {
            searchFilter = ""
        })
        .safeAreaInset(edge: .bottom, content: {
            OverviewMapButtonsView(foliData: foliData, searchFilter: $searchFilter, mapCameraPosition: $mapCameraPosition, showFavourites: $showFavourites)
        })
        .sheet(item: $selectedStop) { stop in
            StopView(foliData: foliData, stop: stop)
        }
        .sheet(isPresented: $showFavourites) {
            FavouritesView(foliData: foliData)
        }
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
    }
}

#Preview {
    let foliData = FoliDataClass()
    
    ContentView(foliData: foliData, locationManager: LocationManagerClass(), mapCameraPosition: .region(foliData.fallbackLocation))
}
