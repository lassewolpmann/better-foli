//
//  GtfsTrip.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import Foundation

struct GtfsTrip: Decodable {
    // https://data.foli.fi/doc/gtfs/v0/trips-en
    var trip_id: String = "00010036__1001050100"
    var trip_headsign: String = "Satama"
    var shape_id: String = "434"
    var route_id: String = "1"
}
