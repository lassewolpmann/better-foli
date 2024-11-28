//
//  StopTimeView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 28.11.2024.
//

import SwiftUI

struct UpcomingBusLinesView: View {
    var stop: Stop?
    let foliData: FoliDataClass
    
    @State private var upcomingBuses: [HumanReadableStopTime] = []
    
    var body: some View {
        ScrollView {
            ForEach(upcomingBuses, id: \.tripID) { upcomingBus in
                HStack {
                    Label {
                        Text(upcomingBus.routeName)
                    } icon: {
                        Text(upcomingBus.busLine)
                            .bold()
                            .padding(.vertical, 2)
                            .padding(.horizontal, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 5).fill(.orange)
                            )
                    }
                    Spacer()
                    Text("\(upcomingBus.minutesUntilDeparture) min")
                }
            }
        }
        .task {
            do {
                if let stop {
                    guard let stopTimes = try await foliData.loadStopTimes(stopCode: stop.stop_code) else { return }
                    let futureStopTimes = stopTimes.filter { stopTime in
                        guard let date = ISO8601DateFormatter().date(from: stopTime.departure_time) else { return false }
                        
                        return date.timeIntervalSinceNow > 0
                    }
                    
                    for stopTime in futureStopTimes {
                        guard let trip = try await foliData.loadTrip(tripID: stopTime.trip_id) else { continue }
                        guard let route = try await foliData.loadRoute(routeID: trip.route_id) else { continue }
                        guard let date = ISO8601DateFormatter().date(from: stopTime.departure_time) else { continue }
                        
                        upcomingBuses.append(HumanReadableStopTime(
                            tripID: stopTime.trip_id,
                            busLine: route.route_short_name,
                            routeName: trip.trip_headsign,
                            departureDate: date,
                            minutesUntilDeparture: 0
                        ))
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    UpcomingBusLinesView(foliData: FoliDataClass())
}
