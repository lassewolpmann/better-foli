//
//  RouteOverviewBusRow.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 16.12.2024.
//

import SwiftUI

struct RouteOverviewBusRow: View {
    let foliData: FoliDataClass
    let trip: TripData
    let route: RouteData
    let vehicle: VehicleData
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(vehicle.lineReference)
                .bold()
                .frame(width: 50)
            
            if (vehicle.monitored) {
                NavigationLink {
                    LiveBusView(foliData: foliData, upcomingBus: vehicle, selectedStopCode: "", route: route, trip: trip)
                } label: {
                    Label {
                        Text(vehicle.destinationName)
                    } icon: {
                        Image(systemName: "location.circle.fill")
                            .foregroundStyle(.orange)
                    }
                    .labelStyle(AlignedLabel())
                }
            } else {
                Text(vehicle.destinationName)
            }
            
            Spacer()
        }
    }
}

#Preview {
    RouteOverviewBusRow(foliData: FoliDataClass(), trip: TripData(trip: GtfsTrip()), route: RouteData(route: GtfsRoute()), vehicle: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
}
