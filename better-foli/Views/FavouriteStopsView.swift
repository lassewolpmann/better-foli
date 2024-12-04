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
            ScrollView {
                VStack {
                    ForEach(favouriteStops, id: \.stopCode) { favourite in
                        HStack(alignment: .center) {
                            Label {
                                Text(favourite.stopCode)
                            } icon: {
                                BusStopLabelView()
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                                // StopView(foliData: foliData, stop: favourite)
                            } label: {
                                Text(favourite.stopName)
                            }
                            
                            Button {
                                context.delete(favourite)
                                
                                do {
                                    try context.save()
                                } catch {
                                    print(error)
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
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
    FavouriteStopsView(foliData: FoliDataClass())
}
