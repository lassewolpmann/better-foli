//
//  OverviewActualMapView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 13.12.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct OverviewActualMapView: View {
    @Query var allStops: [StopData]
    
    @State private var selectedStop: StopData?
    
    let foliData: FoliDataClass
    let cameraRegion: MKCoordinateRegion

    init(foliData: FoliDataClass, cameraRegion: MKCoordinateRegion) {
        self.foliData = foliData
        self.cameraRegion = cameraRegion
        
        let latitude = cameraRegion.center.latitude
        let longitude = cameraRegion.center.longitude
        let latDelta = cameraRegion.span.latitudeDelta
        let lonDelta = cameraRegion.span.longitudeDelta
        
        let minLat = latitude - latDelta / 2
        let maxLat = latitude + latDelta / 2
        
        let minLon = longitude - lonDelta / 2
        let maxLon = longitude + lonDelta / 2
                
        let predicate = #Predicate<StopData> { stop in
            return stop.latitude >= minLat && stop.latitude <= maxLat && stop.longitude >= minLon && stop.longitude <= maxLon
        }
        
        _allStops = Query(filter: predicate)
    }
    
    var body: some View {
        Map(initialPosition: .userLocation(fallback: .automatic), bounds: .init(maximumDistance: 10000), selection: $selectedStop) {
            // Always show user location
            UserAnnotation()
            
            ForEach(allStops, id: \.code) { stop in
                Marker(stop.name, systemImage: stop.isFavourite ? "star.fill" : "bus", coordinate: stop.coords)
                    .tint(.orange)
                    .tag(stop)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: true))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .sheet(item: $selectedStop) { stop in
            StopView(foliData: foliData, stop: stop)
        }
    }
}

#Preview(traits: .sampleData) {
    OverviewActualMapView(foliData: FoliDataClass(), cameraRegion: .init(center: FoliDataClass().fallbackLocation.center, span: FoliDataClass().fallbackLocation.span))
}
