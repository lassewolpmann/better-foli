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
                            Label {
                                Text(stop.name)
                            } icon: {
                                Text(stop.code)
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
