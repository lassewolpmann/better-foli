//
//  StopData.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 9.12.2024.
//

import Foundation
import CoreLocation
import SwiftData

@Model
class StopData {
    #Index<StopData>([\.latitude], [\.longitude], [\.name], [\.code], [\.name, \.code])

    @Attribute(.unique) var code: String
    var name: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var coords: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    var isFavourite: Bool = false
    var customLabel: String = ""
    
    init(gtfsStop: GtfsStop) {
        self.code = gtfsStop.stop_code
        self.name = gtfsStop.stop_name
        self.latitude = CLLocationDegrees(gtfsStop.stop_lat)
        self.longitude = CLLocationDegrees(gtfsStop.stop_lon)
    }
}
