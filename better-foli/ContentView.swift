//
//  ContentView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var foliData = FoliDataClass()
    @State private var locationManager = LocationManagerClass()
    
    @State private var tempSearch: String = ""
        
    var body: some View {
        let center = CLLocationCoordinate2D(latitude: 60.451201, longitude: 22.263379)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let fallbackLocation = MKCoordinateRegion(center: center, span: span)
        
        NavigationStack {
            VStack(spacing: 10) {
                TextField("\(Image(systemName: "bus")) Find Stop", text: $tempSearch)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.thinMaterial)
                    )
                
                Map(initialPosition: .userLocation(fallback: .region(fallbackLocation)), bounds: MapCameraBounds(maximumDistance: 5000)) {
                    ForEach(foliData.filteredStops.sorted { $0.key < $1.key} , id: \.key) { stopDict in
                        let stop = stopDict.value
                        let stopCoords = CLLocationCoordinate2D(latitude: CLLocationDegrees(stop.stop_lat), longitude: CLLocationDegrees(stop.stop_lon))
                        
                        Annotation(stop.stop_name, coordinate: stopCoords) {
                            NavigationLink {
                                StopView(foliData: foliData, stop: stop)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(.orange)
                                    
                                    Image(systemName: "parkingsign.square")
                                        .foregroundStyle(.white)
                                        .padding(5)
                                }
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .mapControls {
                    if (locationManager.isAuthorized) {
                        MapUserLocationButton()
                    }
                    
                    MapCompass()
                }
                .onMapCameraChange(frequency: .continuous, { context in
                    foliData.cameraPosition = context.region
                })
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
            }
            .padding(10)
            .navigationTitle("Föli")
        }
        .task {
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
    ContentView()
}
