//
//  OverviewActualMapView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 13.12.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct EdgeCoords: Hashable {
    var bottomLeft: Coord
    var bottomRight: Coord
    var topLeft: Coord
    var topRight: Coord
}

struct Coord: Hashable {
    var lat: Double
    var lon: Double
}

struct GridRect: Identifiable, Hashable {
    static func == (lhs: GridRect, rhs: GridRect) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    var edgeCoords: EdgeCoords
    var centerCoord: Coord
    var stops: [StopData]
}

struct StopsMapView: View {
    @Query var allStops: [StopData]
    @State private var selectedRect: GridRect?
    
    @State private var sheetStopItem: StopData?
    @State private var sheetStopItems: [StopData]?
    
    @State private var annotationSize: Double = 0.0

    let foliData: FoliDataClass
    let cameraRegion: MKCoordinateRegion
    let latitudeGridLines: Int = 6
    let longitudeGridLines: Int = 4

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
    
    var rects: [GridRect] {
        var rects: [GridRect] = []
        
        let minLat = cameraRegion.center.latitude - cameraRegion.span.latitudeDelta / 2
        let minLon = cameraRegion.center.longitude - cameraRegion.span.longitudeDelta / 2
        
        let maxLat = cameraRegion.center.latitude + cameraRegion.span.latitudeDelta / 2
        let maxLon = cameraRegion.center.longitude + cameraRegion.span.longitudeDelta / 2
        
        let latGridGap = cameraRegion.span.latitudeDelta / Double(latitudeGridLines)
        let lonGridGap = cameraRegion.span.longitudeDelta / Double(longitudeGridLines)
        
        let startingLat = minLat - minLat.truncatingRemainder(dividingBy: latGridGap) - latGridGap
        let startingLon = minLon - minLon.truncatingRemainder(dividingBy: lonGridGap) - lonGridGap
        
        var lat = startingLat
        var lon = startingLon
        
        while lat < maxLat {
            while lon < maxLon {
                let bottomLeft = Coord(lat: lat, lon: lon)
                let bottomRight = Coord(lat: lat, lon: lon + lonGridGap)
                let topLeft = Coord(lat: lat + latGridGap, lon: lon)
                let topRight = Coord(lat: lat + latGridGap, lon: lon + lonGridGap)
                
                let geoCenter = CLLocationCoordinate2D(latitude: bottomLeft.lat + latGridGap / 2, longitude: bottomLeft.lon + lonGridGap / 2)

                let stops = allStops.filter { stop in
                    let stopLat = stop.coords.latitude
                    let stopLon = stop.coords.longitude
                    
                    return stopLat >= bottomLeft.lat && stopLat < topLeft.lat && stopLon >= bottomLeft.lon && stopLon < bottomRight.lon
                }
                
                let stopsCenter = stops.reduce(geoCenter, { x, y in
                    let newLat = x.latitude + x.latitude.distance(to: y.latitude) / 2
                    let newLon = x.longitude + x.longitude.distance(to: y.longitude) / 2
                    
                    return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
                })
                
                let centerCoord = Coord(lat: stopsCenter.latitude, lon: stopsCenter.longitude)
                let edgeCoords = EdgeCoords(bottomLeft: bottomLeft, bottomRight: bottomRight, topLeft: topLeft, topRight: topRight)
                
                rects.append(GridRect(edgeCoords: edgeCoords, centerCoord: centerCoord, stops: stops))
                
                lon = lon + lonGridGap
            }
            lon = startingLon
            lat = lat + latGridGap
        }

        return rects
    }
    
    var body: some View {
        Map(initialPosition: .userLocation(fallback: .region(foliData.fallbackLocation)), selection: $selectedRect) {
            // Always show user location
            UserAnnotation()
            
            ForEach(rects) { rect in
                if (rect.stops.count == 1) {
                    if let stop = rect.stops.first {
                        Marker(stop.name, systemImage: "parkingsign", coordinate: CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude))
                            .tint(.orange)
                            .tag(rect)
                    }
                } else if (rect.stops.count > 1) {
                    let count = rect.stops.count > 99 ? "99+" : rect.stops.count.description
                    Marker("Stops", monogram: Text(verbatim: count), coordinate: CLLocationCoordinate2D(latitude: rect.centerCoord.lat, longitude: rect.centerCoord.lon))
                        .annotationTitles(.hidden)
                        .tint(.orange)
                        .tag(rect)
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: true))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .sheet(item: $selectedRect) { rect in
            if (rect.stops.count == 1) {
                if let stop = rect.stops.first {
                    BusStopView(foliData: foliData, stop: stop)
                }
            } else if (rect.stops.count > 1) {
                NavigationStack {
                    List(rect.stops.sorted { $0.code < $1.code }) { stop in
                        NavigationLink {
                            BusStopView(foliData: foliData, stop: stop)
                        } label: {
                            BusStopLabel(customLabelText: stop.customLabel, stop: stop, editMode: .inactive)
                        }
                    }
                    .navigationTitle("\(rect.stops.count) Stops")
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    StopsMapView(foliData: FoliDataClass(), cameraRegion: .init(center: FoliDataClass().fallbackLocation.center, span: FoliDataClass().fallbackLocation.span))
}
