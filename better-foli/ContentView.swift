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
    
    @State private var selectedStop: Stop? = nil
    @State private var showStopSheet = false
        
    var body: some View {
        Map(initialPosition: .userLocation(fallback: .automatic)) {
            ForEach(foliData.filteredStops, id: \.stop_code) { stop in
                let stopCoords = CLLocationCoordinate2D(latitude: CLLocationDegrees(stop.stop_lat), longitude: CLLocationDegrees(stop.stop_lon))
                
                Annotation(stop.stop_name, coordinate: stopCoords) {
                    ZStack {
                        Circle()
                            .fill(.orange)
                        
                        Image(systemName: "bus")
                            .foregroundStyle(.white)
                            .padding(5)
                            .onTapGesture {
                                print(stop)
                                selectedStop = stop
                                showStopSheet = true
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $showStopSheet, onDismiss: {
            selectedStop = nil
            showStopSheet = false
        }, content: {
            VStack(alignment: .leading) {
                Text(selectedStop?.stop_name ?? "")
                    .font(.title)
                
                UpcomingBusLinesView(stop: selectedStop, foliData: foliData)
            }
            .padding(10)
            .presentationDetents([.medium])
        })
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
                if let data = try await foliData.loadStops() {
                    foliData.allStops = data.array
                }
            } catch {
                print(error)
            }
        }
    }
    
    func showMarker(stopCoords: CLLocationCoordinate2D, context: MapCameraUpdateContext) -> Bool {
        var show = true
        
        let lat = context.region.center.latitude
        let latMin = lat - context.region.span.latitudeDelta / 2
        let latMax = lat + context.region.span.latitudeDelta / 2
        
        let lon = context.region.center.longitude
        let lonMin = lon - context.region.span.longitudeDelta / 2
        let lonMax = lon + context.region.span.longitudeDelta / 2
        
        if (stopCoords.latitude >= latMin && stopCoords.latitude <= latMax && stopCoords.longitude >= lonMin && stopCoords.longitude <= lonMax) {
            show = false
        }
        
        let distance = context.camera.distance
        
        if (distance > 5000) {
            show = false
        }
        
        return show
    }
}

#Preview {
    ContentView()
}
