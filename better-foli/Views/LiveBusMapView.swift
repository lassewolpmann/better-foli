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
    let trip: TripData
    let vehicleStops: [StopData]
    let shape: ShapeData?
    
    var shapeCoords: [CLLocationCoordinate2D]? {
        shape?.locations.map { $0.coords }
    }
    
    @State var mapCameraPosition: MapCameraPosition
    @State var vehicle: VehicleData
    @State private var showTimetable: Bool = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        if let shapeCoords {
            Map(position: $mapCameraPosition) {
                // Always show user location
                UserAnnotation()
                
                MapPolyline(coordinates: shapeCoords, contourStyle: .straight)
                    .stroke(.orange.opacity(0.8), lineWidth: 3)
                
                
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
        } else {
            ProgressView("Loading trip...")
                .task {
                    do {
                        guard let shape = try await foliData.getShape(shapeID: trip.shapeID) else { return }
                        context.insert(shape)
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

#Preview(traits: .sampleData) {
    let foliData = FoliDataClass()
    LiveBusMapView(foliData: FoliDataClass(), selectedStopCode: "1", trip: TripData(trip: GtfsTrip()), vehicleStops: [StopData(gtfsStop: GtfsStop())], shape: ShapeData(shapeID: "434", shapes: [GtfsShape()]), mapCameraPosition: .region(foliData.fallbackLocation), vehicle: VehicleData(vehicleKey: "80051", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
}
