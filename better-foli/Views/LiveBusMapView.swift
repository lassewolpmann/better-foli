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
    let foliData: FoliDataClass
    let selectedStopCode: String
    let trip: TripData
    let vehicle: VehicleData
    let vehicleStops: [StopData]
    let shape: ShapeData?
    
    var shapeCoords: [CLLocationCoordinate2D]? {
        shape?.locations.map { $0.coords }
    }
    
    @State var mapCameraPosition: MapCameraPosition
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
                    Annotation(coordinate: stop.coords) {
                        Circle()
                            .fill(stop.code == selectedStopCode ? .white : .orange)
                            .stroke(.orange, lineWidth: 1)
                            .shadow(radius: 2)
                    } label: {
                        Text(stop.name)
                    }
                }
                
                Annotation(coordinate: vehicle.coords) {
                    Image(systemName: "bus")
                        .foregroundStyle(.orange)
                        .padding(5)
                        .background (
                            Circle()
                                .fill(.white)
                                .stroke(.orange, lineWidth: 1)
                                .shadow(radius: 2)
                        )
                } label: {
                    Text(vehicle.lineReference)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: true))
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
    let sampleVehicle = VehicleData(vehicleKey: "80051", vehicleData: SiriVehicleMonitoring.Result.Vehicle())
    let sampleStop = StopData(gtfsStop: GtfsStop())
    
    LiveBusMapView(foliData: FoliDataClass(), selectedStopCode: "1", trip: TripData(trip: GtfsTrip()), vehicle: sampleVehicle, vehicleStops: [sampleStop], shape: ShapeData(shapeID: "434", shapes: [GtfsShape()]), mapCameraPosition: .camera(.init(centerCoordinate: sampleVehicle.coords, distance: 2000)))
}
