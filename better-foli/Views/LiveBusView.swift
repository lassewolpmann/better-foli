//
//  LiveBusView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct LiveBusView: View {
    @Environment(\.modelContext) private var context
    @Query var allTrips: [TripData]
    @Query var routes: [RouteData]
    
    @State private var vehicle: VehicleData?
    
    let foliData: FoliDataClass
    let upcomingBus: DetailedSiriStop.Result
    let selectedStopCode: String
    
    var route: RouteData? { routes.first }
    
    var trip: TripData? {
        allTrips.first { $0.tripID == vehicle?.tripID }
    }
    
    init(foliData: FoliDataClass, upcomingBus: DetailedSiriStop.Result, selectedStopCode: String) {
        self.foliData = foliData
        self.upcomingBus = upcomingBus
        self.selectedStopCode = selectedStopCode
        
        let busRouteRef = upcomingBus.__routeref ?? ""
        let predicate = #Predicate<RouteData> { route in
            route.routeID == busRouteRef
        }
        _routes = Query(filter: predicate)
    }
    
    var body: some View {
        if let vehicle, let route {
            let mapCameraPosition: MapCameraPosition = .region(.init(center: vehicle.coords, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
            
            NavigationStack {
                LiveBusMapView(foliData: foliData, selectedStopCode: selectedStopCode, trip: trip, mapCameraPosition: mapCameraPosition, vehicle: vehicle)
                    .navigationBarTitle("\(route.shortName) - \(route.longName)")
                    .toolbar {
                        Button {
                            route.isFavourite.toggle()
                            
                            do {
                                try context.save()
                            } catch {
                                print(error)
                            }
                        } label: {
                            Image(systemName: route.isFavourite ? "star.fill" : "star")
                        }
                    }
            }
        } else {
            ProgressView("Getting vehicle data...")
                .task {
                    print("Getting vehicle data...")
                    do {
                        let allVehicles = try await foliData.getAllVehicles()
                        vehicle = allVehicles.first { $0.vehicleID == upcomingBus.vehicleref }
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

#Preview(traits: .sampleData) {
    LiveBusView(foliData: FoliDataClass(), upcomingBus: DetailedSiriStop.Result(recordedattime: 0, monitored: true, lineref: "1", destinationdisplay: "Satama"), selectedStopCode: "1")
}
