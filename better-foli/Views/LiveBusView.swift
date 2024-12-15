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
    let selectedStopCode: String
    
    @State private var vehicle: VehicleData?
    
    @Query var allTrips: [TripData]
    
    var trip: TripData? {
        allTrips.first { $0.tripID == vehicle?.tripID }
    }
    
    var body: some View {
        if let vehicle {
            let mapCameraPosition: MapCameraPosition = .region(.init(center: vehicle.coords, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
            LiveBusMapView(foliData: foliData, selectedStopCode: selectedStopCode, trip: trip, mapCameraPosition: mapCameraPosition, vehicle: vehicle)
        } else {
            ProgressView("Getting vehicle data...")
                .task {
                    print("Getting vehicle data...")
                    do {
                        let allVehicles = try await foliData.getAllVehicles()
                        vehicle = allVehicles.first { $0.vehicleID == upcomingBus.vehicleref }
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

#Preview(traits: .sampleData) {
    LiveBusView(foliData: FoliDataClass(), upcomingBus: DetailedSiriStop.Result(recordedattime: 0, monitored: true, lineref: "1", destinationdisplay: "Satama"), selectedStopCode: "1")
}
