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
    @Query var vehicleStops: [StopData]
    @Query var tripShape: [ShapeData]
    @Query var allTrips: [TripData]
    
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
                HStack {
                    Spacer()
                    
                    Button {
                        mapCameraPosition = .region(vehicle.region)
                    } label: {
                        Label {
                            Text("Find Bus")
                        } icon: {
                            Image(systemName: "location.circle")
                        }
                    }
                    
                    Button {
                        showTimetable.toggle()
                    } label: {
                        Label {
                            Text("Timetable")
                        } icon: {
                            Image(systemName: "calendar")
                        }
                    }
                    
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .padding(.vertical, 15)
                .background(.ultraThinMaterial)
            })
            .sheet(isPresented: $showTimetable, content: {
                if (!vehicle.onwardCalls.isEmpty) {
                    ScrollView {
                        VStack(spacing: 10) {
                            Label {
                                Text("Upcoming Stops")
                                    .font(.title)
                            } icon: {
                                Image(systemName: "parkingsign")
                            }
                            
                            ForEach(vehicle.onwardCalls, id: \.stoppointref) { call in
                                HStack(alignment: .center) {
                                    Text(call.stoppointref)
                                        .bold()
                                        .frame(width: 75)
                                    Text(call.stoppointname)
                                    
                                    Spacer()
                                                                   
                                    VStack {
                                        ArrivalTimeView(aimedArrival: call.aimedarrivaltime, expectedArrival: call.expectedarrivaltime)
                                        DepartureTimeView(aimedDeparture: call.aimeddeparturetime, expectedDeparture: call.expecteddeparturetime)
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                    .presentationDetents([.medium])
                    .presentationBackground(.regularMaterial)
                }
            })
        }
    }
}

#Preview(traits: .sampleData) {
    let foliData = FoliDataClass()
    LiveBusMapView(foliData: FoliDataClass(), selectedStopCode: "1", trip: nil, mapCameraPosition: .region(foliData.fallbackLocation), vehicle: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
}
