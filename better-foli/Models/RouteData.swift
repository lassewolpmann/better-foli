//
//  RouteData.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 15.12.2024.
//

import Foundation
import SwiftData

@Model
final class RouteData {
    @Attribute(.unique) var routeID: String
    var shortName: String
    var longName: String
    
    var isFavourite: Bool = false
    var customLabel: String = ""
    
    init(route: GtfsRoute) {
        self.routeID = route.route_id
        self.shortName = route.route_short_name
        self.longName = route.route_long_name
    }
}
