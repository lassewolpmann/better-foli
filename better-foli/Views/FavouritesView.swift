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
                            StopView(foliData: foliData, stopCode: stop.code)
                        } label: {
                            StopListPreviewView(stopCode: stop.code)
                        }
                    }
                } header: {
                    Text("Bus Stops")
                }
                
                Section {
                    ForEach(favouriteRoutes, id: \.routeID) { route in
                        NavigationLink {
                            RouteOverviewView(foliData: foliData, routeID: route.routeID)
                        } label: {
                            Label {
                                Text(route.longName)
                            } icon: {
                                Text(route.shortName)
                            }
                        }
                    }
                } header: {
                    Text("Bus Lines")
                }
            }
            .navigationTitle("Favourites")
        }
    }
}

#Preview(traits: .sampleData) {
    FavouritesView(foliData: FoliDataClass())
}
