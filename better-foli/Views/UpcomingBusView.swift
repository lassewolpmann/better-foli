//
//  UpcomingBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI

struct UpcomingBusView: View {
    let foliData: FoliDataClass
    let upcomingBus: DetailedSiriStop.Result
    
    @State var headsign: String?
    @State var routeNumber: String?
    
    var body: some View {
        HStack(spacing: 5) {
            Text(routeNumber ?? "")
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.orange)
                )

            if (upcomingBus.monitored) {
                NavigationLink {
                    Text("Bus")
                } label: {
                    Label {
                        Text(headsign ?? "")
                    } icon: {
                        Image(systemName: "location.circle")
                    }
                }
            } else {
                Text(headsign ?? "")
            }
            
            Spacer()
            
            VStack {
                if let aimedArrival = upcomingBus.aimedarrivaltime, let expectedArrival = upcomingBus.expectedarrivaltime {
                    let aimedDate = Date(timeIntervalSince1970: TimeInterval(aimedArrival))
                    let expectedDate = Date(timeIntervalSince1970: TimeInterval(expectedArrival))
                    
                    Label {
                        Text(aimedDate, style: .time)
                    } icon: {
                        Image(systemName: "arrow.right")
                    }
                }
                
                if let aimedDeparture = upcomingBus.aimeddeparturetime, let expectedDeparture = upcomingBus.expecteddeparturetime {
                    let aimedDate = Date(timeIntervalSince1970: TimeInterval(aimedDeparture))
                    let expectedDate = Date(timeIntervalSince1970: TimeInterval(expectedDeparture))
                    
                    Label {
                        Text(aimedDate, style: .time)
                    } icon: {
                        Image(systemName: "arrow.left")
                    }
                }
            }
        }
        .task {
            do {
                guard let trip = try await foliData.loadTrip(tripID: upcomingBus.__tripref) else { return }
                guard let route = try await foliData.loadRoute(routeID: trip.route_id) else { return }
                
                headsign = trip.trip_headsign
                routeNumber = route.route_short_name
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    UpcomingBusView(foliData: FoliDataClass(), upcomingBus: DetailedSiriStop.Result(recordedattime: 0, monitored: false, __tripref: ""))
}
