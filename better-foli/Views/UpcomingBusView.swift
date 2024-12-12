//
//  UpcomingBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct UpcomingBusView: View {
    @Environment(\.dismiss) private var dismiss
    
    let foliData: FoliDataClass
    let upcomingBus: DetailedSiriStop.Result
    
    @Query var allTrips: [TripData]
    
    init(foliData: FoliDataClass, upcomingBus: DetailedSiriStop.Result) {
        let tripID = upcomingBus.__tripref

        let predicate = #Predicate<TripData> {
            $0.tripID == tripID
        }

        self.foliData = foliData
        self.upcomingBus = upcomingBus
        _allTrips = Query(filter: predicate)
    }
    
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
                    
                    if let trip = allTrips.first {
                        LiveBusView(foliData: foliData, upcomingBus: upcomingBus, trip: trip, busCoords: center, mapCameraPosition: mapCameraPosition)
                    }
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
                    ArrivalTimeView(aimedArrival: aimedArrival, expectedArrival: expectedArrival)
                }
                
                if let aimedDeparture = upcomingBus.aimeddeparturetime, let expectedDeparture = upcomingBus.expecteddeparturetime {
                    DepartureTimeView(aimedDeparture: aimedDeparture, expectedDeparture: expectedDeparture)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UpcomingBusView(foliData: FoliDataClass(), upcomingBus: DetailedSiriStop.Result())
    }
    .padding(10)
}
