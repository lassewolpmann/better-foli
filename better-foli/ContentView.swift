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
    @Bindable var foliData: FoliDataClass
    let locationManager: LocationManagerClass
    
    @State var mapCameraPosition: MapCameraPosition
    @State private var cameraRegion: MKCoordinateRegion?
    @State private var cameraDistance: Double?
    
    @Environment(\.modelContext) private var context
    @Query var allStops: [StopData]
    
    var filteredStops: [StopData] {
        guard let cameraRegion, let cameraDistance else { return [] }
        let spanBuffer = 0.001
        
        return allStops.filter { stop in
            let lat = cameraRegion.center.latitude
            let latMin = (lat - cameraRegion.span.latitudeDelta / 2) - spanBuffer
            let latMax = (lat + cameraRegion.span.latitudeDelta / 2) + spanBuffer
            
            let lon = cameraRegion.center.longitude
            let lonMin = (lon - cameraRegion.span.longitudeDelta / 2) - spanBuffer
            let lonMax = (lon + cameraRegion.span.longitudeDelta / 2) + spanBuffer
            
            // Return true if stop is in favourites, regardless of any other factor
            // if (favouriteStops.contains { $0.stopCode == stop.code }) { return true }
            
            // Return false if no upcoming Buses and option to show Stops with no buses is false
            // if (stop.upcomingBuses.isEmpty && !self.showStopsWithNoBuses) { return false }
            
            // Return true if stop is in camera region and distance
            if (stop.latitude >= latMin && stop.latitude <= latMax && stop.longitude >= lonMin && stop.longitude <= lonMax && cameraDistance <= 3000) { return true }
            
            // Default return false
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    BusStopSearchView(foliData: foliData, locationManager: locationManager, mapCameraPosition: mapCameraPosition)
                } label: {
                    Label {
                        Text("Search Stop")
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.thinMaterial)
                )
                
                ZStack(alignment: .bottomTrailing) {
                    Map(position: $mapCameraPosition) {
                        // Always show user location
                        UserAnnotation()
                        
                        ForEach(filteredStops, id: \.code) { stop in
                            Annotation(stop.name, coordinate: stop.coords) {
                                NavigationLink {
                                    StopView(foliData: foliData, stop: stop)
                                } label: {
                                    BusStopLabelView(isFavourite: stop.isFavourite)
                                }
                            }
                        }
                    }
                    .onMapCameraChange(frequency: .onEnd, { context in
                        cameraRegion = context.region
                        cameraDistance = context.camera.distance
                    })
                    .mapControls {
                        MapCompass()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Button {
                            mapCameraPosition = .userLocation(fallback: .region(foliData.fallbackLocation))
                        } label: {
                            Image(systemName: "location")
                        }
                        
                        Menu {
                            Toggle(isOn: $foliData.showStopsWithNoBuses) {
                                Label {
                                    Text("Show inactive stops")
                                } icon: {
                                    Image(systemName: "bus")
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .padding(10)
            .navigationTitle("Föli Map")
            .toolbar {
                NavigationLink {
                    FavouritesView(foliData: foliData)
                } label: {
                    Image(systemName: "star.fill")
                }
            }
        }
        .onChange(of: allStops, { _, _ in
            print("allStops has changed")
        })
        .task {
            if (allStops.isEmpty) {
                do {
                    let stops = try await foliData.getStops()
                    
                    // Update context to ensure that all stops are stored in context
                    for stop in stops {
                        context.insert(stop)
                    }
                } catch {
                    print(error)
                }
            }
            
            print(allStops.count)
            locationManager.requestAuthorization()
        }
    }
    
    func showAnnotation(stop: StopData) {
        
    }
}

#Preview {
    let foliData = FoliDataClass()
    
    ContentView(foliData: foliData, locationManager: LocationManagerClass(), mapCameraPosition: .region(foliData.fallbackLocation))
}
