//
//  GtfsTrip.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import Foundation

struct GtfsTrip: Decodable {
    // https://data.foli.fi/doc/gtfs/v0/trips-en
    var trip_id: String
    var trip_headsign: String
    var shape_id: String
    var route_id: String
}
