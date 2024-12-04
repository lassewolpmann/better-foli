//
//  FavouriteStopsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI

struct FavouriteStopsView: View {
    let foliData: FoliDataClass
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(foliData.favouriteStops, id: \.stop_code) { favourite in
                        NavigationLink {
                            StopView(foliData: foliData, stop: favourite)
                        } label: {
                            HStack {
                                Label {
                                    Text(favourite.stop_code)
                                } icon: {
                                    BusStopLabelView()
                                }
                                
                                Spacer()
                                
                                Text(favourite.stop_name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favourites")
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    let foliData = FoliDataClass()
    foliData.favouriteStops = [GtfsStop(), GtfsStop(), GtfsStop()]
    return FavouriteStopsView(foliData: foliData)
}
