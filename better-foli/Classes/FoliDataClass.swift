//
//  FoliDataClass.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import Foundation
import MapKit

struct Stop: Decodable {
    // https://data.foli.fi/doc/gtfs/v0/stops-en
    var stop_code: String
    var stop_name: String
    var stop_desc: String
    var stop_lat: Float
    var stop_lon: Float
    var zone_id: String
    var stop_url: String
    var location_type: Int
    var parent_station: Int
    var stop_timezone: String
    var wheelchair_boarding: Int
}

struct HumanReadableStopTime {
    var tripID: String
    var busLine: String
    var routeName: String
    var departureDate: Date
    var minutesUntilDeparture: Int
}

struct StopTime: Decodable {
    // https://data.foli.fi/doc/gtfs/v0/stop_times-en
    var trip_id: String
    var arrival_time: String
    var departure_time: String
}

struct Trip: Decodable {
    // https://data.foli.fi/doc/gtfs/v0/trips-en
    var route_id: String
    var trip_headsign: String
}

struct Route: Decodable {
    // https://data.foli.fi/doc/gtfs/v0/routes-en
    var route_id: String
    var route_short_name: String
    var route_long_name: String
}

struct DecodedArray: Decodable {
    var array: [Stop]
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempArray = [Stop]()
        for key in container.allKeys {
            let decodedObject = try container.decode(Stop.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }

        array = tempArray
    }
}

@Observable class FoliDataClass {
    let baseURL = "https://data.foli.fi/gtfs"
    
    var allStops: [Stop]?
    
    var cameraPosition: MKCoordinateRegion?
    var cameraDistance: Double?
    
    func loadStops() async throws -> DecodedArray? {
        guard let url = URL(string: "\(baseURL)/stops") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResult = try JSONDecoder().decode(DecodedArray.self, from: data)
        
        return decodedResult
    }
    
    func loadStopTimes(stopCode: String) async throws -> [StopTime]? {
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        guard let url = URL(string: "\(baseURL)/stop_times/stop/\(stopCode)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let stopTimes = try JSONDecoder().decode([StopTime].self, from: data)
        
        let fixedStopTimes = stopTimes.map { stopTime in
            let stopTimeDeparture = stopTime.departure_time
            let stopTimeDepartureISOString = "\(year)-\(month)-\(day)T\(stopTimeDeparture)+02:00"
            
            let stopTimeArrival = stopTime.departure_time
            let stopTimeArrivalISOString = "\(year)-\(month)-\(day)T\(stopTimeArrival)+02:00"
            
            return StopTime(
                trip_id: stopTime.trip_id,
                arrival_time: stopTimeDepartureISOString,
                departure_time: stopTimeArrivalISOString
            )
        }
        
        return fixedStopTimes
    }
    
    func loadTrip(tripID: String) async throws -> Trip? {
        guard let url = URL(string: "\(baseURL)/trips/trip/\(tripID)") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let trips = try JSONDecoder().decode([Trip].self, from: data)
        
        return trips.first
    }
    
    func loadRoute(routeID: String) async throws -> Route? {
        guard let url = URL(string: "\(baseURL)/routes") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let routes = try JSONDecoder().decode([Route].self, from: data)
        
        return routes.filter { route in
            route.route_id == routeID
        }.first
    }
    
    var filteredStops: [Stop] {
        if let allStops, let cameraPosition, let cameraDistance {
            return allStops.filter { stop in
                let stopCoords = CLLocationCoordinate2D(latitude: CLLocationDegrees(stop.stop_lat), longitude: CLLocationDegrees(stop.stop_lon))
                                
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
            return []
        }
    }
}
