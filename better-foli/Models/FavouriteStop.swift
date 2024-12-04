//
//  FavouriteStop.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import Foundation
import SwiftData

@Model
class FavouriteStop {
    @Attribute(.unique) var stopCode: String
    var stopName: String
    
    init(stop: GtfsStop) {
        self.stopCode = stop.stop_code
        self.stopName = stop.stop_name
    }
}
