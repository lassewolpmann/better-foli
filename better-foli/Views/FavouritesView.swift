//
//  FavouriteStopsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI
import SwiftData

struct FavouritesView: View {
    @Environment(\.modelContext) private var context
    @Query var allStops: [StopData]
    @Query var favouriteStops: [FavouriteStop]
    
    let foliData: FoliDataClass
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(favouriteStops, id: \.stopCode) { favourite in
                        if let stop = allStops.first(where: { $0.code == favourite.stopCode }) {
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
