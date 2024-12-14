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
    let trip: TripData

    @State var mapCameraPosition: MapCameraPosition
    @State var vehicle: VehicleData
    @State private var showTimetable: Bool = false
    
    @Environment(\.modelContext) private var context
    @Query var allStops: [StopData]
    @Query var allShapes: [ShapeData]
    
    init(foliData: FoliDataClass, trip: TripData, mapCameraPosition: MapCameraPosition, vehicle: VehicleData) {
        self.foliData = foliData
        self.trip = trip
        self.mapCameraPosition = mapCameraPosition
        self.vehicle = vehicle
        
        let shapeID = trip.shapeID
        let allStopPointRefs = vehicle.onwardCalls.map { $0.stoppointref }
        
        _allStops = Query(filter: #Predicate<StopData> { allStopPointRefs.contains($0.code) })
        _allShapes = Query(filter: #Predicate<ShapeData> { $0.shapeID == shapeID })
    }
    
    var body: some View {
        if (allShapes.isEmpty) {
            ProgressView("Loading trip...")
                .task {
                    do {
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
                
                if let shapeCoords = allShapes.first?.locations.map({ $0.coords }) {
                    MapPolyline(coordinates: shapeCoords, contourStyle: .straight)
                        .stroke(.orange.opacity(0.8), lineWidth: 3)
                }
                
                
                ForEach(vehicle.onwardCalls, id: \.stoppointref) { call in
                    let stop = allStops.first { $0.code == call.stoppointref }
                    
                    if let stop {
                        Marker(stop.name, systemImage: stop.isFavourite ? "star.fill" : "parkingsign", coordinate: stop.coords)
                            .tint(.orange)
                    }
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
                .padding(.top, 15)
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

#Preview {
    let foliData = FoliDataClass()
    LiveBusMapView(foliData: FoliDataClass(), trip: TripData(trip: GtfsTrip()), mapCameraPosition: .region(foliData.fallbackLocation), vehicle: VehicleData(vehicleKey: "", vehicleData: SiriVehicleMonitoring.Result.Vehicle()))
}
