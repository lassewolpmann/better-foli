//
//  LiveBusMapView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 12.12.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct LiveBusMapView: View {
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    let foliData: FoliDataClass
    let selectedStopCode: String
    let trip: TripData?

    @State var mapCameraPosition: MapCameraPosition
    @State var vehicle: VehicleData
    @State private var showTimetable: Bool = false
    
    @Environment(\.modelContext) private var context
    @Query var tripShape: [ShapeData]
    @Query var vehicleStops: [StopData]

    var shapeCoords: [CLLocationCoordinate2D]? {
        tripShape.first?.locations.map { $0.coords }
    }
    
    init(foliData: FoliDataClass, selectedStopCode: String, trip: TripData?, mapCameraPosition: MapCameraPosition, vehicle: VehicleData) {
        self.foliData = foliData
        self.selectedStopCode = selectedStopCode
        self.trip = trip
        self.mapCameraPosition = mapCameraPosition
        self.vehicle = vehicle
                
        let shapeID = trip?.shapeID ?? ""
        _tripShape = Query(filter: #Predicate<ShapeData> { $0.shapeID == shapeID })
        
        let onwardCallStopCodes = vehicle.onwardCalls.map { $0.stoppointref }
        
        let predicate = #Predicate<StopData> { stop in
            return onwardCallStopCodes.contains(stop.code)
        }
        
        _vehicleStops = Query(filter: predicate)
    }
    
    var body: some View {
        if (tripShape.isEmpty) {
            ProgressView("Loading trip...")
                .task {
                    do {
                        guard let trip else { return }
                        guard let shape = try await foliData.getShape(shapeID: trip.shapeID) else { return }
                        context.insert(shape)
                        try context.save()
                    } catch {
                        print(error)
                    }
                }
        } else {
            Map(position: $mapCameraPosition) {
                // Always show user location
                UserAnnotation()
                
                if let shapeCoords {
                    MapPolyline(coordinates: shapeCoords, contourStyle: .straight)
                        .stroke(.orange.opacity(0.8), lineWidth: 3)
                }
                
                
                ForEach(vehicleStops, id: \.code) { stop in
                    Marker(stop.name, systemImage: stop.isFavourite ? "star.fill" : "parkingsign", coordinate: stop.coords)
                        .tint(stop.code == selectedStopCode ? .green : .orange)
                }
                
                Marker(vehicle.lineReference, systemImage: "bus", coordinate: vehicle.coords)
            }
            .onReceive(timer) { _ in
                print("Updating vehicle...")
                Task {
                    do {
                        let allVehicles = try await foliData.getAllVehicles()
                        guard let newVehicle = allVehicles.first(where: { $0.vehicleID == vehicle.vehicleID }) else { return }
                        vehicle = newVehicle
                    } catch {
                        print(error)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                LiveBusMapButtonsView(mapCameraPosition: $mapCameraPosition, showTimetable: $showTimetable, vehicle: vehicle)
            })
            .sheet(isPresented: $showTimetable, content: {
                LiveBusMapTimetableView(vehicle: vehicle)
            })
        }
    }
}

#Preview(traits: .sampleData) {
    let foliData = FoliDataClass()
    LiveBusMapView(foliData: FoliDataClass(), selectedStopCode: "1", trip: nil, mapCameraPosition: .region(foliData.fallbackLocation), vehicle: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
}
