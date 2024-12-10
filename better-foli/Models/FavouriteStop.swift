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
    
    init(stop: StopData) {
        self.stopCode = stop.code
        self.stopName = stop.name
    }
}
