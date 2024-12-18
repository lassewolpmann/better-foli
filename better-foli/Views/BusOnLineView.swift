//
//  RouteOverviewBusRow.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 16.12.2024.
//

import SwiftUI
import MapKit

struct BusOnLineView: View {
    let foliData: FoliDataClass
    let trip: TripData
    let route: RouteData
    let vehicle: VehicleData
    
    var body: some View {
        NavigationLink {
            LiveBusView(foliData: foliData, upcomingBus: vehicle, selectedStopCode: "", route: route, trip: trip)
        } label: {
            HStack(alignment: .center) {
                Map(initialPosition: .camera(.init(centerCoordinate: vehicle.coords, distance: 15000))) {
                    Marker(vehicle.lineReference, systemImage: "bus", coordinate: vehicle.coords)
                        .tint(.orange)
                        .annotationTitles(.hidden)
                }
                .disabled(true)
                .frame(width: 75, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 5)
                
                Text(vehicle.lineReference)
                    .bold()
                    .frame(width: 50)
                
                Text(vehicle.destinationName)
            }
        }
        .disabled(!vehicle.monitored)
    }
}

#Preview {
    NavigationStack {
        List {
            BusOnLineView(foliData: FoliDataClass(), trip: TripData(trip: GtfsTrip()), route: RouteData(route: GtfsRoute()), vehicle: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
        }
    }
}
