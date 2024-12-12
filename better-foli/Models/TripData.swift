//
//  TripData.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 12.12.2024.
//

import Foundation
import SwiftData

@Model
class TripData {
    @Attribute(.unique) var tripID: String
    var shapeID: String
    var routeID: String
    
    init(trip: GtfsTrip) {
        self.tripID = trip.trip_id
        self.shapeID = trip.shape_id
        self.routeID = trip.route_id
    }
}
