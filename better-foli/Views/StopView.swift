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
    @Query var allTrips: [TripData]
    
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
                        stop.isFavourite.toggle()
                    } label: {
                        Label {
                            Text("Save to Favourites")
                        } icon: {
                            Image(systemName: stop.isFavourite ? "star.fill" : "star")
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
                }
        }
    }
}

#Preview {
    StopView(foliData: FoliDataClass(), stop: StopData(gtfsStop: GtfsStop()))
}
