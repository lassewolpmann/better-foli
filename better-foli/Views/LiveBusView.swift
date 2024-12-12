//
//  LiveBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct LiveBusView: View {
    let foliData: FoliDataClass
    let upcomingBus: DetailedSiriStop.Result
    
    @State private var vehicle: VehicleData?
    @State private var trip: TripData?
    
    @Query var allTrips: [TripData]
    
    var body: some View {
        if let vehicle, let trip {
            let mapCameraPosition: MapCameraPosition = .region(.init(center: vehicle.coords, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
            LiveBusMapView(foliData: foliData, trip: trip, mapCameraPosition: mapCameraPosition, vehicle: vehicle)
        } else {
            ProgressView("Getting vehicle data...")
                .task {
                    do {
                        let allVehicles = try await foliData.getAllVehicles()
                        vehicle = allVehicles.first(where: { $0.vehicleID == upcomingBus.vehicleref })
                        trip = allTrips.first(where: { $0.tripID == vehicle?.tripID })
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

#Preview {
    LiveBusView(foliData: FoliDataClass(), upcomingBus: DetailedSiriStop.Result())
}
