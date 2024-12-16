//
//  GtfsRoute.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import Foundation

struct GtfsRoute: Decodable {
    // https://data.foli.fi/doc/gtfs/v0/routes-en
    var route_id: String = "1"
    var route_short_name: String = "1"
    var route_long_name: String = "Lentoasema-Satama"
}
