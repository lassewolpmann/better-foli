//
//  BusStopSearchView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 5.12.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct BusStopSearchView: View {
    let foliData: FoliDataClass
    let locationManager: LocationManagerClass
    
    @State var searchFilter: String = ""
    @State var mapCameraPosition: MapCameraPosition
    
    @Query var allStops: [StopData]
    
    var body: some View {
        VStack {
            TextField("\(Image(systemName: "bus")) Find Stop", text: $searchFilter)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.thinMaterial)
                )
            
            ScrollView {
                let searchFilteredStops = allStops.filter { stop in
                    return true
                }
                
                ForEach(searchFilteredStops , id: \.code) { stop in
                    let span = MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025)
                    let stopLocation = MKCoordinateRegion(center: stop.coords, span: span)
                    
                    HStack {
                        FavouriteStopLabelView(stop: stop)

                        Spacer()
                        
                        if let location = locationManager.manager.location {
                            let distance = location.distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))
                            let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
                            Text(distanceMeasurement.formatted(.measurement(width: .abbreviated)))
                        }
                        
                        Button {
                            mapCameraPosition = .region(stopLocation)
                        } label: {
                            Image(systemName: "location.circle")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    let foliData = FoliDataClass()
    
    BusStopSearchView(foliData: foliData, locationManager: LocationManagerClass(), mapCameraPosition: .region(foliData.fallbackLocation))
}
