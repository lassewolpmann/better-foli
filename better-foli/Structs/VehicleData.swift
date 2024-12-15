//
//  VehicleData.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 12.12.2024.
//

import Foundation
import MapKit

struct VehicleData {
    var vehicleID: String
    var tripID: String
    var routeID: String
    var onwardCalls: [SiriVehicleMonitoring.Result.Vehicle.OnwardCalls]
    var lineReference: String
    var destinationName: String
    var monitored: Bool
    var latitude: Double
    var longitude: Double
    var coords: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var region: MKCoordinateRegion {
        MKCoordinateRegion(center: coords, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
    
    init(vehicleKey: String, vehicleData: SiriVehicleMonitoring.Result.Vehicle) {
        self.vehicleID = vehicleKey
        self.tripID = vehicleData.__tripref ?? ""
        self.routeID = vehicleData.__routeref  ?? ""
        self.onwardCalls = vehicleData.onwardcalls ?? []
        self.lineReference = vehicleData.lineref ?? ""
        self.destinationName = vehicleData.destinationname ?? ""
        self.monitored = vehicleData.monitored ?? false
        self.latitude = vehicleData.latitude ?? 0.0
        self.longitude = vehicleData.longitude ?? 0.0
    }
}
