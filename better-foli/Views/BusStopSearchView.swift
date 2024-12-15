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
    @Environment(\.dismiss) private var dismiss
    let searchFilter: String
    
    @Binding var mapCameraPosition: MapCameraPosition
    @Binding var selectedStop: StopData?
    
    @Query var filteredStops: [StopData]
    
    init(searchFilter: String, mapCameraPosition: Binding<MapCameraPosition>, selectedStop: Binding<StopData?>) {
        self.searchFilter = searchFilter
        
        _mapCameraPosition = mapCameraPosition
        _selectedStop = selectedStop
        
        let predicate = #Predicate<StopData> {
            $0.name.contains(searchFilter)
        }
        
        _filteredStops = Query(filter: predicate)
    }
    
    var body: some View {
        ScrollView {
            ForEach(filteredStops, id: \.code) { stop in
                HStack {
                    Text(stop.name)
                    Spacer()
                    Button {
                        let region = MKCoordinateRegion(center: stop.coords, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        mapCameraPosition = .region(region)
                        selectedStop = stop
                        dismiss()
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

#Preview(traits: .sampleData) {
    let foliData = FoliDataClass()
    BusStopSearchView(searchFilter: "", mapCameraPosition: .constant(.userLocation(fallback: .region(foliData.fallbackLocation))), selectedStop: .constant(nil))
}
