//
//  FoliDataClass.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import Foundation
import MapKit
import SwiftData

@Observable
class FoliDataClass {
    let baseURL = "https://data.foli.fi"
    let fallbackLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.451201, longitude: 22.263379), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    var vehicleData: [SiriVehicleMonitoring.Result.Vehicle] = []
    
    func getAllStops() async throws -> [StopData] {
        guard let url = URL(string: "\(baseURL)/gtfs/stops") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let gtfsStops = try JSONDecoder().decode([String: GtfsStop].self, from: data)

        return gtfsStops.map { stop in
            return StopData(gtfsStop: stop.value)
        }
    }
    
    func getSiriStopData(stop: StopData) async throws -> DetailedSiriStop? {
        guard let url = URL(string: "\(baseURL)/siri/stops/\(stop.code)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(DetailedSiriStop.self, from: data)
    }
    
    func getSiriVehicleData() async throws -> SiriVehicleMonitoring? {
        guard let url = URL(string: "\(baseURL)/siri/vm") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SiriVehicleMonitoring.self, from: data)
    }
    
    func getVehiclePosition(vehicleRef: String) async throws -> SiriVehicleMonitoring.Result.Vehicle? {
        if let allVehicles = try await getSiriVehicleData() {
            return allVehicles.result.vehicles.filter { vehicle in
                return vehicle.key == vehicleRef
            }.first?.value
        } else {
            return nil
        }
    }
    
    func getAllTrips() async throws -> [TripData] {
        guard let url = URL(string: "\(baseURL)/gtfs/trips/all") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let trips = try JSONDecoder().decode([GtfsTrip].self, from: data)
        return trips.map { TripData(trip: $0) }
    }
    
    func getAllShapes() async throws -> [ShapeData] {
        guard let url = URL(string: "\(baseURL)/gtfs/shapes") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let shapes = try JSONDecoder().decode([String].self, from: data)
        return shapes.map { ShapeData(shapeID: $0 )}
    }
    
    func getShape(shapeID: String) async throws -> ShapeCoordsData? {
        guard let url = URL(string: "\(baseURL)/gtfs/shapes/\(shapeID)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let gtfsShapes = try JSONDecoder().decode([GtfsShape].self, from: data)
        return ShapeCoordsData(shapeID: shapeID, shapes: gtfsShapes)
    }
}
