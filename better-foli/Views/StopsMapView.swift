//
//  OverviewActualMapView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 13.12.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct StopsMapView: View {
    @Query var allStops: [StopData]
    @State private var selectedStop: StopData?
    @State private var annotationSize: Double = 0.0

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
                Annotation(coordinate: stop.coords) {
                    Circle()
                        .fill(.orange)
                        .stroke(.orange, lineWidth: 1)
                        .frame(height: annotationSize)
                        .shadow(radius: 2)
                } label: {
                    Text(stop.name)
                }
                .tag(stop)
            }
        }
        .onMapCameraChange(frequency: .continuous) { context in
            let region = context.region
            let maxLat = region.center.latitude + (region.span.latitudeDelta / 2)
            let minLat = region.center.latitude - (region.span.latitudeDelta / 2)
            let maxLoc = CLLocation(latitude: maxLat, longitude: region.center.longitude)
            let minLoc = CLLocation(latitude: minLat, longitude: region.center.longitude)
            let distance = maxLoc.distance(from: minLoc)
            
            let minimumSize: Double = 10
            
            let sizeInMeters: Double = 10
            let size = (sizeInMeters * 1000) / distance
            
            annotationSize = size < minimumSize ? minimumSize : size
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: true))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .sheet(item: $selectedStop) { stop in
            BusStopView(foliData: foliData, stop: stop)
        }
    }
}

#Preview(traits: .sampleData) {
    StopsMapView(foliData: FoliDataClass(), cameraRegion: .init(center: FoliDataClass().fallbackLocation.center, span: FoliDataClass().fallbackLocation.span))
}
