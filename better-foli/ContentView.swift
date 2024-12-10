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
    
    @Environment(\.modelContext) private var context
    @Query var allStops: [StopData]
    @Query var favouriteStops: [FavouriteStop]
    
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
                        
                        ForEach(foliData.filteredStops, id: \.code) { stop in
                            Annotation(stop.name, coordinate: stop.coords) {
                                NavigationLink {
                                    StopView(foliData: foliData, stop: stop)
                                } label: {
                                    let isFavourite = favouriteStops.contains { $0.stopCode == stop.code }
                                    
                                    BusStopLabelView(isFavourite: isFavourite)
                                }
                            }
                        }
                    }
                    .mapControls {
                        MapCompass()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onMapCameraChange(frequency: .continuous, { context in
                        foliData.cameraRegion = context.region
                        foliData.cameraDistance = context.camera.distance
                    })

                    VStack(alignment: .trailing, spacing: 5) {
                        Button {
                            guard let locationCoords = locationManager.manager.location?.coordinate else { return }
                            mapCameraPosition = .camera(MapCamera(centerCoordinate: locationCoords, distance: 2000))
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
            
            foliData.allStops = allStops
            foliData.favouriteStops = favouriteStops
            
            locationManager.requestAuthorization()
        }
    }
}

#Preview {
    let foliData = FoliDataClass()
    
    ContentView(foliData: foliData, locationManager: LocationManagerClass(), mapCameraPosition: .region(foliData.fallbackLocation))
}
