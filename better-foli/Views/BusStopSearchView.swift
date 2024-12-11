//
//  BusStopSearchView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 11.12.2024.
//

import SwiftUI
import SwiftData
import MapKit

struct BusStopSearchView: View {
    @Query var allStops: [StopData]
    @Binding var mapCameraPosition: MapCameraPosition
    
    init(searchFilter: String, mapCameraPosition: Binding<MapCameraPosition>) {
        let predicate = #Predicate<StopData> {
            $0.name.contains(searchFilter)
        }

        _allStops = Query(filter: predicate)
        _mapCameraPosition = mapCameraPosition
    }
    
    var body: some View {
        ScrollView {
            ForEach(allStops, id: \.code) { stop in
                HStack {
                    Text(stop.name)
                    Spacer()
                    Button {
                        let region = MKCoordinateRegion(center: stop.coords, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        mapCameraPosition = .region(region)
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    let foliData = FoliDataClass()
    BusStopSearchView(searchFilter: "", mapCameraPosition: .constant(.userLocation(fallback: .region(foliData.fallbackLocation))))
}
