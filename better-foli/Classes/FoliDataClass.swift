//
//  FoliDataClass.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import Foundation
import MapKit
import SwiftData

@Observable class FoliDataClass {
    let baseURL = "https://data.foli.fi"
    let fallbackLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.451201, longitude: 22.263379), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    var showStopsWithNoBuses: Bool = false
            
    func getStops() async throws -> [StopData] {
        guard let url = URL(string: "\(baseURL)/gtfs/stops") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let gtfsStops = try JSONDecoder().decode([String: GtfsStop].self, from: data)

        return gtfsStops.map { stop in
            return StopData(gtfsStop: stop.value)
        }
    }
    
    /*
    var filteredStops: [StopData] {
        guard let cameraRegion, let cameraDistance else { return [] }
        let spanBuffer = 0.001
        
        return allStops.filter { stop in
            let lat = cameraRegion.center.latitude
            let latMin = (lat - cameraRegion.span.latitudeDelta / 2) - spanBuffer
            let latMax = (lat + cameraRegion.span.latitudeDelta / 2) + spanBuffer
            
            let lon = cameraRegion.center.longitude
            let lonMin = (lon - cameraRegion.span.longitudeDelta / 2) - spanBuffer
            let lonMax = (lon + cameraRegion.span.longitudeDelta / 2) + spanBuffer
            
            // Return true if stop is in favourites, regardless of any other factor
            if (favouriteStops.contains { $0.stopCode == stop.code }) { return true }
            
            // Return false if no upcoming Buses and option to show Stops with no buses is false
            // if (stop.upcomingBuses.isEmpty && !self.showStopsWithNoBuses) { return false }
            
            // Return true if stop is in camera region and distance
            if (stop.latitude >= latMin && stop.latitude <= latMax && stop.longitude >= lonMin && stop.longitude <= lonMax && cameraDistance <= 3000) { return true }
            
            // Default return false
            return false
        }
    }
     */
    
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
    
    func getGtfsTripsForRoute(routeID: String, tripID: String) async throws -> GtfsTrip? {
        guard let url = URL(string: "\(baseURL)/gtfs/trips/route/\(routeID)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let trips = try JSONDecoder().decode([GtfsTrip].self, from: data)
        
        let filteredTrips = trips.filter { trip in
            return trip.trip_id == tripID
        }
                        
        return filteredTrips.first
    }
    
    func getTripShape(routeID: String, tripID: String) async throws -> [GtfsShape]? {
        if let trip = try await getGtfsTripsForRoute(routeID: routeID, tripID: tripID) {
            guard let url = URL(string: "\(baseURL)/gtfs/shapes/\(trip.shape_id)") else { return nil }
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([GtfsShape].self, from: data)
        } else {
            return []
        }
    }
    
    func getTripCoordinates(routeID: String, tripID: String) async throws -> [CLLocationCoordinate2D] {
        if let shapes = try await getTripShape(routeID: routeID, tripID: tripID) {
            let coordinates = shapes.map { shape in
                return CLLocationCoordinate2D(latitude: shape.lat, longitude: shape.lon)
            }
            
            return coordinates
        } else {
            return []
        }
    }
}
