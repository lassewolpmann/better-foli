//
//  FavouriteStopsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI
import SwiftData
import MapKit

struct FavouritesView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<StopData> { $0.isFavourite }, sort: \.code) var favouriteStops: [StopData]
    @Query(filter: #Predicate<RouteData> { $0.isFavourite }, sort: \.shortName) var favouriteRoutes: [RouteData]
    
    @State var editMode: EditMode = .inactive
    @State var tempLabelText: String = ""
    
    let foliData: FoliDataClass
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(favouriteStops, id: \.code) { stop in
                        NavigationLink {
                            StopView(foliData: foliData, stop: stop)
                        } label: {
                            StopListPreviewView(stop: stop)
                        }
                    }
                    .onDelete(perform: deleteFavouriteStop)
                } header: {
                    Text("Bus Stops")
                }
                
                Section {
                    ForEach(favouriteRoutes, id: \.routeID) { route in
                        if (editMode == .inactive) {
                            NavigationLink {
                                RouteOverviewView(foliData: foliData, route: route)
                            } label: {
                                FavouriteLineLabel(customLabelText: route.customLabel, route: route, editMode: editMode)
                            }
                        } else if (editMode == .active) {
                            FavouriteLineLabel(customLabelText: route.customLabel, route: route, editMode: editMode)
                        }
                    }
                    .onDelete(perform: deleteFavouriteLine)
                } header: {
                    Text("Bus Lines")
                }
            }
            .toolbar {
                Button {
                    editMode = editMode == .active ? .inactive : .active
                } label: {
                    Text(editMode == .active ? "Done" : "Edit")
                }
            }
            .animation(.easeInOut(duration: 0.1), value: editMode)
            .environment(\.editMode, $editMode)
            .navigationTitle("Favourites")
        }
    }
    
    func deleteFavouriteStop(at offsets: IndexSet) {
        for offset in offsets {
            favouriteStops[offset].isFavourite.toggle()
        }
    }
    
    func deleteFavouriteLine(at offsets: IndexSet) {
        for offset in offsets {
            favouriteRoutes[offset].isFavourite.toggle()
        }
    }
}

#Preview(traits: .sampleData) {
    FavouritesView(foliData: FoliDataClass())
}
