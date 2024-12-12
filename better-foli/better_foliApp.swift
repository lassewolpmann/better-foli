//
//  better_foliApp.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import SwiftUI
import MapKit
import SwiftData

@main
struct better_foliApp: App {
    @State var foliData = FoliDataClass()
    let locationManager = LocationManagerClass()
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some Scene {
        WindowGroup {
            ContentView(foliData: foliData, locationManager: locationManager, mapCameraPosition: .userLocation(fallback: .region(foliData.fallbackLocation)))
                .modelContainer(for: [
                    StopData.self,
                    TripData.self,
                    ShapeData.self,
                    ShapeCoordsData.self
                ], isAutosaveEnabled: true)
                .onReceive(timer) { _ in
                    Task {
                        guard let vehicleData = try await foliData.getSiriVehicleData() else { return }
                        foliData.vehicleData = vehicleData.result.vehicles.map { $0.value }
                    }
                }
        }
    }
}
