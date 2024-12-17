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
    @Query var busRoutes: [RouteData]
    @Query var busTrips: [TripData]
    
    var busRoute: RouteData? { busRoutes.first }
    var busTrip: TripData? { busTrips.first }
    
    let foliData: FoliDataClass
    let upcomingBus: VehicleData
    let selectedStopCode: String
    
    init(foliData: FoliDataClass, upcomingBus: VehicleData, selectedStopCode: String) {
        self.foliData = foliData
        self.upcomingBus = upcomingBus
        self.selectedStopCode = selectedStopCode
        
        let busRouteID = upcomingBus.routeID
        let busTripID = upcomingBus.tripID
        
        _busRoutes = Query(filter: #Predicate<RouteData> { $0.routeID == busRouteID })
        _busTrips = Query(filter: #Predicate<TripData> { $0.tripID == busTripID })
    }
    
    var body: some View {
        if let stop = upcomingBus.onwardCalls.first(where: { $0.stoppointref == selectedStopCode }), let busRoute, let busTrip {
            NavigationLink {
                LiveBusView(foliData: foliData, upcomingBus: upcomingBus, selectedStopCode: selectedStopCode, route: busRoute, trip: busTrip)
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Text(upcomingBus.lineReference)
                        .bold()
                        .frame(width: 50)
                    
                    Text(upcomingBus.destinationName)
                    
                    Spacer()
                    
                    VStack {
                        let aimedArrival = stop.aimedarrivaltime
                        let expectedArrival = stop.expectedarrivaltime
                        BusTimeView(aimedTime: aimedArrival, expectedTime: expectedArrival, image: "arrow.right")
                        
                        let aimedDeparture = stop.aimeddeparturetime
                        let expectedDeparture = stop.expecteddeparturetime
                        BusTimeView(aimedTime: aimedDeparture, expectedTime: expectedDeparture, image: "arrow.left")
                    }
                }
            }
            .disabled(!upcomingBus.monitored)
        }
    }
}

#Preview {
    NavigationStack {
        UpcomingBusView(foliData: FoliDataClass(), upcomingBus: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()), selectedStopCode: "1")
    }
    .padding(10)
}
