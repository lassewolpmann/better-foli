//
//  RouteOverviewView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 15.12.2024.
//

import SwiftUI
import SwiftData
import MapKit

struct RouteOverviewView: View {
    @Query var tripsOnRoute: [TripData]
    @State private var busesOnThisRoute: [VehicleData]?
    
    let foliData: FoliDataClass
    let route: RouteData
    
    init(foliData: FoliDataClass, route: RouteData) {
        self.foliData = foliData
        self.route = route
        
        let routeID = route.routeID
        
        let predicate = #Predicate<TripData> { $0.routeID == routeID }
        _tripsOnRoute = Query(filter: predicate)
    }
    
    var body: some View {
        if let busesOnThisRoute {
            List {
                Section {
                    ForEach(busesOnThisRoute, id: \.vehicleID) { vehicle in
                        if let trip = tripsOnRoute.first(where: { $0.tripID == vehicle.tripID }) {
                            RouteOverviewBusRow(foliData: foliData, trip: trip, route: route, vehicle: vehicle)
                        }
                    }
                } header: {
                    Text("Active Buses on this Line")
                }
            }
            .toolbar {
                Button {
                    route.isFavourite.toggle()
                } label: {
                    Image(systemName: route.isFavourite ? "star.fill": "star")
                }
            }
        } else {
            ProgressView("Loading buses on this route...")
                .task {
                    let tripIDs = tripsOnRoute.map { $0.tripID }
                    do {
                        let vehicles = try await foliData.getAllVehicles()
                        busesOnThisRoute = vehicles.filter { tripIDs.contains($0.tripID) && $0.monitored }
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

#Preview(traits: .sampleData) {
    RouteOverviewView(foliData: FoliDataClass(), route: RouteData(route: GtfsRoute()))
}
