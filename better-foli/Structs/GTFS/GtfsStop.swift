//
//  GtfsStop.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import Foundation

struct GtfsStop: Decodable, Equatable {
    // https://data.foli.fi/doc/gtfs/v0/stops-en
    var stop_code: String = "0"
    var stop_name: String = "Test Stop"
    var stop_desc: String = "Test Stop Description"
    var stop_lat: Float = 0.0
    var stop_lon: Float = 0.0
    var zone_id: String = "Test Zone"
    var stop_url: String = ""
    var location_type: Int = 0
    var parent_station: Int = 0
    var stop_timezone: String = "Europe/Helsinki"
    var wheelchair_boarding: Int = 0
}
