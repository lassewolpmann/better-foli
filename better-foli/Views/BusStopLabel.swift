//
//  StopListPreviewView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 14.12.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct BusStopLabel: View {
    @State var customLabelText: String
    
    let stop: StopData
    let editMode: EditMode

    var body: some View {
        HStack {
            Map(initialPosition: .camera(.init(centerCoordinate: stop.coords, distance: 1500))) {
                Marker(stop.name, systemImage: "parkingsign", coordinate: stop.coords)
                    .tint(.orange)
                    .annotationTitles(.hidden)
            }
            .disabled(true)
            .frame(width: 75, height: 75)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .shadow(radius: 5)
            
            Text(stop.code)
                .bold()
                .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(stop.name)
                
                if (editMode == .inactive) {
                    if (!stop.customLabel.isEmpty) {
                        Text(stop.customLabel)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                } else if (editMode == .active) {
                    TextField(stop.customLabel.isEmpty ? "Custom Label" : stop.customLabel, text: $customLabelText)
                        .onSubmit {
                            stop.customLabel = customLabelText
                        }
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    List {
        BusStopLabel(customLabelText: "", stop: StopData(gtfsStop: GtfsStop()), editMode: .active)
    }
}
