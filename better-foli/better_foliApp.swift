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
    var body: some Scene {
        let center = CLLocationCoordinate2D(latitude: 60.451201, longitude: 22.263379)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let fallbackLocation = MKCoordinateRegion(center: center, span: span)
        
        WindowGroup {
            ContentView(mapCameraPosition: .userLocation(fallback: .region(fallbackLocation)))
                .modelContainer(for: [
                    FavouriteStop.self
                ])
        }
    }
}
