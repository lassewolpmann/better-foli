//
//  FavouriteStopsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI
import SwiftData

struct FavouriteStopsView: View {
    @Query var favouriteStops: [FavouriteStop]
    @Environment(\.modelContext) private var context
    
    let foliData: FoliDataClass
    
    var body: some View {
        NavigationStack {
            List(favouriteStops, id: \.stopCode) { favourite in
                if let gtfsStop = foliData.allStops.first(where: { $0.value.stop_code == favourite.stopCode }) {
                    let stop = gtfsStop.value

                    NavigationLink {
                        StopView(foliData: foliData, stop: stop)
                    } label: {
                        HStack(alignment: .center, spacing: 15) {
                            Text(stop.stop_code)
                                .frame(width: 50)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                                .foregroundStyle(.orange)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.clear)
                                        .stroke(.orange, lineWidth: 2)
                                )
                            
                            Text(stop.stop_name)
                        }
                    }
                }
            }
            .navigationTitle("Favourites")
        }
    }
}

#Preview {
    FavouriteStopsView(foliData: FoliDataClass())
}
