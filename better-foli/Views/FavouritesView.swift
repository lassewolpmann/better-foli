//
//  FavouriteStopsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI
import SwiftData

struct FavouritesView: View {
    @Query var favouriteStops: [FavouriteStop]
    @Environment(\.modelContext) private var context
    
    let foliData: FoliDataClass
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(favouriteStops, id: \.stopCode) { favourite in
                        if let gtfsStop = foliData.allStops.first(where: { $0.value.stop_code == favourite.stopCode }) {
                            let stop = gtfsStop.value

                            NavigationLink {
                                StopView(foliData: foliData, stop: stop)
                            } label: {
                                FavouriteStopLabelView(stop: stop)
                            }
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

#Preview {
    FavouritesView(foliData: FoliDataClass())
}
