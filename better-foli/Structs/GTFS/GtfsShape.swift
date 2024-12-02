//
//  GtfsShape.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 2.12.2024.
//

import Foundation

struct GtfsShape: Decodable {
    var lat: Double
    var lon: Double
    var traveled: Int
}
