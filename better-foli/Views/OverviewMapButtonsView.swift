//
//  OverviewMapButtonsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 11.12.2024.
//

import SwiftUI
import MapKit

struct OverviewMapButtonsView: View {
    @Environment(\.modelContext) private var context

    @Bindable var foliData: FoliDataClass
    @Binding var mapCameraPosition: MapCameraPosition
    @Binding var selectedStop: StopData?
    
    @State var searchFilter: String = ""
    @State private var showSearchSheet: Bool = false
    
    var body: some View {        
        HStack(spacing: 5) {
            TextField(text: $searchFilter) {
                Label {
                    Text("Search for stop")
                } icon: {
                    Image(systemName: "bus")
                }
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.primary.opacity(0.2))
            )
            .onSubmit {
                showSearchSheet.toggle()
            }
            
            Button {
                showSearchSheet.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
            }
            
            Spacer()
            
            Button {
                mapCameraPosition = .userLocation(fallback: .region(foliData.fallbackLocation))
            } label: {
                Image(systemName: "location.fill")
            }
            
            /*
            Spacer()
            
            Button {
                do {
                    try context.delete(model: StopData.self)
                    try context.delete(model: ShapeData.self)
                    try context.delete(model: TripData.self)
                } catch {
                    print(error)
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
             */
        }
        .buttonStyle(.borderedProminent)
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showSearchSheet, onDismiss: {
            searchFilter = ""
        }) {
            BusStopSearchView(searchFilter: searchFilter, mapCameraPosition: $mapCameraPosition, selectedStop: $selectedStop)
        }
    }
}

#Preview {
    let foliData = FoliDataClass()
    OverviewMapButtonsView(foliData: foliData, mapCameraPosition: .constant(.region(foliData.fallbackLocation)), selectedStop: .constant(nil))
}
