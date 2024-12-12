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
    let foliData: FoliDataClass
    let upcomingBus: DetailedSiriStop.Result
    let trip: TripData
    
    @State var mapCameraPosition: MapCameraPosition
    @State private var vehicle: VehicleData?
        
    @Environment(\.modelContext) private var context
    @Query var allShapes: [ShapeData]
    
    init(foliData: FoliDataClass, upcomingBus: DetailedSiriStop.Result, trip: TripData, mapCameraPosition: MapCameraPosition) {
        let shapeID = trip.shapeID
        
        let predicate = #Predicate<ShapeData> {
            $0.shapeID == shapeID
        }
        
        self.foliData = foliData
        self.upcomingBus = upcomingBus
        self.trip = trip
        self.mapCameraPosition = mapCameraPosition
        
        _allShapes = Query(filter: predicate)
    }
    
    var body: some View {
        if let shape = allShapes.first {
            let shapeCoords: [CLLocationCoordinate2D] = shape.locations.map { $0.coords }

            if let vehicle {
                LiveBusMapView(foliData: foliData, mapCameraPosition: $mapCameraPosition, vehicle: vehicle, shapeCoords: shapeCoords)
            } else {
                ProgressView("Getting bus position...")
                    .task {
                        print("Loading vehicle...")
                        do {
                            let allVehicles = try await foliData.getAllVehicles()
                            vehicle = allVehicles.first(where: { $0.vehicleID == upcomingBus.vehicleref })

                        } catch {
                            print(error)
                        }
                    }
            }
            

        } else {
            ProgressView("Loading route...")
                .task {
                    do {
                        print("Getting shape coords...")
                        guard let shapeCoords = try await foliData.getShape(shapeID: trip.shapeID) else { return }
                        context.insert(shapeCoords)
                        try context.save()
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

#Preview {
    let upcomingBus = DetailedSiriStop.Result()
    
    let center = CLLocationCoordinate2D(latitude: upcomingBus.latitude ?? 0.0, longitude: upcomingBus.longitude ?? 0.0)
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    let mapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: center, span: span))
    
    LiveBusView(foliData: FoliDataClass(), upcomingBus: upcomingBus, trip: TripData(trip: GtfsTrip()), mapCameraPosition: mapCameraPosition)
}
