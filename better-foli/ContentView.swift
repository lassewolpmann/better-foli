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
    
    @State private var searchFilter: String = ""
    @State var mapCameraPosition: MapCameraPosition
    
    @Query var favouriteStops: [FavouriteStop]
        
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                TextField("\(Image(systemName: "bus")) Find Stop", text: $searchFilter)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.thinMaterial)
                    )
                
                Map(position: $mapCameraPosition) {
                    UserAnnotation()
                    
                    ForEach(foliData.filteredStops.sorted { $0.key < $1.key} , id: \.key) { stopDict in
                        let stop = stopDict.value
                        let stopCoords = CLLocationCoordinate2D(latitude: CLLocationDegrees(stop.stop_lat), longitude: CLLocationDegrees(stop.stop_lon))
                        
                        Annotation(coordinate: stopCoords) {
                            NavigationLink {
                                StopView(foliData: foliData, stop: stop)
                            } label: {
                                let isFavourite = favouriteStops.contains { $0.stopCode == stop.stop_code }
                                
                                BusStopLabelView(isFavourite: isFavourite)
                            }
                        } label: {
                            Text(stop.stop_name)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .mapControls {
                    MapUserLocationButton().disabled(!locationManager.isAuthorized)
                    MapCompass()
                }
                .onMapCameraChange(frequency: .continuous, { context in
                    foliData.cameraPosition = context.region
                    foliData.cameraHeight = context.camera.distance
                })
            }
            .padding(10)
            .navigationTitle("Föli")
            .toolbar {
                NavigationLink {
                    FavouriteStopsView(foliData: foliData)
                } label: {
                    Label {
                        Text("Favourites")
                    } icon: {
                        Image(systemName: "star.fill")
                    }
                }
            }
        }
        .task {
            foliData.favouriteStops = favouriteStops
            locationManager.requestAuthorization()
            
            do {
                try await foliData.getGtfsStops()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    let center = CLLocationCoordinate2D(latitude: 60.451201, longitude: 22.263379)
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    let fallbackLocation = MKCoordinateRegion(center: center, span: span)
    
    ContentView(foliData: FoliDataClass(), locationManager: LocationManagerClass(), mapCameraPosition: .region(fallbackLocation))
}
