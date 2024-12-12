//
//  TripShape.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 12.12.2024.
//

import Foundation
import SwiftData

@Model
class ShapeData {
    @Attribute(.unique) var shapeID: String
    
    init(shapeID: String) {
        self.shapeID = shapeID
    }
}
