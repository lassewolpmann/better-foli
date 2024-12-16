//
//  GtfsStop.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import Foundation

struct GtfsStop: Decodable, Equatable {
    // https://data.foli.fi/doc/gtfs/v0/stops-en
    var stop_code: String = "1"
    var stop_name: String = "Turun satama (Silja)"
    var stop_lat: Double = 60.43497
    var stop_lon: Double = 22.21966
}
