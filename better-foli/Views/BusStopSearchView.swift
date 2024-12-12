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
    let foliData: FoliDataClass
    
    @Binding var mapCameraPosition: MapCameraPosition
    
    var body: some View {
        ScrollView {
            ForEach(foliData.searchFilteredStops, id: \.code) { stop in
                HStack {
                    Text(stop.name)
                    Spacer()
                    Button {
                        let region = MKCoordinateRegion(center: stop.coords, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        mapCameraPosition = .region(region)
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

#Preview {
    let foliData = FoliDataClass()
    BusStopSearchView(foliData: foliData, mapCameraPosition: .constant(.userLocation(fallback: .region(foliData.fallbackLocation))))
}
