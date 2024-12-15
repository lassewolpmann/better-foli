//
//  LiveBusMapTimetableView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 15.12.2024.
//

import SwiftUI

struct LiveBusMapTimetableView: View {
    let vehicle: VehicleData
    
    var body: some View {
        if (!vehicle.onwardCalls.isEmpty) {
            ScrollView {
                VStack(spacing: 10) {
                    Label {
                        Text("Upcoming Stops")
                            .font(.title)
                    } icon: {
                        Image(systemName: "parkingsign")
                    }
                    
                    ForEach(vehicle.onwardCalls, id: \.stoppointref) { call in
                        HStack(alignment: .center) {
                            Text(call.stoppointref)
                                .bold()
                                .frame(width: 75)
                            Text(call.stoppointname)
                            
                            Spacer()
                                                           
                            VStack {
                                ArrivalTimeView(aimedArrival: call.aimedarrivaltime, expectedArrival: call.expectedarrivaltime)
                                DepartureTimeView(aimedDeparture: call.aimeddeparturetime, expectedDeparture: call.expecteddeparturetime)
                            }
                        }
                    }
                }
            }
            .padding(10)
            .presentationDetents([.medium])
            .presentationBackground(.regularMaterial)
        }
    }
}

#Preview {
    LiveBusMapTimetableView(vehicle: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
}
