//
//  FavouriteLine.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 5.12.2024.
//

import Foundation
import SwiftData

@Model
class FavouriteLine {
    @Attribute(.unique) var lineRef: String
    
    init() {
        self.lineRef = "0"
    }
}
