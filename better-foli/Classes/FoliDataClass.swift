//
//  FoliDataClass.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import Foundation
import MapKit

@Observable class FoliDataClass {
    let baseURL = "https://data.foli.fi"
    
    var allStops: [String: GtfsStop] = [:]
    
    var cameraPosition: MKCoordinateRegion?
    var cameraHeight: Double?
    var favouriteStops: [FavouriteStop]?
    
    func getGtfsStops() async throws -> Void {
        guard let url = URL(string: "\(baseURL)/gtfs/stops") else { return }
        let (data, _) = try await URLSession.shared.data(from: url)
        self.allStops = try JSONDecoder().decode([String: GtfsStop].self, from: data)
    }
    
    var filteredStops: [String: GtfsStop] {
        if let cameraPosition, let cameraHeight, let favouriteStops {
            return allStops.filter { stop in
                let stopData = stop.value
                
                let stopCoords = CLLocationCoordinate2D(latitude: CLLocationDegrees(stopData.stop_lat), longitude: CLLocationDegrees(stopData.stop_lon))
                                
                let lat = cameraPosition.center.latitude
                let latMin = lat - cameraPosition.span.latitudeDelta / 2
                let latMax = lat + cameraPosition.span.latitudeDelta / 2
                
                let lon = cameraPosition.center.longitude
                let lonMin = lon - cameraPosition.span.longitudeDelta / 2
                let lonMax = lon + cameraPosition.span.longitudeDelta / 2
                
                // Return true if stop is in favourites, regardless of map position
                if (favouriteStops.contains { $0.stopCode == stopData.stop_code}) { return true }
                
                // Return true if stop is in camera region and distance
                if (stopCoords.latitude >= latMin && stopCoords.latitude <= latMax && stopCoords.longitude >= lonMin && stopCoords.longitude <= lonMax && cameraHeight <= 3000) { return true }
                
                // Default return false
                return false
            }
        } else {
            return [:]
        }
    }
    
    func getSiriStopData(stopCode: String) async throws -> DetailedSiriStop? {
        guard let url = URL(string: "\(baseURL)/siri/stops/\(stopCode)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let stopData = try JSONDecoder().decode(DetailedSiriStop.self, from: data)
                
        return stopData
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
