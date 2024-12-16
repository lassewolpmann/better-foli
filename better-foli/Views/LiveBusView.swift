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
    @Query var tripShapes: [ShapeData]
    @Query var vehicleStops: [StopData]
    
    var tripShape: ShapeData? { tripShapes.first }
        
    let foliData: FoliDataClass
    let vehicle: VehicleData
    let selectedStopCode: String
    let route: RouteData
    let trip: TripData
    
    init(foliData: FoliDataClass, upcomingBus: VehicleData, selectedStopCode: String, route: RouteData, trip: TripData) {
        self.foliData = foliData
        self.vehicle = upcomingBus
        self.selectedStopCode = selectedStopCode
        self.route = route
        self.trip = trip
        
        let tripShapeID = trip.shapeID
        
        _tripShapes = Query(filter: #Predicate<ShapeData> { $0.shapeID == tripShapeID })
        
        let onwardCallStopCodes = vehicle.onwardCalls.map { $0.stoppointref }
        let predicate = #Predicate<StopData> { stop in
            return onwardCallStopCodes.contains(stop.code)
        }
        
        _vehicleStops = Query(filter: predicate)
    }
    
    var body: some View {
        let mapCameraPosition: MapCameraPosition = .region(.init(center: vehicle.coords, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        
        LiveBusMapView(foliData: foliData, selectedStopCode: selectedStopCode, trip: trip, vehicleStops: vehicleStops, shape: tripShape, mapCameraPosition: mapCameraPosition, vehicle: vehicle)
            .navigationBarTitle("\(route.shortName) - \(route.longName)")
            .toolbar {
                Button {
                    route.isFavourite.toggle()
                } label: {
                    Image(systemName: route.isFavourite ? "star.fill" : "star")
                }
            }
    }
}

#Preview(traits: .sampleData) {
    LiveBusView(foliData: FoliDataClass(), upcomingBus: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()), selectedStopCode: "", route: RouteData(route: GtfsRoute()), trip: TripData(trip: GtfsTrip()))
}
