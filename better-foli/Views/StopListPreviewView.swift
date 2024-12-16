//
//  StopListPreviewView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 14.12.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct StopListPreviewView: View {
    let stop: StopData

    var body: some View {
        HStack(spacing: 10) {
            Map(initialPosition: .camera(.init(centerCoordinate: stop.coords, distance: 1500))) {
                Marker(stop.name, systemImage: "parkingsign", coordinate: stop.coords)
                    .tint(.orange)
                    .annotationTitles(.hidden)
            }
            .disabled(true)
            .frame(width: 50, height: 75)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .shadow(radius: 5)
            
            Text(stop.code)
                .font(.subheadline)
                .frame(width: 50, height: 25)
                .background {
                    RoundedRectangle(cornerRadius: 5).fill(.orange)
                }
            
            Text(stop.name)
        }
    }
}

#Preview(traits: .sampleData) {
    List {
        StopListPreviewView(stop: StopData(gtfsStop: GtfsStop()))
    }
}
