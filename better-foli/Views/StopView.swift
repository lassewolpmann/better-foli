//
//  StopView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import SwiftData

struct StopView: View {
    let foliData: FoliDataClass
    let stop: StopData
    
    @State var detailedStop: DetailedSiriStop?
    @State private var isFavourite: Bool = false
    
    @Environment(\.modelContext) private var context
    @Query var favouriteStops: [FavouriteStop]
    
    var body: some View {
        if let detailedStop {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(detailedStop.result, id: \.__tripref) { upcomingBus in
                            UpcomingBusView(foliData: foliData, upcomingBus: upcomingBus)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .navigationTitle("\(stop.name) - \(stop.code)")
                .toolbar {
                    Button {
                        if (isFavourite) {
                            deleteFavouriteStop()
                        } else {
                            insertFavouriteStop()
                        }
                    } label: {
                        Label {
                            Text("Save to Favourites")
                        } icon: {
                            Image(systemName: isFavourite ? "star.fill" : "star")
                        }
                    }
                }
            }
        } else {
            ProgressView("Loading data...")
                .task {
                    do {
                        detailedStop = try await foliData.getSiriStopData(stop: stop)
                    } catch {
                        print(error)
                    }
                    
                    isFavourite = favouriteStops.contains { $0.stopCode == stop.code }
                }
        }
    }
    
    private func insertFavouriteStop() {
        let favouriteStop = FavouriteStop(stop: stop)
        context.insert(favouriteStop)
    }
    
    private func deleteFavouriteStop() {
        if let stopToDelete = favouriteStops.first(where: { $0.stopCode == stop.code }) {
            context.delete(stopToDelete)
        }
    }
}

#Preview {
    StopView(foliData: FoliDataClass(), stop: StopData(gtfsStop: GtfsStop()))
}
