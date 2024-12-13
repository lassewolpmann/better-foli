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
    @Query(filter: #Predicate<StopData> { $0.isFavourite }) var favouriteStops: [StopData]
    
    let foliData: FoliDataClass
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(favouriteStops, id: \.code) { stop in
                        NavigationLink {
                            StopView(foliData: foliData, stop: stop)
                        } label: {
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
                            
                            /*
                            Label {
                                Text(stop.name)
                            } icon: {
                                Text(stop.code)
                            }
                             */
                        }
                    }
                } header: {
                    Text("Bus Stops")
                }
                
                Section {
                    
                } header: {
                    Text("Bus Lines")
                }
            }
            .navigationTitle("Favourites")
        }
    }
}

#Preview(traits: .sampleStopData) {
    FavouritesView(foliData: FoliDataClass())
}
