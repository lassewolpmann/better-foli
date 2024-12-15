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
    @Environment(\.modelContext) private var context
    @Query var routes: [RouteData]
    var route: RouteData? { routes.first }
    
    @State var busesOnThisRoute: [VehicleData] = []
    
    let foliData: FoliDataClass
    let routeID: String
    
    init(foliData: FoliDataClass, routeID: String) {
        self.foliData = foliData
        self.routeID = routeID
        
        _routes = Query(filter: #Predicate<RouteData> { $0.routeID == routeID })
    }

    var body: some View {
        if (busesOnThisRoute.isEmpty) {
            ProgressView("Loading buses on this route...")
                .task {
                    do {
                        let vehicles = try await foliData.getAllVehicles()
                        busesOnThisRoute = vehicles.filter { $0.routeID == routeID }
                    } catch {
                        print(error)
                    }
                }
        } else {
            NavigationStack {
                List {
                    Section {
                        ForEach(busesOnThisRoute, id: \.vehicleID) { vehicle in
                            RouteOverviewBusRow(foliData: foliData, vehicle: vehicle)
                        }
                    } header: {
                        Text("Buses on this Line")
                    }
                }
                .toolbar {
                    if let route {
                        Button {
                            route.isFavourite.toggle()
                            
                            do {
                                try context.save()
                            } catch {
                                print(error)
                            }
                        } label: {
                            Image(systemName: route.isFavourite ? "star.fill": "star")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RouteOverviewView(foliData: FoliDataClass(), routeID: "1")
}
