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
    var cameraDistance: Double?
    
    // MARK: Load stops
    func getGtfsStops() async throws -> Void {
        guard let url = URL(string: "\(baseURL)/gtfs/stops") else { return }
        let (data, _) = try await URLSession.shared.data(from: url)
        self.allStops = try JSONDecoder().decode([String: GtfsStop].self, from: data)
    }
    
    var filteredStops: [String: GtfsStop] {
        if let cameraPosition, let cameraDistance {
            return allStops.filter { stop in
                let stopData = stop.value
                
                let stopCoords = CLLocationCoordinate2D(latitude: CLLocationDegrees(stopData.stop_lat), longitude: CLLocationDegrees(stopData.stop_lon))
                                
                let lat = cameraPosition.center.latitude
                let latMin = lat - cameraPosition.span.latitudeDelta / 2
                let latMax = lat + cameraPosition.span.latitudeDelta / 2
                
                let lon = cameraPosition.center.longitude
                let lonMin = lon - cameraPosition.span.longitudeDelta / 2
                let lonMax = lon + cameraPosition.span.longitudeDelta / 2
                
                if (stopCoords.latitude >= latMin && stopCoords.latitude <= latMax && stopCoords.longitude >= lonMin && stopCoords.longitude <= lonMax && cameraDistance < 4000) {
                    return true
                } else {
                    return false
                }
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
    
    func loadTrip(tripID: String) async throws -> GtfsTrip? {
        guard let url = URL(string: "\(baseURL)/gtfs/trips/trip/\(tripID)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let trips = try JSONDecoder().decode([GtfsTrip].self, from: data)
        
        return trips.first
    }
    
    func loadRoute(routeID: String) async throws -> GtfsRoute? {
        guard let url = URL(string: "\(baseURL)/gtfs/routes") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let routes = try JSONDecoder().decode([GtfsRoute].self, from: data)
        
        return routes.filter { route in
            route.route_id == routeID
        }.first
    }
}
