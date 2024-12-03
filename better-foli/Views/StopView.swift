//
//  StopView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI

struct StopView: View {
    let foliData: FoliDataClass
    let stop: GtfsStop
    
    @State var detailedStop: DetailedSiriStop?
    
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