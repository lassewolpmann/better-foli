//
//  LiveBusMapButtonsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 15.12.2024.
//

import SwiftUI
import MapKit

struct LiveBusMapButtonsView: View {
    @Binding var mapCameraPosition: MapCameraPosition
    @Binding var showTimetable: Bool
    
    let vehicle: VehicleData
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                mapCameraPosition = .region(vehicle.region)
            } label: {
                Label {
                    Text("Find Bus")
                } icon: {
                    Image(systemName: "location.circle")
                }
            }
            
            Button {
                showTimetable.toggle()
            } label: {
                Label {
                    Text("Timetable")
                } icon: {
                    Image(systemName: "calendar")
                }
            }
            
            Spacer()
        }
        .buttonStyle(.borderedProminent)
        .padding(.vertical, 15)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    LiveBusMapButtonsView(mapCameraPosition: .constant(.region(FoliDataClass().fallbackLocation)), showTimetable: .constant(false), vehicle: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
}
