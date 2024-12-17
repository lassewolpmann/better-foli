//
//  OverviewMapView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 13.12.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct AllStopsView: View {
    @State var cameraRegion: MKCoordinateRegion = .init(center: FoliDataClass().fallbackLocation.center, span: FoliDataClass().fallbackLocation.span)
    
    let foliData: FoliDataClass
    let locationManager: LocationManagerClass
    
    var body: some View {
        MapReader { _ in
            StopsMapView(foliData: foliData, cameraRegion: cameraRegion)
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            cameraRegion = context.region
        }
        .task {
            locationManager.requestAuthorization()
        }
    }
}

#Preview(traits: .sampleData) {
    AllStopsView(foliData: FoliDataClass(), locationManager: LocationManagerClass())
}
