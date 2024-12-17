//
//  LiveBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import MapKit
import SwiftData

enum VehicleFetchError: Error {
    case noVehicle
}

struct LiveBusView: View {
    @Query var tripShapes: [ShapeData]
    @Query var allVehicleStops: [StopData]
    @State var vehicle: VehicleData
    var vehicleStops: [StopData] {
        let onwardCallStopCodes = vehicle.onwardCalls.map { $0.stoppointref }
        return allVehicleStops.filter({ onwardCallStopCodes.contains($0.code) })
    }

    var tripShape: ShapeData? { tripShapes.first }
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    let foliData: FoliDataClass
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
        
        _allVehicleStops = Query(filter: predicate)
    }
    
    var body: some View {
        let mapCameraPosition: MapCameraPosition = .region(.init(center: vehicle.coords, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        
        LiveBusMapView(foliData: foliData, selectedStopCode: selectedStopCode, trip: trip, vehicle: vehicle, vehicleStops: vehicleStops, shape: tripShape, mapCameraPosition: mapCameraPosition)
            .navigationBarTitle("\(route.shortName) - \(route.longName)")
            .toolbar {
                Button {
                    route.isFavourite.toggle()
                } label: {
                    Image(systemName: route.isFavourite ? "star.fill" : "star")
                }
            }
            .task {
                do {
                    vehicle = try await getVehicle()
                } catch {
                    print(error)
                }
            }
            .onReceive(timer) { _ in
                Task {
                    do {
                        vehicle = try await getVehicle()
                    } catch {
                        print(error)
                    }
                }
            }
    }
    
    func getVehicle() async throws -> VehicleData {
        let allVehicles = try await foliData.getAllVehicles()
        guard let newVehicle = allVehicles.first(where: { $0.vehicleID == vehicle.vehicleID }) else { throw VehicleFetchError.noVehicle }
        return newVehicle
    }
}

#Preview(traits: .sampleData) {
    LiveBusView(foliData: FoliDataClass(), upcomingBus: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()), selectedStopCode: "", route: RouteData(route: GtfsRoute()), trip: TripData(trip: GtfsTrip()))
}
