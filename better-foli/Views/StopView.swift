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
    let upcomingBus = DetailedSiriStop.Result(
        recordedattime: currentTimestamp,
        monitored: true,
        lineref: "51",
        destinationdisplay: "Oriniemi Häppilän kautta",
        aimedarrivaltime: currentTimestamp + 60,
        expectedarrivaltime: currentTimestamp + 120,
        aimeddeparturetime: currentTimestamp + 180,
        expecteddeparturetime: currentTimestamp + 240,
        __tripref: "00015150__1050051106", __routeref: ""
    )
    
    StopView(foliData: FoliDataClass(), stop: GtfsStop(), detailedStop: DetailedSiriStop(status: "OK", servertime: currentTimestamp, result: [upcomingBus]))
}
