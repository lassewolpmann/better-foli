//
//  StopListPreviewView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 14.12.2024.
//

import SwiftUI
import MapKit

struct StopListPreviewView: View {
    let stop: StopData
    
    var body: some View {
        HStack {
            Map(initialPosition: .camera(.init(centerCoordinate: stop.coords, distance: 2500))) {
                Marker(stop.name, systemImage: "parkingsign", coordinate: stop.coords)
                    .tint(.orange)
                    .annotationTitles(.hidden)
            }
            .disabled(true)
            .frame(width: 75, height: 75)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            
            Text(stop.name)
        }
    }
}

#Preview {
    StopListPreviewView(stop: StopData(gtfsStop: GtfsStop()))
}
