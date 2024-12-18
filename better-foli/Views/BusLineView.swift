//
//  RouteOverviewView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 15.12.2024.
//

import SwiftUI
import SwiftData
import MapKit

struct BusLineView: View {
    @Query var tripsOnRoute: [TripData]
    @State private var busesOnThisRoute: [VehicleData]?
    
    let foliData: FoliDataClass
    let locationManager: LocationManagerClass
    let route: RouteData
    
    init(foliData: FoliDataClass, locationManager: LocationManagerClass, route: RouteData) {
        self.foliData = foliData
        self.locationManager = locationManager
        self.route = route
        
        let routeID = route.routeID
        
        let predicate = #Predicate<TripData> { $0.routeID == routeID }
        _tripsOnRoute = Query(filter: predicate)
    }
    
    var body: some View {
        if let busesOnThisRoute {
            List {
                Section {
                    ForEach(busesOnThisRoute.sorted {
                        if (!locationManager.isAuthorized) { return true }
                        guard let userLocation = locationManager.manager.location else { return true }
                        
                        let distanceA = userLocation.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))
                        let distanceB = userLocation.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude))
                        
                        return distanceA < distanceB
                    }, id: \.vehicleID) { vehicle in
                        if let trip = tripsOnRoute.first(where: { $0.tripID == vehicle.tripID }) {
                            BusOnLineView(foliData: foliData, trip: trip, route: route, vehicle: vehicle)
                        }
                    }
                } header: {
                    Text("Active Buses on this Line")
                } footer: {
                    Text("Buses are sorted by distance to your current location.")
                }
            }
            .toolbar {
                Button {
                    route.isFavourite.toggle()
                } label: {
                    Image(systemName: route.isFavourite ? "star.fill": "star")
                }
                .sensoryFeedback(.success, trigger: route.isFavourite)
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
    BusLineView(foliData: FoliDataClass(), locationManager: LocationManagerClass(), route: RouteData(route: GtfsRoute()))
}
