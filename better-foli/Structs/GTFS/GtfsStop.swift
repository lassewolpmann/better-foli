//
//  GtfsStop.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import Foundation

struct GtfsStop: Decodable, Equatable {
    // https://data.foli.fi/doc/gtfs/v0/stops-en
    var stop_code: String
    var stop_name: String
    var stop_lat: Float
    var stop_lon: Float
}
