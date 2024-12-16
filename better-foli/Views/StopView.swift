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
    
    @State private var upcomingBuses: [VehicleData]?
    
    var body: some View {
        if let upcomingBuses {
            NavigationStack {
                List {
                    if (upcomingBuses.isEmpty) {
                        Label {
                            Text("There are currently no buses scheduled for this stop.")
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.yellow)
                        }
                        .font(.headline)
                        .padding(10)
                        .labelStyle(AlignedLabel())
                    } else {
                        ForEach(upcomingBuses.sorted {
                            let a = $0.onwardCalls.first(where: { $0.stoppointref == stop.code})?.aimedarrivaltime ?? 0
                            let b = $1.onwardCalls.first(where: { $0.stoppointref == stop.code})?.aimedarrivaltime ?? 0
                            return a < b
                        }, id: \.vehicleID) { upcomingBus in
                            UpcomingBusView(foliData: foliData, upcomingBus: upcomingBus, selectedStopCode: stop.code)
                        }
                    }
                }
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
                        upcomingBuses = try await foliData.getUpcomingBuses(stop: stop)
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

#Preview(traits: .sampleData) {
    StopView(foliData: FoliDataClass(), stop: StopData(gtfsStop: GtfsStop()))
}
