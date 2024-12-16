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
                        NavigationLink {
                            RouteOverviewView(foliData: foliData, route: route)
                        } label: {
                            Label {
                                Text(route.longName)
                            } icon: {
                                Text(route.shortName)
                            }
                        }
                    }
                    .onDelete(perform: deleteFavouriteLine)
                } header: {
                    Text("Bus Lines")
                }
            }
            .toolbar {
                EditButton()
            }
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
