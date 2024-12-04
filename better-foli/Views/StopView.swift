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
    let stop: GtfsStop
    
    @State var detailedStop: DetailedSiriStop?
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if let detailedStop {
                        ForEach(detailedStop.result, id: \.__tripref) { result in
                            UpcomingBusView(foliData: foliData, upcomingBus: result)
                        }
                    } else {
                        ProgressView("Loading upcoming Buses...")
                    }
                }
            }
            .padding(.horizontal, 10)
            .navigationTitle("\(stop.stop_name) - \(stop.stop_code)")
            .toolbar {
                Button {
                    let favouriteStop = FavouriteStop(stop: stop)
                    context.insert(favouriteStop)
                    
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                } label: {
                    Label {
                        Text("Save to Favourites")
                    } icon: {
                        Image(systemName: "star")
                    }
                }
            }
        }
        .task {
            do {
                detailedStop = try await foliData.getSiriStopData(stopCode: stop.stop_code)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    let currentTimestamp = Int(Date.now.timeIntervalSince1970)
    let upcomingBus = DetailedSiriStop.Result()
    
    StopView(foliData: FoliDataClass(), stop: GtfsStop(), detailedStop: DetailedSiriStop(status: "OK", servertime: currentTimestamp, result: [upcomingBus, upcomingBus]))
}
