//
//  RouteOverviewBusRow.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 15.12.2024.
//

import SwiftUI
import SwiftData
import MapKit

struct RouteOverviewBusRow: View {
    @Query var trips: [TripData]
    var trip: TripData? { trips.first }
    
    let foliData: FoliDataClass
    let vehicle: VehicleData
    
    init(foliData: FoliDataClass, vehicle: VehicleData) {
        self.foliData = foliData
        self.vehicle = vehicle
        
        let vehicleTripID = vehicle.tripID
        let predicate = #Predicate<TripData> { $0.tripID == vehicleTripID }
        
        _trips = Query(filter: predicate)
    }
    
    var body: some View {
        if (vehicle.monitored) {
            NavigationLink {
                let mapCameraPosition: MapCameraPosition = .region(vehicle.region)
                LiveBusMapView(foliData: foliData, selectedStopCode: "", trip: trip, mapCameraPosition: mapCameraPosition, vehicle: vehicle)
            } label: {
                HStack {
                    Label {
                        Text(vehicle.lineReference)
                    } icon: {
                        Image(systemName: "bus")
                    }
                }
                
                Spacer()
                
                Text(vehicle.destinationName)
            }
        }
    }
}

#Preview {
    RouteOverviewBusRow(foliData: FoliDataClass(), vehicle: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
}
