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
        
    var body: some View {
        NavigationStack {
            Map(initialPosition: .userLocation(fallback: .automatic)) {
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
                                
                                Image(systemName: "bus")
                                    .foregroundStyle(.white)
                                    .padding(5)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bus Stops")
        }
        .mapControls {
            if (locationManager.isAuthorized) {
                MapUserLocationButton()
            }
        }
        .onMapCameraChange(frequency: .continuous, { context in
            foliData.cameraDistance = context.camera.distance
            foliData.cameraPosition = context.region
        })
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .onAppear {
            locationManager.requestAuthorization()
        }
        .task {
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
