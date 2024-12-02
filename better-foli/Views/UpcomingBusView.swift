//
//  UpcomingBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI

struct AlignedLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
            configuration.title
        }
        .multilineTextAlignment(.leading)
    }
}

struct UpcomingBusView: View {
    let foliData: FoliDataClass
    let upcomingBus: DetailedSiriStop.Result
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(upcomingBus.lineref)
                .bold()
                .frame(width: 50)

            if (upcomingBus.monitored) {
                NavigationLink {
                    LiveBusView(foliData: foliData, upcomingBus: upcomingBus)
                } label: {
                    Label {
                        Text(upcomingBus.destinationdisplay)
                    } icon: {
                        Image(systemName: "location.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .labelStyle(AlignedLabel())
                }
            } else {
                Text(upcomingBus.destinationdisplay)
            }
                      
            Spacer()
            
            VStack {
                if let aimedArrival = upcomingBus.aimedarrivaltime, let expectedArrival = upcomingBus.expectedarrivaltime {
                    let aimedDate = Date(timeIntervalSince1970: TimeInterval(aimedArrival))
                    let expectedDate = Date(timeIntervalSince1970: TimeInterval(expectedArrival))
                    let delay = Int(floor(expectedDate.timeIntervalSince(aimedDate) / 60))
                    
                    Label {
                        HStack(alignment: .top, spacing: 2) {
                            Text(aimedDate, style: .time)
                            Text("\(delay >= 0 ? "+" : "")\(delay)")
                                .foregroundStyle(delay > 0 ? .red : .primary)
                                .font(.footnote)
                        }
                    } icon: {
                        Image(systemName: "arrow.right")
                    }
                    .labelStyle(AlignedLabel())
                }
                
                if let aimedDeparture = upcomingBus.aimeddeparturetime, let expectedDeparture = upcomingBus.expecteddeparturetime {
                    let aimedDate = Date(timeIntervalSince1970: TimeInterval(aimedDeparture))
                    let expectedDate = Date(timeIntervalSince1970: TimeInterval(expectedDeparture))
                    let delay = Int(floor(expectedDate.timeIntervalSince(aimedDate) / 60))
                    
                    Label {
                        HStack(alignment: .top, spacing: 2) {
                            Text(aimedDate, style: .time)
                            Text("\(delay >= 0 ? "+" : "")\(delay)")
                                .foregroundStyle(delay > 0 ? .red : .primary)
                                .font(.footnote)
                        }
                    } icon: {
                        Image(systemName: "arrow.left")
                    }
                    .labelStyle(AlignedLabel())
                }
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
    
    NavigationStack {
        UpcomingBusView(foliData: FoliDataClass(), upcomingBus: upcomingBus)
    }
    .padding(10)
}
