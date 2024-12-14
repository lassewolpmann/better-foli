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
    
    @State var mapCameraPosition: MapCameraPosition = .userLocation(fallback: .region(FoliDataClass().fallbackLocation))
    @State private var selectedStop: StopData?
    
    let foliData: FoliDataClass
    let locationManager: LocationManagerClass
    let cameraRegion: MKCoordinateRegion

    init(foliData: FoliDataClass, locationManager: LocationManagerClass, cameraRegion: MKCoordinateRegion) {
        self.foliData = foliData
        self.locationManager = locationManager
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
        Map(position: $mapCameraPosition, bounds: .init(maximumDistance: 10000), selection: $selectedStop) {
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
            MapCompass()
        }
        .sheet(item: $selectedStop) { stop in
            StopView(foliData: foliData, stop: stop)
        }
        .safeAreaInset(edge: .top, content: {
            OverviewMapButtonsView(foliData: foliData, locationManager: locationManager, mapCameraPosition: $mapCameraPosition, selectedStop: $selectedStop)
        })
    }
}

#Preview {
    OverviewActualMapView(foliData: FoliDataClass(), locationManager: LocationManagerClass(), cameraRegion: .init(center: FoliDataClass().fallbackLocation.center, span: FoliDataClass().fallbackLocation.span))
}
