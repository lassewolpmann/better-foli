//
//  ShapeCoords.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 12.12.2024.
//

import Foundation
import SwiftData
import CoreLocation

struct ShapeLocation: Codable {
    var lat: Double = 0.0
    var lon: Double = 0.0
    var traveled: Int = 0
    var coords: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
    }
}

@Model
class ShapeData {
    #Index<ShapeData>([\.shapeID])
    @Attribute(.unique) var shapeID: String
    var locations: [ShapeLocation]
    
    init(shapeID: String, shapes: [GtfsShape]) {
        self.shapeID = shapeID
        self.locations = shapes.map { ShapeLocation(lat: $0.lat, lon: $0.lon, traveled: $0.traveled) }
    }
}
