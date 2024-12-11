//
//  better_foliApp.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import SwiftUI
import MapKit
import SwiftData

@main
struct better_foliApp: App {
    let foliData = FoliDataClass()
    let locationManager = LocationManagerClass()
    
    var body: some Scene {
        WindowGroup {
            ContentView(foliData: foliData, locationManager: locationManager, mapCameraPosition: .userLocation(fallback: .region(foliData.fallbackLocation)))
                .modelContainer(for: [
                    StopData.self
                ], isAutosaveEnabled: true)
            
        }
    }
}
