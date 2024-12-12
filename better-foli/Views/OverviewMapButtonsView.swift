//
//  OverviewMapButtonsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 11.12.2024.
//

import SwiftUI
import MapKit

struct OverviewMapButtonsView: View {
    @Bindable var foliData: FoliDataClass    
    @Binding var mapCameraPosition: MapCameraPosition
    @Binding var showFavourites: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            Spacer()
            
            TextField(text: $foliData.searchFilter) {
                Label {
                    Text("Search stops")
                } icon: {
                    Image(systemName: "bus")
                }
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.primary.opacity(0.2))
            )
            
            Button {
                mapCameraPosition = .userLocation(fallback: .region(foliData.fallbackLocation))
            } label: {
                Image(systemName: "location.fill")
            }
            
            Button {
                showFavourites.toggle()
            } label: {
                Image(systemName: "star.fill")
            }
            
            Spacer()
        }
        .buttonStyle(.borderedProminent)
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    let foliData = FoliDataClass()
    OverviewMapButtonsView(foliData: foliData, mapCameraPosition: .constant(.region(foliData.fallbackLocation)), showFavourites: .constant(false))
}
