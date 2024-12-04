//
//  UpcomingBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import MapKit

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
                    let center = CLLocationCoordinate2D(latitude: upcomingBus.latitude ?? 0.0, longitude: upcomingBus.longitude ?? 0.0)
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let mapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: center, span: span))
                    
                    LiveBusView(foliData: foliData, upcomingBus: upcomingBus, mapCameraPosition: mapCameraPosition)
                } label: {
                    Label {
                        Text(upcomingBus.destinationdisplay)
                    } icon: {
                        Image(systemName: "location.circle.fill")
                            .foregroundStyle(.orange)
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
    let upcomingBus = DetailedSiriStop.Result()
    
    NavigationStack {
        UpcomingBusView(foliData: FoliDataClass(), upcomingBus: upcomingBus)
    }
    .padding(10)
}
